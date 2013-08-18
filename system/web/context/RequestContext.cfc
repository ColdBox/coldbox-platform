<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Description :
	I model a coldbox request. I hold the request's variables, rendering variables,
	and facade to the request's HTTP request.

----------------------------------------------------------------------->
<cfcomponent hint="The request context object simulates a user request. It has two internal data collections: one public and one private.  You can also manipulate the request stream and contents from this object." output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" hint="constructor" returntype="RequestContext">
		<cfargument name="properties" type="any" required="true" hint="The context properties struct">
		<cfargument name="controller"  type="any" required="true" hint="The ColdBox Controller">
		
		<cfscript>
			instance = structnew();
			
			// Store controller;
			instance.controller = arguments.controller;
			
			// Create the Collections
			instance.context		= structnew();
			instance.privateContext = structnew();

			// flag if using SES
			instance.isSES 				= false;
			// routed SES structures
			instance.routedStruct 		= structnew();
			// flag for no event execution
			instance.isNoExecution  	= false;
			// the name of the event via URL/FORM/REMOTE
			instance.eventName			= arguments.properties.eventName;

			// Registered Layouts
			instance.registeredLayouts	= structnew();
			if( structKeyExists(arguments.properties,"registeredLayouts") ){
				instance.registeredLayouts = arguments.properties.registeredLayouts;
			}

			// Registered Folder Layouts
			instance.folderLayouts	= structnew();
			if( structKeyExists(arguments.properties,"folderLayouts") ){
				instance.folderLayouts = arguments.properties.folderLayouts;
			}

			// Registered View Layouts
			instance.viewLayouts	= structnew();
			if( structKeyExists(arguments.properties,"viewLayouts") ){
				instance.viewLayouts = arguments.properties.viewLayouts;
			}

			// Modules reference
			instance.modules = arguments.properties.modules;

			// Default layout + View
			instance.defaultLayout = arguments.properties.defaultLayout;
			instance.defaultView = arguments.properties.defaultView;

			// SES Base URL
			instance.SESBaseURL = "";
			if( structKeyExists(arguments.properties,"SESBaseURL") ){
				instance.SESBaseURL = arguments.properties.SESBaseURL;
			}

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="getCollection" returntype="any" access="Public" hint="I Get a reference or deep copy of the public or private request Collection" output="false" colddoc:generic="struct">
		<cfargument name="deepCopyFlag" type="boolean" required="false" default="false" hint="Default is false, gives a reference to the collection. True, creates a deep copy of the collection.">
		<cfargument name="private" 		type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			// Private Collection
			if( arguments.private ){
				if( arguments.deepCopyFlag ){ return duplicate(instance.privateContext); }
				return instance.privateContext;
			}
			// Public Collection
			if ( arguments.deepCopyFlag ){ return duplicate(instance.context); }
			return instance.context;
		</cfscript>
	</cffunction>

	<cffunction name="clearCollection" access="public" returntype="any" output="false" hint="Clears the entire collection">
		<cfargument name="private" type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			if( arguments.private ) { structClear(instance.privateContext); }
			else { structClear(instance.context); }
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="collectionAppend" access="public" returntype="any" output="false" hint="Append a structure to the collection, with overwrite or not. Overwrite = false by default">
		<cfargument name="collection" 	type="any"  	required="true" hint="A collection to append">
		<cfargument name="overwrite"  	type="boolean" 	required="false" default="false" hint="If you need to override data in the collection, set this to true.">
		<cfargument name="private" 		type="boolean" 	required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			if( arguments.private ) { structAppend(instance.privateContext,arguments.collection, arguments.overwrite); }
			else { structAppend(instance.context,arguments.collection, arguments.overwrite); }
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="getSize" access="public" returntype="numeric" output="false" hint="Returns the number of elements in the collection">
		<cfargument name="private" type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			if( arguments.private ){ return structCount(instance.privateContext); }
			return structCount(instance.context);
		</cfscript>
	</cffunction>

	<cffunction name="getValue" returntype="Any" access="Public" hint="I Get a value from the public or private request collection." output="false">
		<cfargument name="name"         type="any" 		required="true"  hint="Name of the variable to get from the request collection">
		<cfargument name="defaultValue"	type="any" 		required="false" hint="Default value to return if not found.">
		<cfargument name="private" 		type="any" 		required="false" default="false" hint="Use public or private request collection. Boolean"/>
		<cfscript>
			var collection = instance.context;

			// private context switch
			if( arguments.private ){ collection = instance.privateContext; }

			// Check if key exists
			if( structKeyExists(collection, arguments.name) ){
				return collection[arguments.name];
			}

			// Default value
			if( structKeyExists(arguments, "defaultValue") ){
				return arguments.defaultValue;
			}

			$throw("The variable: #arguments.name# is undefined in the request collection (private=#arguments.private#)",
				   "Keys Found: #structKeyList(collection)#",
				   "RequestContext.ValueNotFound");
		</cfscript>
	</cffunction>

	<cffunction name="getTrimValue" returntype="Any" access="Public" hint="I Get a value from the request collection and if simple value, I will trim it." output="false">
		<cfargument name="name"         type="any" 		required="true"  hint="Name of the variable to get from the request collection">
		<cfargument name="defaultValue"	type="any" 		required="false" hint="Default value to return if not found.">
		<cfargument name="private" 		type="boolean" 	required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			var value = getValue(argumentCollection=arguments);

			// Verify if Simple
			if( isSimpleValue(value) ){ return trim(value); }

			return value;
		</cfscript>
	</cffunction>

	<cffunction name="setValue" access="Public" hint="I Set a value in the request collection" output="false" returntype="any">
		<cfargument name="name"  	type="any" 		required="true" hint="The name of the variable to set. String">
		<cfargument name="value" 	type="any" 		required="true" hint="The value of the variable to set">
		<cfargument name="private" 	type="boolean" 	required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			var collection = instance.context;
			if( arguments.private ) { collection = instance.privateContext; }

			collection[arguments.name] = arguments.value;
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="removeValue" access="Public" hint="I remove a value in the request collection" output="false" returntype="any">
		<cfargument name="name"  	type="string" 	required="true" hint="The name of the variable to remove.">
		<cfargument name="private" 	type="boolean" 	required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			var collection = instance.context;
			if( arguments.private ){ collection = instance.privateContext; }

			structDelete(collection,arguments.name);

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="valueExists" returntype="boolean" access="Public"	hint="I Check if a value exists in the request collection." output="false">
		<cfargument name="name" 	type="any" 		required="true" hint="Name of the variable to find in the request collection: String">
		<cfargument name="private" 	type="boolean" 	required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			var collection = instance.context;
			if( arguments.private ){ collection = instance.privateContext; }
			return structKeyExists(collection, arguments.name);
		</cfscript>
	</cffunction>

	<cffunction name="paramValue" returntype="any" access="Public"	hint="Just like cfparam, but for the request collection" output="false">
		<cfargument name="name" 	type="any" 		required="true" hint="Name of the variable to param in the request collection: String">
		<cfargument name="value" 	type="any" 		required="true" hint="The value of the variable to set if not found.">
		<cfargument name="private" 	type="boolean" 	required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			if ( not valueExists(name=arguments.name,private=arguments.private) ){
				setValue(name=arguments.name,value=arguments.value,private=arguments.private);
			}
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="getCurrentView" access="public" hint="Gets the current set view the framework will try to render for this request" returntype="any" output="false">
		<cfreturn getValue("currentView","",true)>
	</cffunction>

	<cffunction name="getCurrentViewArgs" access="public" hint="Gets the current set view the framework will try to render for this request" returntype="any" output="false">
		<cfreturn getValue("currentViewArgs", structNew(), true)>
	</cffunction>

	<cffunction name="getCurrentViewModule" access="public" hint="Gets the current set views's module for rendering" returntype="any" output="false">
		<cfreturn getValue("viewModule","",true)>
	</cffunction>

	<cffunction name="setView" access="public" returntype="any" hint="I Set the view to render in this request. Private Request Collection Name: currentView, currentLayout"  output="false">
		<!--- ************************************************************* --->
	    <cfargument name="view"     				required="false" type="any"  	hint="The name of the view to set. If a layout has been defined it will assign it, else if will assign the default layout. No extension please">
		<cfargument name="nolayout" 				required="false" type="boolean" default="false" hint="Boolean flag, wether the view sent in will be using a layout or not. Default is false. Uses a pre set layout or the default layout.">
		<cfargument name="cache" 					required="false" type="boolean" default="false" hint="True if you want to cache the rendered view.">
		<cfargument name="cacheTimeout" 			required="false" type="any"  	default=""	hint="The cache timeout">
		<cfargument name="cacheLastAccessTimeout" 	required="false" type="any"  	default="" hint="The last access timeout">
		<cfargument name="cacheSuffix" 				required="false" type="any"  	default="" hint="Add a cache suffix to the view cache entry. Great for multi-domain caching or i18n caching."/>
		<cfargument name="cacheProvider" 			required="false" type="any"  	default="template" hint="The cache provider you want to use for storing the rendered view. By default we use the 'template' cache provider">
		<cfargument name="layout" 					required="false" type="any"  	hint="You can override the rendering layout of this setView() call if you want to. Else it defaults to implicit resolution or another override.">
		<cfargument name="module" 					required="false" type="any"  	default="" hint="Is the view from a module or not"/>
		<cfargument name="args" 					required="false" type="struct"  default="#structNew()#" hint="An optional set of arguments that will be available when the view is rendered"/>
		<!--- ************************************************************* --->
	    <cfscript>
		    var key 		= "";
		    var cacheEntry 	= structnew();
			var cModule		= getCurrentModule();

			// view and name mesh
			if( structKeyExists(arguments,"name") ){ arguments.view = arguments.name; }

			// stash the view module
 			instance.privateContext["viewModule"] = arguments.module;

			// Local Override
			if( structKeyExists(arguments,"layout") ){
				setLayout(arguments.layout);
			}

			// If we need a layout or we haven't overriden the current layout enter if...
		    else if ( NOT arguments.nolayout AND NOT getValue("layoutoverride",false,true) ){

		    	//Verify that the view has a layout in the viewLayouts structure.
			    if ( StructKeyExists(instance.ViewLayouts, lcase(arguments.view)) ){
					setValue("currentLayout",instance.ViewLayouts[lcase(arguments.view)],true);
			    }
				else{
					//Check the folders structure
					for( key in instance.FolderLayouts ){
						if ( reFindnocase('^#key#', lcase(arguments.view)) ){
							setValue("currentLayout",instance.FolderLayouts[key],true);
							break;
						}
					}//end for loop
				}//end else

				//If not layout, then set default from main application
				if( not valueExists("currentLayout",true) ){
					setValue("currentLayout", instance.defaultLayout,true);
				}

				// Check for module integration
				if( len(cModule)
				    AND structKeyExists(instance.modules,cModule)
					AND len(instance.modules[cModule].layoutSettings.defaultLayout) ){
					setValue("currentLayout", instance.modules[getCurrentModule()].layoutSettings.defaultLayout,true);
				}

			}//end if overridding layout

			// No Layout Rendering?
			if( arguments.nolayout ){
				removeValue('currentLayout',true);
			}

			// Do we need to cache the view
			if( arguments.cache ){
				// prepare the cache keys
				cacheEntry.view = arguments.view;
				// Argument cleanup
				if ( not isNumeric(arguments.cacheTimeout) )
					cacheEntry.Timeout = "";
				else
					cacheEntry.Timeout = arguments.CacheTimeout;
				if ( not isNumeric(arguments.cacheLastAccessTimeout) )
					cacheEntry.LastAccessTimeout = "";
				else
					cacheEntry.LastAccessTimeout = arguments.cacheLastAccessTimeout;
				// Cache Suffix
				cacheEntry.cacheSuffix 		= arguments.cacheSuffix;
				// Cache Provider
				cacheEntry.cacheProvider 	= arguments.cacheProvider;

				//Save the view cache entry
				setViewCacheableEntry(cacheEntry);
			}

			//Set the current view to render.
			instance.privateContext["currentView"] = arguments.view;

			// Record the optional arguments
			setValue("currentViewArgs", arguments.args, true);
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="getCurrentLayout" access="public" hint="Gets the current set layout for rendering" returntype="any" output="false">
		<cfreturn getValue("currentLayout","",true)>
	</cffunction>

	<cffunction name="getCurrentLayoutModule" access="public" hint="Gets the current set layout's module for rendering" returntype="any" output="false">
		<cfreturn getValue("layoutmodule","",true)>
	</cffunction>

	<cffunction name="getCurrentRoute" output="false" access="public" returntype="any" hint="Get the current request's SES route that matched">
    	<cfreturn getValue("currentRoute","",true)>
    </cffunction>

	<cffunction name="getCurrentRoutedURL" output="false" access="public" returntype="any" hint="Get the current routed URL that matched the SES route">
    	<cfreturn getValue("currentRoutedURL","",true)>
    </cffunction>
    
    <cffunction name="getCurrentRoutedNamespace" output="false" access="public" returntype="any" hint="Get the current routed namespace that matched the SES route, if any">
    	<cfreturn getValue("currentRoutedNamespace","",true)>
    </cffunction>

    <cffunction name="noLayout" output="false" access="public" returntype="any" hint="Mark this request to not use a layout for rendering">
    	<cfscript>
			// remove layout if any
			structDelete(instance.privateContext,"currentLayout");
			// set layout overwritten flag.
			instance.privateContext["layoutoverride"] = true;
			return this;
    	</cfscript>
    </cffunction>

	<cffunction name="setLayout" access="public" returntype="any" hint="I Set the layout to override and render. Layouts are pre-defined in the config file. However I can override these settings if needed. Do not append a the cfm extension. Private Request Collection name: currentLayout"  output="false">
		<cfargument name="name" 	required="true"  hint="The name or alias of the layout file to set.">
		<cfargument name="module" 	required="false" default="" hint="Is the layout from a module or not"/>
		<cfscript>
			var layouts = instance.registeredLayouts;
			// Set direct layout first.
			instance.privateContext["currentLayout"] = trim(arguments.name) & ".cfm";
			// Do an Alias Check and override if found.
			if( structKeyExists(layouts,arguments.name) ){
				instance.privateContext["currentLayout"] = layouts[arguments.name];
			}
			// set layout overwritten flag.
			instance.privateContext["layoutoverride"] = true;
			// module layout?
			instance.privateContext["layoutmodule"] = arguments.module;
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="getModuleRoot" output="false" access="public" returntype="any" hint="Convenience method to get the current request's module root path. If no module, then returns empty path. You can also get this from the modules settings.">
		<cfargument name="module" required="false" default="" hint="Optional name of the module you want the root for, defaults to the current module">
		<cfscript>
			var theModule = "";
			if (structKeyExists(arguments,"module") and len(arguments.module)) {
				theModule = arguments.module;
			} else {
				theModule = getCurrentModule();
			}
			if( len(theModule) ){
				return instance.modules[theModule].mapping;
			}
			return "";
		</cfscript>
	</cffunction>

	<cffunction name="getCurrentModule" access="public" hint="Gets the current module name, else returns empty string" returntype="any" output="false">
		<cfscript>
			var event = getCurrentEvent();
			if( NOT find(":",event) ){ return "";}
			return listFirst(event,":");
		</cfscript>
	</cffunction>

	<cffunction name="getCurrentEvent" access="public" hint="Gets the current incoming event" returntype="any" output="false">
		<cfreturn getValue(getEventName(),"")>
	</cffunction>

	<cffunction name="getCurrentHandler" access="public" hint="Gets the current handler requested in the current event: String" returntype="any" output="false">
		<cfscript>
			var testHandler = reReplace(getCurrentEvent(),"\.[^.]*$","");
			if( listLen(testHandler,".") eq 1){
				return testHandler;
			}

			return listLast(testHandler,".");
		</cfscript>
	</cffunction>

	<cffunction name="getCurrentAction" access="public" hint="Gets the current action requested in the current event: String" returntype="any" output="false">
		<cfreturn listLast(getCurrentEvent(),".")>
	</cffunction>

	<cffunction name="overrideEvent" access="Public" hint="I Override the current event in the request collection. This method does not execute the event, it just replaces the event to be executed by the framework's RunEvent() method. This method is usually called from an onRequestStart or onApplicationStart method."  output="false" returntype="any">
		<cfargument name="event" hint="The name of the event to override.">
		 <cfscript>
	    setValue(getEventName(),arguments.event);
		return this;
	    </cfscript>
	</cffunction>

	<cffunction name="showDebugPanel" access="public" returntype="any" hint="I can override to show or not the debug panel. Very useful in AJAX debugging" output="false">
		<cfargument name="show" type="boolean" required="true">
		<cfscript>
		setValue(name="coldbox_debugpanel",value=arguments.show,private=true);
		return this;
		</cfscript>
	</cffunction>

	<cffunction name="getDebugPanelFlag" access="public" returntype="boolean" hint="I return the debugpanel flag for this request." output="false">
		<cfreturn getValue(name="coldbox_debugpanel",defaultValue=true,private=true)>
	</cffunction>

	<cffunction name="isProxyRequest" access="public" returntype="boolean" hint="Is this a coldbox proxy request" output="false">
		<cfreturn getValue(name="coldbox_proxyrequest",defaultValue=false,private=true)>
	</cffunction>

	<cffunction name="setProxyRequest" access="public" returntype="any" hint="Set that this is a proxy request" output="false">
		<cfscript>
		setValue(name="coldbox_proxyrequest",value=true,private=true);
		return this;
		</cfscript>
	</cffunction>

	<cffunction name="noRender" access="public" returntype="any" hint="Set the flag that tells the framework not to render, just execute" output="false">
		<cfargument name="remove" required="false" type="boolean" default="false" hint="If true, it removes the flag, else its set.">
		<cfscript>
			if (arguments.remove eq false)
				setValue(name="coldbox_norender",value=true,private=true);
			else
				removeValue(name="coldbox_norender",private=true);

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="isNoRender" access="public" returntype="any" hint="Is this a no render request" output="false">
		<cfreturn getValue(name="coldbox_norender",defaultValue=false,private=true)>
	</cffunction>

	<cffunction name="getEventName" access="public" returntype="any" output="false" hint="The event name used by the application: String">
		<cfreturn instance.eventName>
	</cffunction>

	<cffunction name="getSelf" access="public" output="false" returntype="any" hint="Returns index.cfm?{eventName}= : String">
	   <cfreturn "index.cfm?" & getEventName() & "=">
	</cffunction>

	<cffunction name="buildLink" access="public" output="false" returntype="any" hint="Builds a link to a passed event, either SES or normal link. If the ses interceptor is declared it will create routes.">
		<!--- ************************************************************* --->
		<cfargument name="linkto" 		required="true" 	type="string"  hint="The event or route you want to create the link to">
	    <cfargument name="translate"  	required="false" 	type="boolean" default="true" hint="Translate between . and / depending on the ses mode. So you can just use dot notation."/>
	    <cfargument name="ssl" 			required="false"    type="boolean" default="false" hint="If true, it will change http to https if found in the ses base url."/>
	    <cfargument name="baseURL" 		required="false" 	type="string"  default="" hint="If not using SES, you can use this argument to create your own base url apart from the default of index.cfm. Example: https://mysample.com/index.cfm"/>
	    <cfargument name="queryString"  required="false" 	type="string"  default="" hint="The query string to append, if needed.">
		<!--- ************************************************************* --->
		<cfscript>
		var sesBaseURL = getSESbaseURL();
		var frontController = "index.cfm";

		/* baseURL */
		if( len(trim(arguments.baseURL)) neq 0 ){
			frontController = arguments.baseURL;
		}

		if( isSES() ){
			/* SSL */
			if( arguments.ssl OR isSSL() ){
				sesBaseURL = replacenocase(sesBaseURL,"http:","https:");
			}
			/* Translate link */
			if( arguments.translate ){
				arguments.linkto = replace(arguments.linkto,".","/","all");
			}
			/* Query String Append */
			if ( len(trim(arguments.queryString)) ){
				if (right(arguments.queryString,1) neq  "/") {
					arguments.linkto = arguments.linkto & "/";
				}
				arguments.linkto = arguments.linkto & replace(arguments.queryString,"&","/","all");
				arguments.linkto = replace(arguments.linkto,"=","/","all");
			}
			/* Prepare link */
			if( right(sesBaseURL,1) eq  "/"){
				return sesBaseURL & arguments.linkto;
			}
			else{
				return sesBaseURL & "/" & arguments.linkto;
			}
		}
		else{
			/* Check if sending in QUery String */
			if( len(trim(arguments.queryString)) eq 0 ){
				return "#frontController#?#getEventName()#=#arguments.linkto#";
			}
			else{
				return "#frontController#?#getEventName()#=#arguments.linkto#&#arguments.queryString#";
			}
		}
		</cfscript>
	</cffunction>

	<cffunction name="isEventCacheable" access="public" returntype="any" hint="Check wether the incoming event has been flagged for caching. Boolean" output="false" >
		<cfscript>
			return valueExists(name="cbox_eventCacheableEntry",private=true);
		</cfscript>
	</cffunction>

	<cffunction name="setEventCacheableEntry" access="public" returntype="any" hint="Set the event cacheable entry" output="false" >
		<cfargument name="mdCacheEntry" required="true" type="any" hint="The cache entry we need to get to cache">
		<cfscript>
		setValue(name="cbox_eventCacheableEntry",value=arguments.mdCacheEntry,private=true);
		return this;
		</cfscript>
	</cffunction>

	<cffunction name="getEventCacheableEntry" access="public" returntype="any" hint="Get the event cacheable entry" output="false" >
		<cfreturn getValue(name="cbox_eventCacheableEntry",defaultValue=structnew(),private=true)>
	</cffunction>

	<cffunction name="removeEventCacheableEntry" access="public" returntype="any" hint="Remove the cacheable entry" output="false" >
		<cfscript>
		removeValue(name='cbox_eventCacheableEntry',private=true);
		return this;
		</cfscript>
	</cffunction>

	<cffunction name="isViewCacheable" access="public" returntype="boolean" hint="Check wether the incoming view has been flagged for caching" output="false" >
		<cfscript>
			return valueExists(name="cbox_viewCacheableEntry",private=true);
		</cfscript>
	</cffunction>

	<cffunction name="setViewCacheableEntry" access="public" returntype="any" hint="Set the view cacheable entry" output="false" >
		<cfargument name="mdCacheEntry" required="true" type="any" hint="The cache entry we need to get to cache">
		<cfscript>
			setValue(name="cbox_viewCacheableEntry",value=arguments.mdCacheEntry,private=true);
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="getViewCacheableEntry" access="public" returntype="any" hint="Get the event cacheable entry" output="false" >
		<cfreturn getValue(name="cbox_viewCacheableEntry",defaultValue=structnew(),private=true)>
	</cffunction>

	<cffunction name="isSES" access="public" output="false" returntype="boolean" hint="Determine if you are in SES mode.">
		<cfreturn instance.isSES/>
	</cffunction>

	<cffunction name="setisSES" access="public" output="false" returntype="any" hint="Set the isSES flag, usualy done by the SES interceptor">
		<cfargument name="isSES" type="boolean" required="true"/>
		<cfscript>
		instance.isSES = arguments.isSES;
		return this;
		</cfscript>
	</cffunction>

	<cffunction name="getSESBaseURL" access="public" output="false" returntype="string" hint="Get the ses base URL for this request">
		<cfreturn instance.sesBaseURL/>
	</cffunction>

	<cffunction name="setSESBaseURL" access="public" output="false" returntype="any" hint="Set the ses base URL for this request">
		<cfargument name="sesBaseURL" type="string" required="true"/>
		<cfscript>
		instance.sesBaseURL = arguments.sesBaseURL;
		return this;
		</cfscript>
	</cffunction>

	<cffunction name="getRoutedStruct" access="public" output="false" returntype="struct" hint="Get the routed structure of key-value pairs. What the ses interceptor could match.">
		<cfreturn instance.routedStruct/>
	</cffunction>

	<cffunction name="setRoutedStruct" access="public" output="false" returntype="any" hint="Set routed struct of key-value pairs. This is used only by the SES interceptor. Not for public use.">
		<cfargument name="routedStruct" type="struct" required="true"/>
		<cfscript>
		instance.routedStruct = arguments.routedStruct;
		return this;
		</cfscript>
	</cffunction>

	<cffunction name="getDefaultLayout" access="public" returntype="any" output="false" hint="Get's the default layout of the application: String">
		<cfreturn instance.defaultLayout>
	</cffunction>

	<cffunction name="setDefaultLayout" access="public" returntype="any" output="false" hint="Override the default layout for a request">
		<cfargument name="DefaultLayout" type="string" required="true">
		<cfscript>
		instance.defaultLayout = arguments.DefaultLayout;
		return this;
		</cfscript>
	</cffunction>

	<cffunction name="getDefaultView" access="public" returntype="any" output="false" hint="Get's the default view of the application: String">
		<cfreturn instance.defaultView>
	</cffunction>

	<cffunction name="setDefaultView" access="public" returntype="any" output="false" hint="Override the default view for a request">
		<cfargument name="DefaultView" type="string" required="true">
		<cfscript>
		instance.defaultView = arguments.DefaultView;
		return this;
		</cfscript>
	</cffunction>

	<cffunction name="getViewLayouts" access="public" returntype="struct" output="false" hint="Get the registered view layout associations map">
		<cfreturn instance.ViewLayouts>
	</cffunction>

	<cffunction name="getRegisteredLayouts" output="false" access="public" returntype="struct" hint="Get all the registered layouts in the configuration file">
    	<cfreturn instance.registeredLayouts>
    </cffunction>

	<cffunction name="getFolderLayouts" access="public" returntype="struct" output="false" hint="Get the registered folder layout associations map">
		<cfreturn instance.FolderLayouts>
	</cffunction>

	<cffunction name="getMemento" access="public" returntype="any" output="false" hint="Get the state of this request context">
		<cfreturn variables.instance>
	</cffunction>
	<cffunction name="setMemento" access="public" returntype="any" output="false" hint="Set the state of this request context">
		<cfargument name="memento" type="any" required="true">
		<cfscript>
		variables.instance = arguments.memento;
		return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="renderData" access="public" returntype="any" hint="Use this method to tell the framework to render data for you. The framework will take care of marshalling the data for you" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="type" 		required="false"  type="string" default="HTML" hint="The type of data to render. Valid types are JSON, JSONP, JSONT, XML, WDDX, PLAIN/HTML, TEXT, PDF. The deafult is HTML or PLAIN. If an invalid type is sent in, this method will throw an error">
		<cfargument name="data" 		required="true"  type="any"    hint="The data you would like to marshall and return by the framework">
		<cfargument name="contentType"  required="true"  type="string"  default="" hint="The content type of the data. This will be used in the cfcontent tag: text/html, text/plain, text/xml, text/json, etc. The default value is text/html. However, if you choose JSON this method will choose application/json, if you choose WDDX or XML this method will choose text/xml for you. The default encoding is utf-8"/>
		<cfargument name="encoding" 	required="false" type="string"  default="utf-8" hint="The default character encoding to use"/>
		<cfargument name="statusCode"   required="false" type="numeric" default="200" hint="The HTTP status code to send to the browser. Defaults to 200" />
		<cfargument name="statusText"   required="false" type="string"  default="" hint="Explains the HTTP status code sent to the browser." />
		<cfargument name="location" 	required="false" type="string"  default="" hint="Optional argument used to set the HTTP Location header"/>
		<!--- ************************************************************* --->
		<cfargument name="jsonCallback" 	type="string"  required="false" default="" hint="Only needed when using JSONP, this is the callback to add to the JSON packet"/>
		<cfargument name="jsonQueryFormat" 	type="string"  required="false" default="query" hint="JSON Only: query or array format for encoding. The default is CF query standard" />
		<cfargument name="jsonAsText" 		type="boolean" required="false" default="false" hint="If set to false, defaults content mime-type to application/json, else will change encoding to plain/text"/>
		<!--- ************************************************************* --->
		<cfargument name="xmlColumnList"    type="string"   required="false" default="" hint="XML Only: Choose which columns to inspect, by default it uses all the columns in the query, if using a query">
		<cfargument name="xmlUseCDATA"  	type="boolean"  required="false" default="false" hint="XML Only: Use CDATA content for ALL values. The default is false">
		<cfargument name="xmlListDelimiter" type="string"   required="false" default="," hint="XML Only: The delimiter in the list. Comma by default">
		<cfargument name="xmlRootName"      type="string"   required="false" default="" hint="XML Only: The name of the initial root element of the XML packet">
		<!--- ************************************************************* --->
		<cfargument name="pdfArgs"      	type="struct"   required="false" default="#structNew()#" hint="All the PDF arguments to pass along to the CFDocument tag.">
		<!--- ************************************************************* --->
		<cfargument name="formats"			type="any" 		required="false" default="" hint="The formats list or array that ColdBox should respond to using the passed in data argument. You can pass any of the valid types (JSON,JSONP,JSONT,XML,WDDX,PLAIN,HTML,TEXT,PDF). For PDF and HTML we will try to render the view by convention based on the incoming event.">
		<cfargument name="formatsView"		type="any" 		required="false" default="" hint="The view that should be used for rendering HTML/PLAIN/PDF. By default ColdBox uses the name of the event as an implicit view.">
		<cfargument name="isBinary" 		type="boolean" 	required="false" default="false" hint="Bit that determines if the data being set for rendering is binary or not."/>
		<cfscript>
			var rd = structnew();
			
			// With Formats?
			if( isArray( arguments.formats ) OR len( arguments.formats ) ){
				return renderWithFormats( argumentCollection=arguments );
			}

			// Validate rendering type
			if( not reFindnocase("^(JSON|JSONP|JSONT|WDDX|XML|PLAIN|HTML|TEXT|PDF)$",arguments.type) ){
				$throw("Invalid rendering type","The type you sent #arguments.type# is not a valid rendering type. Valid types are JSON,JSONP,JSONT,XML,WDDX,TEXT,PLAIN,PDF","RequestContext.InvalidRenderTypeException");
			}

			// Default Values for incoming variables
			rd.type = arguments.type;
			rd.data = arguments.data;
			rd.encoding = arguments.encoding;
			rd.contentType = "text/html";
			rd.isBinary = arguments.isBinary;

			// HTTP status
			rd.statusCode = arguments.statusCode;
			rd.statusText = arguments.statusText;

			// XML Properties
			rd.xmlColumnList = arguments.xmlColumnList;
			rd.xmluseCDATA = arguments.xmlUseCDATA;
			rd.xmlListDelimiter = arguments.xmlListDelimiter;
			rd.xmlRootName = arguments.xmlRootName;

			// JSON Properties
			rd.jsonQueryFormat 	= arguments.jsonQueryFormat;
			rd.jsonCallBack 	= arguments.jsonCallBack;

			// PDF properties
			rd.pdfArgs = arguments.pdfArgs;

			// Automatic Content Types by marshalling type
			switch( rd.type ){
				case "JSON" : case "JSONP" : {
					rd.contenttype = 'application/json';
					if( arguments.jsonAsText ){ rd.contentType = "text/plain"; }
					break;
				}
				case "JSONT" :{
					rd.contentType = "text/plain";
					rd.type = "JSON";
					break;
				}
				case "XML" : case "WDDX" : { rd.contentType = "text/xml"; break; }
				case "TEXT" : { rd.contentType = "text/plain"; break; }
				case "PDF" : {
					rd.contentType = "application/pdf";
					rd.isBinary = true;
					break;
				}
			}

			// If contenttype passed, then override it?
			if( len(trim(arguments.contentType)) ){
				rd.contentType = arguments.contentType;
			}

			// HTTP Location?
			if( len(arguments.location) ){ setHTTPHeader(name="location",value=arguments.location); }

			// Save Rendering data privately.
			setValue(name='cbox_renderdata',value=rd,private=true);

			return this;
		</cfscript>
	</cffunction>

	<cffunction name="getRenderData" access="public" output="false" returntype="any" hint="Get the renderData structure.">
		<cfreturn getValue(name="cbox_renderdata",defaultValue=structnew(),private=true)/>
	</cffunction>

	<cffunction name="getHTTPMethod" access="public" returntype="any" hint="Get the HTTP Request Method Type" output="false" >
		<cfreturn cgi.REQUEST_METHOD>
	</cffunction>

	<cffunction name="getHTTPContent" output="false" access="public" returntype="any" hint="Get the raw HTTP content">
    	<cfreturn getHTTPRequestData().content>
    </cffunction>

	<cffunction name="getHTTPHeader" output="false" access="public" returntype="any" hint="Get a HTTP header">
		<cfargument name="header"  type="string" required="true"  hint="The header key"/>
		<cfargument name="default" type="any"    required="false" hint="A default value if the header does not exist"/>
		<cfscript>
			var headers = getHttpRequestData().headers;

			if( structKeyExists(headers, arguments.header) ){
				return headers[arguments.header];
			}
			if( structKeyExists(arguments,"default") ){
				return arguments.default;
			}
			$throw(message="Header #arguments.header# not found in HTTP headers",detail="Headers found: #structKeyList(headers)#",type="RequestContext.InvalidHTTPHeader");
		</cfscript>
	</cffunction>

	<cffunction name="setHTTPHeader" output="false" access="public" returntype="any" hint="Set an HTTP Header">
    	<cfargument name="statusCode" type="string" required="false" hint="A status code"/>
		<cfargument name="statusText" type="string" required="false" default="" hint="A status text"/>
		<cfargument name="name" 	  type="string" required="false" hint="The header name"/>
    	<cfargument name="value" 	  type="string" required="false" default="" hint="The header value"/>
		<cfargument name="charset" 	  type="string" required="false" default="UTF-8" hint="The charset to use"/>

		<!--- statusCode exists? --->
		<cfif structKeyExists(arguments,"statusCode")>
			<cfheader statuscode="#arguments.statusCode#" statustext="#arguments.statusText#">
		<!--- Name exists --->
		<cfelseif structKeyExists(arguments,"name")>
			<cfheader name="#arguments.name#" value="#arguments.value#" charset="#arguments.charset#">
		<cfelse>
			<cfthrow message="Invalid header arguments" detail="Pass in either a statusCode or name argument" type="RequestContext.InvalidHTTPHeaderParameters">
		</cfif>

		<cfreturn this>
	</cffunction>

	<!--- getHTTPBasicCredentials --->
    <cffunction name="getHTTPBasicCredentials" output="false" access="public" returntype="struct" hint="Returns the username and password sent via HTTP basic authentication">
    	<cfscript>
    		var results 	= structnew();
			var authHeader 	= "";

			// defaults
			results.username = "";
			results.password = "";

			// set credentials
			authHeader = getHTTPHeader("Authorization","");

			// continue if it exists
			if( len(authHeader) ){
				authHeader = charsetEncode( binaryDecode( listLast(authHeader," "),"Base64"), "utf-8");
				results.username = listFirst( authHeader, ":");
				results.password = listLast( authHeader, ":");
			}

			return results;
    	</cfscript>
    </cffunction>

	<cffunction name="isSSL" access="public" returntype="boolean" hint="Returns boolean result whether current request is in ssl or not" output="false">
	    <cfscript>
			if (isBoolean(cgi.server_port_secure) AND cgi.server_port_secure) { return true; }
			return false;
		</cfscript>
	</cffunction>

	<cffunction name="isNoExecution" access="public" returntype="any" hint="Determine if we need to execute an incoming event or not." output="false" >
		<cfreturn instance.isNoExecution>
	</cffunction>

	<cffunction name="noExecution" output="false" access="public" returntype="any" hint="Set that the request will not execute an incoming event. Most likely simulating a servlet call.">
   		<cfscript>
		instance.isNoExecution = true;
   		return this;
		</cfscript>
    </cffunction>

	<cffunction name="isAjax" output="false" access="public" returntype="boolean" hint="Determines if in an Ajax call or not by looking at the request headers">
    	<cfscript>
    		return ( getHTTPHeader("X-Requested-With","") eq "XMLHttpRequest" );
		</cfscript>
    </cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
		<!--- renderWithFormats --->    
    <cffunction name="renderWithFormats" output="false" access="private" returntype="any" hint="Render With Formats">    
    	<cfscript>	    
			var viewToRender = "";
			
			// inflate list to array if found
			if( isSimpleValue( arguments.formats ) ){ arguments.formats = listToArray( arguments.formats ); }
			// param incoming rc.format to "html"
			paramValue( "format", "html" );
			// try to match the incoming format with the ones defined, if not defined then throw an exception
			if( arrayFindNoCase( arguments.formats, instance.context.format )  ){
				// Cleanup of formats
				arguments.formats = "";
				// Determine view from incoming or implicit
				//viewToRender = ( len( arguments.formatsView ) ? arguments.formatsView : replace( reReplaceNoCase( getCurrentEvent() , "^([^:.]*):", "" ) , ".", "/" ) );
				if( len( arguments.formatsView ) ){
					viewToRender = arguments.formatsView;
				}
				else{
					viewToRender = replace( reReplaceNoCase( getCurrentEvent() , "^([^:.]*):", "" ) , ".", "/" );
				}
				// Rendering switch
				switch( instance.context.format ){
					case "json" : case "jsonp" : case "jsont" : case "xml" : case "text" : case "wddx" : {
						arguments.type=instance.context.format;
						return renderData( argumentCollection=arguments );
					}
					case "pdf" : {
						arguments.type = "pdf";
						arguments.data = instance.controller.getPlugin("Renderer").renderView( view=viewToRender);
						return renderData( argumentCollection=arguments );
					}
					case "html" : case "plain" : {
						return setView( view=viewToRender);
					}
				}
			}					
			else{
				throw(message="The incoming format #instance.context.format# is not a valid registered format", 
						  detail="Valid incoming formats are #arguments.formats.toString()#", 
						  type="RequestContext.InvalidFormat");
			}
    	</cfscript>    
    </cffunction>

	<cffunction name="$throw" access="private" hint="Facade for cfthrow" output="false">
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>

	<cffunction name="$dump" access="private" hint="Facade for cfmx dump" returntype="void" output="false">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>
		<cfdump var="#var#">
		<cfif arguments.isAbort><cfabort></cfif>
	</cffunction>

</cfcomponent>