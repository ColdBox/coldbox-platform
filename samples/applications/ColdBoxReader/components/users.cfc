<cfcomponent name="users">

	<!--- ******************************************************************************** --->
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="dsnBean" required="true" type="any">
		<!--- ******************************************************************************** --->
		<cfset instance = structnew()>
		<cfset instance.dsn = arguments.dsnBean.getName()>
		<cfset instance.username = arguments.dsnBean.getUsername()>
		<cfset instance.password = arguments.dsnBean.getPassword()>
		<cfreturn this />
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="checkLogin" access="public" returntype="string">
		<!--- ******************************************************************************** --->
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var rtnVal = "">
		<cfset var qry = "">

		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			SELECT *
				FROM users
				WHERE UserName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#">
					AND Password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(arguments.password)#">
		</cfquery>

		<cfif qry.recordCount gt 0>
			<cfset rtnVal = qry.UserID>
			<cfquery name="update" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
					UPDATE users
					SET LastLogin = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
					WHERE UserID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.userID#">
			</cfquery>
		</cfif>

		<cfreturn rtnVal>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="createUser" access="public" returntype="string">
		<!--- ******************************************************************************** --->
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		<cfargument name="email" 	type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var newUserID = CreateUUID()>
		<cfset var qry = "">
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			INSERT INTO users (UserID, UserName, Password, Email, CreatedOn, LastLogin)
				VALUES (
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#newUserID#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.UserName#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(arguments.Password)#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Email#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
						)
		</cfquery>

		<cfreturn newUserID>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="getUser" access="public" returntype="query">
		<!--- ******************************************************************************** --->
		<cfargument name="userID" type="string" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			SELECT UserID, UserName, Email, LastLogin, CreatedOn
				FROM users
				WHERE UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">
		</cfquery>

		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->
	
</cfcomponent>