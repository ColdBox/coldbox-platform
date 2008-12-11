	&lt;cffunction name="exists" access="public" output="false" returntype="boolean"&gt;
		&lt;cfargument name="<xsl:value-of select="//bean/@name"/>" type="<xsl:value-of select="//bean/@path"/>" required="true" /&gt;

		&lt;cfset var qExists = ""&gt;
		&lt;cfquery name="qExists" datasource="#variables.dsn#" maxrows="1"&gt;
			SELECT count(1) as idexists
			FROM	<xsl:value-of select="//dbtable/@name" />
			WHERE	<xsl:for-each select="root/bean/dbtable/column[@primaryKey='Yes']"><xsl:value-of select="@name" /> = &lt;cfqueryparam value="#arguments.<xsl:value-of select="//bean/@name"/>.get<xsl:value-of select="@name" />()#" CFSQLType="<xsl:value-of select="@cfSqlType" />" /&gt;<xsl:if test="position() != last()">
			AND	</xsl:if></xsl:for-each>
		&lt;/cfquery&gt;

		&lt;cfif qExists.idexists&gt;
			&lt;cfreturn true /&gt;
		&lt;cfelse&gt;
			&lt;cfreturn false /&gt;
		&lt;/cfif&gt;
	&lt;/cffunction&gt;