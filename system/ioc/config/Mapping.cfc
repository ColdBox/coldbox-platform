<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	I model a WireBox object mapping in all of its glory and splendour
	

----------------------------------------------------------------------->
<cfcomponent hint="I model a WireBox object mapping in all of its glory and splendour" output="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
		
	<!--- init --->
	<cffunction name="init" access="public" returntype="Mapping" hint="Constructor" output="false" >
		<cfargument name="name" type="string" required="true" hint="The mapping name"/>
		<cfscript>
			
			// Configure Instance
			instance = {
				// Setup the mapping name
				name = arguments.name,
				// Setup the alias list for this mapping.
				alias = [],
				// Mapping Type
				type =  "",
				// Mapped instantiation path
				path = "",
				// Mapped constructor
				constructor = "init",
				// Discovery and wiring flag
				autoWire = true,
				// Auto init or not
				autoInit = true,
				// Lazy load the mapping or not
				eagerInit = false,
				// The storage or visibility scope of the mapping
				scope = "",
				// A construction dsl
				dsl = "",
				// Caching parameters
				cache = {provider="default", key="", timeout="", lastAccessTimeout=""},
				// Explicit Constructor arguments
				DIConstructorArgs = [],
				// Explicit Properties
				DIProperties = [],
				// Explicit Setters
				DISetters = [],
				// Post Processors
				onDIComplete = [],
				// Flag used to distinguish between discovered and non-discovered mappings
				discovered = false,
				// original object's metadata
				metadata = {},
				// discovered provider methods
				providerMethods = []
			};
			
			// DI definition structure
			DIDefinition = {name="",value="",dsl="",scope="variables",javaCast="",ref=""};
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- processMemento --->
    <cffunction name="processMemento" output="false" access="public" returntype="any" hint="Process a mapping memento">
    	<cfargument name="memento" type="struct" required="true" hint="The data memento to process"/>
    	<cfscript>
    		var x = 1;
			var key = "";
			
			// append incoming memento data
    		for(key in arguments.memento){
				
				switch(key){
					//process cache properties
					case "cache" : {
						setCacheProperties(argumentCollection=arguments.memento.cache ); break;
					}
					//process constructor args
					case "DIConstructorArgs" : {
						for(x=1; x lte arrayLen(arguments.memento.DIConstructorArgs); x++){
							addDIConstructorArgument(argumentCollection=arguments.memento.DIConstructorArgs[x] );
						}
						break; 
					}	
					//process properties
					case "DIProperties" : {
						for(x=1; x lte arrayLen(arguments.memento.DIProperties); x++){
							addDIProperty(argumentCollection=arguments.memento.DIProperties[x] );
						} 
						break; 
					}	
					//process DISetters
					case "DISetters" : {
						for(x=1; x lte arrayLen(arguments.memento.DISetters); x++){
							addDISetter(argumentCollection=arguments.memento.DISetters[x] );
						} 
						break; 
					}	
					
					default:{
						instance[key] = arguments.memento[key];
					}
				}// end switch
				
			}
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- Name --->
	<cffunction name="getName" access="public" returntype="string" output="false" hint="Get the mapping name">
    	<cfreturn instance.name>
    </cffunction>
    <cffunction name="setName" access="public" returntype="any" output="false" hint="Name the mapping">
    	<cfargument name="name" type="string" required="true">
    	<cfset instance.name = arguments.name>
    	<cfreturn this>
    </cffunction>
	
	<!--- Aliases --->
	<cffunction name="getAlias" access="public" returntype="array" output="false" hint="Get the mapping aliases">
    	<cfreturn instance.alias>
    </cffunction>
    <cffunction name="setAlias" access="public" returntype="any" output="false" hint="Set the mapping aliases">
    	<cfargument name="alias" type="array" required="true">
    	<cfset instance.alias = arguments.alias>
    	<cfreturn this>
    </cffunction>
	
	<!--- Path --->
	<cffunction name="getPath" access="public" returntype="string" output="false" hint="Get the path to this mapping">
    	<cfreturn instance.path>
    </cffunction>
    <cffunction name="setPath" access="public" returntype="any" output="false" hint="Set the path to this mapping">
    	<cfargument name="path" type="string" required="true">
    	<cfset instance.path = arguments.path>
    	<cfreturn this>
    </cffunction>
    
	<!--- Type --->
	<cffunction name="getType" access="public" returntype="any" output="false" hint="Get the mapping type">
    	<cfreturn instance.type>
    </cffunction>
    <cffunction name="setType" access="public" returntype="any" output="false" hint="Set the mapping type">
    	<cfargument name="type" type="any" required="true">
    	<cfset instance.type = arguments.type>
    	<cfreturn this>
    </cffunction>
	
	<!--- Constructor --->
	<cffunction name="getConstructor" access="public" returntype="string" output="false" hint="Get the name of the constructor method">
    	<cfreturn instance.constructor>
    </cffunction>
    <cffunction name="setConstructor" access="public" returntype="any" output="false" hint="Override the name of the constructor method">
    	<cfargument name="constructor" type="string" required="true">
    	<cfset instance.constructor = arguments.constructor>
    	<cfreturn this>
    </cffunction>
    
	<!--- isAutowire --->
    <cffunction name="isAutowire" output="false" access="public" returntype="boolean" hint="Using autowire or not">
    	<cfreturn instance.autowire>
    </cffunction>
    <cffunction name="setAutowire" access="public" returntype="any" output="false" hint="Set autowire property">
    	<cfargument name="autowire" type="boolean" required="true">
    	<cfset instance.autowire = arguments.autowire>
    	<cfreturn this>
    </cffunction>
	
	<!--- isAutoInit --->
    <cffunction name="isAutoInit" output="false" access="public" returntype="boolean" hint="Using auto init of mapping target or not">
    	<cfreturn instance.autoInit>
    </cffunction>
    <cffunction name="setAutoInit" access="public" returntype="any" output="false" hint="Set autoInit property">
    	<cfargument name="autoInit" type="boolean" required="true">
    	<cfset instance.autoInit = arguments.autoInit>
    	<cfreturn this>
    </cffunction>
	
	<!--- scope --->
	<cffunction name="getScope" access="public" returntype="any" output="false" hint="Get the visibility scope">
    	<cfreturn instance.scope>
    </cffunction>
    <cffunction name="setScope" access="public" returntype="any" output="false" hint="Set the visibility scope">
    	<cfargument name="scope" type="any" required="true">
    	<cfset instance.scope = arguments.scope>
    	<cfreturn this>
    </cffunction>
    
	<!--- DSL --->
	<cffunction name="isDSL" output="false" access="public" returntype="boolean" hint="Does this mapping have a DSL construction element">
		<cfreturn (len(instance.dsl) GT 0)>    	
    </cffunction>
    <cffunction name="getDSL" access="public" returntype="string" output="false" hint="Get the construction DSL">
    	<cfreturn instance.dsl>
    </cffunction>
    <cffunction name="setDSL" access="public" returntype="any" output="false" hint="Set the construction DSL">
    	<cfargument name="dsl" type="string" required="true">
    	<cfset instance.dsl = arguments.dsl>
    	<cfreturn this>
    </cffunction>
	
	<!--- cacheProperties --->
    <cffunction name="setCacheProperties" output="false" access="public" returntype="any" hint="Set the cache properties for this mapping (Needs cachebox integration)">
    	<cfargument name="key" 					type="string" 	required="false" default="" hint="Cache key."/>
    	<cfargument name="timeout" 				type="any" 		required="false" default="" hint="Object Timeout"/>
		<cfargument name="lastAccessTimeout" 	type="any" 		required="false" default="" hint="Object Last Access Timeout"/>
		<cfargument name="provider" 			type="string" 	required="false" default="default" hint="Cache Provider"/>
		<cfscript>
			structAppend( instance.cache, arguments, true);
			return this;
		</cfscript>
    </cffunction>
    <cffunction name="getCacheProperties" output="false" access="public" returntype="struct" hint="Get this mappings cache properties">
    	<cfreturn instance.cache>
    </cffunction>
	
	<!--- getDIConstructorArguments --->
    <cffunction name="getDIConstructorArguments" output="false" access="public" returntype="array" hint="Get all the constructor argument definitions">
    	<cfreturn instance.DIConstructorArgs>
    </cffunction>
	
	<!--- addConstructorArgument --->
    <cffunction name="addDIConstructorArgument" output="false" access="public" returntype="any" hint="Add a new constructor argument">
    	<cfargument name="name" 	type="string" 	required="false" hint="The name of the constructor argument (NA: JAVA,WEBSERVICE)"/>
		<cfargument name="ref" 		type="string" 	required="false" hint="The reference mapping id this constructor argument maps to"/>
		<cfargument name="dsl" 		type="string" 	required="false" hint="The construction dsl this argument references. If used, the name value must be used."/>
		<cfargument name="value" 	type="any" 		required="false" hint="The explicit value of the constructor argument, if passed."/>
    	<cfargument name="javaCast" type="string" 	required="false" hint="The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments"/>
    	<cfscript>
    		var def = getDIDefinition();
			structAppend(def, arguments, true);
			arrayAppend( instance.DIConstructorArgs, def );
			return this;
    	</cfscript>
    </cffunction>

	<!--- getProperties --->
    <cffunction name="getDIProperties" output="false" access="public" returntype="array" hint="Get all the DI property definitions">
    	<cfreturn instance.DIProperties>
    </cffunction>
	
	<!--- addDIProperty --->
    <cffunction name="addDIProperty" output="false" access="public" returntype="any" hint="Add a new cfproperty definition">
    	<cfargument name="name" 	type="string" 	required="true"  hint="The name of the cfproperty to inject"/>
		<cfargument name="ref" 		type="string" 	required="false" hint="The reference mapping id this property maps to"/>
		<cfargument name="dsl" 		type="string" 	required="false" hint="The construction dsl this property references. If used, the name value must be used."/>
		<cfargument name="value" 	type="any" 		required="false" hint="The value of the property, if passed."/>
    	<cfargument name="javaCast" type="string" 	required="false" hint="The type of javaCast() to use on the value of the property. Only used if using dsl or ref arguments"/>
    	<cfargument name="scope" 	type="string" 	required="false" default="variables" hint="The scope in the CFC to inject the property to. By default it will inject it to the variables scope"/>
    	<cfscript>
    		var def = getDIDefinition();
			structAppend(def, arguments, true);
			arrayAppend( instance.DIProperties, def );
			return this;
    	</cfscript>
    </cffunction>

    <!--- getDISetters --->
    <cffunction name="getDISetters" output="false" access="public" returntype="array" hint="Get all the DI setter definitions">
    	<cfreturn instance.DISetters>
    </cffunction>
	
	<!--- addDISetter --->
    <cffunction name="addDISetter" output="false" access="public" returntype="any" hint="Add a new DI setter definition">
    	<cfargument name="name" 	type="string" 	required="true"  hint="The name of the setter method."/>
		<cfargument name="ref" 		type="string" 	required="false" hint="The reference mapping id this setter argument maps to"/>
		<cfargument name="dsl" 		type="string" 	required="false" hint="The construction dsl this argument references. If used, the name value must be used."/>
		<cfargument name="value" 	type="any" 		required="false" hint="The value of the setter argument, if passed."/>
    	<cfargument name="javaCast" type="string" 	required="false" hint="The type of javaCast() to use on the value of the argument. Only used if using dsl or ref arguments"/>
    	<cfscript>
    		var def = getDIDefinition();
			structAppend(def, arguments, true);
			arrayAppend( instance.DISetters, def );
			return this;
    	</cfscript>
    </cffunction>
	
	<!--- onDIComplete --->
    <cffunction name="getOnDIComplete" output="false" access="public" returntype="array" hint="Get all the DI complete methods array">
    	<cfreturn instance.onDIComplete>
    </cffunction>
    <cffunction name="setOnDIComplete" output="false" access="public" returntype="any" hint="Set the DI Complete method array">
  		<cfargument name="DIComplete" type="array" required="true" default="" hint="The method array list"/>
    	<cfset instance.onDIComplete = arguments.DIComplete>
    	<cfreturn this>
    </cffunction>

	<!--- isDiscovered --->
    <cffunction name="isDiscovered" output="false" access="public" returntype="boolean" hint="Checks if this mapping has already been processed or not">
    	<cfreturn instance.discovered>
    </cffunction>
	
	<!--- setDiscovered --->
    <cffunction name="setDiscovered" output="false" access="public" returntype="any" hint="Flag this mapping as discovered">
    	<cfset instance.discovered = true>
    	<cfreturn this>
    </cffunction>
	
	<!--- getMetadata --->
    <cffunction name="getMetadata" output="false" access="public" returntype="any" hint="Get the internal mapping metadata">
    	<cfreturn instance.metadata>
    </cffunction>
	
	<!--- setMetadata --->
    <cffunction name="setMetadata" output="false" access="public" returntype="any" hint="Set the mappings CFC target metadata">
    	<cfargument name="metadata" type="any" required="true" hint="Target CFC metadata"/>
		<cfset instance.metadata = arguments.metadata>
		<cfreturn this>
    </cffunction>

	<!--- isEagerInit --->
    <cffunction name="isEagerInit" output="false" access="public" returntype="boolean" hint="Is this mapping eager initialized">
    	<cfreturn instance.eagerInit>
    </cffunction>
	
	<!--- setEagerInit --->
    <cffunction name="setEagerInit" output="false" access="public" returntype="any" hint="Set the eager init flag">
    	<cfargument name="eagerInit" type="boolean" required="true" hint="Set the eager init flag"/>
    	<cfset instance.eagerInit = arguments.eagerInit>
    	<cfreturn this>
	</cffunction>
	
	<!--- getProviderMethods --->
    <cffunction name="getProviderMethods" output="false" access="public" returntype="array" hint="Get the discovered provider methods">
    	<cfreturn instance.providerMethods>
    </cffunction>
	
	<!--- addProviderMethod --->
    <cffunction name="addProviderMethod" output="false" access="public" returntype="any" hint="Add a new provider method">
    	<cfargument name="method" 	type="string" required="true" hint="The provided method"/>
		<cfargument name="mapping" 	type="string" required="true" hint="The mapping to provide"/>
		<cfset arrayAppend( instance.providerMethods, arguments)>
		<cfreturn this>
    </cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	
	
	<!--- getDIDefinition --->
    <cffunction name="getDIDefinition" output="false" access="private" returntype="struct" hint="Get a new DI definition structure">
    	<cfreturn duplicate(variables.DIDefinition)>
    </cffunction>

</cfcomponent>