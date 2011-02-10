<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	The base interceptor class
----------------------------------------------------------------------->
<cfcomponent hint="This is the base Interceptor class"
			 output="false"
			 extends="coldbox.system.FrameworkSupertype"
			 serializable="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" type="any" 	required="true"  hint="The ColdBox controller reference: coldbox.system.web.Controller">
		<cfargument name="properties" type="struct" required="true"  hint="The Interceptor properties">
		<cfscript>
			// Unique Instance ID for the object.
			instance.__hash = hash(createObject('java','java.lang.System').identityHashCode(this));
			
			// Register Controller
			variables.controller = arguments.controller;
			// Register LogBox
			variables.logBox = arguments.controller.getLogBox();
			// Register Log object
			variables.log = variables.logBox.getLogger(this);
			// Register Flash RAM
			variables.flash = arguments.controller.getRequestService().getFlashScope();
			// Register CacheBox
			variables.cacheBox = arguments.controller.getCacheBox();
			// Register WireBox
			variables.wireBox = arguments.controller.getWireBox();
			
			// Register properties
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
	
	<!--- Unregister From a State --->
	<cffunction name="unregister" access="public" returntype="boolean" hint="Unregister this interceptor from a passed state. If the state does not exists, it returns false" output="false" >
		<cfargument name="state" required="true" type="string" hint="The named state to unregister this interceptor from">
		<cfscript>
			var interceptorClass = listLast(getMetadata(this).name,".");
			return variables.controller.getInterceptorService().unregister(interceptorClass,arguments.state);			
		</cfscript>
	</cffunction>

	<!--- Get the Interceptor Service --->
	<cffunction name="getInterceptorService" access="public" returntype="coldbox.system.web.services.interceptorService" output="false">
		<cfreturn variables.controller.getInterceptorService()>
	</cffunction>
	
<!------------------------------------------- BUFFER METHODS ------------------------------------------>

	<!--- clearBuffer --->
	<cffunction name="clearBuffer" output="false" access="public" returntype="any" hint="Clear the interceptor buffer">
		<cfset getInterceptorService().getRequestBuffer().clear()>
	</cffunction>
	
	<!--- appendToBuffer --->
	<cffunction name="appendToBuffer" output="false" access="public" returntype="void" hint="Append to the interceptor buffer.">
		<cfargument name="str" type="string" required="true" hint="The string to append"/>
		<cfset getInterceptorService().getRequestBuffer().append(arguments.str)>
	</cffunction>
	
	<!--- getBufferString --->
	<cffunction name="getBufferString" output="false" access="public" returntype="any" hint="Get the string representation of the buffer">
		<cfreturn getInterceptorService().getRequestBuffer().getString()>
	</cffunction>
	
	<!--- getBufferObject --->
	<cffunction name="getBufferObject" output="false" access="public" returntype="any" hint="Get the request buffer object: coldbox.system.core.util.RequestBuffer">
		<cfreturn getInterceptorService().getRequestBuffer()>
	</cffunction>
	

</cfcomponent>