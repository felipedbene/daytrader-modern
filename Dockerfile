FROM icr.io/appcafe/open-liberty:kernel-slim-java17-openj9-ubi

USER root

# PostgreSQL JDBC driver (Open Liberty uses /opt/ol/wlp, not /opt/ibm/wlp)
RUN mkdir -p /opt/ol/wlp/usr/shared/resources/postgresql \
    && curl -sL https://jdbc.postgresql.org/download/postgresql-42.7.1.jar \
       -o /opt/ol/wlp/usr/shared/resources/postgresql/postgresql-42.7.1.jar

# Server config + EAR
COPY daytrader-ee7/src/main/liberty/config/server.xml /config/server.xml
COPY daytrader-ee7/target/daytrader-ee7.ear /config/apps/daytrader-ee7.ear

# Install Liberty features declared in server.xml
RUN features.sh

USER 1001
EXPOSE 9080 9443
