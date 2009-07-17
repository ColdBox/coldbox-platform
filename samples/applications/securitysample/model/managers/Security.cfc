<cfcomponent output="false" extends="Base">
	
	<cffunction name="userValidator" access="public" returntype="boolean" output="false" hint="Mandatory method for security interceptor">
        <cfargument name="rule" required="true" type="struct"  hint="The rule to verify">

        <cfset var isAllowed = false>
		<cfset var user = getUserSession()>
		<cfset var currentPermission = ''>
         
		<!--- Check if we have a user in session --->
		<cfif isStruct(user)>
		
			<!--- Check if the user has the right role --->
			<cfif ListFindNoCase(arguments.rule['roles'],user.getUserType().getName())>
				<cfset isAllowed = true>
			</cfif>

	        <!--- Loop Over Permissions --->
			<!--- 
			<cfloop list="#arguments.rule['permissions']#" index="currentPermission">
		        <cfif ListFindNoCase(user.permissions,currentPermission) >
	                <cfset isAllowed = true>
					Allowed so exit loop
	                <cfbreak>
		        </cfif>
	        </cfloop>
			 --->
		
		</cfif> 
		
        <cfreturn isAllowed>
	</cffunction>
	
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
	
	<cffunction name="setUserSession" access="public" output="false" returntype="void">
		<cfargument name="user" required="yes" type="any" hint="transfer object">
		
		<!--- set session objects --->
		<cflock scope="SESSION" type="EXCLUSIVE" timeout="30">
			<cfset session.user = arguments.user>
		</cflock>
				
	</cffunction>

	<cffunction name="isUserVerified" access="public" output="yes" returntype="boolean">
		<cfargument name="email" required="yes" type="string">
		<cfargument name="password" required="yes" type="string">
		
		<cfset var user = getManager("User").getUserByPropertyMap(arguments)>	
        <cfset var isUserVerified = false>
		
		<!--- Check if we found a user --->
		<cfif isNumeric( user.getUserId() ) AND user.getUserId() neq 0>
			<!--- VERIFIED --->
        	<cfset isUserVerified = true>
			<!--- set user session object --->
			<cfset setUserSession(user)>
		</cfif>
		
		<cfreturn isUserVerified>
	</cffunction>	

	<cffunction name="deleteUserSession" access="public" output="false" returntype="void">
		
		<!--- Lock session to read and/or delete user object --->
		<cflock scope="SESSION" type="EXCLUSIVE" timeout="30">
			<cfif isDefined("session.user")>
				<!--- Delete user from session --->
				<cfset StructDelete(session, "user")> 
			</cfif>
		</cflock>
		
	</cffunction>
		
</cfcomponent>	