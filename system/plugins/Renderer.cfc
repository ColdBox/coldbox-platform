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
			instance.debuggerService			= controller.getDebuggerService();
			// Template Cache
			instance.templateCache 				= controller.getColdboxOCM("template");
			instance.layoutsRefMap				= controller.getSetting("layoutsRefMap");
			instance.viewsRefMap				= controller.getSetting("viewsRefMap");
			// Discovery caching is tied to handlers for discovery.
			instance.isDiscoveryCaching			= controller.getSetting("handlerCaching");
			
			// Set event scope, we are not caching, so it is threadsafe.
			event 	= getRequestContext();

			// Create View Scopes
			rc 		= event.getCollection();
			prc 	= event.getCollection(private=true);

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
		<cfargument name="view" 					required="false" type="any"  default=""			hint="If not passed in, the value in the currentView in the current RequestContext will be used">
		<cfargument name="cache" 					required="false" type="any"  default="false" 	hint="True if you want to cache the view">
		<cfargument name="cacheTimeout" 			required="false" type="any"  default=""			hint="The cache timeout for the view contents">
		<cfargument name="cacheLastAccessTimeout" 	required="false" type="any"  default="" 		hint="The last access timeout for the view contents">
		<cfargument name="cacheSuffix" 				required="false" type="any"  default=""     	hint="Add a cache suffix to the view cache entry. Great for multi-domain caching or i18n caching."/>
		<cfargument name="module" 					required="false" type="any"  default=""      	hint="Explicitly render a view from this module by passing the module name"/>
		<!--- ************************************************************* --->
		<cfscript>
			var cbox_RenderedView 		= "";
			var cbox_viewpath 			= "";
			var cbox_viewHelperPath	 	= "";
			var cbox_local				= structnew();
			var cbox_cacheKey 			= "";
			var cbox_cacheEntry 		= "";
			var cbox_timerHash 			= 0;
			var cbox_iData 				= arguments;
			var cbox_locationUDF		= variables.locateView;
			var cbox_explicitModule 	= false;
			var cbox_viewLocationKey 	= "";
		
			// If no incoming explicit module call, default the value to the one in the request context for convenience
			if( NOT len(arguments.module) ){
				// if no module is execution, this will be empty anyways.
				arguments.module = event.getCurrentModule();
			}
			else{
				cbox_explicitModule = true;
			}
			
			// Rendering an explicit view or do we need to get the view from the context?
			if( NOT len(arguments.view) ){ arguments.view = event.getCurrentView();	}
			
			// Do we have a view To render? Else throw exception
			if( NOT len(arguments.view) ){
				$throw(message="The ""currentview"" variable has not been set, therefore there is no view to render.",
					   detail="Please remember to use the 'event.setView()' method in your handler or pass in a view to render.",
					   type="Renderer.ViewNotSetException");
			}
			
			// Change the location algorithm if in module mode
			if( len(arguments.module)  ){ cbox_locationUDF = variables.locateModuleView; }
			
			// Announce preViewRender interception
			announceInterception("preViewRender", cbox_iData);
			
			// Prepare caching arguments if doing implicit caching, and the view to render is the same as the implicitly cached.
			cbox_cacheEntry = event.getViewCacheableEntry();
			if( event.isViewCacheable() AND (arguments.view eq cbox_cacheEntry.view) ){
				arguments.cache						= true;
				arguments.cacheTimeout				= cbox_cacheEntry.timeout;
				arguments.cacheLastAccessTimeout	= cbox_cacheEntry.lastAccessTimeout;
				arguments.cacheSuffix 				= cbox_cacheEntry.cacheSuffix;
				
			}
			
			// Prepare caching key
			cbox_cacheKey = instance.templateCache.VIEW_CACHEKEY_PREFIX & event.getCurrentModule() & ":" & arguments.view & arguments.cacheSuffix;
			
			// Is the view already cached?
			if( instance.templateCache.lookup(cbox_cacheKey) ){
				// Render it out
				cbox_timerHash = instance.debuggerService.timerStart("rendering Cached View [#arguments.view#.cfm]");
				cbox_renderedView = instance.templateCache.get(cbox_cacheKey);
				instance.debuggerService.timerEnd(cbox_timerHash);
				// Post View Render Interception
				cbox_iData.renderedView = cbox_RenderedView;
				announceInterception("postViewRender", cbox_iData);
				// Return it
				return cbox_iData.renderedView;
			}
			
			// View is not cached, so let's render it out			
			//Layout location key
			cbox_viewLocationKey = arguments.view & arguments.module & cbox_explicitModule;
			// Return Cached Entry if it exists
			if( NOT structkeyExists(instance.viewsRefMap,"cbox_viewLocationKey") OR NOT instance.isDiscoveryCaching){
				// Locate the view to render according to discovery algorithm
				instance.viewsRefMap[cbox_viewLocationKey] = cbox_locationUDF(arguments.view,arguments.module,cbox_explicitModule);
			}
			cbox_viewPath = instance.viewsRefMap[cbox_viewLocationKey];
			
			// Check for view helper convention
			cbox_local.dPath = getDirectoryFromPath(cbox_viewPath);
			if( fileExists(expandPath(cbox_viewPath & "Helper.cfm")) ){
				cbox_viewHelperPath = cbox_viewPath & "Helper.cfm";
			}
			// Check for directory helper convention
			else if( fileExists( expandPath( cbox_local.dPath & listLast(cbox_local.dPath,"/") & "Helper.cfm" ) ) ){
				cbox_viewHelperPath = cbox_local.dPath & listLast(cbox_local.dPath,"/") & "Helper.cfm";
			}
		
		</cfscript>

		<!--- Render The View & Its Helpers --->
		<cfset cbox_timerHash = instance.debuggerService.timerStart("rendering View [#arguments.view#.cfm]")>
		<cfsavecontent variable="cbox_RenderedView"><cfif len(cbox_viewHelperPath)><cfoutput><cfinclude template="#cbox_viewHelperPath#"></cfoutput></cfif><cfoutput><cfinclude template="#cbox_viewpath#.cfm"></cfoutput></cfsavecontent>
		<cfset instance.debuggerService.timerEnd(cbox_timerHash)>

		<cfscript>
			// Post View Render Interception point
			cbox_iData.renderedView = cbox_RenderedView;
			announceInterception("postViewRender",cbox_iData);
			
			// Are we caching view
			if ( arguments.cache ){
				instance.templateCache.set(cbox_cacheKey,cbox_iData.renderedView,arguments.cacheTimeout,arguments.cacheLastAccessTimeout);
			}
			
			// Return view content
			return cbox_iData.renderedView;
		</cfscript>
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
		<cfset cbox_cacheKey = instance.templateCache.VIEW_CACHEKEY_PREFIX & "external-" & arguments.view & arguments.cacheSuffix>

		<!--- Do we have a cached view?? --->
		<cfif instance.templateCache.lookup(cbox_cacheKey)>
			<!--- Render The View --->
			<cfset cbox_timerHash = instance.debuggerService.timerStart("rendering Cached External View [#arguments.view#.cfm]")>
				<cfset cbox_RenderedView = instance.templateCache.get(cbox_cacheKey)>
			<cfset instance.debuggerService.timerEnd(cbox_timerHash)>
			<cfreturn cbox_RenderedView>
		</cfif>

		<cfset cbox_timerHash = instance.debuggerService.timerStart("rendering External View [#arguments.view#.cfm]")>
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
		<cfset instance.debuggerService.timerEnd(cbox_timerHash)>

		<!--- Are we caching explicitly --->
		<cfif arguments.cache>
			<cfset instance.templateCache.set(cbox_cacheKey,cbox_RenderedView,arguments.cacheTimeout,arguments.cacheLastAccessTimeout)>
		</cfif>

		<cfreturn cbox_RenderedView>
	</cffunction>

	<!--- Render the layout --->
	<cffunction name="renderLayout" access="Public" hint="Renders the current layout + view Combinations if declared." output="false" returntype="any">
		<cfargument name="layout" type="any" 	required="false" hint="The explicit layout to use in rendering"/>
		<cfargument name="view"   type="any" 	required="false" default="" hint="The name of the view to passthrough as an argument so you can refer to it as arguments.view"/>
		<cfargument name="module" type="any"    required="false" default="" hint="Explicitly render a layout from this module by passing its module name"/>
		
		<cfset var cbox_currentLayout 		= implicitViewChecks()>
		<cfset var cbox_RederedLayout 		= "">
		<cfset var cbox_timerhash 			= "">
		<cfset var cbox_locateUDF 			= variables.locateLayout>
		<cfset var cbox_explicitModule  	= false>
		<cfset var cbox_layoutLocationKey 	= "">
		
		<!--- Module Default Value --->
		<cfif NOT len(arguments.module)>
			<cfset arguments.module = event.getCurrentModule()>
		<cfelse>
			<cfset cbox_explicitModule = true>
		</cfif>

		<!--- Check explicit layout rendering --->
		<cfif structKeyExists(arguments,"layout")>
			<!--- Check if any length on incoming layout --->
			<cfif len ( arguments.layout )>
				<cfset cbox_currentLayout = arguments.layout & ".cfm">
			<cfelse>
				<cfset cbox_currentLayout = "">
			</cfif>
		</cfif>
		
		<!--- Choose location algorithm if in module mode --->
		<cfif len(arguments.module)>
			<cfset cbox_locateUDF = variables.locateModuleLayout>
		</cfif>

		<!--- Start Timer --->
		<cfset cbox_timerhash = instance.debuggerService.timerStart("rendering Layout [#cbox_currentLayout#]")>

		<!--- If Layout is blank, then just delegate to the view --->
		<cfif len(cbox_currentLayout) eq 0>
			<cfset cbox_RederedLayout = renderView()>
		<cfelse>
			
			<cfscript>
			//Layout location key
			cbox_layoutLocationKey = cbox_currentLayout & arguments.module & cbox_explicitModule;
			// Return Cached Entry if it exists
			if( NOT structkeyExists(instance.layoutsRefMap,"cbox_layoutLocationKey") OR NOT instance.isDiscoveryCaching){
				instance.layoutsRefMap[cbox_layoutLocationKey] = cbox_locateUDF(cbox_currentLayout,arguments.module,cbox_explicitModule);
			}
			</cfscript>
				
			<!--- RenderLayout --->
			<cfsavecontent variable="cbox_RederedLayout"><cfoutput><cfinclude template="#instance.layoutsRefMap[cbox_layoutLocationKey]#"></cfoutput></cfsavecontent>
		</cfif>

		<!--- Stop Timer --->
		<cfset instance.debuggerService.timerEnd(cbox_timerhash)>

		<!--- Return Rendered Layout --->
		<cfreturn cbox_RederedLayout>
	</cffunction>

	<!--- locateLayout --->
	<cffunction name="locateLayout" output="false" access="public" returntype="any" hint="Locate the layout to render">
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
	<cffunction name="locateModuleLayout" output="false" access="public" returntype="any" hint="Locate the view to render using module logic">
		<cfargument name="layout" 			type="any" 		required="true"  hint="The layout name to discover" >
		<cfargument name="module" 			type="any" 		required="false" default="" hint="The name of the module we are searching for"/>
		<cfargument name="explicitModule" 	type="boolean" 	required="false" default="false" hint="Are we locating explicitly or implicitly for a module layout"/>
		<cfscript>
			var parentModuleLayoutPath 	= "";
			var parentCommonLayoutPath 	= "";
			var moduleLayoutPath 		= "";
			var moduleName 		 		= "";
			
			// Explicit Module layout lookup?
			if( len(arguments.module) and arguments.explicitModule ){
				return "#instance.modulesConfig[arguments.module].mapping#/#instance.modulesConfig[arguments.module].conventions.layoutsLocation#/#arguments.layout#";
			}
			
			// Declare Locations
			moduleName 	     		= event.getCurrentModule();
			parentModuleLayoutPath 	= "/#instance.appMapping#/#instance.layoutsConvention#/modules/#moduleName#/#arguments.layout#";
			parentCommonLayoutPath 	= "/#instance.appMapping#/#instance.layoutsConvention#/modules/#arguments.layout#";
			moduleLayoutPath 		= "#instance.modulesConfig[moduleName].mapping#/#instance.modulesConfig[moduleName].conventions.layoutsLocation#/#arguments.layout#";

			// Check parent view order setup
			if( instance.modulesConfig[moduleName].layoutParentLookup ){
				// We check if layout is overriden in parent first.
				if( fileExists(expandPath(parentModuleLayoutPath)) ){
					return parentModuleLayoutPath;
				}
				// Check if parent has a common layout override
				if( fileExists(expandPath(parentCommonLayoutPath)) ){
					return parentCommonLayoutPath;
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
			if( fileExists(expandPath(parentModuleLayoutPath)) ){
				return parentModuleLayoutPath;
			}
			// Check if parent has a common layout override
			if( fileExists(expandPath(parentCommonLayoutPath)) ){
				return parentCommonLayoutPath;
			}
			// Return normal layout lookup
			return locateLayout(arguments.layout);
		</cfscript>
	</cffunction>

	<!--- locateView --->
	<cffunction name="locateView" output="false" access="public" returntype="any" hint="Locate the view to render">
		<cfargument name="view" 		type="any" 		required="true" 	hint="The view name" >
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
	<cffunction name="locateModuleView" output="false" access="public" returntype="any" hint="Locate the view to render using module logic">
		<cfargument name="view" 			type="any" 		required="true"  hint="The view name" >
		<cfargument name="module" 			type="any"	    required="false" default="" hint="The name of the module to explicity look for a view"/>
		<cfargument name="explicitModule" 	type="boolean" 	required="false" default="false" hint="Are we locating explicitly or implicitly for a module layout"/>
		<cfscript>
			var parentModuleViewPath = "";
			var parentCommonViewPath = "";
			var moduleViewPath = "";
			var moduleName     = "";
			
			// Explicit Module view lookup?
			if( len(arguments.module) and arguments.explicitModule){
				return "#instance.modulesConfig[arguments.module].mapping#/#instance.modulesConfig[arguments.module].conventions.viewsLocation#/#arguments.view#";
			}
				
			// Declare Locations
			moduleName     = event.getCurrentModule();
			parentModuleViewPath = "/#instance.appMapping#/#instance.viewsConvention#/modules/#moduleName#/#arguments.view#";
			parentCommonViewPath = "/#instance.appMapping#/#instance.viewsConvention#/modules/#arguments.view#";
			moduleViewPath = "#instance.modulesConfig[moduleName].mapping#/#instance.modulesConfig[moduleName].conventions.viewsLocation#/#arguments.view#";

			// Check parent view order setup
			if( instance.modulesConfig[moduleName].viewParentLookup ){
				// We check if view is overriden in parent first.
				if( fileExists(expandPath(parentModuleViewPath & ".cfm")) ){
					return parentModuleViewPath;
				}
				// Check if parent has a common view override
				if( fileExists(expandPath(parentCommonViewPath & ".cfm")) ){
					return parentCommonViewPath;
				}
				// Check module for view
				if( fileExists(expandPath(moduleViewPath & ".cfm")) ){
					return moduleViewPath;
				}
				// Return normal view lookup
				return locateView(arguments.view);
			}

			// If we reach here then we are doing module lookup first then if not parent.
			if( fileExists(expandPath(moduleViewPath & ".cfm")) ){
				return moduleViewPath;
			}
			// We check if view is overriden in parent first.
			if( fileExists(expandPath(parentModuleViewPath & ".cfm")) ){
				return parentModuleViewPath;
			}
			// Check if parent has a common view override
			if( fileExists(expandPath(parentCommonViewPath & ".cfm")) ){
				return parentCommonViewPath;
			}

			// Return normal view lookup
			return locateView(arguments.view);
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- implicitViewChecks --->
	<cffunction name="implicitViewChecks" output="false" access="private" returntype="any" hint="Does implicit view rendering checks">
		<cfscript>
			var layout = event.getCurrentLayout();
			var cEvent = event.getCurrentEvent();
			
			// Cleanup for modules
			cEvent     = reReplaceNoCase(cEvent,"^([^:.]*):","");

			//Check if no view set?
			if( NOT len( event.getCurrentView() ) ){
				
				// check if default view is set?
				if( len( event.getDefaultView() ) ){
					event.setView(event.getDefaultView());
				}
				else{
					// Implicit views
					event.setView( lcase(replace(cEvent,".","/","all")) );
				}
				
				// reset layout according to newly set views;
				layout = event.getCurrentLayout();
			}

			return layout;
		</cfscript>
	</cffunction>

	<!--- Get Modules Convention --->
	<cffunction name="getModulesConvention" access="private" output="false" returntype="string" hint="Get layoutsConvention">
		<cfreturn instance.modulesConvention/>
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