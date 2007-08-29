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
	</cfscript>


<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="getcontroller" access="public" output="false" returntype="any" hint="Get controller">
		<cfreturn instance.controller/>
	</cffunction>
	
	<cffunction name="setcontroller" access="public" output="false" returntype="void" hint="Set controller">
		<cfargument name="controller" type="any" required="true"/>
		<cfset instance.controller = arguments.controller/>
	</cffunction>	
	

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>