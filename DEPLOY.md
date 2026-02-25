# CI/CD Setup for AIX Deployment

## GitHub Secrets Required

Set these in `Settings > Secrets and variables > Actions`:

| Secret | Value |
|--------|-------|
| `AIX_HOST` | Public/reachable IP of AIX VM (e.g., `10.0.2.200`) |
| `AIX_PASSWORD` | root password for AIX |

## How It Works

1. **Push to `master`** → triggers build
2. **Maven** builds the WAR (`daytrader-ee7-web/target/*.war`)
3. **SCP** copies WAR to Liberty `dropins/` on AIX
4. **SSH** restarts Liberty server
5. **Health check** verifies DayTrader is responding

## Manual Deploy

```bash
# Build locally
mvn clean package -pl daytrader-ee7-web -am -DskipTests

# Copy to AIX
scp daytrader-ee7-web/target/daytrader-ee7.war root@AIX_IP:/opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/dropins/

# Restart Liberty on AIX
ssh root@AIX_IP "/opt/IBM/WebSphere/Liberty/bin/server stop defaultServer; /opt/IBM/WebSphere/Liberty/bin/server start defaultServer"
```

## Prerequisites on AIX

- WebSphere Liberty installed at `/opt/IBM/WebSphere/Liberty`
- Java 11+ installed
- SSH access enabled
- Network connectivity from GitHub Actions (or self-hosted runner)

## Note

Since AIX is on a private network, GitHub-hosted runners can't reach it directly.
Options:
1. **Self-hosted runner** on the homelab network
2. **Tailscale/WireGuard** tunnel from GitHub Actions
3. **Manual trigger** from a machine with network access
