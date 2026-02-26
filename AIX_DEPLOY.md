# DayTrader AIX Deployment Guide

## Prerequisites on AIX

1. **IBM WebSphere Liberty** installed at `/opt/IBM/WebSphere/Liberty`
2. **Java 8 64-bit** at `/usr/java8_64`
3. **PostgreSQL JDBC driver** (version 42.7.1 or compatible)

## PostgreSQL Database Setup

The application connects to PostgreSQL running in your K8s cluster:

- **Host:** 10.0.100.104 (MetalLB LoadBalancer, reachable from AIX)
- **Port:** 5432
- **Database:** tradedb
- **Username:** daytrader
- **Password:** daytrader-p8-2026

These are the **default values** in server.xml. You can override them with environment variables if needed.

## Step 1: Install PostgreSQL JDBC Driver on AIX

Download and place the JDBC driver:

```bash
# On AIX
mkdir -p /opt/IBM/WebSphere/Liberty/usr/shared/resources/postgresql

# Download driver (from a machine with internet, then scp to AIX)
wget https://jdbc.postgresql.org/download/postgresql-42.7.1.jar

# Copy to AIX (from your workstation)
scp postgresql-42.7.1.jar root@10.0.1.132:/opt/IBM/WebSphere/Liberty/usr/shared/resources/postgresql/

# Verify on AIX
ls -l /opt/IBM/WebSphere/Liberty/usr/shared/resources/postgresql/
```

**Path must be:** `/opt/IBM/WebSphere/Liberty/usr/shared/resources/postgresql/postgresql-42.7.1.jar`

## Step 2: Verify Liberty Server Configuration

The server.xml is pre-configured for PostgreSQL with sensible defaults. Check the config:

```bash
cat /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/server.xml
```

Look for this section:
```xml
<dataSource connectionManagerRef="conMgr1" id="PostgresDataSource" 
            isolationLevel="TRANSACTION_READ_COMMITTED" 
            jndiName="jdbc/TradeDataSource" statementCacheSize="60">
    <jdbcDriver libraryRef="postgresLib"/>
    <properties.postgresql 
        serverName="${env.DB_HOST:10.0.100.104}" 
        portNumber="${env.DB_PORT:5432}" 
        databaseName="${env.DB_NAME:tradedb}" 
        user="${env.DB_USER:daytrader}" 
        password="${env.DB_PASSWORD:daytrader-p8-2026}"
        currentSchema="public"/>
</dataSource>
```

## Step 3: (Optional) Override Database Connection

If you need different database credentials, set environment variables before starting Liberty:

```bash
export DB_HOST=10.0.100.104
export DB_PORT=5432
export DB_NAME=tradedb
export DB_USER=daytrader
export DB_PASSWORD=your-custom-password
```

Or add them to Liberty's `server.env` file:
```bash
echo "DB_HOST=10.0.100.104" >> /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/server.env
echo "DB_PORT=5432" >> /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/server.env
echo "DB_NAME=tradedb" >> /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/server.env
echo "DB_USER=daytrader" >> /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/server.env
echo "DB_PASSWORD=daytrader-p8-2026" >> /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/server.env
```

## Step 4: Deploy Application

The GitHub Actions workflow automatically deploys to AIX:

```bash
# Manually trigger if needed (or push to master branch)
# The workflow will:
# 1. Build EAR with Maven
# 2. Upload to MinIO
# 3. Download on AIX via curl
# 4. Restart Liberty server
```

Manual deployment:
```bash
# On AIX
cd /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/apps

# Download from MinIO (HTTP - AIX curl lacks homelab CA)
curl -s http://10.0.2.81:9000/daytrader-artifacts/daytrader-latest.ear \
  -o daytrader-ee7.ear

# Restart Liberty
export JAVA_HOME=/usr/java8_64
/opt/IBM/WebSphere/Liberty/bin/server stop defaultServer
/opt/IBM/WebSphere/Liberty/bin/server start defaultServer

# Check logs
tail -f /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/logs/messages.log
```

## Step 5: Initialize Database Schema

On first deployment, you need to create the database schema. DayTrader can do this automatically:

1. Access the web UI: http://10.0.1.132:9082/daytrader
2. Click "Configuration"
3. Click "(Re)create DayTrader Database Tables and Indexes"
4. Click "(Re)populate DayTrader Database"

Or use the REST API:
```bash
# Access from your workstation (AIX doesn't have jq/httpie)
curl -X POST http://10.0.1.132:9082/daytrader/config?action=buildDB
curl -X POST http://10.0.1.132:9082/daytrader/config?action=resetTrade
```

## Step 6: Verify Deployment

Check that the application is working:

```bash
# From your workstation
# Web UI
curl -I http://10.0.1.132:9082/daytrader/

# REST API
curl http://10.0.1.132:9082/daytrader/api/market
curl http://10.0.1.132:9082/daytrader/api/quotes
```

Expected response from `/api/market`:
```json
{
  "tsia": 123.45,
  "openTSIA": 120.00,
  "volume": 1234567.89,
  "topGainers": [...],
  "topLosers": [...],
  "summaryDate": "2026-02-25T21:00:00Z"
}
```

## Troubleshooting

### Issue: Cannot connect to PostgreSQL

Check from AIX:
```bash
telnet 10.0.100.104 5432
# Should connect successfully
```

If fails, check K8s service:
```bash
kubectl get svc -n postgres
kubectl get pods -n postgres
```

### Issue: JDBC driver not found

Check the driver location:
```bash
ls -l /opt/IBM/WebSphere/Liberty/usr/shared/resources/postgresql/
# Should show: postgresql-42.7.1.jar
```

Check Liberty messages.log:
```bash
grep -i "postgresql" /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/logs/messages.log
grep -i "jdbc" /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/logs/messages.log
```

### Issue: Authentication failed

Verify credentials in K8s:
```bash
kubectl get secret -n postgres postgres-credentials -o yaml
```

Test connection from AIX:
```bash
# If psql is available
psql -h 10.0.100.104 -p 5432 -U daytrader -d tradedb
```

### Issue: Application won't start

Check Liberty logs:
```bash
tail -100 /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/logs/messages.log
tail -100 /opt/IBM/WebSphere/Liberty/usr/servers/defaultServer/logs/console.log
```

Check Java version:
```bash
/usr/java8_64/bin/java -version
# Should show: IBM Java 8
```

## Switching Back to Derby (Local Dev)

If you need to test locally without PostgreSQL, edit server.xml:

1. Comment out the PostgreSQL datasource block
2. Uncomment the Derby datasource block
3. Restart Liberty

## Performance Notes

- Connection pool size: 100 (configured in `conMgr1`)
- Statement cache: 60 statements
- Keep-alive: unlimited (`maxKeepAliveRequests="-1"`)
- AIX Liberty is tuned for P8 POWER architecture

## REST API Endpoints

See [API.md](API.md) for complete REST API documentation.

Quick test:
```bash
curl http://10.0.1.132:9082/daytrader/api/market | jq
curl http://10.0.1.132:9082/daytrader/api/quotes | jq
```

## CI/CD Pipeline

The `.github/workflows/deploy.yml` automatically:
1. Builds on homelab runner
2. Uploads to MinIO
3. **Deploys to AIX at 10.0.1.132** ← Primary target
4. (Also builds Docker image for future container deployments)

No manual steps needed for normal deployments — just push to master.
