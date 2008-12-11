	&lt;cffunction name="delete<xsl:value-of select="//bean/@name"/>" access="public" output="false" returntype="boolean"&gt;
		<xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']">&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:value-of select="@type" />" required="<xsl:choose><xsl:when test="@required='Yes'">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose>" /&gt;
		</xsl:for-each>
		&lt;cfset var <xsl:value-of select="//bean/@name"/> = createObject("component","<xsl:value-of select="//bean/@path"/>").init(argumentCollection=arguments) /&gt;
		&lt;cfreturn variables.<xsl:value-of select="//bean/@name"/>DAO.delete(<xsl:value-of select="//bean/@name"/>) /&gt;
	&lt;/cffunction&gt;