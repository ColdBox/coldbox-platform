<cfcomponent name="datastore" hint="A security datastore object">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfset variables.instance = structnew()>
	<cfset variables.instance.datastoreFile = Expandpath("model/users.xml.cfm")>
	<cfif server.ColdFusion.ProductName eq "Coldfusion Server">
		<cfset variables.instance.qUsers = queryNew("id,username,password,name","varchar,varchar,varchar,varchar")>
	<cfelse>
		<cfset variables.instance.qUsers = queryNew("id,username,password,name")>
	</cfif>
	<cfset variables.instance.hashType = "SHA">

	<cffunction name="init" access="public" returntype="datastore" output="false">
		<cfset parseXML()>
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="validateUser" access="public" returntype="struct" output="false">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfset var rtnStruct = structnew()>
		<cfset var thePassword = "">
		<cfset rtnStruct.validated = false>
		<cfset rtnStruct.qUser = "">

		<!--- BD --->
		<cfif server.ColdFusion.ProductName eq "Coldfusion Server">
			<cfset thePassword = hash(arguments.password,'SHA')>
		<cfelse>
			<cfset thePassword = hash(arguments.password)>
		</cfif>
		<!--- Validate a user --->
		<cfquery name="rtnStruct.qUser" dbtype="query">
		select *
		from instance.qUsers
		where username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#"> and
			  password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#thePassword#">
		</cfquery>
		<cfif rtnStruct.qUser.recordcount>
			<cfset rtnStruct.validated = true>
		</cfif>
		<cfreturn rtnStruct>
	</cffunction>

	<cffunction name="getUsers" access="public" returntype="query" output="false">
		<cfreturn instance.qUsers>
	</cffunction>

	<cffunction name="getInstance" access="public" returntype="struct" output="false">
		<cfreturn instance>
	</cffunction>

<!------------------------------------------- PRIVATE METHODS ------------------------------------------->

	<cffunction name="parseXML" access="private" returntype="any" output="false">
		<cfset var FileContents = "">
		<cfset var aUsers = ArrayNew(1)>
		<cfset var i = 0>
		<cffile action="read" file="#instance.datastoreFile#" variable="FileContents">
		<cfset aUsers = XMLParse(FileContents).xmlroot.XMLChildren>

		<cfloop from="1" to="#arrayLen(aUsers)#" index="i">
			<cfset QueryAddRow(instance.qUsers,1)>
			<cfset QuerySetCell(instance.qUsers,"id", trim(aUsers[i].XMLAttributes["id"]))>
			<cfset QuerySetCell(instance.qUsers,"username", trim(aUsers[i].XMLAttributes["username"]))>
			<cfset QuerySetCell(instance.qUsers,"password", trim(aUsers[i].XMLAttributes["password"]))>
			<cfset QuerySetCell(instance.qUsers,"name", trim(aUsers[i].XMLAttributes["name"]))>
		</cfloop>
	</cffunction>

</cfcomponent>