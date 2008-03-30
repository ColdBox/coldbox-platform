<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author: Luis Majano
Date:   July 28, 2006
Description: This is the framework's simple bean factory.

----------------------------------------------------------------------->
<cfcomponent name="beanFactory"
			 hint="I am a simple bean factory and you can use me if you want."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="beanFactory" output="false" hint="constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.controller">
		<!--- ************************************************************* --->
		<cfscript>
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("Bean Factory");
			setpluginVersion("2.0");
			setpluginDescription("I am a simple bean factory");
			
			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Just create and call init, simple --->
	<cffunction name="create" hint="Create a named bean, simple as that" access="public" output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="bean" 		required="true"  type="string" hint="The type of bean to create and return. Uses full cfc path mapping.Ex: coldbox.beans.exceptionBean">
		<cfargument name="callInitFlag"	required="false" type="boolean" default="false" hint="[DEPRECATED] Flag to call an init method on the bean.">
		<!--- ************************************************************* --->
		<cfscript>
			var beanInstance = "";
			
			try{
				/* Try to create bean */
				beanInstance = createObject("component","#arguments.bean#");
				
				/* check if an init */
				if( structKeyExists(beanInstance,"init") ){
					beanInstance = beanInstance.init();
				}
				
				/* Return object */
				return beanInstance;
			}
			Catch(Any e){
				throw("Error creating bean: #arguments.bean#","#e.Detail#<br>#e.message#","Framework.plugins.beanFactory.BeanCreationException");
			}
		</cfscript>
	</cffunction>

	<!--- Populate a bean from the request Collection --->
	<cffunction name="populateBean" access="public" output="false" returntype="Any" hint="Populate a named or instantiated bean (java/cfc) from the request collection items">
		<!--- ************************************************************* --->
		<cfargument name="FormBean" required="true" type="any" hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<!--- ************************************************************* --->
		<cfscript>
			var rc = controller.getRequestService().getContext().getCollection();
			
			/* Inflate from Request Collection */
			return populateFromStruct(arguments.FormBean,rc);			
		</cfscript>
	</cffunction>
	
	<!--- Populate a bean from a structure --->
	<cffunction name="populateFromJSON" access="public" returntype="any" hint="Populate a named or instantiated bean from a json string" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="FormBean" 	required="true" type="any" 		hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="JSONString"   required="true" type="string" 	hint="The JSON string to populate the object with. It has to be valid JSON and also a structure with name-key value pairs. ">
		<!--- ************************************************************* --->
		<cfscript>
			var inflatedStruct = "";
			
			/* Inflate JSON */
			inflatedStruct = getPlugin("json").decode(arguments.JSONString);
			
			/* populate and return */
			return populateFromStruct(arguments.FormBean,inflatedStruct);
		</cfscript>
	</cffunction>

	<!--- Populate a bean from a structure --->
	<cffunction name="populateFromStruct" access="public" returntype="any" hint="Populate a named or instantiated bean from a structure" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="FormBean" required="true" type="any" 		hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="memento"  required="true" type="struct" 	hint="The structure to populate the object with.">
		<!--- ************************************************************* --->
		<cfscript>
			var beanInstance = "";
			var key = "";
			
			try{
				/* Create or just use form bean */
				if( isSimpleValue(arguments.formBean) ){
					beanInstance = create(arguments.formBean);
				}
				else{
					beanInstance = arguments.formBean;
				}
				/* Populate Bean */
				for(key in arguments.memento){
					/* Check if setter exists */
					if( structKeyExists(beanInstance,"set" & key) ){
						evaluate("beanInstance.set#key#(arguments.memento[key])");
					}
				}
				/* Return if created */
				return beanInstance;
			}
			catch(Any e){
				throw(type="Framework.plugins.beanFactory.PopulateBeanException",message="Error populating bean.",detail="#e.Detail#<br>#e.message#");
			}
		</cfscript>
	</cffunction>


<!------------------------------------------- PRIVATE ------------------------------------------->



</cfcomponent>
