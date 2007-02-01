<cfcomponent name="userService">

	<!--- ******************************************************************************** --->
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="usersDAO" required="true" type="any">
		<cfargument name="ModelbasePath" required="true" type="string">
		<!--- ******************************************************************************** --->
		<cfset instance = structnew()>
		<cfset instance.userDAO = arguments.usersDAO>
		<cfset instance.modelBasePath = arguments.ModelBasePath>
		<cfreturn this />
	</cffunction>
	
	<!--- ******************************************************************************** --->
	
	<cffunction name="checkLogin" access="public" returntype="void">
		<!--- ******************************************************************************** --->
		<cfargument name="userBean" type="any" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var qCredentials = "">

		<!--- Verify if username/pass is correct --->
		<cfset qCredentials = instance.userDAO.getUserbyCredentials(arguments.userBean)>
		
		<cfif qCredentials.recordCount gt 0>
			<cfset arguments.userBean.setVerified(true)>
			<cfset instance.userDAO.updateLastLogin(arguments.userBean)>
		<cfelse>
			<cfset arguments.userBean.setVerified(false)>
		</cfif>
	</cffunction>

	<!--- ******************************************************************************** --->

	<cffunction name="createUser" access="public" returntype="void">
		<!--- ******************************************************************************** --->
		<cfargument name="userBean" type="any" required="yes">
		<!--- ******************************************************************************** --->
		<cfset var newUserID = CreateUUID()>
		<cfset var qry = "">
		
		<cfset arguments.userBean.setUserID(newUserID)>
		<cfset instance.userDAO.create(arguments.userBean)>
		
	</cffunction>


	<!--- ******************************************************************************** --->
	
	<cffunction name="createUserBean" access="public" returntype="any">
		<!--- ******************************************************************************** --->
		<cfreturn CreateObject("component",instance.modelBasePath & ".beans.userBean").init()>
	</cffunction>

	<!--- ******************************************************************************** --->
	
</cfcomponent>