<cfcomponent>

	<cfproperty name="coolPizza" inject="provider:pizza" scope="this">

	<cfproperty name="providedLogger" inject="provider:logbox:logger:{this}" scope="this">
	<cfproperty name="mappingProvidedByID" inject="provider:myLogBoxID" scope="this">
	<cfproperty name="providedMappingByID" inject="myProvidedLogBoxID" scope="this">
	<cfproperty name="whatTheHeck" inject="provider:provider:provider:provider:provider:provider:provider:provider:logbox:logger:{this}" scope="this">

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any">
    	<cfreturn this>
    </cffunction>
	
	<cffunction name="getPizza" output="false" returntype="any" access="public" provider="pizza">
	</cffunction>
 
	<cffunction name="getMyLogger" output="false" returntype="any" access="public" provider="logBox:logger:{this}">
	</cffunction>
	
</cfcomponent>