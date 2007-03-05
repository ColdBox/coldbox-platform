<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

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
02/12/2007 - Migrated to 1.2.0 format
----------------------------------------------------------------------->
<cfcomponent name="renderer"
			 hint="This service renders layouts, views, framework includes, etc."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true"
			 cachetimeout="0">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="coldbox.system.plugin" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("Renderer")>
		<cfset setpluginVersion("1.1")>
		<cfset setpluginDescription("This is the rendering service for ColdBox.")>
		<cfset includeUDF()>
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="renderView"	access="Public" hint="Renders the current view." output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="view" required="false" default="" type="string" hint="If not passed in, the value in the currentView in the current RequestContext will be used.">
		<!--- ************************************************************* --->
		<cfset var RenderedView = "">
		<cfset var Context = controller.getRequestService().getContext()>

		<!--- Test Default View --->
		<cfif arguments.view eq "">
			<cfset arguments.view = Context.getValue("currentView","")>
		</cfif>

		<cfmodule template="../includes/timer.cfm" timertag="Rendering View [#arguments.view#.cfm]">
			<!--- Test if we have a view to render --->
			<cfif arguments.view eq "">
				<cfthrow type="Framework.plugins.renderer.ViewNotSetException" message="The ""currentview"" variable has not been set, therefore there is no view to render." detail="Please remember to use the 'setView()' method in your handler.">
			</cfif>
			<!--- Render the View --->
			<cfsavecontent variable="RenderedView"><cfoutput><cfinclude template="/#controller.getSetting("AppMapping")#/views/#arguments.view#.cfm"></cfoutput></cfsavecontent>
		</cfmodule>
		<cfreturn RenderedView>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="renderExternalView"	access="Public" hint="Renders an external view." output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="view" required="true" type="string" hint="The full path to the view. This can be an expanded path or relative. Include extension.">
		<!--- ************************************************************* --->
		<cfset var RenderedView = "">
		<cfset var Context = controller.getRequestService().getContext()>

		<cfmodule template="../includes/timer.cfm" timertag="Rendering View [#arguments.view#]">

			<cftry>
				<!--- Render the View --->
				<cfsavecontent variable="RenderedView"><cfoutput><cfinclude template="#arguments.view#"></cfoutput></cfsavecontent>
				<!--- Catches --->
				<cfcatch type="missinginclude">
					<cfthrow type="Framework.plugin.renderer.RenderExternalViewNotFoundException" message="The external view: #arguments.view# cannot be found. Please check your paths." >
				</cfcatch>
				<cfcatch type="any">
					<cfthrow type="Framework.plugin.renderer.RenderExternalViewInvalidException" message="The external view: #arguments.view# threw an invalid exception when redering." >
				</cfcatch>
			</cftry>

		</cfmodule>
		<cfreturn RenderedView>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="renderLayout" access="Public" hint="Renders the current layout." output="false" returntype="Any">
		<cfset var RederedLayout = "">
		<cfset var Context = controller.getRequestService().getContext()>

		<cfmodule template="../includes/timer.cfm" timertag="Rendering Layout [#Context.getvalue('currentLayout','')#]">
			<!--- Render With No Layout --->
			<cfif not Context.valueExists("currentLayout")>
				<cfset RederedLayout = renderView()>
			<cfelse>
				<cfsavecontent variable="RederedLayout"><cfinclude template="/#controller.getSetting("AppMapping")#/layouts/#Context.getValue("currentLayout")#"></cfsavecontent>
			</cfif>
		</cfmodule>
		<cfreturn RederedLayout>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="renderDebugLog" access="public" hint="Return the debug log." output="false" returntype="Any">
		<cfset var RenderedDebugging = "">
		<cfset var Context = controller.getRequestService().getContext()>
		<cfsavecontent variable="RederedDebugging"><cfinclude template="../includes/debug.cfm"></cfsavecontent>
		<cfreturn RederedDebugging>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="renderBugReport" access="public" hint="Render a Bug Report." output="false" returntype="Any">
		<cfargument name="ExceptionBean" type="any" required="true">
		<cfset var BugReport = "">
		<cfset var Exception = arguments.ExceptionBean>
		<cfset var Context = controller.getRequestService().getContext()>
		<!--- test for custom bug report --->
		<cfif Exception.getErrortype() eq "application" and controller.getSetting("CustomErrorTemplate") neq "">
			<cftry>
				<!--- Place exception in the requset Collection --->
				<Cfset Context.setvalue("ExceptionBean",Exception)>
				<!--- Save the Custom Report --->
				<cfsavecontent variable="BugReport"><cfinclude template="/#controller.getSetting("AppMapping")#/#controller.getSetting("CustomErrorTemplate")#"></cfsavecontent>
				<cfcatch type="any">
					<cfset Exception = controller.ExceptionHandler(cfcatch,"Application","Error creating custom error template.")>
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

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="includeUDF" access="private" hint="Includes the UDF Library if found and exists. Called only by the framework." output="false" returntype="void">
		<!--- check if UDFLibraryFile is defined  --->
		<cfif controller.getSetting("UDFLibraryFile") neq "">
			<!--- Check if file exists on app's includes --->
			<cfif fileExists("#controller.getSetting("ApplicationPath",1)#/#controller.getSetting("UDFLibraryFile")#")>
				<cfinclude template="/#controller.getSetting("AppMapping")#/#controller.getSetting("UDFLibraryFile")#">
			<cfelseif fileExists(ExpandPath("#controller.getSetting("UDFLibraryFile")#"))>
				<cfinclude template="#controller.getSetting("UDFLibraryFile")#">
			<cfelse>
				<cfthrow type="Framework.plugins.renderer.UDFLibraryNotFoundException" message="Error loading UDFLibraryFile.  The file declared in the config.xml: #controller.getSetting("UDFLibraryFile")# was not found in your application's include directory or in the following location: #ExpandPath(controller.getSetting("UDFLibraryFile"))#. Please make sure you verify the file's location.">
			</cfif>
		</cfif>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>