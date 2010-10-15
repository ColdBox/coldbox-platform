<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main interface to produce WireBox namespace DSL processors
	
----------------------------------------------------------------------->
<cfinterface hint="The main interface to produce WireBox namespace DSL processors">

	<!--- process --->
    <cffunction name="process" output="false" access="public" returntype="any" hint="Process an incoming DSL definition and produce an object with it.">
		<cfargument name="injectDSL" type="string" required="true" hint="The injection dsl string to process"/>    	
    </cffunction>
	
</cfinterface>