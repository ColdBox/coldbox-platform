<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I am the singleton scope
	
----------------------------------------------------------------------->
<cfcomponent output="false" implements="coldbox.system.ioc.scopes.IScope" hint="I am the singleton scope">

	<!--- configure --->
    <cffunction name="configure" output="false" access="public" returntype="void" hint="Configure your scope for operation">
    	<cfargument name="wirebox" type="any" required="true" hint="The linked WireBox injector: coldbox.system.ioc.Injector" colddoc:generic="coldbox.system.ioc.Injector"/>
		<cfscript>
			instance = {
				wirebox		= arguments.wirebox,
				singletons 	= {},
				log			= arguments.wireBox.getLogBox().getLogger( this )
			};
		</cfscript>
    </cffunction>

	<!--- getFromScope --->
    <cffunction name="getFromScope" output="false" access="public" returntype="any" hint="Retrieve an object from scope or create it if not found in scope">
    	<cfargument name="mapping" type="any" required="true" hint="The object mapping: coldbox.system.ioc.config.Mapping" colddoc:generic="coldbox.system.ioc.config.Mapping"/>
		
		<cfset var cacheKey = arguments.mapping.getName()>
		
		<!--- Verify in Cache --->
		<cfif NOT structKeyExists(instance.singletons, cacheKey)>
			<!--- Lock it --->
			<cflock name="WireBox.Singleton.#cacheKey#" type="exclusive" timeout="30" throwontimeout="true">
			<cfscript>
				// double lock it
				if( NOT structKeyExists(instance.singletons, cacheKey) ){
					// some nice debug info.
					instance.log.debug("Object: (#cacheKey#) not found in singleton cache, beggining construction.");
					// construct it and store it, to satisfy circular dependencies
					instance.singletons[cacheKey] = instance.wirebox.constructInstance( arguments.mapping );
					// wire it
					instance.wirebox.autowire( instance.instance.singletons[cacheKey] );
					// log it
					instance.log.debug("Object: (#cacheKey#) constructed and stored in singleton cache.");
					// return it
					return instance.singletons[cacheKey];
				}
			</cfscript>
			</cflock>
		</cfif>
		
		<!--- return singleton --->
		<cfreturn instance.singletons[cacheKey]>	
    </cffunction>
	
	<!--- getSingletons --->
    <cffunction name="getSingletons" output="false" access="public" returntype="struct" hint="Get all singletons">
    	<cfreturn instance.singletons>
    </cffunction>
	
</cfcomponent>