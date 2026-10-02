# ARM64 Java Images

Eclipse Temurin Java images for [Pterodactyl](https://pterodactyl.io) and [Pelican](https://pelican.dev) panels. Every image is multi-arch (`linux/arm64` + `linux/amd64`), so the same egg works on ARM nodes (Oracle Ampere, Raspberry Pi 4/5, AWS Graviton, Hetzner CAX) and on x86 nodes.

| Image | Java | Typical use |
| --- | --- | --- |
| `ghcr.io/thatstupidfish/java8` | 8 | Minecraft 1.16.5 and older, legacy Forge |
| `ghcr.io/thatstupidfish/java11` | 11 | Older plugins/apps that need 11 |
| `ghcr.io/thatstupidfish/java17` | 17 | Minecraft 1.17 – 1.20.4 |
| `ghcr.io/thatstupidfish/java21` | 21 | Minecraft 1.20.5 – 1.21.x |
| `ghcr.io/thatstupidfish/java25` | 25 | Minecraft 26.1+ (current Paper/Purpur) |

Images are rebuilt weekly to pick up Temurin and Ubuntu security updates. Each push to `main` also publishes a `sha-<commit>` tag if you want to pin a build.

## Using the images in an egg

### Pterodactyl

1. **Admin → Nests → (your nest) → (your egg)**.
2. In **Docker Images**, add one line per image in `Display Name|image` form, e.g.

   ```
   Java 25|ghcr.io/thatstupidfish/java25
   Java 21|ghcr.io/thatstupidfish/java21
   Java 17|ghcr.io/thatstupidfish/java17
   Java 8|ghcr.io/thatstupidfish/java8
   ```

3. Save, then pick the image per server under **Server → Startup → Docker Image**.

### Pelican

1. **Admin → Eggs → (your egg)**.
2. Under **Docker Images**, add entries with the display name as the key and the image as the value, e.g. `Java 25` → `ghcr.io/thatstupidfish/java25`.
3. Select the image per server on the server's **Startup** page.

## What the image provides

- Runs as the `container` user with `/home/container` as the working directory, and works with whatever UID Wings assigns.
- `{{VARIABLE}}` placeholders in the startup command are replaced with the server's environment variables, and shell operators (`&&`, `|`, `;`) are supported.
- `tini` runs as PID 1 with `STOPSIGNAL SIGINT`, so panel stop and kill signals reach the Java process and the server shuts down cleanly.
- `TZ` defaults to `UTC`, and `INTERNAL_IP` is set to the container's Docker IP.
- Includes common tools used by egg install and startup scripts: `curl`, `git`, `jq`, `zip`/`unzip`, `tar`, `sqlite3`, `lsof`, `iproute2`, `fontconfig`.

## Building locally

All versions share one `Dockerfile`. `JAVA_VERSION` selects the Temurin release:

```bash
docker buildx build --platform linux/arm64 --build-arg JAVA_VERSION=21 --load -t java21-test .
./scripts/smoke-test.sh java21-test 21 linux/arm64
```

The smoke test runs the image the way Wings does: a non-root UID, a bind-mounted `/home/container`, and a templated `STARTUP` command. It checks the Java version, the CPU architecture, variable substitution and write access. CI (`.github/workflows/build.yml`) runs this test on arm64 before it publishes each image to GHCR.
