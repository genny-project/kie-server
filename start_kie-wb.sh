#!/usr/bin/env bash

# Start Wildfly with the given arguments.
echo "Running jBPM Workbench on JBoss Wildfly..."
exec ./standalone.sh -b $JBOSS_BIND_ADDRESS -c standalone-full.xml   -Djboss.socket.binding.port-offset=150 -Dorg.kie.server.location=http://localhost:8230/kie-server/services/rest/server -Dorg.kie.server.controller=http://localhost:8080/kie-wb/rest/controller -Dorg.kie.server.id=kieserver -Dorg.kie.server.persistence.dialect=org.hibernate.dialect.MySQL5Dialect -Dorg.kie.server.persistence.ds=java:jboss/datasources/jbpmDS
exit $?
