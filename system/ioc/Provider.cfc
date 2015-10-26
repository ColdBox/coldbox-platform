<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A WireBox provider object that retrieves objects by using the provider pattern.
	
----------------------------------------------------------------------->
<cfcomponent implements="coldbox.system.ioc.IProvider" hint="A WireBox provider object that retrieves objects by using the provider pattern." output="false">
	
	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="Provider" hint="Constructor">
    	<cfargument name="scopeRegistration" required="true" 	hint="The injector scope registration structure" colddoc:generic="struct"/>
		<cfargument name="scopeStorage" 	 required="true" 	hint="The scope storage utility" 				  colddoc:generic="coldbox.system.core.collections.ScopeStorage"/>
		<cfargument name="name" 			 required="false" 	hint="The name of the mapping this provider is binded to, MUTEX with name"/>
		<cfargument name="dsl"				 required="false" 	hint="The DSL string this provider is binded to, MUTEX with name"/>
		<cfargument name="targetObject"		 required="true" 	hint="The target object that requested the provider."/>
		<cfscript>
			instance = {
				name = "",
				dsl  = "",
				scopeRegistration 	= arguments.scopeRegistration,
				scopeStorage 		= arguments.scopeStorage,
				targetObject		= arguments.targetObject
			};
			
			// Verify incoming name or DSL
			if( structKeyExists( arguments, "name" ) ){ instance.name = arguments.name; }
			if( structKeyExists( arguments, "dsl" ) ){ instance.dsl = arguments.dsl; }
			
			return this;
		</cfscript>
    </cffunction>

	<!--- get --->
    <cffunction name="get" output="false" access="public" returntype="any" hint="Get the provided object">
    	<cfscript>
    		var scopeInfo = instance.scopeRegistration;
			
    		// Return if scope exists, else throw exception
			if( instance.scopeStorage.exists(scopeInfo.key, scopeInfo.scope) ){
				// retrieve by name or DSL
				if( len( instance.name ) )
					return instance.scopeStorage.get( scopeInfo.key, scopeInfo.scope ).getInstance( name=instance.name, targetObject=instance.targetObject );
				if( len( instance.dsl ) )
					return instance.scopeStorage.get( scopeInfo.key, scopeInfo.scope ).getInstance( dsl=instance.dsl, targetObject=instance.targetObject );
			}
		</cfscript>
    		
		<cfthrow type="Provider.InjectorNotOnScope" message="Injector not found in scope registration information" detail="Scope information: #scopeInfo.toString()#">
    </cffunction>
	
	<!--- onMissingMethod Proxy --->
    <cffunction name="onMissingMethod" output="false" access="public" returntype="any" hint="Proxy calls to provided element">
    	<cfargument	name="missingMethodName"		required="true"	hint="missing method name"	/>
		<cfargument	name="missingMethodArguments" 	required="true"	hint="missing method arguments"/>
    	
		<cfset var refLocal = structnew()>
		
		<cfinvoke component="#get()#"
				  method="#arguments.missingMethodName#"
				  argumentcollection="#arguments.missingmethodArguments#" returnvariable="refLocal.results">
				  
		<cfif structKeyExists(refLocal,"results")>
			<cfreturn refLocal.results>
		</cfif>		
    </cffunction>

</cfcomponent>