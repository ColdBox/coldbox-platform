<cfcomponent displayName="Utils" hint="Set of common methods.">


	<cffunction name="logSearch" returnType="void" output="false" access="public" hint="Logs a search request">
		<cfargument name="searchTerms" type="string" required="true">
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="tableprefix" type="string" required="true">
		
		<cfquery datasource="#arguments.dsn#">
			insert into #arguments.tableprefix#search_log(searchterms, datesearched)
			values(<cfqueryparam cfsqltype="cf_sql_varchar" value="#left(arguments.searchTerms, 255)#">,
			       <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">)
		</cfquery>
		
	</cffunction>
	
	<cffunction name="isUserInAnyRole" access="public" returnType="boolean" output="false"
				hint="isUserInRole only does AND checks. This method allows for OR checks.">
		
		<cfargument name="rolelist" type="string" required="true">
		<cfset var role = "">
		
		<cfloop index="role" list="#rolelist#">
			<cfif isUserInRole(role)>
				<cfreturn true>
			</cfif>
		</cfloop>
		
		<cfreturn false>
		
	</cffunction>
	
	<cffunction name="queryToStruct" access="public" returnType="struct" output="false"
				hint="Transforms a query to a struct.">
		<cfargument name="theQuery" type="query" required="true">
		<cfset var s = structNew()>
		<cfset var q ="">
		
		<cfloop index="q" list="#theQuery.columnList#">
			<cfset s[q] = theQuery[q][1]>
		</cfloop>
		
		<cfreturn s>
		
	</cffunction>
	
	<cffunction name="searchSafe" access="public" returnType="string" output="false"
				hint="Removes any non a-z, 0-9 characters.">
		<cfargument name="string" type="string" required="true">
		
		<cfreturn reReplace(arguments.string,"[^a-zA-Z0-9[:space:]]+","","all")>
	</cffunction>
	
	<cffunction name="throw" access="public" returnType="void" output="false"
				hint="Handles exception throwing.">
				
		<cfargument name="type" type="string" required="true">		
		<cfargument name="message" type="string" required="true">
		
		<cfthrow type="#arguments.type#" message="#arguments.message#">
		
	</cffunction>

</cfcomponent>