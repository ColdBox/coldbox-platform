<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	February 16,2007
Description :
	This is a plugin that enables the setting/getting of permanent variables in
	the application scope.

A ColdBox Storage Plugin implements the following methods:

getVar(name,default):any
setVar(name,value):void
deleteVar(name):boolean
exists(name):boolean
clearAll():void
getStorage():struct
clearStorage():void

----------------------------------------------------------------------->
<cfcomponent name="ApplicationStorage"
			 hint="Application Storage plugin. It provides the user with a mechanism for permanent data storage using the application scope."
			 extends="coldbox.system.Plugin"
			 output="false"
			 singleton="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="ApplicationStorage" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.web.Controller">
		<!--- ************************************************************* --->
		<cfscript>
			/* Init Plugin */
			super.Init(arguments.controller);

			/* Plugin Properties */
			setpluginName("Application Storage Plugin");
			setpluginVersion("2.0");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			setpluginDescription("A permanent data storage plugin using the application scope.");

			/* Lock Name */
			instance.lockName = getController().getAppHash() & "_APPLICATION_STORAGE";
			instance.lockTimeout = 20;

			/* Create Storage */
			createStorage();

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Set a variable --->
	<cffunction name="setVar" access="public" returntype="void" hint="Set a new permanent variable." output="false">
		<!--- ************************************************************* --->
		<cfargument name="name"  type="string" required="true" hint="The name of the variable.">
		<cfargument name="value" type="any"    required="true" hint="The value to set in the variable.">
		<!--- ************************************************************* --->
		<cfset var storage = getStorage()>
		<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfset storage[arguments.name] = arguments.value>
		</cflock>
	</cffunction>

	<!--- Get A Variable --->
	<cffunction name="getVar" access="public" returntype="any" hint="Get a new permanent variable. If the variable does not exist. The method returns blank unless using the default return argument." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" 		type="string"  required="true" 		hint="The variable name to retrieve.">
		<cfargument  name="default"  	type="any"     required="false"  	hint="The default value to set. If not used, a blank is returned." default="">
		<!--- ************************************************************* --->
		<cfset var storage = getStorage()>

		<cflock name="#instance.lockName#" type="readonly" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfscript>
				if ( structKeyExists( storage, arguments.name) )
					return storage[arguments.name];
				else
					return arguments.default;
			</cfscript>
		</cflock>
	</cffunction>

	<!--- Delete a variable --->
	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent application variable. Returns True if deleted." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfset var results = false>
		<cfset var storage = getStorage()>

		<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfset results = structdelete(storage, arguments.name, true)>
		</cflock>

		<cfreturn results>
	</cffunction>

	<!--- Exists check --->
	<cffunction name="exists" access="public" returntype="boolean" hint="Checks wether the permanent variable exists." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfreturn structKeyExists( getStorage(), arguments.name)>
	</cffunction>

	<!--- Clear All From Storage --->
	<cffunction name="clearAll" access="public" returntype="void" hint="Clear the entire coldbox application storage" output="false">
		<cfset var storage = getStorage()>

		<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfset structClear(storage)>
		</cflock>
	</cffunction>

	<!--- Get Storage --->
	<cffunction name="getStorage" access="public" returntype="struct" hint="Get the entire storage scope structure" output="false" >
		<cfscript>
			/* Verify Storage Exists */
			createStorage();
			/* Return Storage */
			return application.cbStorage;
		</cfscript>
	</cffunction>

	<!--- remove Storage --->
	<cffunction name="removeStorage" access="public" returntype="void" hint="remove the entire storage from scope" output="false" >
		<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfset structDelete(application, "cbStorage")>
		</cflock>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Create Storage --->
	<cffunction name="createStorage" access="private" returntype="void" hint="Create the app storage scope. Thread Safe" output="false" >
		<cfif not structKeyExists(application, "cbStorage")>
			<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
				<cfif not structKeyExists(application, "cbStorage")>
					<cfset application.cbStorage = structNew()>
				</cfif>
			</cflock>
		</cfif>
	</cffunction>

</cfcomponent>