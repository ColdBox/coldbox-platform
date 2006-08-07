<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is ColdBox's renderer plugin. In high traffic sites if using
	cfsavecontent for the generated view or layout, java.lang.illegalStateExceptions
	will be produced sporadically.  This has been logged with Adobe as a bug
	on the cfmodule tag.  Thus, it uses a output=true and a simple
	cfinclude.

Modification History:
10/13/2005 - Upgraded the reqCollection to the request scope.
12/23/2005 - Eliminate the dump of application structures.
01/03/2006 - Added var results = "" to init.
01/20/2006 - Removed Dumpvar, to debug template.
06/28/2006 - Updated for Coldbox.
07/27/2006 - renderview with view argument, added cfoutput support.
----------------------------------------------------------------------->
<cfcomponent name="renderer" hint="This plugin renders layouts, views, framework includes, etc." extends="coldbox.system.plugin">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" required="yes" hint="The reference to the framework controller">
			<cfset super.Init(arguments.controller) />
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="renderView"	access="Public" hint="Renders the current view." output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="view" required="false" default="#getvalue('currentView','')#" type="string" hint="If not passed in, the value in the currentView will be used. If passed in, try to render the view and return the contents.">	
		<!--- ************************************************************* --->
		<cfset var RenderedView = "">
		<cfset var AppDir = "">
		<cfmodule template="../includes/timer.cfm" timertag="Rendering View [#arguments.view#.cfm]">
			<!--- Dashboard exceptions --->
			<cfif CompareNocase(getSetting("AppName"),getSetting("DashboardName",1)) eq 0>
				<cfset AppDir = "../admin">
			<cfelse>
				<cfset AppDir = "/#getSetting("AppCFMXMapping")#">
			</cfif>
			<!--- Test if we have a view to render --->
			<cfif len(trim(arguments.view)) eq 0>
				<cfthrow type="Framework.plugins.renderer.ViewNotSetException" message="Framework.renderView: The currentview variable has not been set, therefore there is no view to render.">
			</cfif>
			<!--- Render UDf if no layout is used or if the arguments.view exits--->
			<cfif not valueExists("currentLayout") and arguments.view neq "">
				<!--- UDF Include Library Call --->
				<cfset includeUDF()>
			</cfif>
			<!--- Render the View --->
			<cfsavecontent variable="RenderedView"><cfoutput><cfinclude template="#AppDir#/views/#arguments.view#.cfm"></cfoutput></cfsavecontent>
		</cfmodule>
		<cfreturn RenderedView>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="renderLayout" access="Public" hint="Renders the current layout." output="false" returntype="Any">
		<cfset var RederedLayout = "">
		<cfset var AppDir = "">
		<cfmodule template="../includes/timer.cfm" timertag="Rendering Layout [#getvalue('currentLayout','')#]">
			<cfif CompareNocase(getSetting("AppName"),getSetting("DashboardName",1)) eq 0>
				<cfset AppDir = "../admin">
			<cfelse>
				<cfset AppDir = "/#getSetting("AppCFMXMapping")#">
			</cfif>
			<!--- Render With No Layout --->
			<cfif not valueExists("currentLayout")>
				<cfset RederedLayout = renderView()>
			<cfelse>
				<!--- UDF Library Call --->
				<cfset includeUDF()>
				<cfsavecontent variable="RederedLayout"><cfinclude template="#AppDir#/layouts/#getValue("currentLayout")#"></cfsavecontent>
			</cfif>
		</cfmodule>
		<cfreturn RederedLayout>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="renderDebugLog" access="public" hint="Return the debug log." output="false" returntype="Any">
		<cfset var RenderedDebugging = "">
		<cfsavecontent variable="RederedDebugging"><cfinclude template="../includes/debug.cfm"></cfsavecontent>
		<cfreturn RederedDebugging>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="renderBugReport" access="public" hint="Render a Bug Report." output="false" returntype="Any">
		<cfargument name="ExceptionBean" type="any" required="true">
		<cfset var BugReport = "">
		<cfset var Exception = arguments.ExceptionBean>
		<!--- test for custom bug report --->
		<cfif Exception.getErrortype() eq "application" and getSetting("CustomErrorTemplate") neq "">
			<cftry>
				<!--- Place exception in the requset Collection --->
				<Cfset setvalue("ExceptionBean",Exception)>
				<!--- Save the Custom Report --->
				<cfsavecontent variable="BugReport"><cfinclude template="/#getSetting("AppCFMXMapping")#/#getSetting("CustomErrorTemplate")#"></cfsavecontent>
				<cfcatch type="any">
					<cfset Exception = getPlugin("settings").ExceptionHandler(cfcatch,"Application","Error creating custom error template.")>
					<!--- Save the Bug Report --->
					<cfsavecontent variable="BugReport"><cfinclude template="../includes/BugReport.cfm"></cfsavecontent>
				</cfcatch>
			</cftry>
		<cfelse>
			<!--- Save the Bug Report --->
			<cfsavecontent variable="BugReport"><cfinclude template="../includes/BugReport.cfm"></cfsavecontent>
		</cfif>
		<cfreturn BugReport>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="includeUDF" access="private" hint="Includes the UDF Library if found and exists. Called only by the framework." output="false" returntype="void">
		<!--- check if UDFLibraryFile is defined  --->
		<cfif getSetting("UDFLibraryFile") neq "">
			<!--- Check if file exists on app's includes --->
			<cfif fileExists("#getSetting("ApplicationPath",1)#/#getSetting("UDFLibraryFile")#")>
				<cfinclude template="/#getSetting("AppCFMXMapping")#/#getSetting("UDFLibraryFile")#">
			<cfelseif fileExists(ExpandPath("#getSetting("UDFLibraryFile")#"))>
				<cfinclude template="#getSetting("UDFLibraryFile")#">
			<cfelse>
				<cfthrow type="Framework.plugins.renderer.UDFLibraryNotFoundException" message="Error loading UDFLibraryFile.  The file declared in the config.xml: #getSetting("UDFLibraryFile")# was not found in your application's include directory or in the following location: #ExpandPath(getSetting("UDFLibraryFile"))#. Please make sure you verify the file's location.">
			</cfif>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>