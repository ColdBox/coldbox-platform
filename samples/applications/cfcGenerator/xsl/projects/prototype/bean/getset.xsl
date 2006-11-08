	&lt;!---
	ACCESSORS
	---&gt;<xsl:for-each select="root/bean/dbtable/column">
	&lt;cffunction name="set<xsl:value-of select="@name" />" access="public" returntype="void" output="false"&gt;
		&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:choose><xsl:when test="@type='uuid'">uuid</xsl:when><xsl:otherwise>string</xsl:otherwise></xsl:choose>" required="true" /&gt;
		&lt;cfset variables.instance.<xsl:value-of select="@name" /> = arguments.<xsl:value-of select="@name" /> /&gt;
	&lt;/cffunction&gt;
	&lt;cffunction name="get<xsl:value-of select="@name" />" access="public" returntype="<xsl:choose><xsl:when test="@type='uuid'">uuid</xsl:when><xsl:otherwise>string</xsl:otherwise></xsl:choose>" output="false"&gt;
		&lt;cfreturn variables.instance.<xsl:value-of select="@name" /> /&gt;
	&lt;/cffunction&gt;
</xsl:for-each>