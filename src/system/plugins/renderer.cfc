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

	<cffunction name="init" access="public" returntype="renderer" output="false">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("Renderer")>
		<cfset setpluginVersion("1.1")>
		<cfset setpluginDescription("This is the rendering service for ColdBox.")>
		
		<!--- Set Conventions --->
		<cfset instance.layoutsConvention = getController().getSetting("layoutsConvention",true)>
		<cfset instance.viewsConvention = getController().getSetting("viewsConvention",true)>
		<cfset instance.appMapping = getController().getSetting("AppMapping")>
		
		<!--- Inject UDF For Views/Layouts --->
		<cfset includeUDF(getController().getSetting("UDFLibraryFile"))>
		
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="renderView"	access="Public" hint="Renders the current view." output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="view" required="false" default="" type="string" hint="If not passed in, the value in the currentView in the current RequestContext will be used.">
		<!--- ************************************************************* --->
		<cfset var RenderedView = "">
		<cfset var Event = controller.getRequestService().getContext()>
		<cfset var rc = event.getCollection()>
		
		<!--- Test Default View --->
		<cfif arguments.view eq "">
			<cfset arguments.view = Event.getCurrentView()>
		</cfif>
		<!--- Test if we have a view to render --->
		<cfif arguments.view eq "">
			<cfthrow type="Framework.plugins.renderer.ViewNotSetException" message="The ""currentview"" variable has not been set, therefore there is no view to render." detail="Please remember to use the 'setView()' method in your handler.">
		</cfif>
			
		<cfmodule template="../includes/timer.cfm" timertag="Rendering View [#arguments.view#.cfm]">
			<!--- Render the View --->
			<cfsavecontent variable="RenderedView"><cfoutput><cfinclude template="/#getappMapping()#/#getViewsConvention()#/#arguments.view#.cfm"></cfoutput></cfsavecontent>
		</cfmodule>
		
		<cfreturn RenderedView>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="renderExternalView"	access="Public" hint="Renders an external view." output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="view" required="true" type="string" hint="The full path to the view. This can be an expanded path or relative. Include extension.">
		<!--- ************************************************************* --->
		<cfset var RenderedView = "">
		<cfset var Event = controller.getRequestService().getContext()>
		<cfset var rc = event.getCollection()>
		
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
		<cfset var Event = controller.getRequestService().getContext()>
		<cfset var rc = event.getCollection()>
		
		<!--- Check if no view has been set, if not, then set the default view --->
		<cfif event.getCurrentView() eq "">
			<cfset event.setView(event.getDefaultView())>
		</cfif>
		
		<cfmodule template="../includes/timer.cfm" timertag="Rendering Layout [#Event.getcurrentLayout()#]">
			<!--- Render With No Layout Test--->
			<cfif Event.getcurrentLayout() eq "">
				<cfset RederedLayout = renderView()>
			<cfelse>
				<cfsavecontent variable="RederedLayout"><cfinclude template="/#getappMapping()#/#getLayoutsConvention()#/#Event.getcurrentLayout()#"></cfsavecontent>
			</cfif>
		</cfmodule>
		
		<cfreturn RederedLayout>
	</cffunction>

	<!--- ************************************************************* --->

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="getlayoutsConvention" access="public" output="false" returntype="string" hint="Get layoutsConvention">
		<cfreturn instance.layoutsConvention/>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getviewsConvention" access="public" output="false" returntype="string" hint="Get viewsConvention">
		<cfreturn instance.viewsConvention/>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getappMapping" access="public" output="false" returntype="string" hint="Get appMapping">
		<cfreturn instance.appMapping/>
	</cffunction>
	
</cfcomponent>