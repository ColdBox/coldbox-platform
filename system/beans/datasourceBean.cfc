<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model a coldfusion datasource connection setting.

Modification History:
01/28/2007 - Added the alias property and solved the java contract with correct arg.
----------------------------------------------------------------------->
<cfcomponent name="datasourceBean"
			 hint="I model a datasource connection setting."
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfscript>
		variables.instance = structnew();
		instance.name = "";
		instance.alias = "";
		instance.dbtype = "";
		instance.username = "";
	    instance.password = "" ;
	</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="init" access="public" output="false" hint="I build a new datasource bean." returntype="coldbox.system.beans.datasourceBean">
	    <!--- ************************************************************* --->
	    <cfargument name="datasourceStruct" 	type="struct" required="false" default="#structnew()#" hint="The structure holding the name,dbtype,username,and password variables." >
	    <!--- ************************************************************* --->
	    <cfif not structisEmpty(arguments.datasourceStruct)>
		    <cfset setMemento(arguments.datasourceStruct)>
	    </cfif>
	    <cfreturn this >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getMemento" access="public" returntype="any" output="false" hint="Get the memento">
		<cfreturn variables.instance >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setMemento" access="public" returntype="void" output="false" hint="Set the memento">
		<cfargument name="memento" type="struct" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setname" access="public" returntype="void" output="false" hint="Set name of the datasource, this maps to the Coldfusion datasource name">
	  <cfargument name="name" type="string" required="true">
	  <cfset instance.name=arguments.name >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getname" access="public" returntype="string" output="false" hint="Get the name">
	  <cfreturn instance.name >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setalias" access="public" returntype="void" output="false" hint="Set alias of the datasource, this is used for reference to the structure.">
	  <cfargument name="alias" type="string" required="true">
	  <cfset instance.alias=arguments.alias >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getalias" access="public" returntype="string" output="false" hint="Get the alias">
	  <cfreturn instance.alias >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setDBType" access="public" returntype="void" output="false" hint="Set DBType">
	  <cfargument name="dbtype" type="string" required="true">
	  <cfset instance.dbtype=arguments.dbtype >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getDBType" access="public" returntype="string" output="false" hint="Get DBType">
	  <cfreturn instance.dbtype >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setUsername" access="public" returntype="void" output="false" hint="Set Username">
	  <cfargument name="Username" type="string" required="true">
	  <cfset instance.Username=arguments.Username >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getUsername" access="public" returntype="string" output="false" hint="Get Username">
	  <cfreturn instance.Username >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setPassword" access="public" returntype="void" output="false" hint="Set Password">
	  <cfargument name="Password" type="string" required="true" >
	  <cfset instance.Password=arguments.Password >
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getPassword" access="public" returntype="string" output="false" hint="Get Password">
	  <cfreturn instance.Password >
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>