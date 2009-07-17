<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" indent="no"  />
		<xsl:template match="/">
&lt;cfcomponent displayname="<xsl:value-of select="//bean/@name"/>Gateway" output="false"&gt;
	&lt;cffunction name="init" access="public" output="false" returntype="<xsl:value-of select="//bean/@path"/>Gateway"&gt;
		&lt;cfargument name="dsn" type="string" required="true" /&gt;
		&lt;cfset variables.dsn = arguments.dsn /&gt;
		&lt;cfreturn this /&gt;
	&lt;/cffunction&gt;
	
	<!-- custom code -->

&lt;/cfcomponent&gt;</xsl:template>
</xsl:stylesheet>