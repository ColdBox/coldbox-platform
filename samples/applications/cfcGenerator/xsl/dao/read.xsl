	&lt;cffunction name="read" access="public" output="false" returntype="void"&gt;
		&lt;cfargument name="<xsl:value-of select="//bean/@name"/>" type="<xsl:value-of select="//bean/@path"/>" required="true" /&gt;

		&lt;cfset var qRead = "" /&gt;
		&lt;cfset var strReturn = structNew() /&gt;
		&lt;cftry&gt;
			&lt;cfquery name="qRead" datasource="#variables.dsn#"&gt;
				SELECT
					<xsl:for-each select="root/bean/dbtable/column"><xsl:value-of select="@name" /><xsl:if test="position() != last()">,
					</xsl:if>
					</xsl:for-each>
				FROM	<xsl:value-of select="//dbtable/@name" />
				WHERE	<xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']"><xsl:value-of select="@name" /> = &lt;cfqueryparam value="#arguments.<xsl:value-of select="//bean/@name"/>.get<xsl:value-of select="@name" />()#" CFSQLType="<xsl:value-of select="@cfSqlType" />" /&gt;<xsl:if test="position() != last()">
				AND	</xsl:if></xsl:for-each>
			&lt;/cfquery&gt;
			&lt;cfcatch type="database"&gt;
				&lt;!--- leave the bean as is ---&gt;
			&lt;/cfcatch&gt;
		&lt;/cftry&gt;
		&lt;cfif qRead.recordCount&gt;
			&lt;cfset strReturn = queryRowToStruct(qRead)&gt;
			&lt;cfset arguments.<xsl:value-of select="//bean/@name"/>.init(argumentCollection=strReturn)&gt;
		&lt;/cfif&gt;
	&lt;/cffunction&gt;