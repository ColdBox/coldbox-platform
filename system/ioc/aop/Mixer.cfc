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
			instance = { 
				injector = arguments.injector,
				log = arguments.injector.getLogBox().getLogger( this ),
				properties = arguments.properties 
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
    <cffunction name="afterInstanceCreation" output="false" access="public" returntype="any" hint="">    
    	<cfargument name="data">
		<cfscript>
			
		</cfscript>	
    </cffunction>
	
</cfcomponent>