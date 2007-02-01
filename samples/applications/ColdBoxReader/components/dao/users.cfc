<cfcomponent name="users" extends="basedao" output="false">

	<!--- ******************************************************************************** --->
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="dsnBean" required="true" type="coldbox.system.beans.datasourceBean">
		<!--- ******************************************************************************** --->
		<cfset super.init(arguments.dsnBean)>
		<cfset setTablename("coldboxreader_users")>
		<cfset setIDFieldName("UserID")>
		<cfset setFieldNameList("*")>
		<cfreturn this />
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="getUserbyCredentials" access="public" returntype="query" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="userBean" type="any" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">

		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			SELECT *
				FROM coldboxreader_users
				WHERE UserName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userBean.getusername()#">
					AND Password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(arguments.userBean.getPassword())#">
		</cfquery>
		
		<cfif qry.recordcount>
			<cfscript>
			arguments.userBean.setEmail(qry.email);
			arguments.userBean.setUserID(qry.UserID);
			arguments.userBean.setCreatedOn(qry.CreatedOn);
			arguments.userBean.setLastLogin(qry.LastLogin);
			</cfscript>
		</cfif>
		<cfreturn qry>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="create" access="public" returntype="void" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="userBean" type="any" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
	
		<cfscript>
		arguments.userBean.setCreatedOn(now());
		arguments.userBean.setLastLogin(now());
		</cfscript>
			
		<cfquery name="qry" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			INSERT INTO #instance.TableName# (UserID, UserName, Password, Email, CreatedOn, LastLogin)
				VALUES (
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userBean.getUserID()#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userBean.getUserName()#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(arguments.userBean.getPassword())#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userBean.getEmail()#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.userBean.getCreatedOn()#">,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.userBean.getLastLogin()#">
						)
		</cfquery>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="updateLastLogin" access="public" returntype="void" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="userBean" type="any" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qry = "">
		<cfquery name="update" datasource="#instance.dsn#" username="#instance.username#" password="#instance.password#">
			UPDATE #Instance.TableName#
			SET LastLogin = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
			WHERE #instance.IDFieldName# =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userBean.getuserID()#">
		</cfquery>
	</cffunction>

	<!--- ******************************************************************************** --->
	
</cfcomponent>