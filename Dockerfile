FROM jboss/kie-server:latest

ENV HOME /opt/jboss
ENV JBOSS_HOME $HOME/wildfly

ENV MYSQLCONNECTOR_VERSION 5.1.41

USER root

# Install necessary packages
RUN set -x \
    && yum update -y \
    && yum install -y \
      curl \
      jq \
      sed \
      vim \
      wget \
      xmlstarlet 

COPY java/* /usr/share/java/

############################ Database #############################

ADD changeDatabase.xsl $JBOSS_HOME/
ADD changeSecurity.xsl $JBOSS_HOME/
RUN java -jar /usr/share/java/saxon.jar -s:$JBOSS_HOME/standalone/configuration/standalone.xml -xsl:$JBOSS_HOME/changeDatabase.xsl -o:$JBOSS_HOME/standalone/configuration/standalone.xml 
RUN java -jar /usr/share/java/saxon.jar -s:$JBOSS_HOME/standalone/configuration/standalone-full.xml -xsl:$JBOSS_HOME/changeDatabase.xsl -o:$JBOSS_HOME/standalone/configuration/standalone-full.xml 
RUN java -jar /usr/share/java/saxon.jar -s:$JBOSS_HOME/standalone/configuration/standalone-full.xml -xsl:$JBOSS_HOME/changeSecurity.xsl -o:$JBOSS_HOME/standalone/configuration/standalone-full.xml 

RUN mkdir -p $JBOSS_HOME/modules/system/layers/base/com/mysql/jdbc/main; cd $JBOSS_HOME/modules/system/layers/base/com/mysql/jdbc/main && curl -O http://central.maven.org/maven2/mysql/mysql-connector-java/$MYSQLCONNECTOR_VERSION/mysql-connector-java-$MYSQLCONNECTOR_VERSION.jar

ADD module.xml $JBOSS_HOME/modules/system/layers/base/com/mysql/jdbc/main/
RUN sed -i "s/mysql-connector-java/mysql-connector-java-$MYSQLCONNECTOR_VERSION/g" $JBOSS_HOME/modules/system/layers/base/com/mysql/jdbc/main/module.xml
#RUN sed -i 's/ExampleDS/jbpmDS/g' $JBOSS_HOME/standalone/configuration/standalone.xml
RUN sed -i 's/ExampleDS/jbpmDS/g' $JBOSS_HOME/standalone/configuration/standalone-full.xml
RUN sed -i 's/application-users/kie-server-users/g' $JBOSS_HOME/standalone/configuration/standalone-full.xml
RUN sed -i 's/application-roles/kie-server-roles/g' $JBOSS_HOME/standalone/configuration/standalone-full.xml
ADD start_kie-wb.sh /opt/jboss/wildfly/bin/start_kie-wb.sh
RUN chown jboss:root /opt/jboss/wildfly/bin/start_kie-wb.sh
RUN chmod a+x /opt/jboss/wildfly/bin/start_kie-wb.sh
ADD kie-server-users.properties /opt/jboss/wildfly/standalone/configuration/kie-server-users.properties
ADD kie-server-roles.properties /opt/jboss/wildfly/standalone/configuration/kie-server-roles.properties

