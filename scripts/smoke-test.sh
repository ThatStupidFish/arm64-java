#!/usr/bin/env bash
# Runs an image the way Wings (Pterodactyl/Pelican) does: arbitrary non-root UID,
# a bind-mounted /home/container and a STARTUP command with {{VARIABLE}} placeholders.
set -euo pipefail

image=${1:?usage: smoke-test.sh <image> <java-version> [platform]}
java_version=${2:?usage: smoke-test.sh <image> <java-version> [platform]}
platform=${3:-linux/arm64}

expected_version=$java_version
[ "$java_version" = "8" ] && expected_version="1.8"

data_dir=$(mktemp -d)
trap 'rm -rf "$data_dir"' EXIT
chmod 0777 "$data_dir"

output=$(docker run --rm --platform "$platform" \
    --user 988:988 \
    -v "$data_dir:/home/container" \
    -e SERVER_MEMORY=256 \
    -e SERVER_PORT=25565 \
    -e STARTUP='java -Xms128M -Xmx{{SERVER_MEMORY}}M -XshowSettings:properties -version 2>&1 | grep -E "os.arch|java.version =" && echo "port={{SERVER_PORT}} ip=${INTERNAL_IP} tz=${TZ}" && touch written-by-server' \
    "$image" 2>&1)
echo "$output"

fail() { echo "FAIL: $*" >&2; exit 1; }

case "$platform" in
    linux/arm64*) arch_pattern='os.arch = aarch64' ;;
    linux/amd64) arch_pattern='os.arch = amd64' ;;
    *) arch_pattern='os.arch' ;;
esac

grep -q "version \"${expected_version}" <<<"$output" || fail "expected Java ${expected_version}"
grep -q "$arch_pattern" <<<"$output" || fail "expected ${arch_pattern}"
grep -q "port=25565 ip=[0-9.]\+ tz=UTC" <<<"$output" || fail "startup variables were not substituted"
[ -f "$data_dir/written-by-server" ] || fail "server could not write to /home/container"

echo "PASS: ${image} (${platform})"
