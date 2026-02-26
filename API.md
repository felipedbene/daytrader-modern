# DayTrader 7 Modernization

This is a modernized version of the IBM DayTrader 7 benchmark application with REST API endpoints and PostgreSQL support.

## What's New

### REST API Endpoints

The application now includes JAX-RS REST API endpoints under `/api`:

#### Market Summary
- **GET /api/market** - Get current market summary including TSIA index, volume, top gainers/losers

#### Quotes
- **GET /api/quotes/{symbol}** - Get quote for a specific stock symbol
- **GET /api/quotes** - Get all quotes

#### Accounts
- **GET /api/accounts/{userId}** - Get account information for a user
- **POST /api/accounts/login** - Login user
  ```json
  {
    "userId": "uid:0",
    "password": "xxx"
  }
  ```

#### Portfolio
- **GET /api/portfolio/{userId}** - Get all holdings for a user

#### Orders
- **GET /api/orders/{userId}** - Get all orders for a user
- **POST /api/orders** - Place a buy or sell order
  
  Buy order example:
  ```json
  {
    "orderType": "buy",
    "userId": "uid:0",
    "symbol": "s:0",
    "quantity": 100
  }
  ```
  
  Sell order example:
  ```json
  {
    "orderType": "sell",
    "userId": "uid:0",
    "holdingId": 123
  }
  ```

### PostgreSQL Support

The application is configured to use PostgreSQL by default with these connection details:

- **Host:** 10.0.100.104 (MetalLB LoadBalancer, reachable from AIX)
- **Port:** 5432
- **Database:** tradedb
- **Username:** daytrader
- **Password:** daytrader-p8-2026

These are built-in defaults in `server.xml`. You can override them with environment variables:
- `DB_HOST` - PostgreSQL host
- `DB_PORT` - PostgreSQL port
- `DB_NAME` - Database name
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password

**For AIX deployment:** See [AIX_DEPLOY.md](AIX_DEPLOY.md) for complete setup instructions including JDBC driver installation.

## Building

```bash
mvn clean package -DskipTests
```

## Deployment

### Primary: AIX with Liberty (P8 POWER)

The main deployment target is AIX 7.2 on IBM POWER8. See [AIX_DEPLOY.md](AIX_DEPLOY.md) for:
- PostgreSQL JDBC driver installation
- Server configuration
- Deployment via GitHub Actions
- Troubleshooting

Access the application at:
- Web UI: http://10.0.1.132:9082/daytrader
- REST API: http://10.0.1.132:9082/daytrader/api/market

### Secondary: Docker Compose (Testing)

For local testing with Docker:

```bash
docker-compose up
```

This will start:
- PostgreSQL database
- DayTrader application on port 9082

Access at http://localhost:9082/daytrader

### Local Dev with Liberty

```bash
cd daytrader-ee7
mvn liberty:run
```

Note: You may want to switch to Derby for local dev (edit server.xml)

## Docker Image

Docker images are automatically built and pushed to GitHub Container Registry:
- `ghcr.io/felipedbene/daytrader-modern:latest`
- `ghcr.io/felipedbene/daytrader-modern:<git-sha>`

## Architecture

- **EJB Module** (`daytrader-ee7-ejb`): Business logic, entities, and persistence
- **Web Module** (`daytrader-ee7-web`): JSP/XHTML UI and REST API endpoints
- **EAR** (`daytrader-ee7`): Packaged application with Liberty configuration

## Technologies

- Java EE 7
- EJB 3.2
- JPA 2.1
- JAX-RS 2.1 (REST API)
- JSON-B 1.0 (JSON serialization)
- JSF 2.2 (Web UI)
- WebSocket 1.1
- Open Liberty

## Original Features

All original DayTrader features remain intact:
- Stock trading simulation
- User accounts and portfolios
- Order processing (synchronous and asynchronous)
- Market summary and quotes
- JSP/XHTML web interface
- WebSocket streaming quotes
- JMS messaging for async orders

## CI/CD

GitHub Actions workflow automatically:
1. Builds the application with Maven
2. Uploads WAR/EAR to MinIO (internal)
3. Builds and pushes Docker image to ghcr.io
4. Deploys to AIX Liberty server (if configured)

## License

Apache License 2.0 - See LICENSE file
