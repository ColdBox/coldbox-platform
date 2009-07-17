	&lt;cffunction name="save" access="public" output="false" returntype="boolean"&gt;
		&lt;cfargument name="<xsl:value-of select="//bean/@name"/>" type="<xsl:value-of select="//bean/@path"/>" required="true" /&gt;
		
		&lt;cfset var success = false /&gt;
		&lt;cfif exists(arguments.<xsl:value-of select="//bean/@name"/>)&gt;
			&lt;cfset success = update(arguments.<xsl:value-of select="//bean/@name"/>) /&gt;
		&lt;cfelse&gt;
			&lt;cfset success = create(arguments.<xsl:value-of select="//bean/@name"/>) /&gt;
		&lt;/cfif&gt;
		
		&lt;cfreturn success /&gt;
	&lt;/cffunction&gt;