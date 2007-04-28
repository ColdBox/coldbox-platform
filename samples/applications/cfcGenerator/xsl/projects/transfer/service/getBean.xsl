	&lt;cffunction name="get<xsl:value-of select="//bean/@name"/>" access="public" output="false" returntype="any"&gt;
		<xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']">&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:value-of select="type" />" required="true" /&gt;</xsl:for-each>

		&lt;cfreturn variables.transfer.get("<xsl:value-of select="//bean/@name"/>.<xsl:value-of select="//bean/@name"/>"<xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']">,arguments.<xsl:value-of select="@name" /></xsl:for-each>) /&gt;
	&lt;/cffunction&gt;