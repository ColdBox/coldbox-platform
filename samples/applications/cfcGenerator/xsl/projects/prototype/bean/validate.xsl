	&lt;cffunction name="validate" access="public" returntype="array" output="false"&gt;
		&lt;cfset var errors = arrayNew(1) /&gt;
		&lt;cfset var thisError = structNew() /&gt;
		<xsl:for-each select="root/bean/dbtable/column">
		&lt;!--- <xsl:value-of select="@name" /> ---&gt;
		<xsl:if test="@required='Yes'">&lt;cfif (NOT len(trim(get<xsl:value-of select="@name" />())))&gt;
			&lt;cfset thisError.field = "<xsl:value-of select="@name" />" /&gt;
			&lt;cfset thisError.type = "required" /&gt;
			&lt;cfset thisError.message = "<xsl:value-of select="@name" /> is required" /&gt;
			&lt;cfset arrayAppend(errors,thisError) /&gt;
		&lt;/cfif&gt;
		</xsl:if>
		<xsl:choose>
		<xsl:when test="@type='binary'">&lt;cfif (len(trim(get<xsl:value-of select="@name" />())) AND NOT isBinary(trim(get<xsl:value-of select="@name" />())))&gt;
			&lt;cfset thisError.field = "<xsl:value-of select="@name" />" /&gt;
			&lt;cfset thisError.type = "invalidType" /&gt;
			&lt;cfset thisError.message = "<xsl:value-of select="@name" /> is not binary" /&gt;
			&lt;cfset arrayAppend(errors,thisError) /&gt;
		&lt;/cfif&gt;
		&lt;cfif (len(trim(get<xsl:value-of select="@name" />())) GT <xsl:value-of select="@length" />)&gt;
			&lt;cfset thisError.field = "<xsl:value-of select="@name" />" /&gt;
			&lt;cfset thisError.type = "tooLong" /&gt;
			&lt;cfset thisError.message = "<xsl:value-of select="@name" /> is too long" /&gt;
			&lt;cfset arrayAppend(errors,thisError) /&gt;
		&lt;/cfif&gt;
		</xsl:when>
		<xsl:when test="@type='boolean'">&lt;cfif (len(trim(get<xsl:value-of select="@name" />())) AND NOT isBoolean(trim(get<xsl:value-of select="@name" />())))&gt;
			&lt;cfset thisError.field = "<xsl:value-of select="@name" />" /&gt;
			&lt;cfset thisError.type = "invalidType" /&gt;
			&lt;cfset thisError.message = "<xsl:value-of select="@name" /> is not boolean" /&gt;
			&lt;cfset arrayAppend(errors,thisError) /&gt;
		&lt;/cfif&gt;
		</xsl:when>
		<xsl:when test="@type='date'">&lt;cfif (len(trim(get<xsl:value-of select="@name" />())) AND NOT isDate(trim(get<xsl:value-of select="@name" />())))&gt;
			&lt;cfset thisError.field = "<xsl:value-of select="@name" />" /&gt;
			&lt;cfset thisError.type = "invalidType" /&gt;
			&lt;cfset thisError.message = "<xsl:value-of select="@name" /> is not a date" /&gt;
			&lt;cfset arrayAppend(errors,thisError) /&gt;
		&lt;/cfif&gt;
		</xsl:when>
		<xsl:when test="@type='numeric'">&lt;cfif (len(trim(get<xsl:value-of select="@name" />())) AND NOT isNumeric(trim(get<xsl:value-of select="@name" />())))&gt;
			&lt;cfset thisError.field = "<xsl:value-of select="@name" />" /&gt;
			&lt;cfset thisError.type = "invalidType" /&gt;
			&lt;cfset thisError.message = "<xsl:value-of select="@name" /> is not numeric" /&gt;
			&lt;cfset arrayAppend(errors,thisError) /&gt;
		&lt;/cfif&gt;
		</xsl:when>
		<xsl:when test="@type='string'">&lt;cfif (len(trim(get<xsl:value-of select="@name" />())) AND NOT IsSimpleValue(trim(get<xsl:value-of select="@name" />())))&gt;
			&lt;cfset thisError.field = "<xsl:value-of select="@name" />" /&gt;
			&lt;cfset thisError.type = "invalidType" /&gt;
			&lt;cfset thisError.message = "<xsl:value-of select="@name" /> is not a string" /&gt;
			&lt;cfset arrayAppend(errors,thisError) /&gt;
		&lt;/cfif&gt;
		&lt;cfif (len(trim(get<xsl:value-of select="@name" />())) GT <xsl:value-of select="@length" />)&gt;
			&lt;cfset thisError.field = "<xsl:value-of select="@name" />" /&gt;
			&lt;cfset thisError.type = "tooLong" /&gt;
			&lt;cfset thisError.message = "<xsl:value-of select="@name" /> is too long" /&gt;
			&lt;cfset arrayAppend(errors,thisError) /&gt;
		&lt;/cfif&gt;
		</xsl:when>
		</xsl:choose>
		</xsl:for-each>
		&lt;cfreturn errors /&gt;
	&lt;/cffunction&gt;