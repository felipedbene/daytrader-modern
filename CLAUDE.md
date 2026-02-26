# DayTrader Modern — Project Guide

## Overview
DayTrader 8 (Java EE 8 stock trading benchmark) running on **IBM AIX 7.2 / POWER8 KVM** with a modernized fintech UI. This is a real deployment on vintage enterprise hardware — not a toy.

## Architecture

```
Browser → Cloudflare Tunnel (aix-daytrader)
       → Caddy (aix.k8s.debene.name, TLS)
       → WebSphere Liberty 24.0.0.12 (AIX 7.2, port 9080)
       → PostgreSQL (K8s CNPG, 10.0.100.104:5432)
```

### Runtime
- **OS:** IBM AIX 7.2 TL4 SP2 on QEMU/KVM (POWER8 bare metal host)
- **App Server:** WebSphere Liberty 24.0.0.12 (Java EE 8)
- **Java:** IBM Java 8 (1.8.0_241) ppc64
- **DB (production):** PostgreSQL via CNPG on Kubernetes
- **DB (dev):** Apache Derby 10.14.2 embedded
- **Monitoring:** node_exporter_aix v1.14.3, Grafana dashboard `aix-power8-vm`

### Networking
- **AIX VM IP:** 10.0.1.132 (DHCP, VLAN 1)
- **Internal TLS:** Caddy reverse proxy at `aix.k8s.debene.name` → `10.0.1.132:9080`
- **Public access:** Cloudflare tunnel `aix-daytrader` on `debene.dev` domain
- **Liberty binds:** `host="*"` on port 9080 (HTTP) and 9443 (HTTPS)

## CI/CD Pipeline

```
git push master → GitHub Actions (self-hosted runner)
  → mvn clean package
  → Upload WAR + server.xml + PG driver to MinIO (minio-api.k8s.debene.name)
  → SSH to AIX → download artifacts → restart Liberty
```

- **Runner:** self-hosted, label `homelab`
- **Artifacts:** MinIO bucket `daytrader-artifacts`
- **Secrets required:** `HOMELAB_CA_CERT`, `AIX_SSH_KEY`, `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`

## What to Change (UI Modernization)

- All JSP files in `daytrader-ee7-web/src/main/webapp/`
- All XHTML (JSF) files in the same directory
- All static HTML files (index.html, header.html, footer.html, contentHome.html, etc.)
- CSS files — create new modern stylesheets
- Remove FRAMESET-based layout, replace with modern responsive layout
- The `images/` directory — update or replace dated GIF/JPEG assets if needed

## What NOT to Change

- Java source code (all .java files)
- Server configuration (server.xml, web.xml, persistence.xml)
- Maven build files (pom.xml) — do not change dependencies
- EJB/JPA/JAX-RS backend logic
- Database schemas
- CI/CD workflow (`.github/workflows/deploy.yml`)

## Design Direction
- Clean, modern fintech look (think Robinhood, E*Trade modern UI)
- Dark mode with accent colors (green for gains, red for losses)
- Responsive design (works on mobile)
- Use only vanilla CSS (no npm/node build — this deploys on AIX/WebSphere Liberty)
- Keep all form actions, servlet mappings, and JSP/JSF EL expressions intact
- Preserve all existing functionality — just make it look modern

## JSP/XHTML Notes
- The app uses both JSP (Servlet-based) and XHTML (JSF-based) pages
- Some pages have both versions (e.g., portfolio.jsp and portfolio.xhtml)
- The `*Img.jsp` files are the JSP versions, plain `*.jsp` are non-image versions
- Forms POST to servlets — keep all action URLs the same

## Security Rules

**⚠️ CRITICAL: NO hardcoded passwords or secrets in any file.**

- Database credentials: use `${env.DB_PASSWORD}`, `${env.DB_USER}`, etc.
- All secrets come from environment variables set in `server.env` on AIX
- Default values in server.xml are OK for non-sensitive config (ports, hostnames)
- **NEVER** put passwords as default values: ~~`${env.DB_PASSWORD:mypassword}`~~ ❌
- Correct: `${env.DB_PASSWORD}` ✅
- If you need example values in docs, write `(set via DB_PASSWORD env var)`

## Database Configuration

### PostgreSQL (Production — Active)
```xml
<properties.postgresql
    serverName="${env.DB_HOST}"
    portNumber="${env.DB_PORT}"
    databaseName="${env.DB_NAME}"
    user="${env.DB_USER}"
    password="${env.DB_PASSWORD}"
    currentSchema="public"/>
```

Environment variables on AIX (`server.env`):
```
DB_HOST=10.0.100.104
DB_PORT=5432
DB_NAME=tradedb
DB_USER=daytrader
DB_PASSWORD=(set via env)
```

### Derby (Development — Commented Out)
Embedded Derby for local dev only. Uncomment the Derby block and comment PostgreSQL in `server.xml`.

## Useful Commands

```bash
# SSH to AIX
ssh root@10.0.1.132

# Liberty control
/opt/IBM/WebSphere/Liberty/bin/server start defaultServer
/opt/IBM/WebSphere/Liberty/bin/server stop defaultServer

# Check logs
tail -f /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/logs/messages.log

# Test locally
curl http://10.0.1.132:9080/daytrader/

# Test via Caddy (TLS)
curl -k https://aix.k8s.debene.name/daytrader/
```

## File Structure
```
daytrader-ee7/                    # Main EE7 module
  src/main/liberty/config/
    server.xml                    # Liberty config (DB, JMS, features)
  src/main/webapp/                # JSP/XHTML/CSS/JS
daytrader-ee7-web/                # Web module
  src/main/webapp/                # More JSP/XHTML
.github/workflows/deploy.yml     # CI/CD pipeline
AIX_DEPLOY.md                    # Manual AIX deployment guide
API.md                           # REST API documentation
QUICKREF.md                      # Quick reference
```
