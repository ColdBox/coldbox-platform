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
		instance.appenders = arraynew(1);
	</cfscript>

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="LogBoxConfig" hint="Constructor">
		<cfreturn this>
	</cffunction>

	<!--- addLogger --->
	<cffunction name="add" output="false" access="public" returntype="void" hint="Add an appender configuration">
		<cfargument name="name" 		type="string"  required="true"  hint="A unique name for the appender to register. Only unique names can be registered per instance."/>
		<cfargument name="class" 		type="string"  required="true"  hint="The appender's class to register. We will create, init it and register it for you."/>
		<cfargument name="levelMin" 	type="numeric" required="false" default="0" hint="The default log level for this appender, by default it is 0. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="levelMax" 	type="numeric" required="false" default="5" hint="The default log level for this appender, by default it is 5. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="The structure of properties to configure this appender with."/>
		<cfset arrayAppend(getAppenders(),arguments)>
	</cffunction>
	
	<!--- getappenders --->
	<cffunction name="getAppenders" output="false" access="public" returntype="array" hint="Get all the appenders defined">
		<cfreturn instance.appenders>
	</cffunction>

</cfcomponent>