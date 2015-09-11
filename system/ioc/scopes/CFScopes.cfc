<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I am a scopes that stores in valid CF scopes

----------------------------------------------------------------------->
<cfcomponent output="false" implements="coldbox.system.ioc.scopes.IScope" hint="I am a scopes that stores in valid CF scopes">

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Configure the scope for operation">
    	<cfargument name="injector" type="any" required="true" hint="The linked WireBox injector" colddoc:generic="coldbox.system.ioc.Injector"/>
    	<cfscript>
			instance = {
				injector	 = arguments.injector,
				scopeStorage = createObject("component","coldbox.system.core.collections.ScopeStorage").init(),
				log			 = arguments.injector.getLogBox().getLogger( this )
			};
			return this;
		</cfscript>
    </cffunction>

	<!--- getFromScope --->
    <cffunction name="getFromScope" output="false" access="public" returntype="any" hint="Retrieve an object from scope or create it if not found in scope">
    	<cfargument name="mapping" 			type="any" required="true" hint="The object mapping: coldbox.system.ioc.config.Mapping" colddoc:generic="coldbox.system.ioc.config.Mapping"/>
		<cfargument name="initArguments" 	type="any" required="false" hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>

		<!--- Scope CacheKey --->
		<cfset var cacheKey = "wirebox:#arguments.mapping.getName()#">
		<!--- CF Scope --->
		<cfset var CFScope  = arguments.mapping.getScope()>
		<cfset var target	= "">

		<!--- Verify in CF Scope --->
		<cfif NOT instance.scopeStorage.exists(cacheKey, CFScope)>
			<!--- Lock it --->
			<cflock name="WireBox.#instance.injector.getInjectorID()#.CFScopes-#CFScope#.#cacheKey#" type="exclusive" timeout="15" throwontimeout="true">
			<cfscript>
				// double lock it
				if( NOT instance.scopeStorage.exists(cacheKey, CFScope) ){
					// some nice debug info.
					if( instance.log.canDebug() ){
						instance.log.debug("Object: (#arguments.mapping.getName()#) not found in CFScope (#CFScope#), beggining construction.");
					}
					// construct the instance
					target = instance.injector.buildInstance( arguments.mapping, arguments.initArguments );

					// If not in wiring thread safety, store in scope to satisfy circular dependencies
					if( NOT arguments.mapping.getThreadSafe() ){
						instance.scopeStorage.put(cacheKey, target, CFScope);
					}

					// wire it
					instance.injector.autowire(target=target,mapping=arguments.mapping);

					// If thread safe, then now store it in the scope, as all dependencies are now safely wired
					if( arguments.mapping.getThreadSafe() ){
						instance.scopeStorage.put(cacheKey, target, CFScope);
					}

					// log it
					if( instance.log.canDebug() ){
						instance.log.debug("Object: (#arguments.mapping.getName()#) constructed and stored in CFScope (#CFScope#), threadSafe=#arguments.mapping.getThreadSafe()#.");
					}

					return target;
				}
			</cfscript>
			</cflock>
		</cfif>

		<!--- return from scope --->
		<cfreturn instance.scopeStorage.get(cacheKey, CFScope)>
    </cffunction>

</cfcomponent>