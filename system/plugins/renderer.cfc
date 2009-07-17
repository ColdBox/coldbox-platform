<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is ColdBox's renderer plugin.
----------------------------------------------------------------------->
<cfcomponent name="renderer"
			 hint="This service renders layouts, views, framework includes, etc."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="renderer" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		super.Init(arguments.controller);
		
		/* Plugin Properties */
		setpluginName("Renderer");
		setpluginVersion("2.1");
		setpluginDescription("This is the rendering service for ColdBox.");
		
		/* Set Conventions */
		instance.layoutsConvention = controller.getSetting("layoutsConvention",true);
		instance.viewsConvention = controller.getSetting("viewsConvention",true);
		instance.appMapping = controller.getSetting("AppMapping");
		instance.viewsExternalLocation = controller.getSetting('ViewsExternalLocation');
		
		/* Inject UDF For Views/Layouts */
		if(Len(Trim(controller.getSetting("UDFLibraryFile")))){
			includeUDF(controller.getSetting("UDFLibraryFile"));
		}
		
		/* Return renderer */
		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- purgeView --->
	<cffunction name="purgeView" output="false" access="public" returntype="void" hint="Purges a view from the cache, also see the cache manager for purging views.">
		<!--- ************************************************************* --->
		<cfargument name="view" required="true" type="string" hint="The view to purge from the cache">
		<!--- ************************************************************* --->
		<cfscript>
			/* Clear the view */
			getColdBoxOCM().clearView(arguments.view);
		</cfscript>
	</cffunction>

	<!--- Render the View --->
	<cffunction name="renderView"	access="Public" hint="Renders the current view." output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="view" 					required="false" type="string"  default=""		hint="If not passed in, the value in the currentView in the current RequestContext will be used.">
		<cfargument name="cache" 					required="false" type="boolean" default="false" hint="True if you want to cache the view.">
		<cfargument name="cacheTimeout" 			required="false" type="string"  default=""		hint="The cache timeout">
		<cfargument name="cacheLastAccessTimeout" 	required="false" type="string"  default="" 		hint="The last access timeout">
		<!--- ************************************************************* --->
		<cfset var cbox_RenderedView = "">
		<cfset var cbox_viewpath = "">
		<cfset var cbox_viewHelperPath = "">
		<!--- Local Event --->
		<cfset var Event = controller.getRequestService().getContext()>
		<!--- Create View Scope --->
		<cfset var rc = event.getCollection()>
		<!--- Cache Entries --->
		<cfset var cbox_cacheKey = "">
		<cfset var cbox_cacheEntry = "">
		<cfset var timerHash = 0>
		
		<!--- Test Default View --->
		<cfif len(trim(arguments.view)) eq 0>
			<cfset arguments.view = Event.getCurrentView()>
		</cfif>
		
		<!--- Test if we have a view to render --->
		<cfif len(trim(arguments.view)) eq 0>
			<cfthrow type="plugins.renderer.ViewNotSetException" 
				     message="The ""currentview"" variable has not been set, therefore there is no view to render." 
					 detail="Please remember to use the 'setView()' method in your handler.">
		</cfif>
		
		<!--- Setup the cache key --->
		<cfset cbox_cacheKey = getColdboxOCM().VIEW_CACHEKEY_PREFIX & arguments.view>
		
		<!--- Do we have a cached view?? --->
		<cfif getColdboxOCM().lookup(cbox_cacheKey)>
			<!--- Render The View --->
			<cfset timerHash = controller.getDebuggerService().timerStart("rendering Cached View [#arguments.view#.cfm]")>
				<cfset cbox_RenderedView = controller.getColdBoxOCM().get(cbox_cacheKey)>
			<cfset controller.getDebuggerService().timerEnd(timerHash)>
		<cfelse>
			<!--- The View Path is by convention or external?? --->
			<cfset cbox_viewpath = "/#instance.appMapping#/#instance.viewsConvention#/#arguments.view#.cfm">
			<!--- Check if View in Conventions --->
			<cfif not fileExists(expandPath(cbox_viewpath))>
				<!--- Set the Path to be the External Location --->
				<cfset cbox_viewpath = "#instance.viewsExternalLocation#/#arguments.view#.cfm">
				<!--- Verify the External Location now --->
				<cfif not fileExists(expandPath(cbox_viewpath))>
					<cfthrow message="View not located" 
							 detail="The view: #arguments.view#.cfm could not be located in the conventions folder or in the external location. Please verify the view name" 
							 type="plugins.renderer.ViewNotFound">
				</cfif>
				<!--- Helper? --->
				<cfif fileExists(expandPath("#instance.viewsExternalLocation#/#arguments.view#Helper.cfm"))>
					<cfset cbox_viewHelperPath =  "#instance.viewsExternalLocation#/#arguments.view#Helper.cfm">
				</cfif>				
			<cfelse>
				<!--- Do we have a conventions Helper --->
				<cfif fileExists(expandPath("/#instance.appMapping#/#instance.viewsConvention#/#arguments.view#Helper.cfm"))>
					<cfset cbox_viewHelperPath =  "/#instance.appMapping#/#instance.viewsConvention#/#arguments.view#Helper.cfm">
				</cfif>
			</cfif>
			
			<!--- Render The View & Its Helper --->
			<cfset timerHash = controller.getDebuggerService().timerStart("rendering View [#arguments.view#.cfm]")>
				<cfsavecontent variable="cbox_RenderedView"><cfif len(cbox_viewHelperPath)><cfoutput><cfinclude template="#cbox_viewHelperPath#"></cfoutput></cfif><cfoutput><cfinclude template="#cbox_viewpath#"></cfoutput></cfsavecontent>
			<cfset controller.getDebuggerService().timerEnd(timerHash)>
			
			<!--- Is this view cacheable by setting, and if its the view we need to cache. --->
			<cfif event.isViewCacheable() and (arguments.view eq event.getViewCacheableEntry().view)>
				<!--- Cache it baby!! --->
				<cfset cbox_cacheEntry = event.getViewCacheableEntry()>
				<cfset getColdboxOCM().set(getColdboxOCM().VIEW_CACHEKEY_PREFIX & cbox_cacheEntry.view,cbox_RenderedView,cbox_cacheEntry.timeout,cbox_cacheEntry.lastAccessTimeout)>
			<!--- Are we caching explicitly --->
			<cfelseif arguments.cache>
				<cfset getColdboxOCM().set(cbox_cacheKey,cbox_RenderedView,arguments.cacheTimeout,arguments.cacheLastAccessTimeout)>
			</cfif>
		</cfif>
		
		<!--- Return cached, or rendered view --->
		<cfreturn cbox_RenderedView>
	</cffunction>

	<!--- Render an external View --->
	<cffunction name="renderExternalView"	access="Public" hint="Renders an external view." output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="view" 					required="true"  type="string" hint="The full path to the view. This can be an expanded path or relative. Include extension.">
		<cfargument name="cache" 					required="false" type="boolean" default="false" hint="True if you want to cache the view.">
		<cfargument name="cacheTimeout" 			required="false" type="string"  default=""		hint="The cache timeout">
		<cfargument name="cacheLastAccessTimeout" 	required="false" type="string"  default="" 		hint="The last access timeout">
		<!--- ************************************************************* --->
		<cfset var cbox_RenderedView = "">
		<cfset var Event = controller.getRequestService().getContext()>
		<!--- Create View Scope --->
		<cfset var rc = event.getCollection()>
		<!--- Cache Entries --->
		<cfset var cbox_cacheKey = "">
		<cfset var cbox_cacheEntry = "">
		
		<!--- Setup the cache key --->
		<cfset cbox_cacheKey = getColdboxOCM().VIEW_CACHEKEY_PREFIX & "external-" & arguments.view>
		
		<!--- Do we have a cached view?? --->
		<cfif getColdboxOCM().lookup(cbox_cacheKey)>
			<!--- Render The View --->
			<cfset timerHash = controller.getDebuggerService().timerStart("rendering Cached External View [#arguments.view#.cfm]")>
				<cfset cbox_RenderedView = getColdBoxOCM().get(cbox_cacheKey)>
			<cfset controller.getDebuggerService().timerEnd(timerHash)>
		<cfelse>
			<cfset timerHash = controller.getDebuggerService().timerStart("rendering External View [#arguments.view#.cfm]")>
				<cftry>
					<!--- Render the View --->
					<cfsavecontent variable="cbox_RenderedView"><cfoutput><cfinclude template="#arguments.view#.cfm"></cfoutput></cfsavecontent>
					<!--- Catches --->
					<cfcatch type="missinginclude">
						<cfthrow type="plugins.renderer.RenderExternalViewNotFoundException" message="The external view: #arguments.view# cannot be found. Please check your paths." >
					</cfcatch>
					<cfcatch type="any">
						<cfrethrow />
					</cfcatch>
				</cftry>
			<cfset controller.getDebuggerService().timerEnd(timerHash)>
			
			<!--- Are we caching explicitly --->
			<cfif arguments.cache>
				<cfset getColdboxOCM().set(cbox_cacheKey,cbox_RenderedView,arguments.cacheTimeout,arguments.cacheLastAccessTimeout)>
			</cfif>
		</cfif>

		<cfreturn cbox_RenderedView>
	</cffunction>

	<!--- Render the layout --->
	<cffunction name="renderLayout" access="Public" hint="Renders the current layout + view Combinations if declared." output="false" returntype="any">
		<cfset var cbox_RederedLayout = "">
		<cfset var Event = controller.getRequestService().getContext()>
		<cfset var rc = event.getCollection()>
		<cfset var cbox_CurrentLayout = Event.getcurrentLayout()>
		
		<!--- Check if no view has been set. --->
		<cfif event.getCurrentView() eq "">
			<!--- Implicit Views according to event --->
			<cfset event.setView(replace(event.getCurrentEvent(),".","/","all"))>
			<!--- Check if default view set, if yes, then set it. --->
			<cfif event.getDefaultView() neq "">
				<!--- Set the Default View --->
				<cfset event.setView(event.getDefaultView())>
			</cfif>
			<!--- Reset the layout --->
			<cfset cbox_CurrentLayout = Event.getcurrentLayout()>
		</cfif>
		
		<!--- Render --->
		<cfset timerHash = controller.getDebuggerService().timerStart("rendering Layout [#cbox_CurrentLayout#]")>
			<cfif cbox_CurrentLayout eq "">
				<cfset cbox_RederedLayout = renderView()>
			<cfelse>
				<cfsavecontent variable="cbox_RederedLayout"><cfoutput><cfinclude template="/#instance.appMapping#/#instance.layoutsConvention#/#cbox_CurrentLayout#"></cfoutput></cfsavecontent>
			</cfif>
		<cfset controller.getDebuggerService().timerEnd(timerHash)>
		
		<!--- Return Layout --->
		<cfreturn cbox_RederedLayout>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Get Layouts Convention --->
	<cffunction name="getlayoutsConvention" access="private" output="false" returntype="string" hint="Get layoutsConvention">
		<cfreturn instance.layoutsConvention/>
	</cffunction>
	
	<!--- Get Views Convention --->
	<cffunction name="getviewsConvention" access="private" output="false" returntype="string" hint="Get viewsConvention">
		<cfreturn instance.viewsConvention/>
	</cffunction>
	
	<!--- Get App Mapping --->	
	<cffunction name="getappMapping" access="private" output="false" returntype="string" hint="Get appMapping">
		<cfreturn instance.appMapping/>
	</cffunction>	
	
</cfcomponent>