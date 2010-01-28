<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	This is ColdBox's Renderer plugin.
----------------------------------------------------------------------->
<cfcomponent hint="This service renders layouts, views, framework includes, etc."
			 extends="coldbox.system.Plugin"
			 output="false"
			 cache="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="Renderer" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			super.init(arguments.controller);
				
			// Set Conventions
			instance.layoutsConvention 			= controller.getSetting("layoutsConvention",true);
			instance.viewsConvention 			= controller.getSetting("viewsConvention",true);
			instance.appMapping 				= controller.getSetting("AppMapping");
			instance.viewsExternalLocation 		= controller.getSetting('ViewsExternalLocation');
			instance.layoutsExternalLocation 	= controller.getSetting('LayoutsExternalLocation');
			instance.modulesConfig				= controller.getSetting("modules");
			
			// Set event scope, we are not caching, so it is threadsafe.
			event = getRequestContext();
			
			// Create View Scopes
			rc = event.getCollection();
			prc = event.getCollection(private=true);
		
			// Inject UDF For Views/Layouts
			if(Len(Trim(controller.getSetting("UDFLibraryFile")))){
				includeUDF(controller.getSetting("UDFLibraryFile"));
			}
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Render the View --->
	<cffunction name="renderView"	access="Public" hint="Renders the current view." output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="view" 					required="false" type="string"  default=""		hint="If not passed in, the value in the currentView in the current RequestContext will be used.">
		<cfargument name="cache" 					required="false" type="boolean" default="false" hint="True if you want to cache the view.">
		<cfargument name="cacheTimeout" 			required="false" type="string"  default=""		hint="The cache timeout">
		<cfargument name="cacheLastAccessTimeout" 	required="false" type="string"  default="" 		hint="The last access timeout">
		<cfargument name="cacheSuffix" 				required="false" type="string"  default=""      hint="Add a cache suffix to the view cache entry. Great for multi-domain caching or i18n caching."/>
		<cfargument name="module" 					required="false" type="string"  default=""      hint="Explicitly render a layout from this module"/>
		<!--- ************************************************************* --->
		<cfset var cbox_RenderedView 	= "">
		<cfset var cbox_viewpath 		= "">
		<cfset var cbox_viewHelperPath 	= "">
		<!--- Cache Entries --->
		<cfset var cbox_cacheKey 		= "">
		<cfset var cbox_cacheEntry 		= "">
		<cfset var timerHash 			= 0>
		<cfset var interceptData 		= arguments>
		<cfset var locationUDF			= variables.locateView>
		
		<!--- Check if rendering set view or a-la-carte --->
		<cfif NOT len(arguments.view)>
			<cfset arguments.view = event.getCurrentView()>
			<!--- Is Module Call? --->
			<cfif len(event.getCurrentModule())>
				<cfset locationUDF = variables.locateModuleView>
			</cfif>
		</cfif>
		
		<!--- Check if explicit module view rendering --->
		<cfif len(arguments.module)><cfset locationUDF = variables.locateModuleView></cfif>
		
		<!--- Test if we have a view to render --->
		<cfif NOT len(trim(arguments.view)) >
			<cfthrow type="Renderer.ViewNotSetException" 
				     message="The ""currentview"" variable has not been set, therefore there is no view to render." 
					 detail="Please remember to use the 'setView()' method in your handler or pass in a view to render.">
		</cfif>
		
		<!--- preViewRender interception point --->
		<cfset announceInterception("preViewRender",interceptData)>
		
		<!--- Setup the cache key --->
		<cfset cbox_cacheKey = getColdboxOCM().VIEW_CACHEKEY_PREFIX & arguments.view & arguments.cacheSuffix>
		<cfif len(event.getCurrentModule())>
			<cfset cbox_cacheKey = getColdboxOCM().VIEW_CACHEKEY_PREFIX & event.getCurrentModule() & ":" & arguments.view & arguments.cacheSuffix>
		</cfif>
		
		<!--- Do we have a cached view?? --->
		<cfif getColdboxOCM().lookup(cbox_cacheKey)>
			<!--- Render The View --->
			<cfset timerHash = controller.getDebuggerService().timerStart("rendering Cached View [#arguments.view#.cfm]")>
			<cfset cbox_RenderedView = controller.getColdBoxOCM().get(cbox_cacheKey)>
			<cfset controller.getDebuggerService().timerEnd(timerHash)>
			
			<!--- postViewRender --->
			<cfset interceptData.renderedView = cbox_RenderedView>
			<cfset announceInterception("postViewRender",interceptData)>
			
			<cfreturn interceptData.renderedView>
		</cfif>
		
		<!--- Locate the view to render --->
		<cfset cbox_viewPath = locationUDF(arguments.view)>
		
		<!--- Check for helper convention? --->
		<cfif fileExists(expandPath(cbox_viewPath & "Helper.cfm"))>
			<cfset cbox_viewHelperPath = cbox_viewPath & "Helper.cfm">
		</cfif>
		
		<!--- Render The View & Its Helper --->
		<cfset timerHash = controller.getDebuggerService().timerStart("rendering View [#arguments.view#.cfm]")>
		<cfsavecontent variable="cbox_RenderedView"><cfif len(cbox_viewHelperPath)><cfoutput><cfinclude template="#cbox_viewHelperPath#"></cfoutput></cfif><cfoutput><cfinclude template="#cbox_viewpath#.cfm"></cfoutput></cfsavecontent>
		<cfset controller.getDebuggerService().timerEnd(timerHash)>
		
		<!--- postViewRender --->
		<cfset interceptData.renderedView = cbox_RenderedView>
		<cfset announceInterception("postViewRender",interceptData)>
		
		<!--- Is this view cacheable by setting, and if its the view we need to cache. --->
		<cfif event.isViewCacheable() and (arguments.view eq event.getViewCacheableEntry().view)>
			<!--- Cache it baby!! --->
			<cfset cbox_cacheEntry = event.getViewCacheableEntry()>
			<cfset cbox_cacheKey = getColdboxOCM().VIEW_CACHEKEY_PREFIX & cbox_cacheEntry.view & cbox_cacheEntry.cacheSuffix>
			<cfif len(event.getCurrentModule())>
				<cfset cbox_cacheKey = getColdboxOCM().VIEW_CACHEKEY_PREFIX & event.getCurrentModule() & ":" & cbox_cacheEntry.view & cbox_cacheEntry.cacheSuffix>
			</cfif>
			<cfset getColdboxOCM().set(cbox_cacheKey,
									   interceptData.renderedView,
									   cbox_cacheEntry.timeout,
									   cbox_cacheEntry.lastAccessTimeout)>
		<!--- Are we caching explicitly --->
		<cfelseif arguments.cache>
			<cfset getColdboxOCM().set(cbox_cacheKey,
									   interceptData.renderedView,
									   arguments.cacheTimeout,
									   arguments.cacheLastAccessTimeout)>
		</cfif>
		
		<!--- Return cached, or rendered view --->
		<cfreturn interceptData.renderedView>
	</cffunction>

	<!--- Render an external View --->
	<cffunction name="renderExternalView"	access="Public" hint="Renders an external view." output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="view" 					required="true"  type="string" hint="The full path to the view. This can be an expanded path or relative. Include extension.">
		<cfargument name="cache" 					required="false" type="boolean" default="false" hint="True if you want to cache the view.">
		<cfargument name="cacheTimeout" 			required="false" type="string"  default=""		hint="The cache timeout">
		<cfargument name="cacheLastAccessTimeout" 	required="false" type="string"  default="" 		hint="The last access timeout">
		<cfargument name="cacheSuffix" 				required="false" type="string"  default=""      hint="Add a cache suffix to the view cache entry. Great for multi-domain caching or i18n caching."/>
		<!--- ************************************************************* --->
		<cfset var cbox_RenderedView = "">
		<!--- Cache Entries --->
		<cfset var cbox_cacheKey = "">
		<cfset var cbox_cacheEntry = "">
		
		<!--- Setup the cache key --->
		<cfset cbox_cacheKey = getColdboxOCM().VIEW_CACHEKEY_PREFIX & "external-" & arguments.view & arguments.cacheSuffix>
		
		<!--- Do we have a cached view?? --->
		<cfif getColdboxOCM().lookup(cbox_cacheKey)>
			<!--- Render The View --->
			<cfset timerHash = controller.getDebuggerService().timerStart("rendering Cached External View [#arguments.view#.cfm]")>
				<cfset cbox_RenderedView = getColdBoxOCM().get(cbox_cacheKey)>
			<cfset controller.getDebuggerService().timerEnd(timerHash)>
			<cfreturn cbox_RenderedView>
		</cfif>	
		
		<cfset timerHash = controller.getDebuggerService().timerStart("rendering External View [#arguments.view#.cfm]")>
			<cftry>
				<!--- Render the View --->
				<cfsavecontent variable="cbox_RenderedView"><cfoutput><cfinclude template="#arguments.view#.cfm"></cfoutput></cfsavecontent>
				<!--- Catches --->
				<cfcatch type="missinginclude">
					<cfthrow type="Renderer.RenderExternalViewNotFoundException" message="The external view: #arguments.view# cannot be found. Please check your paths." >
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

		<cfreturn cbox_RenderedView>
	</cffunction>

	<!--- Render the layout --->
	<cffunction name="renderLayout" access="Public" hint="Renders the current layout + view Combinations if declared." output="false" returntype="any">
		<cfargument name="layout" type="any" 	required="false" hint="The explicit layout to use in rendering."/>
		<cfargument name="view"   type="any" 	required="false" default="" hint="The name of the view to passthrough as an argument so you can refer to it as arguments.view"/>
		<cfargument name="module" type="string" required="false" default="" hint="Explicitly render a layout from this module"/>
		<!--- Get Current Set Layout From Request Collection --->
		<cfset var cbox_currentLayout 	= implicitViewChecks()>
		<!--- Content Variables --->
		<cfset var cbox_RederedLayout 	= "">
		<cfset var cbox_timerhash 		= "">
		<cfset var locateUDF 			= variables.locateLayout>
		
		<!--- Check explicit layout rendering --->
		<cfif structKeyExists(arguments,"layout")>
			<cfset cbox_currentLayout = arguments.layout & ".cfm">
			<!--- Check if Explicit Module Layout Call --->
			<cfif len(arguments.module)><cfset locateUDF = variables.locateModuleLayout></cfif>
		<!--- Not explicit, then check if in module rendering? --->
		<cfelseif len(event.getCurrentModule())>
			<cfset locateUDF = variables.locateModuleLayout>
		</cfif>
		
		<!--- Start Timer --->
		<cfset cbox_timerhash = controller.getDebuggerService().timerStart("rendering Layout [#cbox_currentLayout#]")>
			
		<!--- If Layout is blank, then just delegate to the view --->
		<cfif len(cbox_currentLayout) eq 0>
			<cfset cbox_RederedLayout = renderView()>
		<cfelse>			
			<!--- RenderLayout --->
			<cfsavecontent variable="cbox_RederedLayout"><cfoutput><cfinclude template="#locateUDF(cbox_currentLayout)#"></cfoutput></cfsavecontent>
		</cfif>
		
		<!--- Stop Timer --->
		<cfset controller.getDebuggerService().timerEnd(cbox_timerhash)>
		
		<!--- Return Rendered Layout --->
		<cfreturn cbox_RederedLayout>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- implicitViewChecks --->
	<cffunction name="implicitViewChecks" output="false" access="private" returntype="any" hint="Does implicit view rendering checks">
		<cfscript>
			var layout = event.getCurrentLayout();
			var cEvent = event.getCurrentEvent();
			
			// Cleanup for modules
			cEvent = reReplaceNoCase(cEvent,"^([^:.]*):","");
			
			//Check if no view set?
			if( NOT len( event.getCurrentView() ) ){
				// Implicit views
				event.setView( lcase(replace(cEvent,".","/","all")) );
				
				// check if default view is set?
				if( len( event.getDefaultView() ) ){
					event.setView(event.getDefaultView());
				}
				
				// reset layout according to newly set views;
				layout = event.getCurrentLayout();				
			}
			
			return layout;		
		</cfscript>
	</cffunction>

	<!--- locateLayout --->
	<cffunction name="locateLayout" output="false" access="private" returntype="any" hint="Locate the layout to render">
		<cfargument name="layout" type="any" required="true" hint="The layout name"/>
		<cfscript>
			// Default path is the conventions
			var layoutPath 	  		= "/#instance.appMapping#/#instance.layoutsConvention#/#arguments.layout#";
			var extLayoutPath 		= "#instance.layoutsExternalLocation#/#arguments.layout#";
			var moduleName 			= event.getCurrentModule();
			var moduleLayoutPath 	= "";
			
			// If layout exists in module and this is a module call, then use module layout.
			if( len(moduleName) ){
				moduleLayoutPath 	= "#instance.modulesConfig[moduleName].mapping#/#instance.layoutsConvention#/#arguments.layout#";
				if( fileExists(expandPath(moduleLayoutPath)) ){				
					return moduleLayoutPath;
				}
			}
			
			// Check if layout does not exists in Conventions, but in the ext location
			if( NOT fileExists(expandPath(layoutPath)) AND fileExists(expandPath(extLayoutPath)) ){
				return extLayoutPath;
			}
			
			return layoutPath;
		</cfscript>
	</cffunction>
	
	<!--- locateModuleLayout --->
	<cffunction name="locateModuleLayout" output="false" access="private" returntype="any" hint="Locate the view to render using module logic">
		<cfargument name="layout" type="any" required="true" hint="The layout name" >
		<cfscript>
			var parentLayoutPath = "";
			var moduleLayoutPath = "";
			var moduleName = event.getCurrentModule();
			
			parentLayoutPath = "/#instance.appMapping#/#instance.layoutsConvention#/modules/#moduleName#/#arguments.layout#";
			moduleLayoutPath = "#instance.modulesConfig[moduleName].mapping#/layouts/#arguments.layout#";				
			
			// Check parent view order setup
			if( instance.modulesConfig[moduleName].layoutParentLookup ){
				// We check if layout is overriden in parent first.
				if( fileExists(expandPath(parentLayoutPath)) ){
					return parentLayoutPath;
				}
				// Check module
				if( fileExists(expandPath(moduleLayoutPath)) ){
					return moduleLayoutPath;
				}	
				// Return normal layout lookup
				return locateLayout(arguments.layout);		
			}
			
			// If we reach here then we are doing module lookup first then if not parent.
			if( fileExists(expandPath(moduleLayoutPath)) ){
				return moduleLayoutPath;
			}
			// We check if layout is overriden in parent first.
			if( fileExists(expandPath(parentLayoutPath)) ){
				return parentLayoutPath;
			}
			// Return normal layout lookup
			return locateLayout(arguments.layout);
		</cfscript>
	</cffunction>
	
	<!--- locateView --->
	<cffunction name="locateView" output="false" access="private" returntype="any" hint="Locate the view to render">
		<cfargument name="view" 		type="any" 		required="true" hint="The view name" >
		<cfscript>
			// Default path is the conventions
			var viewPath 	= "/#instance.appMapping#/#instance.viewsConvention#/#arguments.view#";
			var extViewPath = "#instance.viewsExternalLocation#/#arguments.view#";
			
			// Check if view does not exists in Conventions
			if( NOT fileExists(expandPath(viewPath & ".cfm")) AND fileExists(expandPath(extViewPath & ".cfm")) ){
				return extViewPath;
			}
			
			return viewPath;
		</cfscript>
	</cffunction>
	
	<!--- locateModuleView --->
	<cffunction name="locateModuleView" output="false" access="private" returntype="any" hint="Locate the view to render using module logic">
		<cfargument name="view" 		type="any" 		required="true" hint="The view name" >
		<cfscript>
			var parentViewPath = "";
			var moduleViewPath = "";
			var moduleName     = event.getCurrentModule();
			
			// Declare Locations
			parentViewPath = "/#instance.appMapping#/#instance.viewsConvention#/modules/#moduleName#/#arguments.view#";
			moduleViewPath = "#instance.modulesConfig[moduleName].mapping#/views/#arguments.view#";				
			
			// Check parent view order setup
			if( instance.modulesConfig[moduleName].viewParentLookup ){
				// We check if view is overriden in parent first.
				if( fileExists(expandPath(parentViewPath & ".cfm")) ){
					return parentViewPath;
				}
				// Not found, then just return module path, let the include throw exception if not found
				return moduleViewPath;				
			}
			
			// If we reach here then we are doing module lookup first then if not parent.
			if( fileExists(expandPath(moduleViewPath & ".cfm")) ){
				return moduleViewPath;
			}
			
			// Not found, then just return parent path, let the include throw exception if not found
			return parentViewPath;
		</cfscript>
	</cffunction>

	<!--- Get Layouts Convention --->
	<cffunction name="getLayoutsConvention" access="private" output="false" returntype="string" hint="Get layoutsConvention">
		<cfreturn instance.layoutsConvention/>
	</cffunction>
	
	<!--- Get Views Convention --->
	<cffunction name="getViewsConvention" access="private" output="false" returntype="string" hint="Get viewsConvention">
		<cfreturn instance.viewsConvention/>
	</cffunction>
	
	<!--- Get App Mapping --->	
	<cffunction name="getAppMapping" access="private" output="false" returntype="string" hint="Get appMapping">
		<cfreturn instance.appMapping/>
	</cffunction>	
	
</cfcomponent>