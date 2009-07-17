	&lt;cffunction name="save<xsl:value-of select="//bean/@name"/>" access="public" output="false" returntype="any"&gt;
		<xsl:for-each select="root/bean/dbtable/column">&lt;cfargument name="<xsl:value-of select="@name" />" type="<xsl:choose><xsl:when test="@type='uuid'">uuid</xsl:when><xsl:otherwise>string</xsl:otherwise></xsl:choose>" required="false" <xsl:choose><xsl:when test="@type = 'uuid'">default="#createUUID()#"</xsl:when><xsl:otherwise>default=""</xsl:otherwise></xsl:choose> /&gt;
		</xsl:for-each>
		
		&lt;cfset var <xsl:value-of select="//bean/@name"/> = variables.transfer.get("<xsl:value-of select="//bean/@name"/>.<xsl:value-of select="//bean/@name"/>" <xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']">,arguments.<xsl:value-of select="@name" /></xsl:for-each>) /&gt;
		<xsl:for-each select="root/bean/dbtable/column">
		&lt;cfif len(arguments.<xsl:value-of select="@name" />)&gt;
			&lt;cfset <xsl:value-of select="//bean/@name"/>.set<xsl:value-of select="@name" />(arguments.<xsl:value-of select="@name" />) /&gt;
		&lt;/cfif&gt;
		</xsl:for-each>&lt;cfset variables.transfer.save(<xsl:value-of select="//bean/@name"/>) /&gt;
		
		&lt;cfreturn <xsl:value-of select="//bean/@name"/> /&gt;
	&lt;/cffunction&gt;