<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" indent="no"  />
		<xsl:template match="/">
&lt;cfcomponent displayname="<xsl:value-of select="//bean/@name"/>TO" output="false"&gt;

	&lt;cffunction name="init" access="public" returntype="<xsl:value-of select="//bean/@path"/>TO" output="false"&gt;
		<xsl:for-each select="root/bean/dbtable/column">&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:value-of select="@type" />" required="false" <xsl:if test="@type = 'uuid'">default="#createUUID()#"</xsl:if> /&gt;
		</xsl:for-each>
		<xsl:for-each select="root/bean/dbtable/column">
		&lt;cfset this.<xsl:value-of select="@name" /> = arguments.<xsl:value-of select="@name" /> /&gt;</xsl:for-each>
		
		&lt;cfrreturn this /&gt;
	&lt;/cffunction&gt;
&lt;/cfcomponent&gt;</xsl:template>
</xsl:stylesheet>