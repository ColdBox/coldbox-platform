<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	  : Luis Majano
Description :
	Base Unit Test Component based on TestBox for the ColdBox Platform

TODO: Remove MXUnit compat for 4.0 and rely only on BaseSpec.

---------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.compat.framework.TestCase" 
			 output="false" 
			 hint="A base test case for doing ColdBox Testing based on the MXUnit Framework">

	<cfscript>
		instance = structnew();
		
		// Internal Properties
		instance.appMapping = "";
		instance.configMapping = "";
		instance.controller = 0;
		instance.coldboxAppKey = "cbController";
		
		// Public Switch Properties
		this.loadColdbox = true;
	</cfscript>

	<!--- metadata Inspection --->
	<cffunction name="metadataInspection" access="private" returntype="void" hint="Inspect test case for annotations" output="false">
		<cfscript>
			var md = getMetadata(this);
			// Inspect for appMapping annotation
			if( structKeyExists(md,"appMapping") ){
				instance.appMapping = md.appMapping;
			}
			// Configuration File mapping
			if( structKeyExists(md,"configMapping") ){
				instance.configMapping = md.configMapping;
			}
			// ColdBox App Key
			if( structKeyExists(md,"coldboxAppKey") ){
				instance.coldboxAppKey = md.coldboxAppKey;
			}	
			// Load coldBox annotation
			if( structKeyExists(md,"loadColdbox") ){
				this.loadColdbox = md.loadColdbox;
			}		
		</cfscript>
	</cffunction>

	<!--- beforeTests --->
	<cffunction name="beforeTests" hint="The main setup method for running ColdBox Integration enabled tests" output="false">
		<cfscript>
		var appRootPath = "";
		var context		= "";
		
		// metadataInspection
		metadataInspection();
		
		// Load ColdBox Application for testing?
		if( this.loadColdbox ){
			// Check on Scope First
			if( structKeyExists(application,getColdboxAppKey()) ){
				instance.controller = application[getColdboxAppKey()];
			}
			else{
				// Verify App Root Path
				if( NOT len( instance.appMapping ) ){ instance.appMapping = "/"; }
				appRootPath = expandPath( instance.appMapping );
				// Clean the path for nice root path.
				if( NOT reFind( "(/|\\)$", appRootPath ) ){
					appRootPath = appRootPath & "/";
				}
				// Setup Coldbox configuration by convention
				if(NOT len( instance.configMapping ) ){
					if( len( instance.appMapping ) ){
						instance.configMapping = instance.appMapping & ".config.Coldbox";
					}
					else{
						instance.configMapping = "config.Coldbox";
					}
				}
				//Initialize mock Controller
				instance.controller = CreateObject("component", "coldbox.system.testing.mock.web.MockController").init( appRootPath=appRootPath, appKey=instance.coldboxAppKey );
				// persist for mock testing in right name
				application[ getColdboxAppKey() ] = instance.controller;
				// Setup
				instance.controller.getLoaderService().loadApplication( instance.configMapping, instance.appMapping );
			}
			// Auto registration of test as interceptor
			instance.controller.getInterceptorService().registerInterceptor(interceptorObject=this);
		}
		</cfscript>
	</cffunction>
	
	<!--- setup --->
	<cffunction name="setup" hint="This executes before any test method for integration tests." output="false">
		<cfscript>
			// Are we doing integration tests
			if( this.loadColdbox ){
				getController().getRequestService().removeContext();
			}
		</cfscript>
	</cffunction>

	<!--- afterTests --->
	<cffunction name="afterTests" hint="xUnit: The main teardown for ColdBox enabled applications after all tests execute" output="false">
		<cfscript>
			structDelete( application, getColdboxAppKey() );
		</cfscript>
	</cffunction>

	<!--- beforeAll --->
	<cffunction name="beforeAll" hint="BDD: The main setup method for running ColdBox Integration enabled tests" output="false">
		<cfscript>
			beforeTests();
		</cfscript>
	</cffunction>

	<!--- afterAll --->
	<cffunction name="afterAll" hint="BDD: The main teardown for ColdBox enabled applications after all tests execute" output="false">
		<cfscript>
			afterTests();
		</cfscript>
	</cffunction>

