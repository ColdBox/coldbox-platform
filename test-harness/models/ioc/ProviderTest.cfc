<cfcomponent>

	<cfproperty name="coolPizza" inject="provider:pizza" scope="this">

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any">
    	<cfreturn this>
    </cffunction>
	
	<cffunction name="getPizza" output="false" returntype="any" access="public" provider="pizza">
	</cffunction>
 
</cfcomponent>