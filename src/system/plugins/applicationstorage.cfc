<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	February 16,2007
Description :
	This is a plugin that enables the setting/getting of permanent variables in
	the application scope.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="applicationstorage"
			 hint="Application Storage plugin. It provides the user with a mechanism for permanent data storage using the application scope."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true"
			 cachetimeout="0">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="applicationstorage" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		
		<!--- Plugin Properties --->
		<cfset setpluginName("Application Storage")>
		<cfset setpluginVersion("1.0")>
		<cfset setpluginDescription("A permanent data storage plugin using the application scope.")>
		
		<!--- Lock Name --->
		<cfset setLockName( getController().getAppHash() & "_APPLICATION_STORAGE" )>
		
		<!--- Create App Storage --->
		<cfset createAppStorage()>
		
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="setVar" access="public" returntype="void" hint="Set a new permanent variable." output="false">
		<!--- ************************************************************* --->
		<cfargument name="name"  type="string" required="true" hint="The name of the variable.">
		<cfargument name="value" type="any"    required="true" hint="The value to set in the variable.">
		<!--- ************************************************************* --->
		<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
			<cfset Application.cbAppStorage[arguments.name] = arguments.value>
		</cflock>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getVar" access="public" returntype="any" hint="Get a new permanent variable. If the variable does not exist. The method returns blank." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" 		type="string"  required="true" 		hint="The variable name to retrieve.">
		<cfargument  name="default"  	type="any"     required="false"  	hint="The default value to set. If not used, a blank is returned." default="">
		<!--- ************************************************************* --->
		<cfif exists(arguments.name)>
			<cfreturn Application.cbAppStorage[arguments.name]>
		<cfelse>
			<cfreturn arguments.default>
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent application var." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfset var results = false>
		
		<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
			<cfset results = structdelete(Application.cbAppStorage, arguments.name, true)>
		</cflock>
		
		<cfreturn results>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="exists" access="public" returntype="boolean" hint="Checks wether the permanent variable exists." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfreturn structKeyExists(Application.cbAppStorage, arguments.name)>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="cleanAll" access="public" returntype="void" hint="Cleans the entire coldbox application storage" output="false">
		<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
			<cfset structClear(Application.cbAppStorage)>
		</cflock>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Create Storage --->
	<cffunction name="createStorage" access="public" returntype="void" hint="Create the app storage scope" output="false" >
		<!--- Create App Storage Scope --->
		<cflock name="#getLockName()#" type="exclusive" timeout="30" throwontimeout="true">
			<cfset application.cbAppStorage = structNew()>
		</cflock>
	</cffunction>

	<!--- get/set lockname --->
	<cffunction name="getlockName" access="private" output="false" returntype="string" hint="Get lockName">
		<cfreturn instance.lockName/>
	</cffunction>	
	<cffunction name="setlockName" access="private" output="false" returntype="void" hint="Set lockName">
		<cfargument name="lockName" type="string" required="true"/>
		<cfset instance.lockName = arguments.lockName/>
	</cffunction>

</cfcomponent>