<!------------------------------------------- HELPERS ------------------------------------------->

	<!--- Get a Mock Datasource Object --->
	<cffunction name="getMockDatasource" access="private" output="false" returnType="coldbox.system.core.db.DatasourceBean" hint="I will return to you a datasourceBean according to the mocking parameters sent">
		<cfargument name="name" 	type="string" required="true"  hint="The name of the DSN on the ColdFusion administrator"/>
		<cfargument name="alias" 	type="string" required="false" default="" hint="The alias to use, if not passed the name will be used also as the alias"/>
		<cfargument name="dbtype" 	type="string" required="false" default="" hint="The db type metadata"/>
		<cfargument name="username" type="string" required="false" default="" hint="The dsn username metadata"/>
		<cfargument name="password" type="string" required="false" default="" hint="The password metadata"/>
		<cfscript>
			if( NOT len(arguments.alias) ){ arguments.alias = arguments.name; }
			return getMockBox().createMock("coldbox.system.core.db.DatasourceBean").init(arguments);
		</cfscript>
	</cffunction>
	
	<!--- getMockConfigBean --->
	<cffunction name="getMockConfigBean" access="private" output="false" returnType="coldbox.system.core.collections.ConfigBean" hint="I will return to you a configBean according to the mocking configuration structure you send in">
		<cfargument name="configStruct" type="struct" required="false" default="#structnew()#" hint="A memento of name-value pairs to init">
	    <cfscript>
			return getMockBox().createMock("coldbox.system.core.collections.ConfigBean").init(arguments.configStruct);
		</cfscript>
	</cffunction>
	
	<!--- getMockRequestBuffer --->
	<cffunction name="getMockRequestBuffer" access="private" output="false" returnType="coldbox.system.core.util.RequestBuffer" hint="I will return to you a mock request buffer object used mostly in interceptor calls">
	    <cfscript>
			return getMockBox().createMock("coldbox.system.core.util.RequestBuffer").init();
		</cfscript>
	</cffunction>
	
	<!--- getMockController --->
	<cffunction name="getMockController" access="private" output="false" returnType="coldbox.system.testing.mock.web.MockController" hint="I will return a mock controller object">
	    <cfscript>
			return CreateObject("component", "coldbox.system.testing.mock.web.MockController").init('/unittest','unitTest');
		</cfscript>
	</cffunction>
		
	<!--- getMockRequestContext --->
	<cffunction name="getMockRequestContext" output="false" access="private" returntype="coldbox.system.web.context.RequestContext" hint="Builds an empty functioning request context mocked with methods via MockBox.  You can also optionally wipe all methods on it.">
		<cfargument name="clearMethods" type="boolean" 	required="false" default="false" hint="Clear Methods on it?"/>
		<cfargument name="decorator" 	type="any" 		required="false" hint="The class path to the decorator to build into the mock request context"/>
		<cfscript>
			var mockRC 			= "";
			var mockController 	= "";
			var rcProps 		= structnew();
			
			if( arguments.clearMethods ){
				if( structKeyExists(arguments,"decorator") ){
					return getMockBox().createEmptyMock(arguments.decorator);
				}
				return getMockBox().createEmptyMock("coldbox.system.web.context.RequestContext");
			}
			
			// Create functioning request context
			mockRC 			= getMockBox().createMock("coldbox.system.web.context.RequestContext");
			mockController = CreateObject("component", "coldbox.system.testing.mock.web.MockController").init('/unittest','unitTest');
				
			// Create mock properties
			rcProps.DefaultLayout = "";
			rcProps.DefaultView = "";
			rcProps.isSES = false;
			rcProps.sesBaseURL = "";
			rcProps.eventName = "event";
			rcProps.ViewLayouts = structnew();
			rcProps.FolderLayouts = structnew();
			rcProps.RegisteredLayouts = structnew();
			rcProps.modules = structnew();
			mockRC.init( properties=rcProps, controller=mockController );
			
			// return decorator context
			if( structKeyExists(arguments,"decorator") ){
				return getMockBox().createMock(arguments.decorator).init(mockRC, mockController);
			}
			
			// return normal RC
			return mockRC;			
		</cfscript>
	</cffunction>
	
	<!--- Get a Mock Model --->
	<cffunction name="getMockModel" access="private" returntype="any" hint="*ColdBox must be loaded for this to work. Get a mock model object by convention. You can optional clear all the methods on the model object if you wanted to. The object is created but not initiated, that would be your job." output="false" >
		<cfargument name="name" 			type="string"   required="true" hint="The name of the model to mock">
		<cfargument name="clearMethods" 	type="boolean"  required="false" default="false" hint="If true, all methods in the target mock object will be removed. You can then mock only the methods that you want to mock"/>
		<cfscript>
			var mockLocation = getController().getPlugin("BeanFactory").locateModel(arguments.name,true);
			
			if( len(mockLocation) ){
				return getMockBox().createMock(className=mockLocation,clearMethods=arguments.clearMethods);
			}
			else{
				throwit(message="Model object #arguments.name# could not be located.",type="ModelNotFoundException");
			}
		</cfscript>
	</cffunction>
	
	<!--- getMockPlugin --->
    <cffunction name="getMockPlugin" output="false" access="private" returntype="any" hint="Get a plugin mocked with capabilities">
    	<cfargument name="path" type="string" required="true" hint="The path of the plugin to mock"/>
    	<cfscript>
    		var mockBox = getMockBox();
			var plugin	= mockBox.createMock( arguments.path );
			
    		// Create Mock Objects
			var mockController 		= mockBox.createEmptyMock("coldbox.system.testing.mock.web.MockController");
			var mockRequestService 	= mockBox.createEmptyMock("coldbox.system.web.services.RequestService");
			var mockLogBox	 		= mockBox.createEmptyMock("coldbox.system.logging.LogBox");
			var mockLogger	 		= mockBox.createEmptyMock("coldbox.system.logging.Logger");
			var mockFlash		 	= mockBox.createMock("coldbox.system.web.flash.MockFlash").init(mockController);
			var mockCacheBox   		= mockBox.createEmptyMock("coldbox.system.cache.CacheFactory");
			var mockWireBox   		= mockBox.createEmptyMock("coldbox.system.ioc.Injector");
			
			// Mock Plugin Dependencies
			mockController.$("getLogBox",mockLogBox)
				.$("getCacheBox",mockCacheBox)
				.$("getWireBox",mockWireBox)
				.$("getRequestService",mockRequestService);
			mockRequestService.$("getFlashScope",mockFlash);
			mockLogBox.$("getLogger",mockLogger);
			
			// Decorate plugin?
			if( NOT getUtil().isFamilyType("plugin", plugin) ){
				getUtil().convertToColdBox( "plugin", plugin );	
				// Check if doing cbInit()
				if( structKeyExists(plugin, "$cbInit") ){ plugin.$cbInit( mockController ); }
			}
			else{
				plugin.init( mockController );
			}
			
			return plugin;
		</cfscript>
    </cffunction>

	<!--- Reset the persistence --->
	<cffunction name="reset" access="private" returntype="void" hint="Reset the persistence of the unit test coldbox app, basically removes the controller from application scope" output="false" >
		<cfset structDelete( application, getColdboxAppKey() )>
		<cfset structClear( request )>
	</cffunction>
	
	<!--- get/Set Coldbox App Key --->
	<cffunction name="getColdboxAppKey" access="private" output="false" returntype="string" hint="Get the coldboxAppKey used to store the coldbox controller in application scope.">
		<cfreturn instance.coldboxAppKey/>
	</cffunction>
	<cffunction name="setColdboxAppKey" access="private" output="false" returntype="void" hint="Override the coldboxAppKey, used to store the coldbox controller in application scope.">
		<cfargument name="coldboxAppKey" type="string" required="true"/>
		<cfset instance.coldboxAppKey = arguments.coldboxAppKey/>
	</cffunction>
	
	<!--- getter for AppMapping --->
	<cffunction name="getAppMapping" access="private" returntype="string" output="false" hint="Get the AppMapping used for this test case">
		<cfreturn instance.appMapping>
	</cffunction>
	
	<!--- setter for AppMapping --->
	<cffunction name="setAppMapping" access="private" output="false" returntype="void" hint="Set the AppMapping for this test case">
		<cfargument name="AppMapping" type="string" required="true"/>
		<cfset instance.appMapping = arguments.appMapping/>
	</cffunction>

	<!--- getter for ConfigMapping --->
	<cffunction name="getConfigMapping" access="private" returntype="string" output="false" hint="Get the ConfigMapping for this test case">
		<cfreturn instance.ConfigMapping>
	</cffunction>
	
	<!--- setter for ConfigMapping --->
	<cffunction name="setConfigMapping" access="private" output="false" returntype="void" hint="Set the ConfigMapping for this test case">
		<cfargument name="ConfigMapping" type="string" required="true"/>
		<cfset instance.ConfigMapping = arguments.ConfigMapping/>
	</cffunction>

	<!--- getter for controller --->
	<cffunction name="getController" access="private" returntype="any" output="false" hint="Get a reference to the ColdBox mock controller">
		<cfreturn instance.controller>
	</cffunction>
	
	<!--- getWireBox --->
    <cffunction name="getWireBox" output="false" access="private" returntype="any" hint="Get the wirebox instance">
    	<cfreturn instance.controller.getwireBox()>
    </cffunction>
	
	<!--- getCacheBox --->
    <cffunction name="getCacheBox" output="false" access="private" returntype="any" hint="Get a reference to cachebox">
    	<cfreturn instance.controller.getCacheBox()>
    </cffunction>
	
	<!--- getLogBox --->
    <cffunction name="getLogBox" output="false" access="private" returntype="any" hint="Get a logbox reference">
    	<cfreturn instance.controller.getLogBox()>
    </cffunction>
	
	<!--- getColdboxOCM --->
    <cffunction name="getColdboxOCM" access="private" output="false" returntype="any" hint="Get ColdboxOCM: coldbox.system.cache.CacheManager or new CacheBox providers coldbox.system.cache.IColdboxApplicationCache" colddoc:generic="coldbox.system.cache.IColdboxApplicationCache">
		<cfargument name="cacheName" type="string" required="false" default="default" hint="The cache name to retrieve"/>
		<cfreturn getController().getColdboxOCM(arguments.cacheName)/>
	</cffunction>

	<!--- Get current request context --->
	<cffunction name="getRequestContext" access="private" output="false" returntype="any" hint="Get a reference to the current mock request context">
		<cfreturn getController().getRequestService().getContext() >
	</cffunction>
	
	<!--- getFlashScope --->
	<cffunction name="getFlashScope" output="false" access="private" returntype="coldbox.system.web.Flash.AbstractFlashScope" hint="Returns to you the currently used flash ram object">
		<cfreturn getController().getRequestService().getFlashScope()>
	</cffunction>

	<!--- Setup a request context --->
	<cffunction name="setupRequest" access="private" output="false" returntype="void" hint="Setup an initial request capture.  I basically look at the FORM/URL scopes and create the request collection out of them.">
		<cfargument name="event" 	required="true"  type="string" hint="The event to setup the request context with">
		<cfscript>
			// Setup the incoming event
			URL[getController().getSetting("EventName")] = arguments.event;
			// Capture the request
			getController().getRequestService().requestCapture();
		</cfscript>
	</cffunction>

	<!--- prepare request, execute request and retrieve request --->
	<cffunction name="execute" access="private" output="false" returntype="any" hint="Executes a framework lifecycle by executing an event.  This method returns a request context object that can be used for assertions">
		<cfargument name="event" 			required="true"  type="string" hint="The event to execute">
		<cfargument name="private" 			required="false" type="boolean" default="false" hint="Call a private event or not">
		<cfargument name="prepostExempt"	required="false" type="boolean" default="false" hint="If true, pre/post handlers will not be fired.">
		<cfargument name="eventArguments"   required="false" type="struct"  default="#structNew()#" hint="A collection of arguments to passthrough to the calling event handler method"/>
		<cfargument name="renderResults" 	required="false" type="boolean" default="false" hint="If true, then it will try to do the normal rendering procedures and store the rendered content in the RC as cbox_rendered_content"/>
		<cfscript>
			var handlerResults  = "";
			var requestContext  = "";
			var relocationTypes = "TestController.setNextEvent,TestController.setNextRoute,TestController.relocate";
			var cbController    = getController();
			var renderData		= "";
			var renderedContent = "";
			var iData			= {};
				
			//Setup the request Context with setup FORM/URL variables set in the unit test.
			setupRequest(arguments.event);
			
			try{
			
				// App Start Handler
				if ( len(cbController.getSetting("ApplicationStartHandler")) ){
					cbController.runEvent(cbController.getSetting("ApplicationStartHandler"),true);
				}
				// preProcess
				cbController.getInterceptorService().processState("preProcess");
				// Request Start Handler
				if ( len(cbController.getSetting("RequestStartHandler")) ){
					cbController.runEvent(cbController.getSetting("RequestStartHandler"),true);
				}
				
				// grab the latest event in the context, in case overrides occur
				requestContext  = getRequestContext();
				arguments.event = requestContext.getCurrentEvent();
				
				// TEST EVENT EXECUTION
				if( NOT requestContext.isNoExecution() ){
					// execute the event
					handlerResults = cbController.runEvent(event=arguments.event,
													   private=arguments.private,
													   prepostExempt=arguments.prepostExempt,
													   eventArguments=arguments.eventArguments);
					
					// Are we doing rendering procedures?
					if( arguments.renderResults ){
						// preLayout
						cbController.getInterceptorService().processState("preLayout");
						
						// Render Data?
						renderData = requestContext.getRenderData();
						if( isStruct( renderData ) and NOT structIsEmpty( renderData ) ){
							renderedContent = cbController.getPlugin("Utilities").marshallData(argumentCollection=renderData);
						}
						// If we have handler results save them in our context for assertions
						else if ( isDefined("handlerResults") ){
							requestContext.setValue("cbox_handler_results", handlerResults);
							renderedContent = handlerResults;
						}
						// render layout/view pair
						else{
							renderedContent = cbController.getPlugin("Renderer")
								.renderLayout(module=requestContext.getCurrentLayoutModule(), 
										     viewModule=requestContext.getCurrentViewModule());
						}
						
						// Pre Render
						iData = { renderedContent = renderedContent };
						cbController.getInterceptorService().processState("preRender", iData);
						renderedContent = iData.renderedContent;
						
						// Store in collection for assertions
						requestContext.setValue( "cbox_rendered_content", renderedContent );
					
						// postRender
						cbController.getInterceptorService().processState("postRender");
					}
				}
				
				// Request End Handler
				if ( len(cbController.getSetting("RequestEndHandler")) ){
					cbController.runEvent( cbController.getSetting("RequestEndHandler"), true );
				}
				
				// postProcess
				cbController.getInterceptorService().processState("postProcess");
				
			}
			catch(Any e){
				// Exclude relocations so they can be asserted.
				if( NOT listFindNoCase(relocationTypes,e.type) ){
					$rethrow(e);
				}
			}
			
			// Return the correct event context.
			requestContext = getRequestContext();
			
			return requestContext;
		</cfscript>
	</cffunction>
	
	<!--- Announce Interception --->
	<cffunction name="announceInterception" access="private" returntype="any" hint="Announce an interception to the system. If you use the asynchronous facilities, you will get a thread structure report as a result." output="true" >
		<cfargument name="state" 			required="true"  type="any" hint="The interception state to execute">
		<cfargument name="interceptData" 	required="false" type="any" default="#structNew()#" hint="A data structure used to pass intercepted information.">
		<cfargument name="async" 			required="false" type="boolean" default="false" hint="If true, the entire interception chain will be ran in a separate thread."/>
		<cfargument name="asyncAll" 		required="false" type="boolean" default="false" hint="If true, each interceptor in the interception chain will be ran in a separate thread and then joined together at the end."/>
		<cfargument name="asyncAllNoJoin"	required="false" type="boolean" default="false" hint="If true, each interceptor in the interception chain will be ran in a separate thread but NOT joined together at the end."/>
		<cfargument name="asyncPriority" 	required="false" type="string"	default="NORMAL" hint="The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL"/>
		<cfargument name="asyncJoinTimeout"	required="false" type="numeric"	default="0" hint="The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout."/>
		<cfreturn getController().getInterceptorService().processState(argumentCollection=arguments)>
	</cffunction>

	<!--- Interceptor Facade --->
	<cffunction name="getInterceptor" access="private" output="false" returntype="any" hint="Get an interceptor">
		<!--- ************************************************************* --->
		<cfargument name="interceptorName" 	required="false" type="string" hint="The name of the interceptor to search for"/>
		<cfargument name="deepSearch" 		required="false" type="boolean" default="false" hint="By default we search the cache for the interceptor reference. If true, we search all the registered interceptor states for a match."/>
		<!--- ************************************************************* --->
		<cfscript>
			return getController().getInterceptorService().getInterceptor(argumentCollection=arguments);
		</cfscript>
	</cffunction>
	
	<!--- Get Model --->
	<cffunction name="getModel" access="private" returntype="any" hint="Create or retrieve model objects by convention" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 			required="false" 	hint="The mapping name or CFC instance path to try to build up"/>
		<cfargument name="dsl"				required="false" 	hint="The dsl string to use to retrieve the instance model object, mutually exclusive with 'name'"/>
		<cfargument name="initArguments" 	required="false" 	default="#structnew()#" hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<!--- ************************************************************* --->
		<cfreturn getController().getPlugin("BeanFactory").getModel(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Throw Facade --->
	<cffunction name="$throw" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
	<!--- Dump facade --->
	<cffunction name="$dump" access="private" hint="Facade for cfmx dump" returntype="void" output="false">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>
		<cfdump var="#var#">
		<cfif arguments.isAbort><cfabort></cfif>
	</cffunction>
	
	<!--- Rethrow Facade --->
	<cffunction name="$rethrow" access="private" returntype="void" hint="Rethrow facade" output="false" >
		<cfargument name="throwObject" required="true" type="any" hint="The cfcatch object">
		<cfthrow object="#arguments.throwObject#">
	</cffunction>
	
	<!--- Abort Facade --->
	<cffunction name="$abort" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>
	
	<!--- Include Facade --->
	<cffunction name="$include" access="private" hint="Facade for cfinclude" returntype="void" output="false">
		<cfargument name="template" type="string">
		<cfinclude template="#template#">
	</cffunction>
	
	<!--- getUtil --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn CreateObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

</cfcomponent>