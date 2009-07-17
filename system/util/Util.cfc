<!-----------------------------------------------------------------------
Template : util.cfc
Author 	  : Luis Majano
Date       : Aug 29, 2007

Description :
	This is a utility method cfc, wished we had static methods.

Modification History:

---------------------------------------------------------------------->
<cfcomponent name="Util" output="false" hint="A utility method cfc">

	<cffunction name="ripExtension" access="public" returntype="string" output="false" hint="Rip the extension of a filename.">
		<cfargument name="filename" type="string" required="true">
		<cfreturn reReplace(arguments.filename,"\.[^.]*$","")>
	</cffunction>

	<cffunction name="throwit" access="public" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
	<cffunction name="rethrowit" access="public" returntype="void" hint="Rethrow an exception" output="false" >
		<cfargument name="throwObject" required="true" type="any" hint="The exception object">
		<cfthrow object="#arguments.throwObject#">
	</cffunction>
	
	<cffunction name="relocate" access="public" hint="Facade for cflocation" returntype="void">
		<cfargument name="url" 		required="true" 	type="string">
		<cfargument name="addtoken" required="false" 	type="boolean" default="false">
		<cflocation url="#arguments.url#" addtoken="#addtoken#">
	</cffunction>
	
	<cffunction name="dumpit" access="public" hint="Facade for cfmx dump" returntype="void">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>
		<cfdump var="#var#">
		<cfif arguments.isAbort><cfabort></cfif>
	</cffunction>
	
	<cffunction name="abortit" access="public" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>
	
	<cffunction name="includeit" access="public" hint="Facade for cfinclude" returntype="void" output="false">
		<cfargument name="template" type="string" required="yes">
		<cfinclude template="#template#">
	</cffunction>

</cfcomponent>