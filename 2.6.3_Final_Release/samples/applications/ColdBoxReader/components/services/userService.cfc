<cfcomponent name="userService">

	<!--- ******************************************************************************** --->
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<!--- ******************************************************************************** --->
		<cfargument name="usersDAO" required="true" type="any">
		<cfargument name="ModelbasePath" required="true" type="string">
		<cfargument name="ownerEmail" type="string" required="true" hint=""/>
		<!--- ******************************************************************************** --->
		<cfset instance = structnew()>
		<cfset instance.userDAO = arguments.usersDAO>
		<cfset instance.modelBasePath = arguments.ModelBasePath>
		<cfset instance.ownerEmail = arguments.ownerEmail>
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

	<cffunction name="saveUser" access="public" returntype="void">
		<!--- ******************************************************************************** --->
		<cfargument name="userBean" type="any" required="yes">
		<cfargument name="authorize" type="boolean" required="false" default="false" hint="Authorize the user"/>
		<!--- ******************************************************************************** --->
		<cfset var newUserID = CreateUUID()>
		<cfset var qry = "">
		
		<cfif arguments.userBean.getUserID() eq "">
			<cfset arguments.userBean.setUserID(newUserID)>
			<cfset instance.userDAO.create(arguments.userBean)>
		<cfelse>
			<cfset instance.userDAO.update(arguments.userBean)>
		</cfif>
		
		<cfif arguments.authorize>
			<cfset arguments.userBean.setVerified(true)>
		</cfif>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="getUserByUsername" access="public" returntype="void">
		<!--- ******************************************************************************** --->
		<cfargument name="userBean" type="any" required="yes">
		<!--- ******************************************************************************** --->
		<cfset instance.userDAO.getUserByUsername(arguments.userBean)>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="generateNewPassword" access="public" returntype="void">
		<!--- ******************************************************************************** --->
		<cfargument name="userBean"     type="any"    required="yes">
		<!--- ******************************************************************************** --->
		<cfset var newPassword = instance.userDAO.generateNewPass(arguments.userBean.getuserID())>
		
		<cfmail to="#arguments.userBean.getEmail()#" 
				from="#instance.ownerEmail#"
			    subject="ColdBox Reader: Password Generator Reminder">
		This is a password reminder from the ColdBox Reader
		
		Your new password is: #newPassword#
		
		Please change this password as soon as you log in.
		</cfmail>
	</cffunction>

	<!--- ******************************************************************************** --->
	
	<cffunction name="createUserBean" access="public" returntype="any">
		<!--- ******************************************************************************** --->
		<cfreturn CreateObject("component",instance.modelBasePath & ".beans.userBean").init()>
	</cffunction>

	<!--- ******************************************************************************** --->
	
</cfcomponent>