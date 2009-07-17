<cfcomponent output="false" extends="Base">
<!--- 
	<cffunction name="setPassword" access="public" returntype="void" output="false" hint="Replaces default setPassword method to MD5 Hash the Password">
		<cfargument name="password" type="string" required="true" />
		<cfset getTransferObject().setPassword(hash(arguments.password)) />
	</cffunction> --->
	
	<cffunction name="getFullName" access="public" returntype="string" output="false">
		<cfset var fullName = getFirstName() & " " & getLastName()>
		<cfreturn fullName>
	</cffunction>
	
</cfcomponent>