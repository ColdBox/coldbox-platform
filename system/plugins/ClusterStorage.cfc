<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Sana Ullah
Date     :	November 10,2008
Description :
	This is a plugin that enables the setting/getting of permanent variables in the cluster scope.

getVar(name,default):any
setVar(name,value):void
deleteVar(name):boolean
exists(name):boolean
clearAll():void
getStorage():struct
clearStorage():void

Blog Etnry (help/doc): http://www.railo.ch/blog/index.cfm/2008/7/6/Cluster-Scope

----------------------------------------------------------------------->
<cfcomponent name="ClusterStorage"
			 hint="Cluster Storage plugin. It provides the user with a mechanism for permanent data storage using the Cluster scope. This plugin creates a special variable in cluster scope that correctly identifies the coldbox app."
			 extends="coldbox.system.Plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="ClusterStorage" output="false">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.web.Controller">
		<!--- ************************************************************* --->
		<cfscript>
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("Cluster Storage");
			setpluginVersion("1.0");
			setpluginDescription("A permanent data storage plugin using the Cluster scope. Only supported by Railo");
			setpluginAuthor("Sana Ullah");
			setpluginAuthorURL("http://www.coldbox.org");
			
			/* Lock Name */
			instance.lockName = getController().getAppHash() & "_CLUSTER_STORAGE";
			instance.lockTimeout = 20;
			instance.clusterKey = safeName(getSetting("AppName")) & "_storage"; 
		
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
	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent cluster variable. Returns True if deleted." output="false">
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
	<cffunction name="clearAll" access="public" returntype="void" hint="Clear the entire coldbox cluster storage" output="false">
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
			return cluster[instance.clusterKey];
		</cfscript>
	</cffunction>
	
	<!--- remove Storage --->
	<cffunction name="removeStorage" access="public" returntype="void" hint="remove the entire storage from scope" output="false" >
		<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
			<cfset structDelete(cluster,instance.clusterKey)>
		</cflock>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Create Storage --->
	<cffunction name="createStorage" access="private" returntype="void" hint="Create the storage scope. Thread Safe" output="false" >
		<cfif not structKeyExists(cluster,instance.clusterKey)>
			<cflock name="#instance.lockName#" type="exclusive" timeout="#instance.lockTimeout#" throwontimeout="true">
				<cfif not structKeyExists(cluster,instance.clusterKey)>
					<cfset cluster[instance.clusterKey] = structNew()>
				</cfif>
			</cflock>
		</cfif>
	</cffunction>
	
	<!--- Var Safe Name --->
	<cffunction name="safeName" access="private" returntype="any" hint="Make a variable a safe var name" output="false" >
		<cfargument name="value"  type="any" required="true" hint="The value to make it var safe">
		<cfreturn reReplaceNoCase(arguments.value,"(\s|\W\D)","-","all")>
	</cffunction>

</cfcomponent>
