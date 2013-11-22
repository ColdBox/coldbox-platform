<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author: Luis Majano
Description:
I am a plugin that taps into WireBox. I will be eventually removed as you can access wirebox directly :)

----------------------------------------------------------------------->
<cfcomponent hint="I am a plugin that taps into WireBox. I will be eventually removed as you can access wirebox directly :)"
			 extends="coldbox.system.Plugin"
			 output="false"
			 singleton>

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="BeanFactory" output="false" hint="constructor">
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.web.Controller">
		<cfscript>
			super.init(arguments.controller);

			//Plugin properties
			setpluginName("BeanFactory - WireBox Facade");
			setpluginVersion("2.0");
			setpluginDescription("I am a plugin that taps into WireBox. I will be eventually removed as you can access wirebox directly :)");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");

			// Bean Populator
			instance.beanPopulator 	= createObject("component","coldbox.system.core.dynamic.BeanPopulator").init();

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get Model --->
	<cffunction name="getModel" access="public" returntype="any" hint="Create or retrieve model objects by convention." output="false" >
		<cfargument name="name" 			required="false" 	hint="The mapping name or CFC instance path to try to build up"/>
		<cfargument name="dsl"				required="false" 	hint="The dsl string to use to retrieve the instance model object, mutually exclusive with 'name'"/>
		<cfargument name="initArguments" 	required="false" 	default="#structnew()#" hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfscript>
			return wirebox.getInstance(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- removeExternalLocations --->
	<cffunction name="removeExternalLocations" output="false" access="public" returntype="void" hint="Try to remove all the external locations passed in. @deprecated by 3.1">
		<cfargument name="locations" type="any" required="true" hint="Locations to remove from the lookup.  Comma delimited allowed."/>
		<cfscript>
			wirebox.getBinder().removeScanLocations( arguments.locations );
		</cfscript>
	</cffunction>

	<!--- appendExternalLocation --->
	<cffunction name="appendExternalLocations" output="false" access="public" returntype="void" hint="Try to append a new model external location. @deprecated by 3.1">
		<cfargument name="locations" type="any" required="true" hint="Locations to add to the lookup, will be added in passed order.  Comma delimited allowed."/>
		<cfscript>
			wirebox.getBinder().scanLocations( arguments.locations );
		</cfscript>
	</cffunction>

	<!--- Locate a Model Object --->
	<cffunction name="locateModel" access="public" returntype="string" hint="Get the location instantiation path for a model object. If the model location is not found, this method returns an empty string. @deprecated by 3.1" output="false" >
		<cfargument name="name" 		type="any"  required="true" hint="The model to locate">
		<cfargument name="resolveAlias" type="any"  required="false" default="false" hint="Resolve model aliases">
		<cfscript>
			return wirebox.locateInstance( arguments.name );
		</cfscript>
	</cffunction>

	<!--- Populate a model object from the request Collection --->
	<cffunction name="populateModel" access="public" output="false" returntype="Any" hint="Populate a named or instantiated model (java/cfc) from the request collection items">
		<!--- ************************************************************* --->
		<cfargument name="model" 			required="true"  type="any" 	hint="The name of the model to get and populate or the acutal model object. If you already have an instance of a model, then use the populateBean() method">
		<cfargument name="scope" 			required="false" type="string"  default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<!--- ************************************************************* --->
		<cfscript>
			arguments.memento = controller.getRequestService().getContext().getCollection();

			// Do we have a model or name
			if( isSimpleValue(arguments.model) ){
				arguments.target = getModel(model);
			}
			else{
				arguments.target = arguments.model;
			}

			// Inflate from Request Collection
			return instance.beanPopulator.populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate a bean from the request Collection --->
	<cffunction name="populateBean" access="public" output="false" returntype="Any" hint="Populate a named or instantiated bean (java/cfc) from the request collection items">
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true" 	type="any" 	hint="This can be an instantiated bean object or a bean instantitation path as a string.  This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="scope" 			required="false" 	type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<!--- ************************************************************* --->
		<cfscript>
			arguments.memento = controller.getRequestService().getContext().getCollection();

			if( isSimpleValue(arguments.target) ){
				arguments.target = getModel(arguments.target);
			}

			return instance.beanPopulator.populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate a bean from a structure --->
	<cffunction name="populateFromJSON" access="public" returntype="any" hint="Populate a named or instantiated bean from a json string" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true" 	type="any" 		hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="JSONString"   	required="true" 	type="string" 	hint="The JSON string to populate the object with. It has to be valid JSON and also a structure with name-key value pairs. ">
		<cfargument name="scope" 			required="false" 	type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<!--- ************************************************************* --->
		<cfscript>
			if( isSimpleValue(arguments.target) ){
				arguments.target = getModel(arguments.target);
			}

			return instance.beanPopulator.populateFromJSON(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate from XML--->
	<cffunction name="populateFromXML" access="public" returntype="any" hint="Populate a named or instantiated bean from an XML packet" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true" 	type="any" 		hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="xml"   			required="true" 	type="any" 	hint="The XML string or packet">
		<cfargument name="root"   			required="false" 	type="string" 	default=""  hint="The XML root element to start from">
		<cfargument name="scope" 			required="false" 	type="string"  default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" 	type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" 	type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false"	type="string"  default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<!--- ************************************************************* --->
		<cfscript>
			if( isSimpleValue(arguments.target) ){
				arguments.target = getModel(arguments.target);
			}

			return instance.beanPopulator.populateFromXML(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate from Query --->
	<cffunction name="populateFromQuery" access="public" returntype="any" hint="Populate a named or instantiated bean from query" output="false">
		<!--- ************************************************************* --->
		<cfargument name="target"  			required="true"  type="any" 	 hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="qry"       		required="true"  type="query"   hint="The query to popluate the bean object with">
		<cfargument name="RowNumber" 		required="false" type="Numeric" hint="The query row number to use for population" default="1">
		<cfargument name="scope" 			required="false" type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<!--- ************************************************************* --->
		<cfscript>
			if( isSimpleValue(arguments.target) ){
				arguments.target = getModel(arguments.target);
			}

			return instance.beanPopulator.populateFromQuery(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate an object using a query, but, only specific columns in the query. --->
	<cffunction name="populateFromQueryWithPrefix" output="false" returnType="any" hint="Populates an Object using only specific columns from a query. Useful for performing a query with joins that needs to populate multiple objects.">
		<cfargument name="target"  			required="true"  	type="any" 	 	hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="qry"       		required="true"  	type="query"   	hint="The query to popluate the bean object with">
		<cfargument name="RowNumber" 		required="false" 	type="Numeric" 	hint="The query row number to use for population" default="1">
		<cfargument name="scope" 			required="false" 	type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" 	type="boolean" 	default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" 	type="string"  	default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" 	type="string"  	default="" hint="A list of keys to exclude in the population">
		<cfargument name="prefix"  			required="true" 	type="string"  	hint="The prefix used to filter, Example: 'user_' would apply to the following columns: 'user_id' and 'user_name' but not 'address_id'.">
		<cfargument name="ignoreEmpty" 		required="false" type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<cfscript>
			if( isSimpleValue(arguments.target) ){
				arguments.target = getModel(arguments.target);
			}

			//populate bean and return
			return instance.beanPopulator.populateFromQueryWithPrefix(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate a bean from a structure --->
	<cffunction name="populateFromStruct" access="public" returntype="any" hint="Populate a named or instantiated bean from a structure" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true"  type="any" 	hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="memento"  		required="true"  type="struct" 	hint="The structure to populate the object with.">
		<cfargument name="scope" 			required="false" type="string"  hint="Use scope injection instead of setters population."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<!--- ************************************************************* --->
		<cfscript>
			if( isSimpleValue(arguments.target) ){
				arguments.target = getModel(arguments.target);
			}

			return instance.beanPopulator.populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>
	
	<!---Populate from a struct with prefix --->
	<cffunction name="populateFromStructWithPrefix" access="public" returntype="any" hint="Populate a named or instantiated bean from a structure" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true"  type="any" 	hint="The target to populate">
		<cfargument name="memento"  		required="true"  type="struct" 	hint="The structure to populate the object with.">
		<cfargument name="scope" 			required="false" type="string"  hint="Use scope injection instead of setters population."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<cfargument name="prefix"               required="true"  type="string"  hint="The prefix used to filter, Example: 'user' would apply to the following formfield: 'user_id' and 'user_name' but not 'address_id'.">
        <!--- ************************************************************* --->
		<cfscript>
			if( isSimpleValue(arguments.target) ){
				arguments.target = getModel(arguments.target);
			}

			return instance.beanPopulator.populateFromStructWithPrefix(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Autowire --->
	<cffunction name="autowire" access="public" returntype="void" output="false" hint="Autowire an object using the ColdBox DSL">
		<!--- ************************************************************* --->
		<cfargument name="target" 				required="true" 	hint="The target object to wire up"/>
		<cfargument name="mapping" 				required="false" 	hint="The object mapping with all the necessary wiring metadata. Usually passed by scopes and not a-la-carte autowires" colddoc:generic="coldbox.system.ioc.config.Mapping"/>
		<cfargument name="targetID" 			required="false" 	default="" hint="A unique identifier for this target to wire up. Usually a class path or file path should do. If none is passed we will get the id from the passed target via introspection but it will slow down the wiring"/>
    	<cfargument name="annotationCheck" 		required="false" 	default="false" hint="This value determines if we check if the target contains an autowire annotation in the cfcomponent tag: autowire=true|false, it will only autowire if that metadata attribute is set to true. The default is false, which will autowire anything automatically." colddoc:generic="Boolean">
		<!--- ************************************************************* --->
		<cfscript>
			wirebox.autowire(argumentCollection=arguments);
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>