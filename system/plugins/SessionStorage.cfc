<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	February 16,2007
Description :
	This is a plugin that enables the setting/getting of permanent variables in
	the session scope.

getVar(name,default):any
setVar(name,value):void
deleteVar(name):boolean
exists(name):boolean
clearAll():void
getStorage():struct
clearStorage():void

----------------------------------------------------------------------->
<cfcomponent name="SessionStorage"
			 hint="Session Storage plugin. It provides the user with a mechanism for permanent data storage using the session scope."
			 extends="coldbox.system.Plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="SessionStorage" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			super.Init(arguments.controller);
			
			// Plugin Properties
			setpluginName("Session Storage");
			setpluginVersion("2.0");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			setpluginDescription("A permanent data storage plugin using the session scope.");
			
			// Lock Properties 
			instance.lockTimeout = 20;
			
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
		
		<cflock scope="session" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfset storage[arguments.name] = arguments.value>
		</cflock>
	</cffunction>

	<!--- Get A Variable --->
	<cffunction name="getVar" access="public" returntype="any" hint="Get a new permanent variable. If the variable does not exist. The method returns blank." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" 		type="string"  required="true" 		hint="The variable name to retrieve.">
		<cfargument  name="default"  	type="any"     required="false"  	hint="The default value to set. If not used, a blank is returned." default="">
		<!--- ************************************************************* --->
		<cfset var storage = getStorage()>
		<cfset var results = "">
		
		<cflock scope="session" type="readonly" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfscript>
				if ( structKeyExists( storage, arguments.name) )
					results = storage[arguments.name];
				else
					results = arguments.default;
			</cfscript>
		</cflock>
		
		<cfreturn results>
	</cffunction>

	<!--- Delete a variable --->
	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent session var." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfset var results = false>
		<cfset var storage = getStorage()>
		
		<cflock scope="session" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfset results = structdelete(storage, arguments.name, true)>
		</cflock>
		
		<cfreturn results>
	</cffunction>

	<!--- Exists check --->
	<cffunction name="exists" access="public" returntype="boolean" hint="Checks wether the permanent variable exists." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfif NOT isDefined("session") OR NOT structKeyExists(session,"cbStorage")>
			<cfreturn false>
		<cfelse>
			<cfreturn structKeyExists( getStorage(), arguments.name)>
		</cfif>
	</cffunction>

	<!--- Clear All From Storage --->
	<cffunction name="clearAll" access="public" returntype="void" hint="Clear the entire coldbox session storage" output="false">
		<cfset var storage = getStorage()>
		
		<cflock scope="session" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfset structClear(storage)>
		</cflock>
	</cffunction>
	
	<!--- Get Storage --->
	<cffunction name="getStorage" access="public" returntype="any" hint="Get the entire storage scope" output="false" >
		<cfscript>
			// Verify Storage Exists
			createStorage();
			// Return it
			return session.cbStorage;
		</cfscript>
	</cffunction>
	
	<!--- remove Storage --->
	<cffunction name="removeStorage" access="public" returntype="void" hint="remove the entire storage scope" output="false" >
		<cflock scope="session" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfset structDelete(session, "cbStorage")>
		</cflock>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Create Storage --->
	<cffunction name="createStorage" access="private" returntype="void" hint="Create the session storage scope" output="false" >
		<cfif isDefined("session") AND NOT structKeyExists(session, "cbStorage")>
			<!--- Create session Storage Scope --->
			<cflock scope="session" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
				<cfif not structKeyExists(session, "cbStorage")>
					<cfset session["cbStorage"] = structNew()>
				</cfif>
			</cflock>
		</cfif>
	</cffunction>

</cfcomponent>