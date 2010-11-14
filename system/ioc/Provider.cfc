<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A WireBox provider object that retrieves objects by using the provider pattern.
	
----------------------------------------------------------------------->
<cfcomponent hint="A WireBox provider object that retrieves objects by using the provider pattern." output="false">
	
	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="Provider" hint="Constructor">
    	<cfargument name="wireBox" 	type="coldbox.system.ioc.Injector" required="true" hint="The injector linkage of this provider"/>
		<cfargument name="name" 	type="string" required="true" hint="The name of the mapping this provider is binded to"/>
		<cfscript>
			instance = {
				name 	= arguments.name,
				wirebox = arguments.wirebox
			};
		</cfscript>
    </cffunction>

	<!--- get --->
    <cffunction name="get" output="false" access="public" returntype="any" hint="Get the provided object">
    	<cfreturn instance.wirebox.getInstance( instance.name )>
    </cffunction>

</cfcomponent>