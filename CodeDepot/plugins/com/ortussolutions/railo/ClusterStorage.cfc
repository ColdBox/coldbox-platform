<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Sana Ullah
Date     :	November 10,2008
Description :
	This is a plugin that enables the setting/getting of permanent variables in the cluster scope.

Modification History:

----------------------------------------------------------------------->
<!--- Blog Etnry (help/doc): http://www.railo.ch/blog/index.cfm/2008/7/6/Cluster-Scope --->
<cfcomponent name="ClusterStorage"
			 hint="Cluster Storage plugin. It provides the user with a mechanism for permanent data storage using the Cluster scope."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="ClusterStorage" output="false">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.controller">
		<!--- ************************************************************* --->
		<cfscript>
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("Cluster Storage");
			setpluginVersion("1.0");
			setpluginDescription("A permanent data storage plugin using the Cluster scope. Only supported by Railo");
			
			/* Lock Name */
			setLockName( getController().getAppHash() & "_CLUSTER_STORAGE" );
		
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
		<cflock name="#getLockName()#" type="exclusive" timeout="10" throwontimeout="true">
			<cfset cluster[arguments.name] = arguments.value>
		</cflock>
	</cffunction>

	<!--- Get A Variable --->
	<cffunction name="getVar" access="public" returntype="any" hint="Get a new permanent variable. If the variable does not exist. The method returns blank." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" 		type="string"  required="true" 		hint="The variable name to retrieve.">
		<cfargument  name="default"  	type="any"     required="false"  	hint="The default value to set. If not used, a blank is returned." default="">
		<!--- ************************************************************* --->
		<cflock name="#getLockName()#" type="readonly" timeout="10" throwontimeout="true">
			<cfscript>
				if ( structKeyExists( Cluster, arguments.name) )
					return cluster[arguments.name];
				else
					arguments.default;
			</cfscript>
		</cflock>
	</cffunction>

	<!--- Delete a variable --->
	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent application var." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfset var results = false>
		
		<cflock name="#getLockName()#" type="exclusive" timeout="10" throwontimeout="true">
			<cfset results = StructDelete(cluster, arguments.name, true)>
		</cflock>
		
		<cfreturn results>
	</cffunction>

	<!--- Exists check --->
	<cffunction name="exists" access="public" returntype="boolean" hint="Checks wether the permanent variable exists." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfreturn StructKeyExists( cluster, arguments.name)>
	</cffunction>

	<!--- Clear All From Storage --->
	<cffunction name="clearAll" access="public" returntype="void" hint="Clear the entire coldbox application storage" output="false">
		<cflock name="#getLockName()#" type="exclusive" timeout="10" throwontimeout="true">
			<cfset StructClear(cluster)>
		</cflock>
	</cffunction>
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- get/set lockname --->
	<cffunction name="getlockName" access="private" output="false" returntype="string" hint="Get lockName">
		<cfreturn instance.lockName/>
	</cffunction>	
	<cffunction name="setlockName" access="private" output="false" returntype="void" hint="Set lockName">
		<cfargument name="lockName" type="string" required="true"/>
		<cfset instance.lockName = arguments.lockName/>
	</cffunction>

</cfcomponent>
