<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	The base interceptor class
----------------------------------------------------------------------->
<cfcomponent name="interceptor"
			 hint="This is the base Interceptor class"
			 output="false"
			 extends="frameworkSupertype">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" type="any" 	required="true"  hint="The ColdBox controller reference: coldbox.system.controller">
		<cfargument name="properties" type="struct" required="true"  hint="The Interceptor properties">
		<cfscript>
			/* Register Controller */
			setController(arguments.controller);
			/* Register properties */
			setProperties(arguments.properties);
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Configure the interceptor --->
	<cffunction name="Configure" access="public" returntype="void" hint="This is the configuration method for your interceptors. THIS IS EXECUTED BEFORE THE ASPECTS ARE LOADED." output="false" >
		<!--- Implemented by Concrete classes: --->
	</cffunction>
	
	<!--- getter for the properties structure --->
	<cffunction name="getproperties" access="public" output="false" returntype="struct" hint="Get properties">
		<cfreturn instance.properties/>
	</cffunction>
	
	<!--- setter for the properties structure --->
	<cffunction name="setproperties" access="public" output="false" returntype="void" hint="Set properties">
		<cfargument name="properties" type="struct" required="true"/>
		<cfset instance.properties = arguments.properties/>
	</cffunction>
	
	<!--- get a property --->
	<cffunction name="getProperty" access="public" returntype="any" hint="Get a property, throws exception if not found." output="false" >
		<cfargument name="property" required="true" type="string" hint="The key of the property to return.">
		<cfreturn instance.properties[arguments.property]>
	</cffunction>
	
	<!--- set a property --->
	<cffunction name="setProperty" access="public" returntype="void" hint="Set a property" output="false" >
		<cfargument name="property" required="true" type="string" 	hint="The property name to set.">
		<cfargument name="value" 	required="true" type="any" 		hint="The value of the property.">
		<cfset instance.properties[arguments.property] = arguments.value>
	</cffunction>
	
	<!--- check for a property --->
	<cffunction name="propertyExists" access="public" returntype="boolean" hint="Checks wether a given property exists or not." output="false" >
		<cfargument name="property" required="true" type="string" hint="The property name">
		<cfreturn structKeyExists(instance.properties,arguments.property)>		
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<!--- After Configuration Load --->
	<cffunction name="afterConfigurationLoad" access="public" returntype="void" hint="Executes after the framework and application configuration loads, but before the aspects get configured. " output="false" >
		<cfargument name="event" 	required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
	
	<!--- After Aspects Load --->
	<cffunction name="afterAspectsLoad" access="public" returntype="void" hint="Executes after the application aspects get configured." output="false" >
		<cfargument name="event" 	required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
	
	<!--- After Handler Creation --->
	<cffunction name="afterHandlerCreation" access="public" returntype="void" output="false" hint="Executes after any handler gets created." >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted data = [handlerPath (The path of the handler), oHandler (The actual handler object)]">
		<!--- ************************************************************* --->
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
		
	<!--- After Plugin Creation --->
	<cffunction name="afterPluginCreation" access="public" returntype="void" output="false" hint="Executes after any plugin gets created." >
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted data = [pluginPath (The path of the plugin), custom (Flag if the plugin is custom or not), oPlugin (The actual plugin object)]">
		<!--- ************************************************************* --->
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
	
	<!--- Session Start --->
	<cffunction name="sessionStart" access="public" returntype="void" hint="Executes on Session start" output="false" >
		<cfargument name="event" 	required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information. THE SESSION SCOPE">
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
	
	<!--- Session End --->
	<cffunction name="sessionEnd" access="public" returntype="void" hint="Executes on Session end." output="false" >
		<cfargument name="event" 	required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information. THE SESSION SCOPE">
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
	
	<!--- Pre execution process --->
	<cffunction name="preProcess" access="public" returntype="void" hint="Executes before any event execution occurs" output="false" >
		<cfargument name="event" 	required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
	
	<!--- Pre Event execution --->
	<cffunction name="preEvent" access="public" returntype="void" hint="Executes right before any run event is executed." output="false" >
		<cfargument name="event" 		required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" 	required="true" type="struct" hint="A structure containing intercepted information = [processedEvent]">
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
	
	<!--- Post Event Execution --->
	<cffunction name="postEvent" access="public" returntype="void" hint="Executes after a run event is executed" output="false" >
		<cfargument name="event" 		required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" 	required="true" type="struct" hint="A structure containing intercepted information = [processedEvent]">
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
	
	<!--- Pre Render Execution --->
	<cffunction name="preRender" access="public" returntype="void" hint="Executes before the framework starts the rendering cycle." output="false" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" 	required="true" type="struct" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
	
	<!--- Post Rendering Cycle --->
	<cffunction name="postRender" access="public" returntype="void" hint="Executes after the rendering cycle." output="false" >
		<cfargument name="event" 	required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
	
	<!--- Post Process --->
	<cffunction name="postProcess" access="public" returntype="void" hint="Executes after executions and renderings." output="false" >
		<cfargument name="event" 	required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
	
	<!--- After an Elemente is inserted in the cache --->
	<cffunction name="afterCacheElementInsert" access="public" returntype="void" hint="Executes after an object is inserted into the cache." output="false" >
		<cfargument name="event" 	required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information = [cacheObjectKey,cacheObjectTimeout]">
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>
	
	<!--- After an Element is removed from the cache --->
	<cffunction name="afterCacheElementRemoved" access="public" returntype="void" hint="Executes after an object is removed from the cache." output="false" >
		<cfargument name="event" 	required="true" type="coldbox.system.beans.requestContext" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information = [cacheObjectKey]">
		<!--- IMPLEMENTED BY INTERCEPTOR --->
	</cffunction>

</cfcomponent>