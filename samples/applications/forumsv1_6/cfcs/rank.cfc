<!---
	Name         : rank.cfc
	Author       : Raymond Camden 
	Created      : August 28, 2005
	Last Updated : 
	History      : 
	Purpose		 : 
--->
<cfcomponent displayName="Rank" hint="Handles Ranks. It's not stinky.">

	<cfset variables.dsn = "">
	<cfset variables.dbtype = "">
	<cfset variables.tableprefix = "">
	<cfset variables.utils = createObject("component","utils")>
		
	<cffunction name="init" access="public" returnType="rank" output="false"
				hint="Returns an instance of the CFC initialized with the correct DSN.">
		<cfargument name="settings" type="struct" required="true" hint="Setting">
						
		<cfset variables.dsn = arguments.settings.dsn>
		<cfset variables.dbtype = arguments.settings.dbtype>
		<cfset variables.tableprefix = arguments.settings.tableprefix>

		<cfreturn this>
		
	</cffunction>

	<cffunction name="addRank" access="remote" returnType="uuid" roles="forumsadmin" output="false"
				hint="Adds a rank.">
				
		<cfargument name="rank" type="struct" required="true">
		<cfset var newid = createUUID()>
		
		<cfif not validRank(arguments.rank)>
			<cfset variables.utils.throw("RankCFC","Invalid data passed to addRank.")>
		</cfif>
		
		<cfquery datasource="#variables.dsn#">
			insert into #variables.tableprefix#ranks(id,name,minposts)
			values(<cfqueryparam value="#newid#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">,
				   <cfqueryparam value="#arguments.rank.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">,
				   <cfqueryparam value="#arguments.rank.minposts#" cfsqltype="CF_SQL_INTEGER">)
		</cfquery>
		
		<cfreturn newid>
		
	</cffunction>
	
	<cffunction name="deleteRank" access="public" returnType="void" roles="forumsadmin" output="false"
				hint="Deletes a rank.">

		<cfargument name="id" type="uuid" required="true">
						
		<cfquery datasource="#variables.dsn#">
			delete	from #variables.tableprefix#ranks
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>

	<cffunction name="getHighestRank" access="public" returnType="string" output="false"
				hint="For a 'minpost' value, returns the highest rank">
		<cfargument name="minposts" type="numeric" required="true">
		<cfset var qGetRank = "">
		
		<cfquery name="qGetRank" datasource="#variables.dsn#">
		select	
		<cfif variables.dbtype is not "mysql">
				top 1
		</cfif>
		name
		from	#variables.tableprefix#ranks
		where	minposts <= <cfqueryparam value="#arguments.minposts#" cfsqltype="cf_sql_numeric">
		order by minposts desc
		<cfif variables.dbtype is "mysql">
				limit 1
		</cfif>
		</cfquery>
		
		<cfreturn qGetRank.name>
		
	</cffunction>
	
	<cffunction name="getRank" access="remote" returnType="struct" output="false"
				hint="Returns a struct copy of the rank.">
		<cfargument name="id" type="uuid" required="true">
		<cfset var qGetRank = "">
				
		<cfquery name="qGetRank" datasource="#variables.dsn#">
			select	id, name, minposts
			from	#variables.tableprefix#ranks
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>

		<!--- Throw if invalid id passed --->
		<cfif not qGetRank.recordCount>
			<cfset variables.utils.throw("RankCFC","Invalid ID")>
		</cfif>
		
		<cfreturn variables.utils.queryToStruct(qGetRank)>
			
	</cffunction>
		
	<cffunction name="getRanks" access="remote" returnType="query" output="false"
				hint="Returns a list of ranks.">
		<cfset var qGetRanks = "">
				
		<cfquery name="qGetRanks" datasource="#variables.dsn#">
			select	id, name, minposts
			from	#variables.tableprefix#ranks
		</cfquery>
		
		<cfreturn qGetRanks>
			
	</cffunction>
	
	<cffunction name="saveRank" access="remote" returnType="void" roles="forumsadmin" output="false"
				hint="Saves an existing rank.">
				
		<cfargument name="id" type="uuid" required="true">
		<cfargument name="rank" type="struct" required="true">
		
		<cfif not validRank(arguments.rank)>
			<cfset variables.utils.throw("RankCFC","Invalid data passed to saveRank.")>
		</cfif>
		
		<cfquery datasource="#variables.dsn#">
			update	#variables.tableprefix#ranks
			set		name = <cfqueryparam value="#arguments.rank.name#" cfsqltype="CF_SQL_VARCHAR" maxlength="100">,
					minposts = <cfqueryparam value="#arguments.rank.minposts#" cfsqltype="CF_SQL_INTEGER">
			where	id = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_VARCHAR" maxlength="35">
		</cfquery>
		
	</cffunction>
		
	<cffunction name="validRank" access="private" returnType="boolean" output="false"
				hint="Checks a structure to see if it contains all the proper keys/values for a rank.">
		
		<cfargument name="cData" type="struct" required="true">
		<cfset var rList = "name,minposts">
		<cfset var x = "">
		
		<cfloop index="x" list="#rList#">
			<cfif not structKeyExists(cData,x)>
				<cfreturn false>
			</cfif>
		</cfloop>
		
		<cfreturn true>
		
	</cffunction>
</cfcomponent>