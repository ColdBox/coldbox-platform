	&lt;cffunction name="get<xsl:value-of select="//bean/@name"/>" access="public" output="false" returntype="void"&gt;
		&lt;cfargument name="<xsl:value-of select="//bean/@name"/>" type="<xsl:value-of select="//bean/@path"/>" required="true" /&gt;
		&lt;cfreturn variables.<xsl:value-of select="//bean/@name"/>DAO.read(arguments.<xsl:value-of select="//bean/@name"/>) /&gt;
	&lt;/cffunction&gt;