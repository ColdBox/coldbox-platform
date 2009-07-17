<cfcomponent displayname="SecurityService" output="false">

<!----------------------------------- CONSTRUCTOR --------------------------------------->	
	
	<cfscript>
		//instance scope
		instance = structnew();
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">
        <cfargument name="Transfer" type="any">
		<cfargument name="UserService" type="any">
			<cfset instance.transfer = arguments.transfer >
			<cfset instance.UserService = arguments.UserService>
		<!--- Any constructor code here --->
				
		<cfreturn this>
	</cffunction>

<!----------------------------------- PUBLIC METHODS --------------------------------------->

	<!--- userValidator --->
	<cffunction name="userValidator" access="public" returntype="boolean" output="false" hint="Mandatory method for security interceptor">
        <cfargument name="rule" required="true" type="struct"  hint="The rule to verify">

        <cfset var isAllowed = false>
		<cfset var user = getUserSession()>
		<cfset var currentPermission = ''>
         
		<!--- Check if we have a user in session --->
		<cfif isStruct(user)>
		
			<!--- Check if the user has the right role --->
			<cfif ListFindNoCase(arguments.rule['roles'],user.getUserType())>
				<cfset isAllowed = true>
			</cfif>
		
		</cfif> 
		
        <cfreturn isAllowed>
	</cffunction>
	
	<!--- getUserSession --->
	<cffunction name="getUserSession" access="public" output="false" returntype="any">
		<cfset var user = ''>
		
		<!--- Read user from session if exists --->
		<cflock timeout="30" type="READONLY" scope="SESSION">
			<cfif isDefined("session.user")>
				<cfset user = session.user>
			</cfif>
		</cflock>
		
		<cfreturn user>
	</cffunction>
	
	<!--- setUserSession --->
	<cffunction name="setUserSession" access="public" output="false" returntype="void">
		<cfargument name="user" required="yes" type="any" hint="transfer object">
		
		<!--- set session objects --->
		<cflock scope="SESSION" type="EXCLUSIVE" timeout="30">
			<cfset session.user = arguments.user>
		</cflock>
				
	</cffunction>
	
	<!--- deleteUserSession --->
	<cffunction name="deleteUserSession" access="public" output="false" returntype="void">
		
		<!--- Lock session to read and/or delete user object --->
		<cflock scope="SESSION" type="EXCLUSIVE" timeout="30">
			<cfif isDefined("session.user")>
				<!--- Delete user from session --->
				<cfset StructDelete(session, "user")> 
			</cfif>
		</cflock>
		
	</cffunction>


	<!--- isUserVerified --->
	<cffunction name="isUserVerified" access="public" output="yes" returntype="boolean">
		<cfargument name="username" required="yes" type="string">
		<cfargument name="password" required="yes" type="string">
			
			<cfset var user = instance.UserService.getUserByPropertyMap(arguments)>	
	        <cfset var isUserVerified = false>
			
			<!--- Check if we found a user --->
			<cfif isNumeric( user.getUser_id() ) AND user.getUser_id() neq 0>
				<!--- VERIFIED --->
	        	<cfset isUserVerified = true>
				<!--- set user session object --->
				<cfset setUserSession(user)>
			</cfif>
			
			<cfreturn isUserVerified>
		</cffunction>	

</cfcomponent>