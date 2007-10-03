<!-----------------------------------------------------------------------
Template : util.cfc
Author 	  : Luis Majano
Date       : Aug 29, 2007

Description :
	This is a utility method cfc, wished we had static methods.

Modification History:

---------------------------------------------------------------------->
<cfcomponent name="util" output="false" hint="A utility method cfc">

	<cffunction name="throw" access="public" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
	<cffunction name="dump" access="public" hint="Facade for cfmx dump" returntype="void">
		<cfargument name="var" required="yes" type="any">
		<cfdump var="#var#">
	</cffunction>
	
	<cffunction name="abort" access="public" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>
	
	<cffunction name="include" access="public" hint="Facade for cfinclude" returntype="void" output="false">
		<cfargument name="template" type="string">
		<cfinclude template="#template#">
	</cffunction>

</cfcomponent>