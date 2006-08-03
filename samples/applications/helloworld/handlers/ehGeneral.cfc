<!-----------------------------------------------------------------------Author 	 :	Luis MajanoDate     :	September 25, 2005Description : 				General handler for my hello application. Please remember to extend 	your event handler to the system eventhanlder using your colfusion	mapping.	example:		Mapping: coldboxSamples		Modification History:Sep/25/2005 - Luis Majano	-Created the template.-----------------------------------------------------------------------><cfcomponent name="ehGeneral" extends="coldboxSamples.system.eventhandler">	<!--- ************************************************************* --->	<cffunction name="init" access="public" returntype="Any">		<cfargument name="controller" required="yes" hint="The reference to the framework controller">			<cfset super.init(arguments.controller)>		<cfreturn this>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="onRequestStart" access="public">	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="onRequestEnd" access="public">	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="dspHello" access="public" returntype="string">		<!--- Do Your Logic Here --->		<cfset getPlugin("logger").tracer("Starting dspHello. Using default name")>		<cfset setValue("firstname",getSetting("Codename", true) & getSetting("Version", true) )>		<!--- Set the View To Display, after Logic --->		<cfset setView("vwHello")>		<cfset getPlugin("logger").tracer("View has been set")>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="doHello" access="public" returntype="string">		<cfset getPlugin("logger").tracer(getValue("firstname"))>		<!--- Do Your Logic Here --->		<cfif getValue("firstname") eq "">			<cfset setValue("firstname","Not Found")>		<cfelse>			<cfset setValue("firstname",getValue("firstname"))>		</cfif>		<!--- Set the View To Display, after Logic --->		<cfset setView("vwHelloRich")>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="doStartOver" access="public" returntype="string">		<!--- Do Your Logic Here --->		<cfset setNextEvent("ehGeneral.dspHello")>	</cffunction>	<!--- ************************************************************* --->	<!--- ************************************************************* --->	<cffunction name="dspPopup" access="public" returntype="string">		<!--- Do Your Logic Here --->		<cfset setView("vwTest",true)>	</cffunction>	<!--- ************************************************************* --->	</cfcomponent>