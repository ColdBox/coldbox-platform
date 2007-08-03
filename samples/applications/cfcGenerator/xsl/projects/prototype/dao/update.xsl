	&lt;cffunction name="update" access="public" output="false" returntype="boolean"&gt;
		&lt;cfargument name="<xsl:value-of select="//bean/@name"/>" type="<xsl:value-of select="//bean/@path"/>" required="true" /&gt;

		&lt;cfset var qUpdate = "" /&gt;
		&lt;cftry&gt;
			&lt;cfquery name="qUpdate" datasource="#variables.dsn#"&gt;
				UPDATE	<xsl:value-of select="//dbtable/@name" />
				SET
					<xsl:for-each select="root/bean/dbtable/column[@primaryKey != 'Yes']"><xsl:value-of select="@name" /> = &lt;cfqueryparam value="#arguments.<xsl:value-of select="//bean/@name"/>.get<xsl:value-of select="@name" />()#" CFSQLType="<xsl:value-of select="@cfSqlType" />"<xsl:if test="@required != 'Yes'"> null="#not len(arguments.<xsl:value-of select="//bean/@name"/>.get<xsl:value-of select="@name" />())#"</xsl:if> /&gt;<xsl:if test="position() != last()">,
					</xsl:if>
					</xsl:for-each>
				WHERE	<xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']"><xsl:value-of select="@name" /> = &lt;cfqueryparam value="#arguments.<xsl:value-of select="//bean/@name"/>.get<xsl:value-of select="@name" />()#" CFSQLType="<xsl:value-of select="@cfSqlType" />" /&gt;<xsl:if test="position() != last()">
				AND	</xsl:if></xsl:for-each>
			&lt;/cfquery&gt;
			&lt;cfcatch type="database"&gt;
				&lt;cfreturn false /&gt;
			&lt;/cfcatch&gt;
		&lt;/cftry&gt;
		&lt;cfreturn true /&gt;
	&lt;/cffunction&gt;