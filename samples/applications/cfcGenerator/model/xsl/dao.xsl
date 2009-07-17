<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" indent="no"  />
		<xsl:template match="/">
&lt;cfcomponent displayname="<xsl:value-of select="//bean/@name"/>DAO" hint="table ID column = <xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']"><xsl:value-of select="@name" /><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>"&gt;

	&lt;cffunction name="init" access="public" output="false" returntype="<xsl:value-of select="//bean/@path"/>DAO"&gt;
		&lt;cfargument name="dsn" type="string" required="true"&gt;
		&lt;cfset variables.dsn = arguments.dsn&gt;
		&lt;cfreturn this&gt;
	&lt;/cffunction&gt;
	
	<!-- custom code -->

&lt;/cfcomponent&gt;</xsl:template>
</xsl:stylesheet>