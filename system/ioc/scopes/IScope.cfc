<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main interface to produce WireBox storage scopes
	
----------------------------------------------------------------------->
<cfinterface hint="The main interface to produce WireBox storage scopes">

	<!--- configure --->
    <cffunction name="configure" output="false" access="public" returntype="void" hint="Configure your scope for operation">
    	<cfargument name="wirebox" type="coldbox.system.ioc.Injector" required="true" hint="The linked WireBox injector"/>
    </cffunction>

	<!--- getFromScope --->
    <cffunction name="getFromScope" output="false" access="public" returntype="any" hint="Retrieve an object from scope or create it if not found in scope">
    	<cfargument name="mapping" type="coldbox.system.ioc.Mapping" required="true" hint="The object mapping"/>
    </cffunction>
	
</cfinterface>