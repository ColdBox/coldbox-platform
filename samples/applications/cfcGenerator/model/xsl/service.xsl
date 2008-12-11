<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" indent="no"  />
		<xsl:template match="/">
&lt;cfcomponent name="<xsl:value-of select="//bean/@name"/>Service" output="false"&gt;

	&lt;cffunction name="init" access="public" output="false" returntype="<xsl:value-of select="//bean/@path"/>Service"&gt;
		&lt;cfargument name="<xsl:value-of select="//bean/@name"/>DAO" type="<xsl:value-of select="//bean/@path"/>DAO" required="true" /&gt;
		&lt;cfargument name="<xsl:value-of select="//bean/@name"/>Gateway" type="<xsl:value-of select="//bean/@path"/>Gateway" required="true" /&gt;

		&lt;cfset variables.<xsl:value-of select="//bean/@name"/>DAO = arguments.<xsl:value-of select="//bean/@name"/>DAO /&gt;
		&lt;cfset variables.<xsl:value-of select="//bean/@name"/>Gateway = arguments.<xsl:value-of select="//bean/@name"/>Gateway /&gt;

		&lt;cfreturn this/&gt;
	&lt;/cffunction&gt;

	<!-- custom code -->
&lt;/cfcomponent&gt;</xsl:template>
</xsl:stylesheet>