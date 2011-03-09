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
    	<cfargument name="injector" required="true" hint="The injector linkage of this provider" colddoc:generic="coldbox.system.ioc.Injector"/>
		<cfargument name="name" 	required="true" hint="The name of the mapping this provider is binded to"/>
		<cfscript>
			instance = {
				name 		= arguments.name,
				injector 	= arguments.injector
			};
			return this;
		</cfscript>
    </cffunction>

	<!--- get --->
    <cffunction name="get" output="false" access="public" returntype="any" hint="Get the provided object">
    	<cfreturn instance.injector.locateScopedSelf().getInstance( instance.name )>
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