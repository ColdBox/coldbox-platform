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
			instance.explicitView 				= "";

			// Template Cache & Caching Maps
			instance.templateCache 				= controller.getColdboxOCM("template");
			instance.renderedHelpers			= {};
			instance.lockName					= "rendering.#controller.getAppHash()#";

			// Discovery caching is tied to handlers for discovery.
			instance.isDiscoveryCaching			= controller.getSetting("handlerCaching");

			// Set event scope, we are not caching, so it is threadsafe.
			event 	= getRequestContext();

			// Create View Scopes
			rc 		= event.getCollection();
			prc 	= event.getCollection(private=true);

			// Set the HTML Helper Plugin Scope
			html	= getPlugin("HTMLHelper");

			// Load global UDF Libraries into target
			loadGlobalUDFLibraries();

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- setExplicitView --->
    <cffunction name="setExplicitView" output="false" access="public" returntype="any" hint="Set the explicit view to render, usually called to create new rendering contexts">
    	<cfargument name="view" required="true" hint="The view to explicitly set">
		<cfscript>
			instance.explicitView = arguments.view;
			return this;
		</cfscript>
    </cffunction>

	<!--- Render the View --->
	<cffunction name="renderView"	access="Public" hint="Renders the current view." output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="view" 					required="false" type="any"  default=""			hint="If not passed in, the value in the currentView in the current RequestContext will be used">
		<cfargument name="cache" 					required="false" type="any"  default="false" 	hint="Cache the rendered view or not">
		<cfargument name="cacheTimeout" 			required="false" type="any"  default=""			hint="The cache timeout for the rendered view">
		<cfargument name="cacheLastAccessTimeout" 	required="false" type="any"  default="" 		hint="The last access timeout for the rendered view">
		<cfargument name="cacheSuffix" 				required="false" type="any"  default=""     	hint="Add a cache suffix to the view cache entry. Great for multi-domain caching or i18n caching."/>
		<cfargument name="cacheProvider" 			required="false" type="any"  default="template" hint="The cache provider you want to use for storing the rendered view. By default we use the 'template' cache provider">
		<cfargument name="module" 					required="false" type="any"  default=""      	hint="Explicitly render a view from this module by passing the module name"/>
		<cfargument name="args"   					required="false" type="any"  default="#event.getCurrentViewArgs()#" hint="An optional set of arguments that will be available to this layouts/view rendering ONLY"/>
		<cfargument name="collection" 				required="false" type="any"  hint="A collection to use by this Renderer to render the view as many times as the items in the collection (Array or Query)" colddoc:generic="collection"/>
		<cfargument name="collectionAs" 			required="false" type="any"	 default=""  	    hint="The name of the collection variable in the partial rendering.  If not passed, we will use the name of the view by convention"/>
		<cfargument name="collectionStartRow" 		required="false" type="any"	 default="1"  	    hint="The start row to limit the collection rendering with" colddoc:generic="numeric"/>
		<cfargument name="collectionMaxRows" 		required="false" type="any"	 default="0"  	    hint="The max rows to iterate over the collection rendering with" colddoc:generic="numeric"/>
		<cfargument name="collectionDelim" 			required="false" type="any"	 default=""  	    hint="A string to delimit the collection renderings by"/>
		<cfargument name="prepostExempt" 			required="false" type="any"	 default="false" 	hint="If true, pre/post view interceptors will not be fired. By default they do fire" colddoc:generic="boolean">
		<!--- ************************************************************* --->
		<cfscript>
			var viewCacheKey 		= "";
			var viewCacheEntry 		= "";
			var viewCacheProvider 	= instance.templateCache;
			var timerHash 			= 0;
			var iData 				= arguments;
			var explicitModule 		= false;
			var viewLocations		= "";

			// If no incoming explicit module call, default the value to the one in the request context for convenience
			if( NOT len(arguments.module) ){

				// check for an explicit view module
				arguments.module = event.getCurrentViewModule();

				// if module is still empty check the event pattern
				// if no module is execution, this will be empty anyways.
				if( NOT len(arguments.module) ){
					arguments.module = event.getCurrentModule();
				}

			}
			else{
				explicitModule = true;
			}

			// Rendering an explicit view or do we need to get the view from the context or explicit context?
			if( NOT len(arguments.view) ){
				// Rendering an explicit Renderer view/layout combo?
				if( len(instance.explicitView) ){
					arguments.view = instance.explicitView;
					// clear the explicit view now that it has been used
					setExplicitView("");
				}
				// Render the view in the context
				else{ arguments.view = event.getCurrentView(); }
			}

			// Do we have a view To render? Else throw exception
			if( NOT len(arguments.view) ){
				$throw(message="The ""currentview"" variable has not been set, therefore there is no view to render.",
					   detail="Please remember to use the 'event.setView()' method in your handler or pass in a view to render.",
					   type="Renderer.ViewNotSetException");
			}
			
			// Cleanup leading / in views, just in case
			arguments.view = reReplace( arguments.view, "^(\\|/)", "" );
			
			// Announce preViewRender interception
			if( NOT arguments.prepostExempt ){ announceInterception("preViewRender", iData); }

			// Prepare caching arguments if doing implicit caching, and the view to render is the same as the implicitly cached.
			viewCacheEntry = event.getViewCacheableEntry();
			if( event.isViewCacheable() AND (arguments.view EQ viewCacheEntry.view) ){
				arguments.cache						= true;
				arguments.cacheTimeout				= viewCacheEntry.timeout;
				arguments.cacheLastAccessTimeout	= viewCacheEntry.lastAccessTimeout;
				arguments.cacheSuffix 				= viewCacheEntry.cacheSuffix;
				arguments.cacheProvider				= viewCacheEntry.cacheProvider;
			}
			// Prepare caching key
			viewCacheKey = instance.templateCache.VIEW_CACHEKEY_PREFIX & arguments.module & ":" & arguments.view & arguments.cacheSuffix;
			// Are we caching?
			if (arguments.cache){
				// Which provider you want to use?
				if( arguments.cacheProvider neq "template" ){
					viewCacheProvider = cacheBox.getCache( arguments.cacheProvider );
				}
				// Try to get from cache
				timerHash = instance.debuggerService.timerStart("rendering Cached View [#arguments.view#.cfm] from '#arguments.cacheProvider# provider'");
				iData.renderedView = viewCacheProvider.get( viewCacheKey );
				// Verify it existed
				if( structKeyExists(iData, "renderedView") ){
					instance.debuggerService.timerEnd( timerHash );
					// Post View Render Interception
					if( NOT arguments.prepostExempt ){ announceInterception("postViewRender", iData); }
					// Return it
					return iData.renderedView;
				}
			}

			// No caching, just render
			// Discover and cache view/helper locations
			viewLocations = discoverViewPaths(arguments.view,arguments.module,explicitModule);

			// Render View Composite or View Collection
			timerHash = instance.debuggerService.timerStart("rendering View [#arguments.view#.cfm]");
			if( structKeyExists(arguments,"collection") ){
				// render collection in next context
				iData.renderedView = getPlugin("Renderer").renderViewCollection(arguments.view, viewLocations.viewPath, viewLocations.viewHelperPath, arguments.args, arguments.collection, arguments.collectionAs, arguments.collectionStartRow, arguments.collectionMaxRows, arguments.collectionDelim);
			}
			else{
				// render simple composite view
				iData.renderedView = renderViewComposite(arguments.view, viewLocations.viewPath, viewLocations.viewHelperPath, arguments.args);
			}
			instance.debuggerService.timerEnd(timerHash);

			// Post View Render Interception point
			if( NOT arguments.prepostExempt ){ announceInterception("postViewRender", iData); }

			// Are we caching view
			if ( arguments.cache ){
				viewCacheProvider.set(viewCacheKey, iData.renderedView, arguments.cacheTimeout, arguments.cacheLastAccessTimeout);
			}

			// Return view content
			return iData.renderedView;
		</cfscript>
	</cffunction>

	<!--- discoverViewPaths --->
    <cffunction name="discoverViewPaths" output="false" access="private" returntype="any" hint="Discover view paths and cache if necessary and return its locations">
    	<cfargument name="view">
    	<cfargument name="module">
    	<cfargument name="explicitModule">

    	<cfscript>
    		var locationKey 	= arguments.view & arguments.module & arguments.explicitModule;
			var locationUDF 	= variables.locateView;
			var dPath			= "";
			var refMap			= "";
		</cfscript>

		<!--- Check cached paths first --->
		<cflock name="#locationKey#.#instance.lockName#" type="readonly" timeout="15" throwontimeout="true">
			<cfif structkeyExists( controller.getSetting("viewsRefMap") ,locationKey) AND instance.isDiscoveryCaching>
				<cfreturn structFind( controller.getSetting("viewsRefMap"), locationKey)>
			</cfif>
		</cflock>

		<cfscript>
			if (left(arguments.view, 1) EQ "/") {

				refMap = {
					viewPath = arguments.view,
					viewHelperPath = ""
				};

			} else { // view discovery based on relative path

				// module change mode
				if( len(arguments.module) ){ locationUDF = variables.locateModuleView; }

				// Locate the view to render according to discovery algorithm and create cache map
				refMap = {
					viewPath = locationUDF(arguments.view,arguments.module,arguments.explicitModule),
					viewHelperPath = ""
				};

			}

			// Check for view helper convention
			dPath = getDirectoryFromPath( refMap.viewPath );
			if( fileExists(expandPath( refMap.viewPath & "Helper.cfm")) ){
				refMap.viewHelperPath = refMap.viewPath & "Helper.cfm";
			}
			// Check for directory helper convention
			else if( fileExists( expandPath( dPath & listLast(dPath,"/") & "Helper.cfm" ) ) ){
				refMap.viewHelperPath = dPath & listLast(dPath,"/") & "Helper.cfm";
			}
		</cfscript>

		<!--- Lock and create view entry --->
		<cfif NOT structkeyExists( controller.getSetting("viewsRefMap") ,locationKey) >
			<cflock name="#locationKey#.#instance.lockName#" type="exclusive" timeout="15" throwontimeout="true">
				<cfset structInsert( controller.getSetting("viewsRefMap"), locationKey, refMap, true)>
			</cflock>
		</cfif>

		<cfreturn refMap>
    </cffunction>

	<!--- renderViewComposite --->
    <cffunction name="renderViewCollection" output="false" access="public" returntype="any" hint="Render a view composed of collections">
    	<cfargument name="view">
		<cfargument name="viewpath">
		<cfargument name="viewHelperPath">
		<cfargument name="args"/>
		<cfargument name="collection">
		<cfargument name="collectionAs">
		<cfargument name="collectionStartRow" default="1"/>
		<cfargument name="collectionMaxRows"  default="0"/>
		<cfargument name="collectionDelim"  default=""/>

		<cfscript>
			var buffer 	= createObject("java","java.lang.StringBuffer").init();
			var x 		= 1;
			var recLen 	= 0;

			// Determine the collectionAs key
			if( NOT len(arguments.collectionAs) ){
				arguments.collectionAs = listLast(arguments.view,"/");
			}

			// Array Rendering
			if( isArray(arguments.collection) ){
				recLen = arrayLen(arguments.collection);
				// is max rows passed?
				if( arguments.collectionMaxRows NEQ 0 AND arguments.collectionMaxRows LTE recLen){ recLen = arguments.collectionMaxRows; }
				// Create local marker
				variables._items	= recLen;
				// iterate and present
				for(x=arguments.collectionStartRow; x lte recLen; x++){
					// setup local cvariables
					variables._counter  = x;
					variables[ arguments.collectionAs ] = arguments.collection[x];
					// prepend the delim
					if ( x NEQ arguments.collectionStartRow ) {
						buffer.append( arguments.collectionDelim );
					}
					// render item composite
					buffer.append( renderViewComposite(arguments.view,arguments.viewPath,arguments.viewHelperPath,arguments.args) );
				}
				return buffer.toString();
			}
		</cfscript>

			<!--- Query Rendering --->
			<cfset variables._items	= arguments.collection.recordCount>
			<!--- Max Rows --->
			<cfif arguments.collectionMaxRows NEQ 0 AND arguments.collectionMaxRows LTE arguments.collection.recordCount>
				<cfset variables._items	= arguments.collectionMaxRows>
			</cfif>
			<cfloop query="arguments.collection" startrow="#arguments.collectionStartRow#" endrow="#(arguments.collectionStartRow+variables._items)-1#">
				<cfscript>
					// setup local cvariables
					variables._counter  = arguments.collection.currentRow;
					variables[ arguments.collectionAs ] = arguments.collection;
					// prepend the delim
					if ( variables._counter NEQ 1 ) {
						buffer.append( arguments.collectionDelim );
					}
					// render item composite
					buffer.append( renderViewComposite(arguments.view,arguments.viewPath,arguments.viewHelperPath,arguments.args) );
				</cfscript>
			</cfloop>
			<cfreturn buffer.toString()>
    </cffunction>

	<!--- renderViewComposite --->
    <cffunction name="renderViewComposite" output="false" access="public" returntype="any" hint="Render a view composite">
    	<cfargument name="view">
		<cfargument name="viewpath">
		<cfargument name="viewHelperPath">
		<cfargument name="args"/>

    	<cfset var cbox_renderedView = "">
		<!--- Nasty CF Whitespace --->
		<cfsavecontent variable="cbox_renderedView"><cfif len(arguments.viewHelperPath) AND NOT structKeyExists(instance.renderedHelpers,arguments.viewHelperPath)><cfoutput><cfinclude template="#arguments.viewHelperPath#"><cfset instance.renderedHelpers[arguments.viewHelperPath]=true></cfoutput></cfif><cfoutput><cfinclude template="#arguments.viewPath#.cfm"></cfoutput></cfsavecontent>

    	<cfreturn cbox_renderedView>
    </cffunction>

	<!--- Render an external View --->
	<cffunction name="renderExternalView"	access="Public" hint="Renders an external view." output="false" returntype="Any">
		<!--- ************************************************************* --->
		<cfargument name="view" 					required="true"  type="any" 	hint="The full path to the view. This can be an expanded path or relative. Include extension.">
		<cfargument name="cache" 					required="false" type="boolean" default="false" hint="True if you want to cache the view.">
		<cfargument name="cacheTimeout" 			required="false" type="any"  	default=""		hint="The cache timeout">
		<cfargument name="cacheLastAccessTimeout" 	required="false" type="any"  	default="" 		hint="The last access timeout">
		<cfargument name="cacheSuffix" 				required="false" type="any"  	default=""      hint="Add a cache suffix to the view cache entry. Great for multi-domain caching or i18n caching."/>
		<cfargument name="cacheProvider" 			required="false" type="any"  	default="template" hint="The cache provider you want to use for storing the rendered view. By default we use the 'template' cache provider">
		<cfargument name="args"   					required="false" type="any"  	default="#event.getCurrentViewArgs()#" hint="An optional set of arguments that will be available to this layouts/view rendering ONLY"/>
		<!--- ************************************************************* --->
		<cfscript>
			var cbox_renderedView = "";
			// Cache Entries
			var cbox_cacheKey 		= "";
			var cbox_cacheEntry 	= "";
			var cbox_cacheProvider 	= instance.templateCache;
			var viewLocations 		= "";

			// Setup the cache key
			cbox_cacheKey = instance.templateCache.VIEW_CACHEKEY_PREFIX & "external-" & arguments.view & arguments.cacheSuffix;
			// Setup the cache provider
			if( arguments.cacheProvider neq "template" ){ cbox_cacheProvider = cacheBox.getCache( arguments.cacheProvider ); }
			// Try to get from cache
			cbox_timerHash 		= instance.debuggerService.timerStart("rendering Cached External View [#arguments.view#.cfm] from '#arguments.cacheProvider#' provider");
			cbox_renderedView 	= cbox_cacheProvider.get(cbox_cacheKey);
			if( isDefined("cbox_renderedView") ){
				instance.debuggerService.timerEnd( cbox_timerHash );
				return cbox_renderedView;
			}
			// Not in cache, render it
			cbox_timerHash = instance.debuggerService.timerStart("rendering External View [#arguments.view#.cfm]");
			// Get view locations
			viewLocations = discoverViewPaths( arguments.view,"",false);
			// Render External View
			cbox_renderedView = renderViewComposite(view, viewLocations.viewPath, viewLocations.viewHelperPath, args);
 			instance.debuggerService.timerEnd(cbox_timerHash);
 			// Are we caching it
 			if( arguments.cache ){
 				cbox_cacheProvider.set(cbox_cacheKey, cbox_renderedView, arguments.cacheTimeout, arguments.cacheLastAccessTimeout);
 			}
 			return cbox_renderedView;
		</cfscript>
	</cffunction>

	<!--- Render the layout --->
	<cffunction name="renderLayout" access="Public" hint="Renders the current layout + view Combinations if declared." output="false" returntype="any">
		<cfargument name="layout" 		type="any" 	required="false" hint="The explicit layout to use in rendering"/>
		<cfargument name="view"   		type="any" 	required="false" default="" hint="The view to render within this layout explicitly"/>
		<cfargument name="module" 		type="any"  required="false" default="" hint="Explicitly render a layout from this module by passing its module name"/>
		<cfargument name="args"   		type="any" 	required="false" default="#event.getCurrentViewArgs()#" hint="An optional set of arguments that will be available to this layouts/view rendering ONLY"/>
		<cfargument name="viewModule"   type="any" 	required="false" default="" hint="Explicitly render a view from this module"/>
		<cfargument name="prepostExempt" type="any"	required="false" default="false" 	hint="If true, pre/post layout interceptors will not be fired. By default they do fire" colddoc:generic="boolean">

		<cfset var cbox_implicitLayout 		= implicitViewChecks()>
		<cfset var cbox_currentLayout 		= cbox_implicitLayout>
		<cfset var cbox_timerhash 			= "">
		<cfset var cbox_locateUDF 			= variables.locateLayout>
		<cfset var cbox_explicitModule  	= false>
		<cfset var cbox_layoutLocationKey 	= "">
		<cfset var cbox_layoutLocation		= "">
		<cfset var iData					= arguments>
		<cfset var viewLocations = "" />

		<!--- Are we doing a nested view/layout explicit combo or already in its rendering algorithm? --->
		<cfif len(trim(arguments.view)) AND arguments.view neq instance.explicitView>
			<cfreturn getPlugin("Renderer").setExplicitView(arguments.view).renderLayout(argumentCollection=arguments)>
		</cfif>

		<!--- If the layout has not been specified set it to the implicit value. --->
		<cfif NOT structKeyExists(arguments,"layout")>
			<!--- Strip off the .cfm extension if it is set. --->
			<cfif len(cbox_implicitLayout) gt 4 AND right(cbox_implicitLayout,4) eq '.cfm'>
				<cfset cbox_implicitLayout = left(cbox_implicitLayout,len(cbox_implicitLayout)-4) />
			</cfif>
			<cfset arguments.layout = cbox_implicitLayout />
		</cfif>

		<!--- Module Default Value --->
		<cfif NOT len(arguments.module)>
			<cfset arguments.module = event.getCurrentModule()>
		<cfelse>
			<cfset cbox_explicitModule = true>
		</cfif>

		<!--- Announce preLayoutRender interception --->
		<cfif NOT arguments.prepostExempt>
			<cfset announceInterception("preLayoutRender", iData)>
		</cfif>

		<!--- Check explicit layout rendering --->
		<cfif structKeyExists(arguments,"layout")>
			<!--- Check if any length on incoming layout --->
			<cfif len ( arguments.layout )>
				<!--- Cleanup leading / in views, just in case --->
				<cfset arguments.layout = reReplace( arguments.layout, "^(\\|/)", "" )>
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
			<cfset iData.renderedLayout = renderView( module = arguments.viewModule )>
		<cfelse>
			<!--- Layout location key --->
			<cfset cbox_layoutLocationKey = cbox_currentLayout & arguments.module & cbox_explicitModule>

			<!--- Check cached paths first --->
			<cfif structkeyExists( controller.getSetting("layoutsRefMap") ,cbox_layoutLocationKey) AND instance.isDiscoveryCaching>
				<cflock name="#cbox_layoutLocationKey#.#instance.lockName#" type="readonly" timeout="15" throwontimeout="true">
					<cfset cbox_layoutLocation = structFind( controller.getSetting("layoutsRefMap"), cbox_layoutLocationKey)>
				</cflock>
			<cfelse>
				<!--- Not found, cache it --->
				<cflock name="#cbox_layoutLocationKey#.#instance.lockname#" type="exclusive" timeout="15" throwontimeout="true">
					<cfset cbox_layoutLocation = cbox_locateUDF(cbox_currentLayout,arguments.module,cbox_explicitModule)>
					<cfset structInsert( controller.getSetting("layoutsRefMap"), cbox_layoutLocationKey, cbox_layoutLocation, true)>
				</cflock>
			</cfif>

			<cfset viewLocations = discoverViewPaths( reverse ( listRest( reverse( cbox_layoutLocation ), ".")),arguments.module,cbox_explicitModule) />
			<!--- RenderLayout --->
			<cfset iData.renderedLayout = renderViewComposite(cbox_currentLayout, viewLocations.viewPath, viewLocations.viewHelperPath, args) />
		</cfif>

		<!--- Stop Timer --->
		<cfset instance.debuggerService.timerEnd(cbox_timerhash)>

		<!--- Post Layout Render Interception point --->
		<cfif NOT arguments.prepostExempt>
			<cfset announceInterception("postLayoutRender", iData)>
		</cfif>

		<!--- Return Rendered Layout --->
		<cfreturn iData.renderedLayout>
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
			moduleName     = arguments.module;
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

			// Is implicit views enabled?
			if( not controller.getSetting(name="ImplicitViews") ){ return layout; }

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
					if( getSetting(name="caseSensitiveImplicitViews",defaultValue=false) ){
						event.setView( replace(cEvent,".","/","all") );
					}
					else{
						event.setView( lcase(replace(cEvent,".","/","all")) );
					}
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
