<cfcomponent name="formBean" hint="I model a simple form bean" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfset variables.instance = structnew()>
	<cfset variables.instance.fname = "">
	<cfset variables.instance.lname = "">
    <cfset variables.instance.email = "" >
	<cfset variables.instance.initDate = "">

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" output="false" hint="I return a form bean instance" returntype="any">
		<cfargument name="AppName" type="string" inject="coldbox:setting:AppName" hint="My setting name"/>
		<cfscript>
		instance.initDate = now();
		instance.fname = arguments.appName;
		return this;
		</cfscript>
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
	<cffunction name="setfname" access="public" return="void" output="false" hint="Set fname">
	  <cfargument name="fname" type="string" >
	  <cfset variables.instance.fname=arguments.fname >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getfname" access="public" return="string" output="false" hint="Get fname">
	  <cfreturn variables.instance.fname >
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setlname" access="public" return="void" output="false" hint="Set lname">
	  <cfargument name="lname" type="string" >
	  <cfset variables.instance.lname=arguments.lname >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getlname" access="public" return="string" output="false" hint="Get lname">
	  <cfreturn variables.instance.lname >
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setemail" access="public" return="void" output="false" hint="Set email">
	  <cfargument name="email" type="string" >
	  <cfset variables.instance.email=arguments.email >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getemail" access="public" return="string" output="false" hint="Get email">
	  <cfreturn variables.instance.email >
	</cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* --->
	<cffunction name="setinitDate" access="public" return="void" output="false" hint="Set initDate">
	  <cfargument name="initDate" type="string" >
	  <cfset variables.instance.initDate=arguments.initDate >
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getinitDate" access="public" return="string" output="false" hint="Get initDate">
	  <cfreturn variables.instance.initDate >
	</cffunction>
	<!--- ************************************************************* --->
	
</cfcomponent>