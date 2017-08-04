/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Models a ColdBox request, stores the incoming request collection and private request collection.
* It is also used to determine metadata about a request and helps you build RESTFul responses.
**/
component serializable=false accessors="true"{

	/**
	* The request context
	*/
	property name="context" type="struct";

	/**
	* The private request context
	*/
	property name="privateContext" type="struct";

	/**
	* ColdBox Controller
	*/
	property name="controller";

	/**
	* ColdBox System Properties
	*/
	property name="properties";

	/************************************** CONSTRUCTOR *********************************************/

	/**
	* Constructor
	* @properties The ColdBox application settings
	* @controller Acess to the system controller
	*/
	function init( required struct properties={}, required any controller ){

		instance = structnew();

		// Store controller;
		instance.controller = arguments.controller;

		// Create the Collections
		instance.context		= structnew();
		instance.privateContext = structnew();

		// flag for no event execution
		instance.isNoExecution  	= false;
		// the name of the event via URL/FORM/REMOTE
		instance.eventName			= arguments.properties.eventName;

		// Registered Layouts
		instance.registeredLayouts	= structnew();
		if( structKeyExists( arguments.properties, "registeredLayouts" ) ){
			instance.registeredLayouts = arguments.properties.registeredLayouts;
		}

		// Registered Folder Layouts
		instance.folderLayouts	= structnew();
		if( structKeyExists( arguments.properties, "folderLayouts" ) ){
			instance.folderLayouts = arguments.properties.folderLayouts;
		}

		// Registered View Layouts
		instance.viewLayouts	= structnew();
		if( structKeyExists( arguments.properties, "viewLayouts" ) ){
			instance.viewLayouts = arguments.properties.viewLayouts;
		}

		// Modules reference
		instance.modules = arguments.properties.modules;

		// Default layout + View
		instance.defaultLayout 	= arguments.properties.defaultLayout;
		instance.defaultView 	= arguments.properties.defaultView;

		// SES Base URL
		instance.SESBaseURL = "";
		if( structKeyExists( arguments.properties, "SESBaseURL" ) ){
			instance.SESBaseURL = arguments.properties.SESBaseURL;
		}
		// flag if using SES
		instance.isSES 				= false;
		// routed SES structures
		instance.routedStruct 		= structnew();

		// Flag for Invalid HTTP Method
		instance.invalidHTTPMethod 	= false;

		// Rendering Regions
		instance.renderingRegions 	= {};

		return this;
	}

	/************************************** COLLECTION METHODS *********************************************/

	/**
	* Get a representation of this instance
	*/
	struct function getMemento(){
		return instance;
	}

	/**
	* Override the instance
	*/
	function setMemento( required struct memento ){
		variables.instance = arguments.memento;
		return this;
	}

	/**
	* I Get a reference or deep copy of the public or private request Collection
	* @deepCopy Default is false, gives a reference to the collection. True, creates a deep copy of the collection.
	* @private Use public or private request collection
	*/
	struct function getCollection( boolean deepCopy=false, boolean private=false ){
		// Private Collection
		if( arguments.private ){
			if( arguments.deepCopy ){ return duplicate( instance.privateContext ); }
			return instance.privateContext;
		}
		// Public Collection
		if ( arguments.deepCopy ){ return duplicate( instance.context ); }
		return instance.context;
	}

	/**
	* I get a private collection
	* @deepCopy Default is false, gives a reference to the collection. True, creates a deep copy of the collection.
	* @private Use public or private request collection
	*/
	struct function getPrivateCollection( boolean deepCopy=false ){
		arguments.private = true;
		return getCollection( argumentCollection=arguments );
	}

	/**
	* Clears the entire collection
	* @private Use public or private request collection
	*/
	function clearCollection( boolean private=false ){
		if( arguments.private ) { structClear(instance.privateContext); }
		else { structClear(instance.context); }
		return this;
	}

	/**
	* Clears the private collection
	*/
	function clearPrivateCollection(){
		return clearCollection( private=true );
	}

	/**
	* Append a structure to the collection, with overwrite or not. Overwrite = false by default
	* @collection The collection to incorporate
	* @overwrite Overwrite elements, defaults to false
	* @private Private or public, defaults public.
	*/
	function collectionAppend( required struct collection, boolean overwrite=false, boolean private=false ){
		if( arguments.private ) { structAppend(instance.privateContext,arguments.collection, arguments.overwrite); }
		else { structAppend(instance.context,arguments.collection, arguments.overwrite); }
		return this;
	}

	/**
	* Append a structure to the collection, with overwrite or not. Overwrite = false by default
	* @collection The collection to incorporate
	* @overwrite Overwrite elements, defaults to false
	*/
	function privateCollectionAppend( required struct collection, boolean overwrite=false ){
		arguments.private = true;
		return collectionAppend( argumentCollection=arguments );
	}

	/**
	* Get the collection Size
	* @private Private or public, defaults public.
	*/
	numeric function getSize( boolean private=false ){
		if( arguments.private ){ return structCount(instance.privateContext); }
		return structCount(instance.context);
	}

	/**
	* Get the private collection Size
	*/
	numeric function getPrivateSize(){
		return getSize( private=true );
	}

	/************************************** KEY METHODS *********************************************/

	/**
	* Get a value from the public or private request collection.
	* @name The key name
	* @defaultValue default value
	* @private Private or public, defaults public.
	*/
	function getValue( required name, defaultValue, boolean private=false ){
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

		throw(  message="The variable: #arguments.name# is undefined in the request collection (private=#arguments.private#)",
			detail="Keys Found: #structKeyList(collection)#",
			type="RequestContext.ValueNotFound");
	}

	/**
	* Get a value from the private request collection.
	* @name The key name
	* @defaultValue default value
	*/
	function getPrivateValue( required name, defaultValue ){
		arguments.private = true;
		return getValue( argumentCollection=arguments );
	}

	/**
	* Get a value from the request collection and if simple value, I will trim it.
	* @name The key name
	* @defaultValue default value
	* @private Private or public, defaults public.
	*/
	function getTrimValue( required name, defaultValue, boolean private=false ){
		var value = getValue(argumentCollection=arguments);

		// Verify if Simple
		if( isSimpleValue(value) ){ return trim(value); }

		return value;
	}

	/**
	* Get a trim value from the private request collection.
	* @name The key name
	* @defaultValue default value
	*/
	function getPrivateTrimValue( required name, defaultValue ){
		arguments.private = true;
		return getTrimValue( argumentCollection=arguments );
	}

	/**
	* Set a value in the request collection
	* @name The key name
	* @value The value
	* @private Private or public, defaults public.
	*
	* @return RequestContext
	*/
	function setValue( required name, required value, boolean private=false ){
		var collection = instance.context;
		if( arguments.private ) { collection = instance.privateContext; }

		collection[arguments.name] = arguments.value;
		return this;
	}

	/**
	* Set a value in the private request collection
	* @name The key name
	* @value The value
	*
	* @return RequestContext
	*/
	function setPrivateValue( required name, required value ){
		arguments.private = true;
		return setValue( argumentCollection=arguments );
	}

	/**
	* remove a value in the request collection
	* @name The key name
	* @private Private or public, defaults public.
	*
	* @return RequestContext
	*/
	function removeValue( required name, boolean private=false ){
		var collection = instance.context;
		if( arguments.private ){ collection = instance.privateContext; }

		structDelete(collection,arguments.name);

		return this;
	}

	/**
	* remove a value in the private request collection
	* @name The key name
	*
	* @return RequestContext
	*/
	function removePrivateValue( required name, boolean private=false ){
		arguments.private = true;
		return removeValue( argumentCollection=arguments );
	}

	/**
	* Check if a value exists in the request collection
	* @name The key name
	* @private Private or public, defaults public.
	*/
	boolean function valueExists( required name, boolean private=false ){
		var collection = instance.context;
		if( arguments.private ){ collection = instance.privateContext; }
		return structKeyExists(collection, arguments.name);
	}

	/**
	* Check if a value exists in the private request collection
	* @name The key name
	*/
	boolean function privateValueExists( required name ){
		arguments.private = true;
		return valueExists( argumentCollection=arguments );
	}

	/**
	* Just like cfparam, but for the request collection
	* @name The key name
	* @value The value
	* @private Private or public, defaults public.
	*
	* @return RequestContext
	*/
	function paramValue( required name, required value, boolean private=false ){
		if ( not valueExists(name=arguments.name,private=arguments.private) ){
			setValue(name=arguments.name,value=arguments.value,private=arguments.private);
		}
		return this;
	}

	/**
	* Just like cfparam, but for the private request collection
	* @name The key name
	* @value The value
	*
	* @return RequestContext
	*/
	function paramPrivateValue( required name, required value ){
		arguments.private = true;
		return paramValue( argumentCollection=arguments );
	}

	/************************************** CURRENT CONTEXT METHODS *********************************************/

	/**
	* Gets the current set view the framework will try to render for this request
	*/
	string function getCurrentView(){
		return getPrivateValue( "currentView", "" );
	}

	/**
	* Gets the current set view the framework will try to render for this request
	*/
	struct function getCurrentViewArgs(){
		return getPrivateValue( "currentViewArgs", structNew() );
	}

	/**
	* Gets the current set views's module for rendering
	*/
	string function getCurrentViewModule(){
		return getPrivateValue( "viewModule", "" );
	}

	/**
	* Gets the current set layout for rendering
	*/
	string function getCurrentLayout(){
		return getPrivateValue( "currentLayout", "" );
	}

	/**
	* Gets the current set layout's module for rendering
	*/
	string function getCurrentLayoutModule(){
		return getPrivateValue( "layoutmodule", "" );
	}

	/**
	* Get the current request's SES route that matched
	*/
	string function getCurrentRoute(){
		return getPrivateValue( "currentRoute", "" );
	}
	/**
	* Get the current routed URL that matched the SES route
	*/
	string function getCurrentRoutedURL(){
		return getPrivateValue( "currentRoutedURL", "" );
	}

	/**
	* Get the current routed namespace that matched the SES route, if any
	*/
	string function getCurrentRoutedNamespace(){
		return getPrivateValue( "currentRoutedNamespace", "" );
	}

	/**
	* Gets the current incoming event
	*/
	string function getCurrentEvent(){
		return getValue( getEventName(), "" );
	}

	/**
	* Gets the current handler requested in the current event
	*/
	string function getCurrentHandler(){
		var testHandler = reReplace(getCurrentEvent(),"\.[^.]*$","");
		if( listLen(testHandler,".") eq 1){
			return testHandler;
		}

		return listLast(testHandler,".");
	}

	/**
	* Gets the current action requested in the current event
	*/
	string function getCurrentAction(){
		return listLast(getCurrentEvent(),".");
	}

	/**
	* Gets the current module name, else returns empty string
	*/
	string function getCurrentModule(){
		var event = getCurrentEvent();
		if( NOT find(":",event) ){ return "";}
		return listFirst(event,":");
	}

	/**
	* Convenience method to get the current request's module root path. If no module, then returns empty path. You can also get this from the modules settings
	* @module Optional name of the module you want the root for, defaults to the current running module
	*/
	string function getModuleRoot( module="" ){
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
	}

	/**
	* Are we in SSL or not? This method looks at cgi.server_port_secure for indication
	*/
	boolean function isSSL(){
		if( isBoolean( cgi.server_port_secure ) AND cgi.server_port_secure){ return true; }
		// Add typical proxy headers for SSL
		if( getHTTPHeader( "x-forwarded-proto", "http" ) eq "https" ){ return true; }
		if( getHTTPHeader( "x-scheme", "http" ) eq "https" ){ return true; }
		return false;
	}

	/**
	 * Check if the request was made with an invalid HTTP Method
	 */
	boolean function isInvalidHTTPMethod(){
		return instance.invalidHTTPMethod;
	}

	/**
	 * Set the invalid http method flag
	 */
	RequestContext function setIsInvalidHTTPMethod( boolean target=true ){
		instance.invalidHTTPMethod = arguments.target;
		return this;
	}

	/************************************** VIEW-LAYOUT METHODS *********************************************/

	/**
	* Get the current rendering regions
	*/
	function getRenderingRegions(){
		return instance.renderingRegions;
	}

	/**
	* Set the view to render in this request. Private Request Collection Name: currentView, currentLayout
	* @view The name of the view to set. If a layout has been defined it will assign it, else if will assign the default layout. No extension please
	* @args An optional set of arguments that will be available when the view is rendered
	* @layout You can override the rendering layout of this setView() call if you want to. Else it defaults to implicit resolution or another override.
	* @module The explicit module view
	* @noLayout Boolean flag, wether the view sent in will be using a layout or not. Default is false. Uses a pre set layout or the default layout.
	* @cache True if you want to cache the rendered view.
	* @cacheTimeout The cache timeout in minutes
	* @cacheLastAccessTimeout The last access timeout in minutes
	* @cacheSuffix Add a cache suffix to the view cache entry. Great for multi-domain caching or i18n caching.
	* @cacheProvider The cache provider you want to use for storing the rendered view. By default we use the 'template' cache provider
	* @name This triggers a rendering region.  This will be the unique name in the request for specifying a rendering region, you can then render it by passing the unique name to renderView();
	*
	* @return RequestContext
	*/
	function setView(
		view,
		struct args={},
		layout,
		module="",
		boolean noLayout=false,
		boolean cache=false,
		cacheTimeout="",
		cacheLastAccessTimeout="",
		cacheSuffix="",
		cacheProvider="template",
		name
	){
		// Do we have an incoming rendering region definition? If we do, store it and return
		if( structKeyExists( arguments, "name" ) ){
			instance.renderingRegions[ arguments.name ] = arguments;
			return this;
		}

		// stash the view module
		instance.privateContext[ "viewModule" ] = arguments.module;

		// Direct Layout Usage
		if( structKeyExists( arguments, "layout" ) ){
			setLayout( arguments.layout );
		}
		// Discover layout
	    else if ( NOT arguments.nolayout AND NOT getPrivateValue( name="layoutoverride", defaultValue=false ) ){

	    	//Verify that the view has a layout in the viewLayouts structure, static lookups
		    if ( structKeyExists( instance.viewLayouts, lcase( arguments.view ) ) ){
				setPrivateValue( "currentLayout", instance.viewLayouts[ lcase( arguments.view ) ] );
		    } else {
				//Check the folders structure
				for( var key in instance.folderLayouts ){
					if ( reFindnocase( '^#key#', lcase( arguments.view ) ) ){
						setPrivateValue( "currentLayout", instance.folderLayouts[ key ] );
						break;
					}
				}//end for loop
			}//end else

			// If not layout, then set default from main application
			if( not privateValueExists( "currentLayout", true ) ){
				setPrivateValue( "currentLayout", instance.defaultLayout );
			}

			// If in current module, check for a module default layout\
			var cModule	= getCurrentModule();
			if( len( cModule )
			    AND structKeyExists( instance.modules, cModule )
				AND len( instance.modules[ cModule ].layoutSettings.defaultLayout ) ){
				setPrivateValue( "currentLayout", instance.modules[ cModule ].layoutSettings.defaultLayout );
			}

		} //end layout discover

		// No Layout Rendering?
		if( arguments.nolayout ){
			removePrivateValue( 'currentLayout' );
		}

		// Do we need to cache the view
		if( arguments.cache ){
			// prepare the cache keys
			var cacheEntry = {
				view 				= arguments.view,
				timeout 			= "",
				lastAccessTimeout 	= "",
				cacheSuffix 		= arguments.cacheSuffix,
				cacheProvider 		= arguments.cacheProvider
			};
			
			if ( isNumeric( arguments.cacheTimeout ) ){
				cacheEntry.timeout = arguments.cacheTimeout;
			}
			
			if ( isNumeric( arguments.cacheLastAccessTimeout ) ){
				cacheEntry.lastAccessTimeout = arguments.cacheLastAccessTimeout;
			}
			
			//Save the view cache entry
			setViewCacheableEntry( cacheEntry );
		}

		// Set the current view to render.
		instance.privateContext[ "currentView" ] = arguments.view;

		// Record the optional arguments
		setPrivateValue( "currentViewArgs", arguments.args, true );

		return this;
	}

	/**
	* Mark this request to not use a layout for rendering
	* @return RequestContext
	*/
	function noLayout(){
		// remove layout if any
		structDelete( instance.privateContext, "currentLayout" );
		// set layout overwritten flag.
		instance.privateContext[ "layoutoverride" ] = true;
		return this;
	}

	/**
	* Set the layout to override and render. Layouts are pre-defined in the config file. However I can override these settings if needed. Do not append a the cfm extension. Private Request Collection name
	* @name The name of the layout to set
	* @module The module to use
	*/
	function setLayout( required name, module="" ){
		// Set direct layout first.
		instance.privateContext[ "currentLayout" ] = trim( arguments.name ) & ".cfm";
		// Do an Alias Check and override if found.
		if( structKeyExists( instance.registeredLayouts, arguments.name ) ){
			instance.privateContext[ "currentLayout" ] = instance.registeredLayouts[ arguments.name ];
		}
		// set layout overwritten flag.
		instance.privateContext[ "layoutoverride" ] = true;
		// module layout?
		instance.privateContext[ "layoutmodule" ] = arguments.module;
		
		return this;
	}

	/**
	* Get's the default layout of the application
	*/
	string function getDefaultLayout(){
		return instance.defaultLayout;
	}

	/**
	* Override the default layout for a request
	* @return RequestContext
	*/
	function setDefaultLayout( required defaultLayout ){
		instance.defaultLayout = arguments.defaultLayout;
		return this;
	}

	/**
	* Get's the default view of the application
	*/
	string function getDefaultView(){
		return instance.defaultView;
	}

	/**
	* Override the default view for a request
	* @return RequestContext
	*/
	function setDefaultView( required defaultView ){
		instance.defaultView = arguments.defaultView;
		return this;
	}

	/**
	* Get the registered view layout associations map
	*/
	struct function getViewLayouts(){
		return instance.viewLayouts;
	}

	/**
	* Get all the registered layouts in the configuration file
	*/
	struct function getRegisteredLayouts(){
    	return instance.registeredLayouts;
	}

	/**
	* Get the registered folder layout associations map
	*/
	struct function getFolderLayouts(){
		return instance.folderLayouts;
	}

	/************************************** EVENT METHODS *********************************************/

	/**
	* Override the current event in the request collection. This method does not execute the event, it just replaces the event to be executed by the framework's RunEvent() method. This method is usually called from an onRequestStart or onApplicationStart method
	* @event The event to override with
	*
	* @return RequestContext
	*/
	function overrideEvent( required event ){
		setValue(getEventName(),arguments.event);
		return this;
	}

	/**
	* Set that this is a proxy request
	* @return RequestContext
	*/
	function setProxyRequest(){
		return setPrivateValue( "coldbox_proxyrequest", true );
	}

	/**
	* Is this a coldbox proxy request
	*/
	boolean function isProxyRequest(){
		return getPrivateValue( "coldbox_proxyrequest", false );
	}

	/**
	* Set the flag that tells the framework not to render, just execute
	* @remove Remove the flag completely
	*
	* @return RequestContext
	*/
	function noRender( boolean remove=false ){
		if ( arguments.remove eq false )
			return setPrivateValue( name="coldbox_norender", value=true );
		else
			return removePrivateValue( name="coldbox_norender" );
	}

	/**
	* Is this a no render request
	*/
	boolean function isNoRender(){
		return getPrivateValue( name="coldbox_norender", defaultValue=false );
	}

	/**
	* Get the event name
	*/
	function getEventName(){
		return instance.eventName;
	}

	/**
	* Determine if we need to execute an incoming event or not
	*/
	boolean function isNoExecution(){
		return instance.isNoExecution;
	}

	/**
	* Set that the request will not execute an incoming event. Most likely simulating a servlet call
	*
	* @return RequestContext
	*/
	function noExecution(){
		instance.isNoExecution = true;
   		return this;
	}

	/************************************** URL METHODS *********************************************/

	/**
	* Is this request in SES mode
	*/
	boolean function isSES(){
		return instance.isSES;
	}

	/**
	* Is this request in SES mode
	* @return RequestContext
	*/
	function setIsSES( required boolean isSES ){
		instance.isSES = arguments.isSES;
		return this;
	}

	/**
	* Get the SES base URL for this request
	* @return RequestContext
	*/
	string function getSESBaseURL(){
		return instance.sesBaseURL;
	}

	/**
	* Get the HTML base URL that is used for the HTML <base> tag. This also accounts for SSL or not.
	*/
	string function getHTMLBaseURL(){
		return REReplaceNoCase( buildLink( linkTo='', ssl=isSSL() ), "index.cfm\/?", "" );
	}

	/**
	* Set the ses base URL for this request
	* @return RequestContext
	*/
	function setSESBaseURL( required string sesBaseURL ){
		instance.sesBaseURL = arguments.sesBaseURL;
		return this;
	}

	/**
	* Returns index.cfm?{eventName}=
	*/
	string function getSelf(){
		return "index.cfm?" & getEventName() & "=";
	}

	/**
	* Builds a link to a passed event, either SES or normal link. If the ses interceptor is declared it will create routes
	* @linkTo The event or route you want to create the link to
	* @translate Translate between . and / depending on the SES mode on linkTo and queryString arguments. Defaults to true.
	* @ssl Turn SSl on/off on URL creation
	* @baseURL If not using SES, you can use this argument to create your own base url apart from the default of index.cfm. Example: https://mysample.com/index.cfm
	* @queryString The query string to append
	*/
	string function buildLink(
		required linkTo,
		boolean translate=true,
		boolean ssl,
		baseURL="",
		queryString=""
	){
		var sesBaseURL 		= getSESbaseURL();
		var frontController = "index.cfm";

		// Cleanups
		arguments.linkTo 		= trim( arguments.linkTo );
		arguments.baseURL 		= trim( arguments.baseURL );
		arguments.queryString 	= trim( arguments.queryString );

		// Front Controller Base
		if( len( arguments.baseURL ) neq 0 ){
			frontController = arguments.baseURL;
		}

		// SES Mode
		if( isSES() ){
			// SSL ON OR TURN IT ON
			if( isSSL() OR ( structKeyExists( arguments, "ssl" ) and arguments.ssl ) ){
				sesBaseURL = replacenocase( sesBaseURL, "http:", "https:" );
			}
			
			// SSL Turn Off
			if( structKeyExists( arguments, "ssl" ) and arguments.ssl eq false ){
				sesBaseURL = replacenocase( sesBaseURL, "https:", "http:" );
			}
			
			// Translate link or plain
			if( arguments.translate ){
				arguments.linkto = replace( arguments.linkto, ".", "/", "all" );
				// QuqeryString Conversions
				if( len( arguments.queryString ) ){
					if( right( arguments.linkTo, 1 ) neq  "/" ){
						arguments.linkto = arguments.linkto & "/";
					}
					arguments.linkto = arguments.linkto & replace( arguments.queryString, "&", "/", "all" );
					arguments.linkto = replace( arguments.linkto, "=", "/", "all" );
				}
			} else if( len( arguments.queryString ) ){
				arguments.linkto = arguments.linkto & "?" & arguments.queryString;
			}
			
			// Prepare SES Base URL Link
			if( right( sesBaseURL, 1 ) eq  "/" ){
				return sesBaseURL & arguments.linkto;
			} else {
				return sesBaseURL & "/" & arguments.linkto;
			}
		} else {
			// Check if sending in QUery String
			if( len( arguments.queryString ) eq 0 ){
				return "#frontController#?#getEventName()#=#arguments.linkto#";
			} else {
				return "#frontController#?#getEventName()#=#arguments.linkto#&#arguments.queryString#";
			}
		}

	}

	/************************************** CACHING *********************************************/

	/**
	* Check wether the incoming event has been flagged for caching
	*/
	boolean function isEventCacheable(){
		return privateValueExists( name="cbox_eventCacheableEntry" );
	}

	/**
	* Check wether the incoming event has been flagged for caching
	* @cacheEntry The md entry for caching
	*
	* @return RequestContext
	*/
	function setEventCacheableEntry( required struct cacheEntry ){
		return setPrivateValue( name="cbox_eventCacheableEntry", value=arguments.cacheEntry );
	}

	/**
	* Get the event cacheable entry
	*/
	struct function getEventCacheableEntry(){
		return getPrivateValue( name="cbox_eventCacheableEntry", defaultValue=structnew() );
	}

	/**
	* Check wether the incoming event has been flagged for caching
	* @return RequestContext
	*/
	function removeEventCacheableEntry(){
		return removePrivateValue( name='cbox_eventCacheableEntry' );
	}

	/**
	* Check wether the incoming view has been flagged for caching
	*/
	boolean function isViewCacheable(){
		return privateValueExists( name="cbox_viewCacheableEntry" );
	}

	/**
	* Set the view cacheable entry
	* @cacheEntry The md entry for caching
	*
	* @return RequestContext
	*/
	function setViewCacheableEntry( required struct cacheEntry ){
		return setPrivateValue( name="cbox_viewCacheableEntry", value=arguments.cacheEntry );
	}

	/**
	* Get the event cacheable entry
	*/
	struct function getViewCacheableEntry(){
		return getPrivateValue( name="cbox_viewCacheableEntry", defaultValue=structnew() );
	}


	/************************************** RESTFUL *********************************************/

	/**
	* Get the routed structure of key-value pairs. What the ses interceptor could match.
	*/
	struct function getRoutedStruct(){
		return instance.routedStruct;
	}

	/**
	* Get the routed structure of key-value pairs. What the ses interceptor could match.
	* @return RequestContext
	*/
	function setRoutedStruct( required struct routedStruct ){
		instance.routedStruct = arguments.routedStruct;
		return this;
	}

	/**
	 * This method will send a file to the browser or requested HTTP protocol according to arguments.
	 * CF11+ Compatibility
	 *
	 * @file The absolute path to the file or a binary file to send
	 * @name The name to send to the browser via content disposition header.  If not provided then the name of the file or a UUID for a binary file will be used
	 * @mimeType A valid mime type to use.  If not passed, then we will try to use one according to file type
	 * @disposition The browser content disposition (attachment/inline) header
	 * @abortAtEnd If true, then this method will do a hard abort, we do not recommend this, prefer the event.noRender() for a graceful abort.
	 * @extension Only used for binary files which types are not determined.  
	 * @deleteFile Delete the file after it has been streamed to the user. Only used if file is not binary.
	 */
	function sendFile( 
		file="",
		name="",
		mimeType="",
		disposition="attachment",
		boolean abortAtEnd="false",
		extension="",
		boolean deleteFile=false
	){
		var fileSize = 0;

		// Binary detection settings
		if( isBinary( arguments.file ) ){
			if( len( trim( arguments.name ) ) eq 0){
				arguments.name = createUUID();
			}
			if( !len( trim( arguments.extension ) ) ){
				throw( 
					message = "Extension missing for binary file.",
					type 	= "InvalidExtensionException"
				);
			}
			// Determine file size
			fileSize = len( arguments.file );
			//  Lookup mime type 
			if( !len( trim( arguments.mimetype ) ) ){
				arguments.mimetype = getFileMimeType( extension );
			}
		}
		// Else file on disk settings
		else if ( fileExists( arguments.file ) ){
			// Did we pass a name? Else get it from file path
			if( !len( trim( arguments.name ) ) ){
				arguments.name = REReplace( getFileFromPath( arguments.file ), "\.[^.]*$", "" );
			}
			//  Set extension 
			arguments.extension = listLast( arguments.file, "." );
			//  Set size 
			fileSize = getFileInfo( arguments.file ).size;
			//  Lookup mime type 
			if( !len( trim( arguments.mimetype ) ) ){
				arguments.mimetype = fileGetMimeType( arguments.file );
			}
		} else {
			throw( 
				message = "No file binary or file '#arguments.file#' located. Please check your path and arguments.",
				type 	= "InvalidFileException"
			);
		}

		//  Set content headers 
		setHTTPHeader( name="content-disposition", value="#arguments.disposition#; filename='#arguments.name#.#extension#'" );
		setHTTPHeader( name="content-length", value=fileSize );
		
		//  Send file 
		if ( isBinary( arguments.file ) ) {
			cfcontent( variable=arguments.file, type=arguments.mimetype );
		} else {
			cfcontent( deletefile=arguments.deleteFile, file=arguments.file, type=arguments.mimetype );
		}

		//  Abort further processing? 
		if( arguments.abortAtEnd ){
			abort;
		}
	}

	/**
	* Use this method to tell the framework to render data for you. The framework will take care of marshalling the data for you
	* @type The type of data to render. Valid types are JSON, JSONP, JSONT, XML, WDDX, PLAIN/HTML, TEXT, PDF. The deafult is HTML or PLAIN. If an invalid type is sent in, this method will throw an error
	* @data The data you would like to marshall and return by the framework
	* @contentType The content type of the data. This will be used in the cfcontent tag: text/html, text/plain, text/xml, text/json, etc. The default value is text/html. However, if you choose JSON this method will choose application/json, if you choose WDDX or XML this method will choose text/xml for you.
	* @encoding The default character encoding to use.  The default encoding is utf-8
	* @statusCode The HTTP status code to send to the browser. Defaults to 200
	* @statusText Explains the HTTP status code sent to the browser.
	* @location Optional argument used to set the HTTP Location header
	* @jsonCallback Only needed when using JSONP, this is the callback to add to the JSON packet
	* @jsonQueryFormat JSON Only: query or array format for encoding. The default is CF query standard
	* @jsonAsText If set to false, defaults content mime-type to application/json, else will change encoding to plain/text
	* @xmlColumnList XML Only: Choose which columns to inspect, by default it uses all the columns in the query, if using a query
	* @xmlUseCDATA XML Only: Use CDATA content for ALL values. The default is false
	* @xmlListDelimiter XML Only: The delimiter in the list. Comma by default
	* @xmlRootName XML Only: The name of the initial root element of the XML packet
	* @pdfArgs All the PDF arguments to pass along to the CFDocument tag.
	* @formats The formats list or array that ColdBox should respond to using the passed in data argument. You can pass any of the valid types (JSON,JSONP,JSONT,XML,WDDX,PLAIN,HTML,TEXT,PDF). For PDF and HTML we will try to render the view by convention based on the incoming event
	* @formatsView The view that should be used for rendering HTML/PLAIN/PDF. By default ColdBox uses the name of the event as an implicit view
	* @formatsRedirect The arguments that should be passed to setNextEvent as part of a redirect for the HTML action.  If the format is HTML and this struct is not empty, ColdBox will call setNextEvent with these arguments.
	* @isBinary Bit that determines if the data being set for rendering is binary or not.
	*/
	function renderData(
		type="HTML",
		required data,
		contentType="",
		encoding="utf-8",
		numeric statusCode=200,
		statusText="",
		location="",
		jsonCallback="",
	 	jsonQueryFormat="query",
		boolean jsonAsText=false,
		xmlColumnList="",
		boolean xmlUseCDATA=false,
		xmlListDelimiter=",",
		xmlRootName="",
		struct pdfArgs={},
		formats="",
		formatsView="",
		formatsRedirect={},
		boolean isBinary=false
	){

		var rd = structnew();

		// With Formats?
		if( isArray( arguments.formats ) OR len( arguments.formats ) ){
			return renderWithFormats( argumentCollection=arguments );
		}

		// Validate rendering type
		if( not reFindnocase("^(JSON|JSONP|JSONT|WDDX|XML|PLAIN|HTML|TEXT|PDF)$", arguments.type ) ){
			throw(
				message = "Invalid rendering type",
				detail = "The type you sent #arguments.type# is not a valid rendering type. Valid types are JSON,JSONP,JSONT,XML,WDDX,TEXT,PLAIN,PDF",
				type 	= "RequestContext.InvalidRenderTypeException"
			);
		}

		// Default Values for incoming variables
		rd.type 			= arguments.type;
		rd.data 			= arguments.data;
		rd.encoding 		= arguments.encoding;
		rd.contentType 		= "text/html";
		rd.isBinary 		= arguments.isBinary;

		// HTTP status
		rd.statusCode 		= arguments.statusCode;
		rd.statusText 		= arguments.statusText;

		// XML Properties
		rd.xmlColumnList 	= arguments.xmlColumnList;
		rd.xmluseCDATA 		= arguments.xmlUseCDATA;
		rd.xmlListDelimiter = arguments.xmlListDelimiter;
		rd.xmlRootName 		= arguments.xmlRootName;

		// JSON Properties
		rd.jsonQueryFormat 	= arguments.jsonQueryFormat;
		rd.jsonCallBack 	= arguments.jsonCallBack;

		// PDF properties
		rd.pdfArgs 			= arguments.pdfArgs;

		// Automatic Content Types by marshalling type
		switch( rd.type ){
			case "JSON" : {
				rd.contenttype = 'application/json';
				if( arguments.jsonAsText ){
					rd.contentType = "text/plain"; 
				}
				break;
			}
			case "JSONP" : {
				rd.contentType = "application/javascript";
				break;
			}
			case "JSONT" : {
				rd.contentType = "text/plain";
				rd.type = "JSON";
				break;
			}
			case "XML" : case "WDDX" : { 
				rd.contentType = "text/xml"; 
				break; 
			}
			case "TEXT" : { 
				rd.contentType = "text/plain"; 
				break; 
			}
			case "PDF" : {
				rd.contentType = "application/pdf";
				rd.isBinary = true;
				break;
			}
		}

		// If contenttype passed, then override it?
		if( len( trim( arguments.contentType ) ) ){
			rd.contentType = arguments.contentType;
		}

		// HTTP Location?
		if( len( arguments.location ) ){ 
			setHTTPHeader( name="location", value=arguments.location ); 
		}

		// Save Rendering data privately.
		setPrivateValue( name='cbox_renderdata', value=rd );

		return this;
	}

	/**
	* Get the renderData structure
	*/
	struct function getRenderData(){
		return getPrivateValue( name="cbox_renderdata", defaultValue=structnew() );
	}

	/**
	* Get the HTTP Request Method Type
	*/
	string function getHTTPMethod(){
		return getValue( "_method", cgi.REQUEST_METHOD );
	}

	/**
	* Get the raw HTTP content
	* @json Try to return the content as deserialized json
	* @xml Try to return the content as an XML object
	*/
	any function getHTTPContent( boolean json=false, boolean xml=false ){
		var content = getHTTPRequestData().content;

		// ToString() neccessary when body comes in as binary.
		if( arguments.json and isJSON( toString( content ) ) )
			return deserializeJSON( toString( content ) );
		if( arguments.xml and len( toString( content ) ) and isXML( toString( content ) ) )
			return xmlParse( toString( content ) );

		return content;
	}

	/**
	* Get an HTTP header
	* @header.name The header to get
	* @defaultValue The default value if not found
	*/
	function getHTTPHeader( required header, defaultValue="" ){
		var headers = getHttpRequestData().headers;

		if( structKeyExists( headers, arguments.header ) ){
			return headers[ arguments.header ];
		}
		if( structKeyExists( arguments, "defaultValue" ) ){
			return arguments.defaultValue;
		}

		throw( message="Header #arguments.header# not found in HTTP headers",
			   detail="Headers found: #structKeyList( headers )#",
			   type="RequestContext.InvalidHTTPHeader");
	}

	/**
	* Set an HTTP Header
	* @statusCode the status code
	* @statusText the status text
	* @name The header name
	* @value The header value
	* @charset The charset to use, defaults to UTF-8
	*
	* return RequestContext
	*/
	function setHTTPHeader(
		statusCode,
		statusText="",
		name,
		value=""
	){

		// status code?
		if( structKeyExists( arguments, "statusCode" ) ){
			getPageContext().getResponse().setStatus( javaCast( "int", arguments.statusCode ), javaCast( "string", arguments.statusText ) );
		}
		// Name Exists
		else if( structKeyExists( arguments, "name" ) ){
			getPageContext().getResponse().addHeader( javaCast( "string", arguments.name ), javaCast( "string", arguments.value ) );
		} else {
			throw( message="Invalid header arguments",
				  detail="Pass in either a statusCode or name argument",
				  type="RequestContext.InvalidHTTPHeaderParameters" );
		}

		return this;
	}

	/**
	* Returns the username and password sent via HTTP basic authentication
	*/
	struct function getHTTPBasicCredentials(){
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
    }

	/**
	* Determines if in an Ajax call or not by looking at the request headers
	*/
	boolean function isAjax(){
    	return ( getHTTPHeader( "X-Requested-With", "" ) eq "XMLHttpRequest" );
	}

	/**
	* Filters the collection or private collection down to only the provided keys.
	* @keys A list or array of keys to bring back from the collection or private collection.
	* @private Private or public, defaults public.
	*/
	struct function only( required keys, boolean private = false ){
		if( isSimpleValue( arguments.keys ) ){
			arguments.keys = listToArray( arguments.keys );
		}
		// determine target context
		var thisContext = arguments.private ? instance.privateContext : instance.context;

		var returnStruct = {};
		for( var key in arguments.keys ){
			if( structKeyExists( thisContext, key) ){
				returnStruct[ key ] = thisContext[ key ];
			}
		}

		return returnStruct;
	}

	/************************************** RESTFUL *********************************************/

	/**
	* Render data with formats
	*/
	private function renderWithFormats(){
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
			} else {
				viewToRender = replace( reReplaceNoCase( getCurrentEvent() , "^([^:.]*):", "" ) , ".", "/" );
			}
			// Rendering switch
			switch( instance.context.format ){
				case "json" : case "jsonp" : case "jsont" : case "xml" : case "text" : case "wddx" : {
					arguments.type = instance.context.format;
					return renderData( argumentCollection=arguments );
				}
				case "pdf" : {
					arguments.type = "pdf";
					arguments.data = instance.controller.getRenderer().renderView( view=viewToRender);
					return renderData( argumentCollection=arguments );
				}
				case "html" : case "plain" : {
					if( NOT structIsEmpty( arguments.formatsRedirect ) ){
						instance.controller.setNextEvent( argumentCollection = arguments.formatsRedirect );
						return this;
					}
					return setView( view=viewToRender);
				}
			}
		} else {
			throw(
				message = "The incoming format #instance.context.format# is not a valid registered format",
				detail 	= "Valid incoming formats are #arguments.formats.toString()#",
				type 	= "RequestContext.InvalidFormat" 
			);
		}
	}

	//  getFileMimeType 

	/**
	 * Get's the file mime type for a given file extension, this is mostly used for file delivery. 
	 * If not in the most common, we deliver as a binary octet-stream.
	 * @extension The extension to assume.
	 */
	private function getFileMimeType( required string extension ){
		var fileMimeType = '';
		switch ( lcase( arguments.extension ) ) {
			case  "txt,js,css,cfm,cfc,html,htm,jsp,md,wiki":
				fileMimeType = 'text/plain';
				break;
			case  "gif":
				fileMimeType = 'image/gif';
				break;
			case  "jpg,jpeg":
				fileMimeType = 'image/jpg';
				break;
			case  "png":
				fileMimeType = 'image/png';
				break;
			case  "wav":
				fileMimeType = 'audio/wav';
				break;
			case  "mp3":
				fileMimeType = 'audio/mpeg3';
				break;
			case  "pdf":
				fileMimeType = 'application/pdf';
				break;
			case  "zip,tar,gzip":
				fileMimeType = 'application/zip';
				break;
			case  "ppt,pptx":
				fileMimeType = 'application/vnd.ms-powerpoint';
				break;
			case  "doc,docx":
				fileMimeType = 'application/msword';
				break;
			case  "xls,xlsx":
				fileMimeType = 'application/vnd.ms-excel';
				break;
			default:
				fileMimeType = 'application/octet-stream';
				break;
		}
		//  More mimeTypes: http://www.iana.org/assignments/media-types/application/ 
		return fileMimeType;
	}

}
