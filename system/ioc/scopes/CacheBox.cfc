<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I am a scope that talks to CacheBox
	
----------------------------------------------------------------------->
<cfcomponent output="false" implements="coldbox.system.ioc.scopes.IScope" hint="I am a scope that talks to CacheBox">

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Configure the scope for operation">
    	<cfargument name="injector" type="any" required="true" hint="The linked WireBox injector: coldbox.system.ioc.Injector" colddoc:generic="coldbox.system.ioc.Injector"/>
		<cfscript>
			instance = {
				injector	= arguments.injector,
				cacheBox	= arguments.injector.getCacheBox(),
				log			= arguments.injector.getLogBox().getLogger( this )
			};
			return this;
		</cfscript>
    </cffunction>

	<!--- getFromScope --->
    <cffunction name="getFromScope" output="false" access="public" returntype="any" hint="Retrieve an object from scope or create it if not found in scope">
    	<cfargument name="mapping" type="any" required="true" hint="The object mapping: coldbox.system.ioc.config.Mapping" colddoc:generic="coldbox.system.ioc.config.Mapping"/>
		
		<cfset var cacheProperties  = arguments.mapping.getCacheProperties()>
		<cfset var refLocal			= structnew()>
		<cfset var cacheProvider	= instance.cacheBox.getCache( cacheProperties.provider )>
		
		<!--- Get From Cache --->
		<cfset refLocal.target = cacheProvider.get( cacheProperties.key )>
		
		<!--- Verify it --->
		<cfif NOT structKeyExists(refLocal, "target")>
			<!--- Lock it --->
			<cflock name="WireBox.CacheBoxScope.#arguments.mapping.getName()#" type="exclusive" timeout="30" throwontimeout="true">
			<cfscript>
				// double lock it
				if( NOT cacheProvider.lookup( cacheProperties.key ) ){
					// some nice debug info.
					instance.log.debug("Object: (#cacheProperties.toString()#) not found in cacheBox, beginning construction.");
					// construct it and store it, to satisfy circular dependencies
					refLocal.target = instance.injector.constructInstance( arguments.mapping );
					cacheProvider.set(cacheProperties.key, refLocal.target, cacheProperties.timeout, cacheProperties.lastAccessTimeout);
					// wire it
					instance.injector.autowire( refLocal.target );
					// log it
					instance.log.debug("Object: (#cacheProperties.toString()#) constructed and stored in cacheBox.");
					// return it
					return refLocal.target;
				}
			</cfscript>
			</cflock>
		</cfif>
		
		<cfreturn refLocal.target>		
    </cffunction>
	
</cfcomponent>