<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date         :	August 25, 2007
Description :
	This is a base coldbox service. All services built for coldbox will
	be based on this taxonomy.

Modification History:
08/25/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="baseService" hint="A ColdBox base internal service" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		variables.instance = structnew();
		variables.controller = structnew();
	</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="getcontroller" access="package" output="false" returntype="any" hint="Get controller">
		<cfreturn controller/>
	</cffunction>
	
	<cffunction name="setcontroller" access="package" output="false" returntype="void" hint="Set controller">
		<cfargument name="controller" type="any" required="true"/>
		<cfset variables.controller = arguments.controller/>
	</cffunction>	
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.util.util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.util.util")/>
	</cffunction>
	
</cfcomponent>