<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This is a LogBox configuration object.  You can use it to configure
	a log box instance.
----------------------------------------------------------------------->
<cfcomponent name="LogBoxConfig" output="false" hint="This is a LogBox configuration object.  You can use it to configure a log box instance">

	<cfscript>
		// The log levels enum as a public property
		this.levels = createObject("component","coldbox.system.logging.LogLevels");
		
		// Instance private scope
		instance = structnew();
		instance.appenders = createObject("java", "java.util.Collections").synchronizedMap(CreateObject("java","java.util.LinkedHashMap").init(3));
		instance.categories = structnew();
	</cfscript>

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="LogBoxConfig" hint="Constructor">
		<cfreturn this>
	</cffunction>

	<!--- addAppender --->
	<cffunction name="addAppender" output="false" access="public" returntype="void" hint="Add an appender configuration">
		<cfargument name="name" 		type="string"  required="true"  hint="A unique name for the appender to register. Only unique names can be registered per instance."/>
		<cfargument name="class" 		type="string"  required="true"  hint="The appender's class to register. We will create, init it and register it for you."/>
		<cfargument name="levelMin" 	type="numeric" required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="levelMax" 	type="numeric" required="false" default="5" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="The structure of properties to configure this appender with."/>
		<cfset instance.appenders[arguments.name] = arguments>
	</cffunction>
	
	<!--- addCategory --->
	<cffunction name="addCategory" output="false" access="public" returntype="void" hint="Add a new category configuration with appender(s).  Appenders MUST be defined first, else this method will throw an exception">
		<cfargument name="name" 		type="string"  required="true"  hint="A unique name for the appender to register. Only unique names can be registered per instance."/>
		<cfargument name="levelMin" 	type="numeric" required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="levelMax" 	type="numeric" required="false" default="5" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="appenders" 	type="string"  required="true"  hint="A list of appender names to configure this category with."/>
		<cfscript>
			var x = 1;
			
			// Verify Appenders first
			for(x=1; x lte listlen(arguments.appenders); x=x+1){
				if( NOT structKeyExists(instance.appenders, listGetAt(arguments.appenders,x)) ){
					$throw(message="Invalid appender",
						   detail="The appender #listGetAt(arguments.appenders,x)# has not been defined yet. Please define it first.",
						   type="LogBoxConfig.AppenderNotFound");
				}
			}
			// Add category registration
			instance.categories[arguments.name] = arguments;
		</cfscript>
	</cffunction>
	
	<!--- getCategory --->
	<cffunction name="getCategory" output="false" access="public" returntype="struct" hint="Get a specifed category definition">
		<cfargument name="name" type="string" required="true" hint="The category to retrieve"/>
		<cfreturn instance.categories[arguments.name]>
	</cffunction>
	
	<!--- categoryExists --->
	<cffunction name="categoryExists" output="false" access="public" returntype="boolean" hint="Check if a category definition exists">
		<cfargument name="name" type="string" required="true" hint="The category to retrieve"/>
		<cfreturn structKeyExists(instance.categories, arguments.name)>
	</cffunction>
	
	<!--- getCategories --->
	<cffunction name="getCategories" output="false" access="public" returntype="struct" hint="Get the configured categories">
		<cfreturn instance.categories>
	</cffunction>
	
	<!--- getappenders --->
	<cffunction name="getAppenders" output="false" access="public" returntype="struct" hint="Get all the appenders defined">
		<cfreturn instance.appenders>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------>


	<!--- Throw Facade --->
	<cffunction name="$throw" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
</cfcomponent>