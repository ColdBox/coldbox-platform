<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	An interface that enables any CFC to act like a parent injector within WireBox.
	
----------------------------------------------------------------------->
<cfinterface hint="An interface that enables any CFC to act like a parent injector within WireBox">
	
	<!--- setParent --->
    <cffunction name="setParent" output="false" access="public" returntype="void" hint="Link a parent Injector with this injector">
    	<cfargument name="injector" required="true" hint="A WireBox Injector to assign as a parent to this Injector" colddoc:generic="coldbox.system.ioc.Injector">
    </cffunction>
	
	<!--- getParent --->
    <cffunction name="getParent" output="false" access="public" returntype="any" hint="Get a reference to the parent injector instance, else an empty simple string meaning nothing is set" colddoc:generic="coldbox.system.ioc.Injector">
    </cffunction>
	
	<!--- getInstance --->
    <cffunction name="getInstance" output="false" access="public" returntype="any" hint="Locates, Creates, Injects and Configures an object model instance">
    	<cfargument name="name" 			required="false" 	hint="The mapping name or CFC instance path to try to build up"/>
		<cfargument name="dsl"				required="false" 	hint="The dsl string to use to retrieve the instance model object, mutually exclusive with 'name'"/>
		<cfargument name="initArguments" 	required="false" 	hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfargument name="targetObject" 	required="false"	default="" 	hint="The object requesting the dependency, usually only used by DSL lookups"/>
	</cffunction>
	
	<!--- containsInstance --->
    <cffunction name="containsInstance" output="false" access="public" returntype="any" hint="Checks if this injector can locate a model instance or not" colddoc:generic="boolean">
    	<cfargument name="name" required="true" hint="The object name or alias to search for if this container can locate it or has knowledge of it"/>
    </cffunction>

	<!--- shutdown --->
    <cffunction name="shutdown" output="false" access="public" returntype="void" hint="Shutdown the injector gracefully by calling the shutdown events internally.">
    </cffunction>
	
</cfinterface>