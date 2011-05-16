<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I am a WireBox listener that provides you with AOP capabilities in your
	objects
----------------------------------------------------------------------->
<cfcomponent output="false" hint="I am a WireBox listener that provides you with AOP capabilities in your objects">
	
<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- configure --->    
    <cffunction name="configure" output="false" access="public" returntype="any" hint="Constructor">    
    	<cfargument name="injector" 	type="any" required="true" hint="The injector I am linked to"/>
    	<cfargument name="properties"	type="any" required="true" hint="Listener properties">
    	<cfscript>
			// instance data
			instance = { 
				// injector reference
				injector 	= arguments.injector,
				// Binder Reference
				binder		= arguments.injector.getBinder(),
				// local logger
				log 		= arguments.injector.getLogBox().getLogger( this ),
				// listener properties
				properties 	= arguments.properties,
				// class matcher lookup map 
				matchedClasses	= {}
			};
			
			// Default Generation Path?
			if( NOT structKeyExists(instance.properties,"generationPath") ){
				instance.properties.generationPath = expandPath("/coldbox/system/ioc/aop/tmp");
			}
			
			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- afterInstanceCreation --->    
    <cffunction name="afterInstanceCreation" output="false" access="public" returntype="any">    
    	<cfargument name="interceptData">
		<cfscript>
			var mapping = arguments.interceptData.mapping;
			var target 	= arguments.interceptData.target;
			
			// check if target already mixed, if so return;
			if( structKeyExists(target,"$wbAOPMixed") ){ return; }
			
			// Check if the incoming mapping has been checked against any of our bindings?
			if( NOT structKeyExists(instance.matchedClasses, mapping.getName() ) ){
				// check the target and register the matching information
				matchClass( target, mapping );
			}
			
			// If the class matches for AOP, lets AOPfy it! Else ignore
			if( instance.matchedClasses[ mapping.getName() ] ){
				
			}			
		</cfscript>	
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- matchClass --->    
    <cffunction name="matchClass" output="false" access="public" returntype="any" hint="Match a class if it is valid for AOP transformations">    
    	<cfargument name="target" 	type="any" required="true" hint="The incoming target"/>
    	<cfargument name="mapping" 	type="any" required="true" hint="The incoming target mapping"/>
    	<cfscript>
			// Get aspect bindings from the binder
			var aspectBindings = instance.binder.getAspectBindings();
			var bindingsLen = arrayLen(aspectBindings);
			var x	= 1;
			
			// Discover matching for the class via all aspect bindings
			for(x=1; x lte bindingsLen; x++){
			
				// Call class matcher to see if this target matches ANY aspect binding
				if ( aspectBindings[x].classMatcher.matches( ) ){
					instance.matchedClasses[ mapping.getName() ] = false;	
				}
				else{
					instance.matchedClasses[ mapping.getName() ] = false;	
				}
				
			}	
		</cfscript>
    </cffunction>


</cfcomponent>