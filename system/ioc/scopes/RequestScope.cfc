<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I am an awesome request scope

----------------------------------------------------------------------->
<cfcomponent output="false" implements="coldbox.system.ioc.scopes.IScope" hint="I am an awesome request scope">

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Configure the scope for operation">
    	<cfargument name="injector" type="any" required="true" hint="The linked WireBox injector" colddoc:generic="coldbox.system.ioc.Injector"/>
    	<cfscript>
			instance = {
				injector	 = arguments.injector,
				log			 = arguments.injector.getLogBox().getLogger( this )
			};
			return this;
		</cfscript>
    </cffunction>

	<!--- getFromScope --->
    <cffunction name="getFromScope" output="false" access="public" returntype="any" hint="Retrieve an object from scope or create it if not found in scope">
    	<cfargument name="mapping" 			type="any" required="true" hint="The object mapping: coldbox.system.ioc.config.Mapping" colddoc:generic="coldbox.system.ioc.config.Mapping"/>
		<cfargument name="initArguments" 	type="any" required="false" hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfscript>
			var cacheKey = "wirebox:#arguments.mapping.getName()#";
			var target	= "";

			// Check if already in request scope
			if( NOT structKeyExists(request, cacheKey) ){
				// some nice debug info.
				if( instance.log.canDebug() ){
					instance.log.debug("Object: (#arguments.mapping.getName()#) not found in request scope, beggining construction.");
				}
				// construct it and store it, to satisfy circular dependencies
				target = instance.injector.buildInstance( arguments.mapping, arguments.initArguments );
				request[ cacheKey ] = target;
				// wire it
				instance.injector.autowire(target=target,mapping=arguments.mapping);
				// log it
				if( instance.log.canDebug() ){
					instance.log.debug("Object: (#arguments.mapping.getName()#) constructed and stored in Request scope.");
				}
				return target;
			}

			return request[ cacheKey ];
		</cfscript>
    </cffunction>

</cfcomponent>