	&lt;cffunction name="save<xsl:value-of select="//bean/@name"/>" access="public" output="false" returntype="boolean"&gt;
		<xsl:for-each select="root/bean/dbtable/column">&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:value-of select="@type" />" required="<xsl:choose><xsl:when test="@required='Yes'">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose>" /&gt;
		</xsl:for-each>
		
		&lt;cfset var <xsl:value-of select="//bean/@name"/> = get<xsl:value-of select="//bean/@name"/>(<xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']">arguments.<xsl:value-of select="@name" /></xsl:for-each>) /&gt;
		<xsl:for-each select="root/bean/dbtable/column">
		<xsl:if test="@required='No'">&lt;cfif structKeyExists(arguments,"<xsl:value-of select="@name" />")&gt;
			</xsl:if>&lt;cfset <xsl:value-of select="//bean/@name"/>.set<xsl:value-of select="@name" />(arguments.<xsl:value-of select="@name" />) /&gt;
		<xsl:if test="@required='No'">&lt;/cfif&gt;
		</xsl:if>
		</xsl:for-each>&lt;cfreturn variables.<xsl:value-of select="//bean/@name"/>DAO.save(arguments.<xsl:value-of select="//bean/@name"/>) /&gt;
	&lt;/cffunction&gt;