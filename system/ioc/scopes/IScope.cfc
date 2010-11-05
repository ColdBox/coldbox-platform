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
    	<cfargument name="wirebox" type="coldbox.system.ioc.Injector" required="true" hint="The linked injector"/>
    </cffunction>

	<!--- inScope --->
    <cffunction name="inScope" output="false" access="public" returntype="boolean" hint="Verifies if an object mapping is in scope or not">
    	<cfargument name="mapping" type="coldbox.system.ioc.Mapping" required="true" hint="The object mapping"/>
    </cffunction>

	<!--- get --->
    <cffunction name="get" output="false" access="public" returntype="any" hint="Retrieve an object from scope">
    	<cfargument name="mapping" type="coldbox.system.ioc.Mapping" required="true" hint="The object mapping"/>
    </cffunction>

	<!--- store --->
    <cffunction name="store" output="false" access="public" returntype="void" hint="Store an object into this scope">
    	<cfargument name="mapping" 	type="coldbox.system.ioc.Mapping" required="true" hint="The object mapping"/>
		<cfargument name="target" 	type="any" required="true" hint="The target object to store in scope"/>
    </cffunction>
	
</cfinterface>