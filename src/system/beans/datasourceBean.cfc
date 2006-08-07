<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model a coldfusion datasource connection setting.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="datasourceBean" hint="I model a datasource connection setting." output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfset variables.instance = structnew()>
	<cfset variables.instance.name = "">
	<cfset variables.instance.dbtype = "">
	<cfset variables.instance.username = "">
    <cfset variables.instance.password = "" >

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" output="false" hint="I build a new datasource bean." returntype="any">
	    <!--- ************************************************************* --->
	    <cfargument name="datasourceStruct" 	type="struct" required="false" default="#structnew()#" hint="The structure holding the name,dbtype,username,and password variables." >
	    <!--- ************************************************************* --->
	    <cfif not structisEmpty(arguments.datasourceStruct)>
		    <cfset setInstance(arguments.datasourceStruct)>
	    </cfif>
	    <cfreturn this >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getInstance" access="public" returntype="any" output="false">
		<cfreturn variables.instance >
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setInstance" access="public" returntype="void" output="false">
		<cfargument name="instance" type="struct" required="true">
		<cfset variables.instance = arguments.instance>
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setname" access="public" return="void" output="false" hint="Set name of the datasource, this maps to the Coldfusion datasource name">
	  <cfargument name="value" type="string" >
	  <cfset variables.instance.name=arguments.value >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getname" access="public" return="string" output="false" hint="Get the name">
	  <cfreturn variables.instance.name >
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setDBType" access="public" return="void" output="false" hint="Set DBType">
	  <cfargument name="value" type="string" >
	  <cfset variables.instance.dbtype=arguments.value >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getDBType" access="public" return="string" output="false" hint="Get DBType">
	  <cfreturn variables.instance.dbtype >
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setUsername" access="public" return="void" output="false" hint="Set Username">
	  <cfargument name="value" type="string" >
	  <cfset variables.instance.Username=arguments.value >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getUsername" access="public" return="string" output="false" hint="Get Username">
	  <cfreturn variables.instance.Username >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="setPassword" access="public" return="void" output="false" hint="Set Password">
	  <cfargument name="value" type="string" >
	  <cfset variables.instance.Password=arguments.value >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getPassword" access="public" return="string" output="false" hint="Get Password">
	  <cfreturn variables.instance.Password >
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>