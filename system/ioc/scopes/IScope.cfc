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
    <cffunction name="configure" output="false" access="public" returntype="void" hint="Configure the scope for operation">
    	<cfargument name="wirebox" type="any" required="true" hint="The linked WireBox injector" colddoc:generic="coldbox.system.ioc.Injector"/>
    </cffunction>

	<!--- getFromScope --->
    <cffunction name="getFromScope" output="false" access="public" returntype="any" hint="Retrieve an object from scope or create it if not found in scope">
    	<cfargument name="mapping" type="any" required="true" hint="The object mapping" colddoc:generic="coldbox.system.ioc.config.Mapping"/>
    </cffunction>
	
</cfinterface>