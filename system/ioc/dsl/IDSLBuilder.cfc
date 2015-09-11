<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The main interface to produce WireBox namespace DSL Builders
	
----------------------------------------------------------------------->
<cfinterface hint="The main interface to produce WireBox namespace DSL Builders">

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Configure the DSL Builder for operation and returns itself" colddoc:generic="coldbox.system.ioc.dsl.IDSLBuilder">
    	<cfargument name="injector" type="any" required="true" hint="The linked WireBox injector" colddoc:generic="coldbox.system.ioc.Injector"/>
    </cffunction>
	
	<!--- process --->
    <cffunction name="process" output="false" access="public" returntype="any" hint="Process an incoming DSL definition and produce an object with it.">
		<cfargument name="definition" 	required="true"  hint="The injection dsl definition structure to process. Keys: name, dsl"/>  
		<cfargument name="targetObject" required="false" hint="The target object we are building the DSL dependency for. If empty, means we are just requesting building"/>
		  	
    </cffunction>
	
</cfinterface>