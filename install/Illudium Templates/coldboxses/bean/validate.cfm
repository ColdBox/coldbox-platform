	<%cffunction name="validate" access="public" returntype="array" output="false"%>
		<%cfset var errors = arrayNew(1) /%>
		<%cfset var thisError = structNew() /%>
		<cfloop from="1" to="#arrayLen(root.bean.dbtable.xmlChildren)#" index="i">
		<%!--- #root.bean.dbtable.xmlChildren[i].xmlAttributes.name# ---%><cfif root.bean.dbtable.xmlChildren[i].xmlAttributes.required eq "Yes" and root.bean.dbtable.xmlChildren[i].xmlAttributes.identity neq true>
		<%cfif (NOT len(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())))%>
			<%cfset thisError.field = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" /%>
			<%cfset thisError.type = "required" /%>
			<%cfset thisError.message = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# is required" /%>
			<%cfset arrayAppend(errors,duplicate(thisError)) /%>
		<%/cfif%></cfif>
		<cfswitch expression="#root.bean.dbtable.xmlChildren[i].xmlAttributes.type#">
		<cfcase value="binary"><%cfif (len(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())) AND NOT isBinary(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())))%>
			<%cfset thisError.field = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" /%>
			<%cfset thisError.type = "invalidType" /%>
			<%cfset thisError.message = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# is not binary" /%>
			<%cfset arrayAppend(errors,duplicate(thisError)) /%>
		<%/cfif%>
		<%cfif (len(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())) GT #root.bean.dbtable.xmlChildren[i].xmlAttributes.length#)%>
			<%cfset thisError.field = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" /%>
			<%cfset thisError.type = "tooLong" /%>
			<%cfset thisError.message = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# is too long" /%>
			<%cfset arrayAppend(errors,duplicate(thisError)) /%>
		<%/cfif%>
		</cfcase>
		<<cfcase value="boolean"><%cfif (len(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())) AND NOT isBoolean(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())))%>
			<%cfset thisError.field = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" /%>
			<%cfset thisError.type = "invalidType" /%>
			<%cfset thisError.message = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# is not boolean" /%>
			<%cfset arrayAppend(errors,duplicate(thisError)) /%>
		<%/cfif%>
		</cfcase>
		<<cfcase value="date"><%cfif (len(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())) AND NOT isDate(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())))%>
			<%cfset thisError.field = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" /%>
			<%cfset thisError.type = "invalidType" /%>
			<%cfset thisError.message = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# is not a date" /%>
			<%cfset arrayAppend(errors,duplicate(thisError)) /%>
		<%/cfif%>
		</cfcase>
		<<cfcase value="numeric"><%cfif (len(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())) AND NOT isNumeric(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())))%>
			<%cfset thisError.field = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" /%>
			<%cfset thisError.type = "invalidType" /%>
			<%cfset thisError.message = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# is not numeric" /%>
			<%cfset arrayAppend(errors,duplicate(thisError)) /%>
		<%/cfif%>
		</cfcase>
		<<cfcase value="string"><%cfif (len(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())) AND NOT IsSimpleValue(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())))%>
			<%cfset thisError.field = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" /%>
			<%cfset thisError.type = "invalidType" /%>
			<%cfset thisError.message = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# is not a string" /%>
			<%cfset arrayAppend(errors,duplicate(thisError)) /%>
		<%/cfif%>
		<%cfif (len(trim(get#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#())) GT #root.bean.dbtable.xmlChildren[i].xmlAttributes.length#)%>
			<%cfset thisError.field = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name#" /%>
			<%cfset thisError.type = "tooLong" /%>
			<%cfset thisError.message = "#root.bean.dbtable.xmlChildren[i].xmlAttributes.name# is too long" /%>
			<%cfset arrayAppend(errors,duplicate(thisError)) /%>
		<%/cfif%>
		</cfcase></cfswitch></cfloop>
		<%cfreturn errors /%>
	<%/cffunction%>