<cfcomponent extends="dataStore">

	<cffunction name="checkLogin" access="public" returntype="string">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">

		<cfset var rtnVal = "">

		<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
			SELECT *
				FROM users
				WHERE UserName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.username#">
					AND Password = Password(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.password#">)
		</cfquery>

		<cfif qry.recordCount gt 0>
			<cfset rtnVal = qry.UserID>
			<cfquery name="update" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
					UPDATE users
					SET LastLogin = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
					WHERE UserID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#qry.userID#">
			</cfquery>
		</cfif>

		<cfreturn rtnVal>
	</cffunction>

	<cffunction name="createUser" access="public" returntype="string">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		<cfargument name="email" type="string" required="yes">
		<cfset var newUserID = CreateUUID()>

		<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
			INSERT INTO users (UserID, UserName, Password, Email, CreatedOn, LastLogin)
				VALUES (
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#newUserID#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.UserName#">,
						Password(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Password#">),
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Email#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
						)
		</cfquery>

		<cfreturn newUserID>
	</cffunction>

	<cffunction name="getUser" access="public" returntype="query">
		<cfargument name="userID" type="string" required="yes">

		<cfquery name="qry" datasource="#this.datasource#" username="#this.username#" password="#this.password#">
			SELECT UserID, UserName, Email, LastLogin, CreatedOn
				FROM users
				WHERE UserID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">
		</cfquery>

		<cfreturn qry>
	</cffunction>


</cfcomponent>