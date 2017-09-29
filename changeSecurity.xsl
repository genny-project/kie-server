<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ds="urn:jboss:domain:security:1.2">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="//ds:subsystem/ds:security-domains/ds:security-domain[@name='other']">
    <security-domain name="other" cache-type="default">
      <authentication>
        <login-module code="UsersRoles" flag="required">
          <module-option name="usersProperties" value="/opt/jboss/wildfly/standalone/configuration/kie-server-users.properties"/>
          <module-option name="rolesProperties" value="/opt/jboss/wildfly/standalone/configuration/kie-server-roles.properties"/>
        </login-module>
      </authentication>
    </security-domain>
    </xsl:template>

    <xsl:template match="//ds:subsystem/ds:datasources/ds:drivers">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
            <ds:driver name="mysql" module="com.mysql.jdbc">
                <ds:xa-datasource-class>com.mysql.jdbc.jdbc2.optional.MysqlXADataSource</ds:xa-datasource-class>
            </ds:driver>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>

