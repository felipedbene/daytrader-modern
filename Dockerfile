FROM websphere-liberty:full-java17-openj9

# PostgreSQL JDBC driver
COPY --chown=1001:0 lib/postgresql-42.7.1.jar /opt/ibm/wlp/usr/shared/resources/postgresql/postgresql-42.7.1.jar

# Server config
COPY --chown=1001:0 daytrader-ee7/src/main/liberty/config/server.xml /config/server.xml

# DayTrader EAR (built by CI or locally)
COPY --chown=1001:0 daytrader-ee7/target/daytrader-ee7.ear /config/apps/daytrader-ee7.ear

# Pre-configure server for faster startup
RUN configure.sh
