<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	An error observer
----------------------------------------------------------------------->
<cfcomponent hint="This is a simple error observer" output="false">

	<cfproperty name="cache" inject="cachebox" scope="instance">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="Configure" access="public" returntype="void" hint="Configuration" output="false" >
		<!--- Nothing --->
		
	</cffunction>

<!------------------------------------------- INTERCEPTION POINTS ------------------------------------------->

	<cffunction name="preProcess" access="public" returntype="void" hint="My very own custom interception point. " output="false" >
		<!--- ************************************************************* --->
		<cfargument name="event">
		<cfargument name="interceptData">
		<!--- ************************************************************* --->
		<cfscript>
			log.debug("Cache in instance wired: #structKeyExists(instance,'cache')#");
			
			//writeDump(instance);abort;
		</cfscript>
	</cffunction>

</cfcomponent>