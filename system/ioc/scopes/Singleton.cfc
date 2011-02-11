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
	
	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Configure the scope for operation">
    	<cfargument name="injector" type="any" required="true" hint="The linked WireBox injector: coldbox.system.ioc.Injector" colddoc:generic="coldbox.system.ioc.Injector"/>
		<cfscript>
			instance = {
				injector	= arguments.injector,
				singletons 	= createObject("java","java.util.concurrent.ConcurrentHashMap").init(),
				log			= arguments.injector.getLogBox().getLogger( this )
			};
			return this;
		</cfscript>
    </cffunction>

	<!--- getFromScope --->
    <cffunction name="getFromScope" output="false" access="public" returntype="any" hint="Retrieve an object from scope or create it if not found in scope">
    	<cfargument name="mapping" 			type="any" required="true" hint="The object mapping: coldbox.system.ioc.config.Mapping" colddoc:generic="coldbox.system.ioc.config.Mapping"/>
		<cfargument name="initArguments" 	type="any" required="false" hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		
		<cfset var cacheKey = lcase(arguments.mapping.getName())>
		
		<!--- Verify in Cache --->
		<cfif NOT structKeyExists(instance.singletons, cacheKey)>
			<!--- Lock it --->
			<cflock name="WireBox.Singleton.#cacheKey#" type="exclusive" timeout="30" throwontimeout="true">
			<cfscript>
				// double lock it
				if( NOT structKeyExists(instance.singletons, cacheKey) ){
					// some nice debug info.
					if( instance.log.canDebug() ){
						instance.log.debug("Object: (#cacheKey#) not found in singleton cache, beggining construction.");
					}
					// construct it and store it, to satisfy circular dependencies
					instance.singletons[cacheKey] = instance.injector.buildInstance( arguments.mapping, arguments.initArguments);
					// wire it
					instance.injector.autowire(target=instance.singletons[cacheKey],mapping=arguments.mapping);
					// log it
					if( instance.log.canDebug() ){
						instance.log.debug("Object: (#cacheKey#) constructed and stored in singleton cache.");
					}
					// return it
					return instance.singletons[cacheKey];
				}
			</cfscript>
			</cflock>
		</cfif>
		
		<!--- return singleton --->
		<cfreturn instance.singletons[cacheKey]>	
    </cffunction>
	
	<!--- clear --->
    <cffunction name="clear" output="false" access="public" returntype="void" hint="Clear the singletons scope">
    	<cfset instance.singletons.clear()>
    </cffunction>
	
	<!--- getSingletons --->
    <cffunction name="getSingletons" output="false" access="public" returntype="any" hint="Get all singletons structure" colddoc:generic="java.util.concurrent.ConcurrentHashMap">
    	<cfreturn instance.singletons>
    </cffunction>
	
</cfcomponent>