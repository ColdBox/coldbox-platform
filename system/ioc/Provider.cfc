<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A WireBox provider object that retrieves objects by using the provider pattern.
	
----------------------------------------------------------------------->
<cfcomponent implements="coldbox.system.ioc.IProvider" hint="A WireBox provider object that retrieves objects by using the provider pattern." output="false">
	
	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="Provider" hint="Constructor">
    	<cfargument name="scopeRegistration" required="true" hint="The injector scope registration structure" colddoc:generic="struct"/>
		<cfargument name="scopeStorage" 	 required="true" hint="The scope storage utility" 				  colddoc:generic="coldbox.system.core.collections.ScopeStorage"/>
		<cfargument name="name" 			 required="true" hint="The name of the mapping this provider is binded to"/>
		<cfscript>
			instance = {
				name 				= arguments.name,
				scopeRegistration 	= arguments.scopeRegistration,
				scopeStorage 		= arguments.scopeStorage
			};
			return this;
		</cfscript>
    </cffunction>

	<!--- get --->
    <cffunction name="get" output="false" access="public" returntype="any" hint="Get the provided object">
    	<cfscript>
    		var scopeInfo = instance.scopeRegistration;
			
    		// Return if it exists, else throw exception
			if( instance.scopeStorage.exists(scopeInfo.key, scopeInfo.scope) ){
				return instance.scopeStorage.get(scopeInfo.key, scopeInfo.scope).getInstance( instance.name );
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