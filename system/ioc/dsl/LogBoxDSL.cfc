<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The DSL processor for all LogBox Related Stuff
	
----------------------------------------------------------------------->
<cfcomponent hint="The DSL processor for all LogBox Related Stuff" implements="coldbox.system.ioc.dsl.IDSLBuilder" output="false">

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="any" hint="Configure the DSL for operation and returns itself" colddoc:generic="coldbox.system.ioc.dsl.IDSLBuilder">
    	<cfargument name="injector" type="any" required="true" hint="The linked WireBox injector" colddoc:generic="coldbox.system.ioc.Injector"/>
		<cfscript>
			instance = { injector = arguments.injector };
			instance.logBox 	= instance.injector.getLogBox();
			instance.log		= instance.logBox.getLogger( this );
			
			return this;
		</cfscript>   
    </cffunction>
	
	<!--- process --->
    <cffunction name="process" output="false" access="public" returntype="any" hint="Process an incoming DSL definition and produce an object with it.">
		<cfargument name="definition" 	required="true" hint="The injection dsl definition structure to process. Keys: name, dsl"/>
		<cfargument name="targetObject" required="false" hint="The target object we are building the DSL dependency for. If empty, means we are just requesting building"/>
		<cfscript>
			var thisType 			= arguments.definition.dsl;
			var thisTypeLen 		= listLen(thisType,":");
			var thisLocationType 	= "";
			var thisLocationKey 	= "";
			
			// DSL stages
			switch(thisTypeLen){
				// logbox
				case 1 : { return instance.logBox; }
				// logbox:root and logbox:logger 
				case 2 : {
					thisLocationKey = getToken(thisType,2,":");
					switch( thisLocationKey ){
						case "root" 	: { return instance.logbox.getRootLogger(); }
						case "logger" 	: { return instance.logbox.getLogger( arguments.definition.name ); }
					}
					break;
				}
				// Named Loggers
				case 3 : {
					thisLocationType 	= getToken(thisType,2,":");
					thisLocationKey 	= getToken(thisType,3,":");
					// DSL Level 2 Stage Types
					switch(thisLocationType){
						// Get a named Logger
						case "logger" : { 
							// Check for {this} and targetobject exists
							if( thisLocationKey eq "{this}" AND structKeyExists(arguments, "targetObject") ){ 
								return instance.logBox.getLogger( arguments.targetObject ); 
							}
							// Normal Logger injection
							return instance.logBox.getLogger(thisLocationKey); break; 
						}
					}
					break;
				} // end level 3 main DSL
			}
		</cfscript>   	
    </cffunction>		
	
</cfcomponent>