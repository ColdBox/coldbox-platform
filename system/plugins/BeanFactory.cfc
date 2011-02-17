<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author: Luis Majano
Description: 
  I am a plugin that taps into WireBox or the ColdBox Compat BeanFactory and some cool populations.
  This version supports the compat mode until 3.1 where wirebox is the defacto standard.

----------------------------------------------------------------------->
<cfcomponent hint="I am a plugin that taps into WireBox or the ColdBox Compat BeanFactory"
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
			setpluginVersion("1.0");
			setpluginDescription("I am a plugin that taps into WireBox or the ColdBox Compat BeanFactory");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");

			// Bean Populator
			instance.beanPopulator 	= createObject("component","coldbox.system.core.dynamic.BeanPopulator").init();
			
			// Compat Mode or Not?
			if( controller.getSetting("WireBox").enabled ){
				instance.compatMode = false;
			}
			else{
				instance.beanFactory 	= getPlugin("BeanFactoryCompat");
				instance.compatMode		= true;
			}
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- configure --->
	<cffunction name="configure" access="public" returntype="BeanFactory" hint="Configure the bean factory for operation. @deprecated" output="false" >
		<cfscript>
			instance.beanFactory.configure();
		</cfscript>
	</cffunction>
	
	<!--- getBeanFactory --->
    <cffunction name="getBeanFactory" output="false" access="public" returntype="any" hint="Get the compatibility bean factory. @deprecated, removed by 3.1">
    	<cfreturn instance.beanFactory>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Add Model Mapping --->
	<cffunction name="addModelMapping" access="public" returntype="void" hint="Add a new model mapping. Ex: addModelMapping('myBean','security.test.FormBean'). The alias can be a single item or a comma delimmitted list. @deprecated by 3.1" output="false" >
		<cfargument name="alias" required="false" type="any" hint="The model alias to use, this can also be a list of aliases. Ex: SecurityService,Security">
		<cfargument name="path"  required="true"  type="any" hint="The model path (From the model conventions downward). Do not add full path, this is a convenience">
		<cfscript>
			instance.beanFactory.addModelMapping(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Get Model --->
	<cffunction name="getModel" access="public" returntype="any" hint="Create or retrieve model objects by convention." output="false" >
		<cfargument name="name" 				required="false" type="any" default="" hint="The name of the model to retrieve">
		<cfargument name="useSetterInjection" 	required="false" type="any" hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence. Boolean" colddoc:generic="Boolean">
		<cfargument name="onDICompleteUDF" 		required="false" type="any"	hint="After Dependencies are injected, this method will look for this UDF and call it if it exists. The default value is onDIComplete">
		<cfargument name="stopRecursion"		required="false" type="any"  hint="A comma-delimmited list of stoprecursion classpaths.">
		<cfargument name="dsl"					required="false" type="any"  hint="The dsl string to use to retrieve the domain object"/>
		<cfargument name="executeInit"			required="false" type="any" default="true" hint="Whether to execute the init() constructor or not.  Defaults to execute, Boolean" colddoc:generic="Boolean"/>
		<cfargument name="initArguments" 		required="false" hint="The constructor structure of arguments to passthrough when initializing the instance. Only available for WireBox integration" colddoc:generic="struct"/>
		<cfscript>
			if( instance.compatMode ){
				return instance.beanFactory.getModel(argumentCollection=arguments);
			}
			
			return wirebox.getInstance(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- removeExternalLocations --->
	<cffunction name="removeExternalLocations" output="false" access="public" returntype="void" hint="Try to remove all the external locations passed in. @deprecated by 3.1">
		<cfargument name="locations" type="any" required="true" hint="Locations to remove from the lookup.  Comma delimited allowed."/>
		<cfscript>
			if( instance.compatMode ){
				instance.beanFactory.removeExternalLocations(arguments.locations);
				return;
			}
			wirebox.getBinder().removeScanLocations( arguments.locations );
		</cfscript>
	</cffunction>

	<!--- appendExternalLocation --->
	<cffunction name="appendExternalLocations" output="false" access="public" returntype="void" hint="Try to append a new model external location. @deprecated by 3.1">
		<cfargument name="locations" type="any" required="true" hint="Locations to add to the lookup, will be added in passed order.  Comma delimited allowed."/>
		<cfscript>
			if( instance.compatMode ){
				instance.beanFactory.appendExternalLocations(arguments.locations);
				return;
			}
			wirebox.getBinder().scanLocations( arguments.locations );
		</cfscript>
	</cffunction>

	<!--- Locate a Model Object --->
	<cffunction name="locateModel" access="public" returntype="string" hint="Get the location instantiation path for a model object. If the model location is not found, this method returns an empty string. @deprecated by 3.1" output="false" >
		<cfargument name="name" 		type="any"  required="true" hint="The model to locate">
		<cfargument name="resolveAlias" type="any"  required="false" default="false" hint="Resolve model aliases">
		<cfscript>
			if( instance.compatMode ){
				return instance.beanFactory.locateModel(arguments.name, arguments.resolveAlias);
			}
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
		<!--- ************************************************************* --->
		<cfscript>
			if( isSimpleValue(arguments.target) ){
				arguments.target = getModel(arguments.target);
			}

			return instance.beanPopulator.populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Autowire --->
	<cffunction name="autowire" access="public" returntype="void" output="false" hint="Autowire an object using the ColdBox DSL">
		<!--- ************************************************************* --->
		<cfargument name="target" 				required="true" 	type="any" 	hint="The object to autowire">
		<cfargument name="useSetterInjection" 	required="false" 	type="any" 	default="true"	hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence. Boolean Value" colddoc:generic="Boolean">
		<cfargument name="annotationCheck" 		required="false" 	type="any"  default="false" hint="This value determines if we check if the target contains an autowire annotation in the cfcomponent tag: autowire=true|false, it will only autowire if that metadata attribute is set to true. The default is false, which will autowire automatically. Boolean Value" colddoc:generic="Boolean">
		<cfargument name="onDICompleteUDF" 		required="false" 	type="any"	default="onDIComplete" hint="After Dependencies are injected, this method will look for this UDF and call it if it exists. The default value is onDIComplete" colddoc:generic="string">
		<cfargument name="stopRecursion" 		required="false" 	type="any"  default="" hint="The stop recursion class. Ex: transfer.com.TransferDecorator. By default all ColdBox base classes are included." colddoc:generic="string">
		<cfargument name="targetID"				required="false"	type="any"	default="" hint="A unique resource target identifier used for wiring the sent in target. If not sent, then this will become getMetadata(target).name and use resources." colddoc:generic="string">
		<!--- ************************************************************* --->
		<cfscript>
			if( instance.compatMode ){
				instance.beanFactory.autowire(argumentCollection=arguments);
				return;
			}
			// wirebox
			wirebox.autowire(argumentCollection=arguments);
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>