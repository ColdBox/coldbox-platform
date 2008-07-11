<cfcomponent output="false" extends="Base">

	<cffunction name="getUser" access="public" returntype="any">
		<cfargument name="userId" type="string" required="false" default="0">

		<cfset var user = "">
		<!--- Read user from DB? --->
		<cfif isNumeric(arguments.userId) AND arguments.userId neq 0>
			<cfset user = getTransfer().get("user.User",arguments.userId)>
		<cfelse>
			<cfset user = getTransfer().new("user.User")>
			<cfset user.setUserType( getUserType() )>
		</cfif>		
		<cfreturn user>
	</cffunction>

	<cffunction name="getUserByPropertyMap" access="public" returntype="any">
		<cfargument name="propertyMap" type="struct" required="true">
		<cfset var user = getTransfer().readByPropertyMap("user.User",arguments.propertyMap)>
		<cfreturn user>
	</cffunction>

	<cffunction name="getUsers" access="public" returntype="query">
		<cfset var users = getTransfer().list("user.User")>
		<cfreturn users>
	</cffunction>
		
	<cffunction name="saveUser" access="public" returntype="void">
		<cfargument name="user" type="transfer.com.transferObject" required="true">
		<cfset getTransfer().save(arguments.user)>
	</cffunction>

	<cffunction name="deleteUser" access="public" returntype="void">
		<cfargument name="user" type="transfer.com.transferObject" required="true">
		<cfset getTransfer().delete(arguments.user)>
		<cfset getTransfer().recycle(arguments.user)>
	</cffunction>

	<cffunction name="getUserTypes" access="public" returntype="query">
		<cfset var userTypes = getTransfer().list("user.UserType")>
		<cfreturn userTypes>
	</cffunction>

	<cffunction name="getUserType" access="public" returntype="any">
		<cfargument name="userTypeId" type="string" required="false" default="0">

		<cfset var userType = "">
		<!--- Read user from DB? --->
		<cfif isNumeric(arguments.userTypeId) AND arguments.userTypeId neq 0>
			<cfset userType = getTransfer().get("user.UserType",arguments.userTypeId)>
		<cfelse>
			<cfset userType = getTransfer().new("user.UserType")>
		</cfif>		
		<cfreturn userType>
	</cffunction>	

</cfcomponent>