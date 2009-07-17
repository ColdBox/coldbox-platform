<cfcomponent displayname="User Service" output="false">
<!----------------------------------- CONSTRUCTOR --------------------------------------->	
	
	<cfscript>
		//instance scope
		instance = structnew();
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">
        <cfargument name="transfer" type="any">
			<cfset instance.transfer = arguments.transfer >
		
		<!--- Any constructor code here --->
				
		<cfreturn this>
	</cffunction>

<!----------------------------------- PUBLIC METHODS --------------------------------------->

	<!--- getUser --->
	<cffunction name="getUser" access="public" returntype="any">
		<cfargument name="userId" type="string" required="false" default="0">

		<cfset var user = "">
		<!--- if userID is passed in, get user --->
		<cfif isNumeric(arguments.userId) AND arguments.userId neq 0>
			<cfset user = instance.transfer.get("users.user",arguments.userId)>
		<cfelse>
			<cfset user = instance.transfer.new("users.user")>
		</cfif>		
		<cfreturn user>
	</cffunction>
	
	<!--- getUserByPropertyMap --->
	<cffunction name="getUserByPropertyMap" access="public" returntype="any">
		<cfargument name="propertyMap" type="struct" required="true">
		<cfset var user = instance.transfer.readByPropertyMap("users.user",arguments.propertyMap)>
		
		<cfreturn user>
	</cffunction>

</cfcomponent>