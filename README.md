# DayTrader Modern — Stock Trading Benchmark on IBM POWER8

[![Build & Deploy](https://github.com/felipedbene/daytrader-modern/actions/workflows/deploy.yml/badge.svg)](https://github.com/felipedbene/daytrader-modern/actions/workflows/deploy.yml)

A modernized fork of IBM's [DayTrader 7](https://github.com/WASdev/sample.daytrader7) benchmark, running on **IBM POWER8 (ppc64le)** bare metal with Open Liberty + PostgreSQL.

**Live demo:** [aix.debene.dev/daytrader](https://aix.debene.dev/daytrader/) (behind Authentik SSO)

## Architecture

```
Internet → Cloudflare Tunnel → Authentik Proxy (K8s) → IBM POWER8 S822 (Gentoo)
                                                         ├── Open Liberty 26.0.0.2
                                                         │   └── DayTrader EE7 EAR
                                                         └── PostgreSQL 16 (baremetal)
                                                              └── tradedb (15K users, 10K quotes)
```

| Component | Details |
|-----------|---------|
| **Hardware** | IBM S822 — Dual POWER8, 20 cores / 160 threads (SMT8), 128GB RAM |
| **OS** | Gentoo Linux ppc64le, kernel 6.17.x |
| **Runtime** | Open Liberty 26.0.0.2 / Eclipse OpenJ9 JDK 17 |
| **Database** | PostgreSQL 16.12 (baremetal on same host) |
| **Auth** | Authentik Proxy Outpost (external, K8s) |
| **CI/CD** | GitHub Actions → self-hosted runner → SCP + Docker Compose |
| **Container** | `ghcr.io/felipedbene/daytrader-modern:latest` (ppc64le) |

## What is DayTrader?

An online stock trading benchmark simulating real-world Java EE workloads: user registration, portfolio management, stock quotes, buy/sell orders, and market summary. Originally by IBM for WebSphere performance testing.

**Key features:**
- EJB 3.2 (Stateless, Singleton, MDB)
- JPA 2.2 with EclipseLink (PostgreSQL)
- JSF 2.3 + vanilla JS (HTMX polling for market data)
- REST API for market summary, quotes, portfolio, orders
- JMS messaging for async order processing
- 15,000 users / 10,000 stock quotes benchmark dataset

## Quick Start

### Local (Docker Compose)

```bash
git clone https://github.com/felipedbene/daytrader-modern.git
cd daytrader-modern

# Set database password
echo "DB_PASSWORD=your-password" > .env

# Build and run (requires ppc64le host or QEMU emulation)
docker compose up -d --build

# Seed the database
curl http://localhost:9080/daytrader/config?action=buildDBTables
curl http://localhost:9080/daytrader/config?action=buildDB
```

### On POWER8 (Production)

Pushes to `master` trigger automatic build + deploy via GitHub Actions:

1. Maven builds the EAR (JDK 11)
2. Docker builds the Liberty image (ppc64le)
3. SCP deploys to P8
4. `docker compose up -d` starts the service
5. Post-deploy: seeds database + restarts for MarketSummary initialization

## REST API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/daytrader/api/market` | GET | Market summary (TSIA, top gainers/losers) |
| `/daytrader/api/quotes?symbols=s:0,s:1` | GET | Stock quotes |
| `/daytrader/api/portfolio` | GET | Current user's holdings |
| `/daytrader/api/orders` | GET | Order history |

## Load Testing

```bash
# 15K users × 5 trades each, 20 concurrent
# Achieved ~157 trades/sec on POWER8
bash load-test.sh
```

## Project Structure

```
├── .github/workflows/deploy.yml    # CI/CD pipeline
├── daytrader-ee7/                  # EAR module (Liberty config + packaging)
├── daytrader-ee7-ejb/              # Business logic (EJBs, JPA entities, REST)
├── daytrader-ee7-web/              # Web layer (JSF, servlets, JS)
├── Dockerfile                      # Liberty ppc64le image
├── docker-compose.yml              # Production deployment
└── pom.xml                         # Parent Maven POM
```

## Why POWER8?

Because running enterprise Java on a 20-core / 160-thread IBM POWER8 in a homelab is more fun than yet another x86 deployment. This project proves that modern Java EE workloads run perfectly on ppc64le with Open Liberty and OpenJ9.

## Credits

- Original DayTrader by IBM — [WASdev/sample.daytrader7](https://github.com/WASdev/sample.daytrader7)
- Open Liberty — [openliberty.io](https://openliberty.io)
- Infrastructure managed by [Garra De Baitola](https://github.com/openclaw/openclaw) 🦞

## License

Apache License 2.0 — see [LICENSE](LICENSE)
