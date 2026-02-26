FROM eclipse-temurin:17-jdk-focal

# Install Open Liberty (JavaEE8 package - smaller, faster)
ENV LIBERTY_VERSION=24.0.0.12
ENV LIBERTY_HOME=/opt/ibm/wlp

RUN apt-get update && apt-get install -y unzip curl ca-certificates && rm -rf /var/lib/apt/lists/* \
    && curl -sL -o /tmp/openliberty.zip "https://public.dhe.ibm.com/ibmdl/export/pub/software/openliberty/runtime/release/24.0.0.12/openliberty-javaee8-24.0.0.12.zip" \
    && mkdir -p /opt/ibm \
    && unzip -q /tmp/openliberty.zip -d /opt/ibm \
    && rm /tmp/openliberty.zip \
    && useradd -r -u 1001 -g 0 default

# Install OIDC and security features via featureUtility
RUN ${LIBERTY_HOME}/bin/featureUtility installFeature openidConnectClient-1.0 transportSecurity-1.0 appSecurity-3.0 --acceptLicense

# Homelab CA cert (for OIDC to Authentik)
COPY ca/homelab-ca.crt /usr/local/share/ca-certificates/homelab-ca.crt
RUN update-ca-certificates

# Import CA into Java truststore
ENV JAVA_HOME=/opt/java/openjdk
RUN keytool -import -trustcacerts -keystore ${JAVA_HOME}/lib/security/cacerts \
    -storepass changeit -noprompt -alias homelab-ca -file /usr/local/share/ca-certificates/homelab-ca.crt

# PostgreSQL JDBC driver
RUN mkdir -p ${LIBERTY_HOME}/usr/shared/resources/postgresql \
    && curl -sL https://jdbc.postgresql.org/download/postgresql-42.7.1.jar \
    -o ${LIBERTY_HOME}/usr/shared/resources/postgresql/postgresql-42.7.1.jar

# Server config
COPY daytrader-ee7/src/main/liberty/config/server.xml ${LIBERTY_HOME}/usr/servers/defaultServer/server.xml

# DayTrader EAR
COPY daytrader-ee7/target/daytrader-ee7.ear ${LIBERTY_HOME}/usr/servers/defaultServer/apps/daytrader-ee7.ear

# Create needed dirs
RUN mkdir -p ${LIBERTY_HOME}/usr/servers/defaultServer/logs \
    && chown -R 1001:0 ${LIBERTY_HOME} \
    && chmod -R g=u ${LIBERTY_HOME}

USER 1001
EXPOSE 9080 9443

ENV PATH=${LIBERTY_HOME}/bin:${JAVA_HOME}/bin:${PATH}

ENTRYPOINT ["/bin/sh", "-c", "mkdir -p /opt/ibm/wlp/usr/servers/defaultServer/logs && chown -R 1001:0 /opt/ibm/wlp && chmod -R g=u /opt/ibm/wlp && server run defaultServer"]