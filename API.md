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

The application now supports PostgreSQL in addition to Derby. To use PostgreSQL:

1. Edit `daytrader-ee7/src/main/liberty/config/server.xml`
2. Comment out the Derby datasource section
3. Uncomment the PostgreSQL datasource section
4. Download PostgreSQL JDBC driver:
   ```bash
   wget https://jdbc.postgresql.org/download/postgresql-42.7.1.jar -P daytrader-ee7/target/liberty/wlp/usr/shared/resources/postgresql/
   ```
5. Set environment variables:
   - `DB_HOST` - PostgreSQL host (default: localhost)
   - `DB_PORT` - PostgreSQL port (default: 5432)
   - `DB_NAME` - Database name (default: tradedb)
   - `DB_USER` - Database user
   - `DB_PASSWORD` - Database password

## Building

```bash
mvn clean package -DskipTests
```

## Running with Docker Compose

The easiest way to run with PostgreSQL:

```bash
docker-compose up
```

This will start:
- PostgreSQL database
- DayTrader application on port 9082

Access the application at:
- Web UI: http://localhost:9082/daytrader
- REST API: http://localhost:9082/daytrader/api/market

## Running Locally with Liberty

```bash
cd daytrader-ee7
mvn liberty:run
```

Access at http://localhost:9082/daytrader

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
