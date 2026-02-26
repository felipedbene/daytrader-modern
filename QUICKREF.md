# DayTrader Quick Reference

## Production Environment (AIX)

**Application Server:**
- Host: 10.0.1.132 (AIX 7.2 on P8 POWER)
- Liberty: /opt/IBM/WebSphere/Liberty
- Java: /usr/java8_64
- HTTP Port: 9080 (configured in server.xml)
- HTTPS Port: 9443

**Database (PostgreSQL on K8s):**
- Host: 10.0.100.104 (MetalLB LoadBalancer)
- Port: 5432
- Database: tradedb
- User: daytrader
- Password: (set via DB_PASSWORD env var)

**URLs:**
- Web UI: http://10.0.1.132:9080/daytrader
- REST API: http://10.0.1.132:9080/daytrader/api/market

## Key Files on AIX

```
/opt/IBM/WebSphere/Liberty/
├── usr/servers/defaultServer/
│   ├── server.xml                    ← Auto-deployed by CI/CD
│   ├── apps/daytrader-ee7.ear       ← Auto-deployed by CI/CD
│   └── logs/
│       ├── messages.log             ← Main log file
│       └── console.log
└── usr/shared/resources/
    └── postgresql/
        └── postgresql-42.7.1.jar    ← Auto-deployed by CI/CD
```

## Liberty Commands (on AIX)

```bash
# Set Java
export JAVA_HOME=/usr/java8_64

# Start server
/opt/IBM/WebSphere/Liberty/bin/server start defaultServer

# Stop server
/opt/IBM/WebSphere/Liberty/bin/server stop defaultServer

# View logs
tail -f /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/logs/messages.log
```

## REST API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/market | Market summary (TSIA, volume, gainers/losers) |
| GET | /api/quotes | All stock quotes |
| GET | /api/quotes/{symbol} | Single stock quote |
| GET | /api/accounts/{userId} | Account information |
| POST | /api/accounts/login | Login user |
| GET | /api/portfolio/{userId} | User's holdings |
| GET | /api/orders/{userId} | User's orders |
| POST | /api/orders | Place buy/sell order |

## Quick Tests

```bash
# Health check
curl -I http://10.0.1.132:9080/daytrader/

# Market data
curl http://10.0.1.132:9080/daytrader/api/market | jq

# All quotes
curl http://10.0.1.132:9080/daytrader/api/quotes | jq

# Login
curl -X POST http://10.0.1.132:9080/daytrader/api/accounts/login \
  -H "Content-Type: application/json" \
  -d '{"userId":"uid:0","password":"xxx"}' | jq
```

## CI/CD

**Trigger:** Push to master branch or manual workflow dispatch

**What it does:**
1. Build EAR with Maven on homelab runner
2. Upload to MinIO (http://10.0.2.81:9000/daytrader-artifacts/)
3. Deploy to AIX:
   - PostgreSQL JDBC driver
   - server.xml
   - daytrader-ee7.ear
4. Restart Liberty
5. Health check
6. Build Docker image → ghcr.io/felipedbene/daytrader-modern:latest

## Database Schema Setup (First Time Only)

After first deployment, initialize the database:

**Web UI Method:**
1. Go to http://10.0.1.132:9080/daytrader
2. Click "Configuration"
3. Click "(Re)create DayTrader Database Tables and Indexes"
4. Click "(Re)populate DayTrader Database"

**REST API Method:**
```bash
curl -X POST http://10.0.1.132:9080/daytrader/config?action=buildDB
curl -X POST http://10.0.1.132:9080/daytrader/config?action=resetTrade
```

## Troubleshooting

**Check if Liberty is running:**
```bash
ps -ef | grep Liberty
```

**Check database connectivity from AIX:**
```bash
telnet 10.0.100.104 5432
```

**Check JDBC driver:**
```bash
ls -l /opt/IBM/WebSphere/Liberty/usr/shared/resources/postgresql/
```

**View recent errors:**
```bash
grep -i error /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/logs/messages.log | tail -20
grep -i exception /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/logs/messages.log | tail -20
```

**Check datasource:**
```bash
grep -i "postgresql" /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/logs/messages.log
```

## For Local Development

To switch back to Derby for local dev, edit server.xml:
- Comment out PostgreSQL datasource block
- Uncomment Derby datasource block
- Run: `mvn liberty:run`

## Reference Documents

- [API.md](API.md) - Full REST API documentation
- [AIX_DEPLOY.md](AIX_DEPLOY.md) - Complete AIX deployment guide
- [COMPLETION_SUMMARY.md](COMPLETION_SUMMARY.md) - Project modernization overview
