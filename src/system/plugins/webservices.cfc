<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is a webservices framework plugin.
	The refresh web service stubs code is thanks to Dave Stanten at
	Macromedia/Adobe.  dstanten@adobe.com


Modification History:
02/08/2006 - Updated refresws to look for the webservice in the configstruct first.
06/08/2006 - Updated for coldbox
07/29/2006 - Exception is thrown if web service is not found in the configuration structure.
----------------------------------------------------------------------->
<cfcomponent name="webservices" hint="The webservices framework plugin." extends="coldbox.system.plugin">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfset super.Init() />
		<cfset variables.instance.pluginName = "Web Services">
		<cfset variables.instance.pluginVersion = "1.0">
		<cfset variables.instance.pluginDescription = "This is a very useful web services utility plugin.">
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getWS" returntype="any" access="Public" hint="Get a web service's wsdl url from the configStruct according to which environment you are on." output="false">
	<!--- ************************************************************* --->
		<cfargument name="name" hint="The name of the web service. If the web service is not found an exception is thrown." type="string" required="Yes">
	<!--- ************************************************************* --->
		<cfif getSetting("Environment") eq "DEVELOPMENT">
			<cfif structKeyExists(getSetting("WebServices").DEV , arguments.name)>
				<cfreturn getSetting("WebServices").DEV[arguments.name]>
			</cfif>
		<cfelse>
			<cfif structKeyExists(getSetting("WebServices").PRO , arguments.name)>
				<cfreturn getSetting("WebServices").PRO[arguments.name]>
			</cfif>
		</cfif>
		<cfthrow type="Framework.plugins.webservices.WebServiceNotFoundException" message="The webservice #arguments.name# was not found in the configuration structure.">
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="getWSobj" access="Public"	hint="Get a reference to a webservice obj according to which environment you are on." output="false" returntype="any">
	<!--- ************************************************************* --->
		<cfargument name="name" hint="The name of the web service. If the web service is not found an exception is thrown" type="string" required="Yes">
	<!--- ************************************************************* --->
		<cfif getSetting("Environment") eq "DEVELOPMENT">
			<cfif structKeyExists(getSetting("WebServices").DEV , arguments.name)>
				<cfreturn CreateObject("webservice", getSetting("WebServices").DEV[arguments.name] )>
			</cfif>
		<cfelse>
			<cfif structKeyExists(getSetting("WebServices").PRO , arguments.name)>
				<cfreturn CreateObject("webservice", getSetting("WebServices").PRO[arguments.name] )>
			</cfif>
		</cfif>
		<cfthrow type="Framework.plugins.webservices.WebServiceNotFoundException" message="The webservice #arguments.name# was not found in the configuration structure.">
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="refreshWS" access="Public" hint="Refresh a web service stub object" output="false" returntype="void">
	<!--- ************************************************************* --->
		<cfargument name="webservice" hint="The name or wsdl URL of the web service to refresh" type="string" required="Yes">
	<!--- ************************************************************* --->
		<!--- Get the Webservice from the configStruct --->
		<cfset var ws = getWS(arguments.webservice)>
		<cfset var rpcService = "">
		<cfif ws neq "">
			<cfobject type="java" action="create" name="factory" class="coldfusion.server.ServiceFactory">
			<cfset rpcService = factory.XmlRpcService>
			<cfset rpcService.refreshWebService(ws)>
		<cfelse>
			<cfobject type="java" action="create" name="factory" class="coldfusion.server.ServiceFactory">
			<cfset rpcService = factory.XmlRpcService>
			<cfset rpcService.refreshWebService(arguments.webservice)>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>