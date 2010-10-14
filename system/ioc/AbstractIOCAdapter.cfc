<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A base IOC factory adapter

----------------------------------------------------------------------->
<cfcomponent name="AbstractIOCAdapter" 
			 hint="A base IOC factory adapter" 
			 output="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
	
	<cffunction name="init" access="public" returntype="AbstractIOCAdapter" hint="Constructor" output="false" >
		<cfargument name="definitionFile" 	type="string" 	required="false" default="" hint="The definition file to load a factory with"/>
		<cfargument name="properties" 		type="struct" 	required="false" default="#structNew()#" hint="Properties to pass to the factory to create"/>
		<cfargument name="coldbox" 			type="any" 		required="false" default="" hint="A coldbox application that this instance of logbox can be linked to, not used if not using within a ColdBox Application."/>
		<cfscript>
			instance 		 		= structnew();
			// A coldBox reference that might or not exist
			instance.coldbox 		= "";
			// The placeholder for the factory created
			instance.factory 		= "";
			// The definition file to be used by the factory created
			instance.definitionFile	= arguments.definitionFile;
			// The properties passed to the factory to create
			instance.properties 	= arguments.properties;
			
			// Link to coldbox context if passed
			if( isObject(arguments.coldbox) ){ instance.coldbox = arguments.coldbox; }
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- ABSTRACT METHDOS ------------------------------------------>
	
	<!--- An adapter must implement these methods --->

	<!--- createFactory --->
	<cffunction name="createFactory" access="public" returntype="void" output="false" hint="Create the factory" >
	</cffunction>

	<!--- getBean --->
	<cffunction name="getBean" access="public" output="false" returntype="any" hint="Get a Bean from the object factory">
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">
	</cffunction>
	
	<!--- containsBean --->
	<cffunction name="containsBean" access="public" returntype="boolean" hint="Check if the bean factory contains a bean" output="false" >
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">	
	</cffunction>
	
	<!--- setParentFactory --->
    <cffunction name="setParentFactory" output="false" access="public" returntype="void" hint="Set a parent factory on the adapted factory">
    	<cfargument name="parent" type="any" required="true" hint="The parent factory to add"/>
    </cffunction>
	
	<!--- getParent --->
    <cffunction name="getParentFactory" output="false" access="public" returntype="any" hint="Get the parent factory">
    </cffunction>

<!----------------------------------------- CONCRETE PUBLIC ------------------------------------->	
	
	<!--- getProperties --->
    <cffunction name="getProperties" output="false" access="public" returntype="struct" hint="Get the adapter properties">
    	<cfreturn instance.properties>
    </cffunction>
	
	<!--- getDefinitionFile --->
    <cffunction name="getDefinitionFile" output="false" access="public" returntype="string" hint="Get the definition file for this adapter">
    	<cfreturn instance.definitionFile>
    </cffunction>
	
	<!--- getColdBox --->
	<cffunction name="getColdBox" access="public" output="false" returntype="any" hint="Get the ColdBox controller this adapter is linked to. If not linked and exception is thrown" colddoc:generic="coldbox.system.web.Controller">
		<cfreturn instance.coldbox/>
	</cffunction>
	
	<!--- getFactory --->
	<cffunction name="getFactory" access="public" output="false" returntype="any" hint="Get the adapted factory">
		<cfreturn instance.factory/>
	</cffunction>
	
	<!--- invokeFactoryMethod --->
	<cffunction name="invokeFactoryMethod" access="public" returntype="any" hint="Invoke a factory method in the bean factory. If the factory returns a void/null, this method returns void or null" output="false" >
		<cfargument name="method"   type="string" required="true" hint="The method to invoke">
		<cfargument name="args"  	type="struct" required="false" default="#structnew()#" hint="The arguments to pass into the method">
		<cfset var refLocal = structnew()>
		
		<cfinvoke component="#getFactory()#"
				  method="#arguments.method#"
				  argumentcollection="#arguments.args#"
				  returnvariable="refLocal.results">
		
		<cfif structKeyExists(refLocal,"results")>
			<cfreturn refLocal.results>
		</cfif>
	</cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	
	
	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>	
	
</cfcomponent>