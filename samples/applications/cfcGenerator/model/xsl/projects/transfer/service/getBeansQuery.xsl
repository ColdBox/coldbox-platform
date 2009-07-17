	&lt;cffunction name="get<xsl:value-of select="//bean/@name"/>s" access="public" output="false" returntype="query"&gt;
		<xsl:for-each select="root/bean/dbtable/column">&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:value-of select="@type" />" required="false" /&gt;
		</xsl:for-each>
		&lt;cfreturn variables.<xsl:value-of select="//bean/@name"/>Gateway.getByAttributes(argumentCollection=arguments) /&gt;
	&lt;/cffunction&gt;