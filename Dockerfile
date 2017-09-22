FROM jboss/kie-server:latest

ENV HOME /opt/jboss
ENV JBOSS_HOME /opt/jboss/wildfly

ENV KEYCLOAK_VERSION 3.1.0.Final
ENV MYSQLCONNECTOR_VERSION 5.1.41

# Enables signals getting passed from startup script to JVM
# ensuring clean shutdown when container is stopped.
ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV MYSQL_PORT_3306_TCP_ADDR 10.64.0.22
ENV MYSQL_PORT_3306_TCP_PORT 3306

USER root

# Install necessary packages
RUN set -x \
    && yum update -y \
    && yum install -y \
      curl \
      jq \
      vim \
      wget \
      xmlstarlet 

COPY java/* /usr/share/java/

############################ Database #############################

ADD changeDatabase.xsl $JBOSS_HOME/
RUN java -jar /usr/share/java/saxon.jar -s:$JBOSS_HOME/standalone/configuration/standalone.xml -xsl:$JBOSS_HOME/changeDatabase.xsl -o:$JBOSS_HOME/standalone/configuration/standalone.xml; java -jar /usr/share/java/saxon.jar -s:$JBOSS_HOME/standalone/configuration/standalone-ha.xml -xsl:$JBOSS_HOME/changeDatabase.xsl -o:$JBOSS_HOME/standalone/configuration/standalone-ha.xml;

RUN mkdir -p $JBOSS_HOME/modules/system/layers/base/com/mysql/jdbc/main; cd $JBOSS_HOME/modules/system/layers/base/com/mysql/jdbc/main && curl -O http://central.maven.org/maven2/mysql/mysql-connector-java/$MYSQLCONNECTOR_VERSION/mysql-connector-java-$MYSQLCONNECTOR_VERSION.jar

ADD module.xml $JBOSS_HOME/modules/system/layers/base/com/mysql/jdbc/main/
RUN sed -i "s/mysql-connector-java/mysql-connector-java-$MYSQLCONNECTOR_VERSION/g" $JBOSS_HOME/modules/system/layers/base/com/mysql/jdbc/main/module.xml
RUN sed -i 's/ExampleDS/gennyDS/g' $JBOSS_HOME/standalone/configuration/standalone.xml

