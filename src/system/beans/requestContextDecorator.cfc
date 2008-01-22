<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/2/2007
Description :
	This is the base request context decorator object
----------------------------------------------------------------------->
<cfcomponent name="requestContextDecorator" hint="This is the base request context decorator" output="false" extends="coldbox.system.beans.requestContext">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
		
	<cffunction name="init" access="public" output="false" hint="constructor" returntype="any">
		<!--- ************************************************************* --->
		<cfargument name="oContext" 	 	type="any" 		required="true" hint="The original context we are decorating. coldbox.system.beans.requestContext">
		<cfargument name="struct1" 		 	type="any" 		required="true" hint="Usually the FORM scope">
		<cfargument name="struct2" 		 	type="any" 		required="true" hint="Usually the URL scope">
		<cfargument name="DefaultLayout" 	type="string" 	required="true">
		<cfargument name="DefaultView" 	 	type="string" 	required="true">
		<cfargument name="EventName" 	 	type="string" 	required="true"/>
		<cfargument name="ViewLayouts"   	type="struct"   required="true">
		<cfargument name="FolderLayouts"   	type="struct"   required="true">
		<!--- ************************************************************* --->
		<cfscript>
			//Composite the original context
			setRequestContext(arguments.oContext);
			//setup yourself now
			super.init(argumentCollection=arguments);
			//Configure this decorated request context.
			configure();
			return this;
		</cfscript>		
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Configure --->
	<cffunction name="Configure" access="public" returntype="void" hint="Override to provide a pseudo-constructor for your decorator" output="false" >
	</cffunction>
	
	<!--- Get the original context --->
	<cffunction name="getrequestContext" access="public" output="false" returntype="any" hint="Get the original request context. coldbox.system.beans.requestContext">
		<cfreturn instance.requestContext/>
	</cffunction>
	
	<!--- Set the original context --->
	<cffunction name="setrequestContext" access="public" output="false" returntype="void" hint="DO NOT OVERRIDE: Set the original request context.">
		<cfargument name="requestContext" type="any" required="true"/>
		<cfset instance.requestContext = arguments.requestContext/>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>