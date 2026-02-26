FROM icr.io/appcafe/open-liberty:full-java11-openj9-ubi

# Copy server configuration
COPY --chown=1001:0 daytrader-ee7/src/main/liberty/config/server.xml /config/server.xml

# Copy application EAR
COPY --chown=1001:0 daytrader-ee7/target/daytrader-ee7.ear /config/apps/

# Optional: Copy PostgreSQL JDBC driver (uncomment if using PostgreSQL)
# COPY --chown=1001:0 postgresql-42.*.jar /opt/ol/wlp/usr/shared/resources/postgresql/

# Configure Liberty server
RUN configure.sh

