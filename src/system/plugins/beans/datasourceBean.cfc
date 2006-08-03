<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model a coldfusion datasource connection setting.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="datasourceBean" hint="I model a datasource connection setting." output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfset variables.name = "">
	<cfset variables.dbtype = "">
	<cfset variables.username = "">
    <cfset variables.password = "" >

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" output="false" hint="I build a new datasource bean." returntype="any">
	    <!--- ************************************************************* --->
	    <cfargument name="datasourceStruct" 	type="struct" required="false" default="#structnew()#" hint="The structure holding the name,dbtype,username,and password variables." >
	    <!--- ************************************************************* --->
	    <cfif not structisEmpty(arguments.datasourceStruct)>
		    <cfset variables.name = arguments.datasourceStruct.name >
		    <cfset variables.dbtype = arguments.datasourceStruct.dbtype>
		    <cfset variables.username = arguments.datasourceStruct.username>
		    <cfset variables.password = arguments.datasourceStruct.password>
	    </cfif>
	    <cfreturn this >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="setname" access="public" return="void" output="false" hint="Set name of the datasource, this maps to the Coldfusion datasource name">
	  <cfargument name="value" type="string" >
	  <cfset variables.name=arguments.value >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getname" access="public" return="string" output="false" hint="Get the name">
	  <cfreturn variables.name >
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setDBType" access="public" return="void" output="false" hint="Set DBType">
	  <cfargument name="value" type="string" >
	  <cfset variables.dbtype=arguments.value >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getDBType" access="public" return="string" output="false" hint="Get DBType">
	  <cfreturn variables.dbtype >
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setUsername" access="public" return="void" output="false" hint="Set Username">
	  <cfargument name="value" type="string" >
	  <cfset variables.Username=arguments.value >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getUsername" access="public" return="string" output="false" hint="Get Username">
	  <cfreturn variables.Username >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="setPassword" access="public" return="void" output="false" hint="Set Password">
	  <cfargument name="value" type="string" >
	  <cfset variables.Password=arguments.value >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getPassword" access="public" return="string" output="false" hint="Get Password">
	  <cfreturn variables.Password >
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>