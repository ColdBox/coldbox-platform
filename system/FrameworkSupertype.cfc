<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	August 21, 2006
Description :
	This is a cfc that contains method implementations for the base
	cfc's eventhandler and plugin. This is an action base controller,
	is where all action methods will be placed.
	The front controller remains lean and mean.

----------------------------------------------------------------------->
<cfcomponent hint="This is the layer supertype cfc for all ColdBox related objects." output="false" serializable="false">

	<!--- init instance for all --->
	<cfset instance	= {}>

<!------------------------------------------- PUBLIC METHODS ------------------------------------------->

	<!--- Get Memento --->
	<cffunction name="getMemento" access="public" hint="Get the memento of this object" returntype="any" output="false">
		<cfreturn instance>
	</cffunction>

	<!--- Discover fw Locale --->
	<cffunction name="getfwLocale" access="public" output="false" returnType="any" hint="Get the user's currently set locale or default locale">
		<cfscript>
			if(NOT structKeyExists(variables,"cbox18n") ){
				variables.cbox18n = controller.getPlugin("i18n");
			}
			return variables.cbox18n.getfwLocale();
		</cfscript>
	</cffunction>

	<!--- set the fw locale for a user --->
	<cffunction name="setfwLocale" access="public" output="false" returnType="any" hint="Set the default locale to use in the framework for a specific user. Utility Method">
		<cfargument name="locale"     		type="any"  required="false"  hint="The locale to change and set. Must be Java Style: en_US">
		<cfargument name="dontloadRBFlag" 	type="any" 	required="false"  hint="Flag to load the resource bundle for the specified locale (If not already loaded) or just change the framework's locale. Boolean" colddoc:generic="Boolean">
		<cfscript>
			if(NOT structKeyExists(variables,"cbox18n") ){
				variables.cbox18n = controller.getPlugin("i18n");
			}
			return variables.cbox18n.setfwLocale(argumentCollection=arguments);
		</cfscript>
	</cffunction>

<!------------------------------------------- Private RESOURCE METHODS ------------------------------------------->

	<!--- Get a Datasource Object --->
	<cffunction name="getDatasource" access="public" output="false" returnType="any" hint="I will return to you a datasourceBean according to the alias of the datasource you wish to get from the configstruct" colddoc:generic="coldbox.system.core.db.DatasourceBean">
		<cfargument name="alias" type="any" hint="The alias of the datasource to get from the configstruct (alias property in the config file)">
		<cfscript>
		var datasources = controller.getSetting("Datasources");
		//Check for datasources structure
		if ( structIsEmpty(datasources) ){
			$throw("There are no datasources defined for this application.","","FrameworkSupertype.DatasourceStructureEmptyException");
		}

		//Try to get the correct datasource.
		if ( structKeyExists(datasources, arguments.alias) ){
			return CreateObject("component","coldbox.system.core.db.DatasourceBean").init(datasources[arguments.alias]);
		}

		$throw("The datasource: #arguments.alias# is not defined.","Datasources: #structKeyList(datasources)#","FrameworkSupertype.DatasourceNotFoundException");
		</cfscript>
	</cffunction>

	<!--- Get Mail Settings Object --->
	<cffunction name="getMailSettings" access="public" output="false" returnType="any" hint="I will return to you a mailsettingsBean modeled after your mail settings in your config file." colddoc:generic="coldbox.system.core.mail.MailSettingsBean">
		<cfreturn CreateObject("component","coldbox.system.core.mail.MailSettingsBean").init(argumentCollection=controller.getSetting("mailSettings"))>
	</cffunction>

	<!--- getMailService --->
    <cffunction name="getMailService" output="false" access="public" returntype="any" hint="Get a reference to our Mail Service plugin">
    	<cfreturn controller.getPlugin("MailService")>
    </cffunction>

	<!--- getNewMail --->
    <cffunction name="getNewMail" output="false" access="public" returntype="any" hint="Get a new mail payload object ready for sending email through our mail service.  This function's arguments match the cfmail tag, so send whatever you like">
    	<cfreturn controller.getPlugin("MailService").newMail(argumentCollection=arguments)>
    </cffunction>

	<!--- Get a Resource --->
	<cffunction name="getResource" access="public" output="false" returnType="any" hint="Facade to i18n.getResource. Returns a string.">
		<cfargument name="resource" type="any" required="true"  hint="The resource (key) to retrieve from the main loaded bundle.">
		<cfargument name="default"  type="any" required="false" hint="A default value to send back if the resource (key) not found" >
		<cfargument name="locale"   type="any" required="false" hint="Pass in which locale to take the resource from. By default it uses the user's current set locale" >
		<cfargument name="values" 	type="any" required="false" hint="An array, struct or simple string of value replacements to use on the resource string"/>
		<cfargument name="bundle" 	type="any" required="false"	hint="The bundle alias to use to get the resource from when using multiple resource bundles. By default the bundle name used is 'default'">
		<cfscript>
			if( NOT structKeyExists( variables, "cboxResourceBundle" ) ){
				variables.cboxResourceBundle = controller.getPlugin( "ResourceBundle" );
			}
			return variables.cboxResourceBundle.getResource( argumentCollection=arguments );
		</cfscript>
	</cffunction>

	<!--- Get a Settings Bean --->
	<cffunction name="getSettingsBean"  hint="Returns a configBean with all the configuration structure." access="public"  returntype="coldbox.system.core.collections.ConfigBean"   output="false">
		<cfargument name="FWSetting"  	type="boolean" 	 required="false"  default="false" hint="Whether to build the config bean with coldbox settings or config settings">
		<cfscript>
			var config = createObject("component","coldbox.system.core.collections.ConfigBean");
			if( arguments.FWSetting ){
				return config.init( controller.getColdboxSettings() );
			}
			return config.init( controller.getConfigSettings() );
		</cfscript>
	</cffunction>

	<!--- Get Model --->
	<cffunction name="getModel" access="public" returntype="any" hint="Create or retrieve model objects by convention" output="false" >
		<cfargument name="name" 			required="false" 	hint="The mapping name or CFC instance path to try to build up"/>
		<cfargument name="dsl"				required="false" 	hint="The dsl string to use to retrieve the instance model object, mutually exclusive with 'name'"/>
		<cfargument name="initArguments" 	required="false" 	default="#structnew()#" hint="The constructor structure of arguments to passthrough when initializing the instance" colddoc:generic="struct"/>
		<cfreturn controller.getWireBox().getInstance(argumentCollection=arguments)>
	</cffunction>

	<!--- validateModel --->
    <cffunction name="validateModel" output="false" access="public" returntype="coldbox.system.validation.result.IValidationResult" hint="Validate a target object">
    	<cfargument name="target" 		type="any" 		required="true" hint="The target object to validate or a structure of name-value paris to validate."/>
		<cfargument name="fields" 		type="string" 	required="false" default="*" hint="Validate on all or one or a list of fields (properties) on the target, by default we validate all fields declared in its constraints"/>
		<cfargument name="constraints" 	type="any" 		required="false" hint="The shared constraint name to use, or an actual constraints structure"/>
    	<cfargument name="locale"		type="string" 	required="false" default="" hint="The locale to validate in"/>
    	<cfargument name="excludeFields" type="string" 	required="false" default="" hint="The fields to exclude in the validation"/>
    	<cfreturn getValidationManager().validate(argumentCollection=arguments)>
    </cffunction>

    <!--- Retrieve the applications Validation Manager --->
   <cffunction name="getValidationManager" access="public" returntype="coldbox.system.validation.IValidationManager" output="false" hint="Retrieve the application's configured Validation Manager">
    	<cfreturn controller.getValidationManager()>
    </cffunction>

	<!--- Populate a model object from the request Collection --->
	<cffunction name="populateModel" access="public" output="false" returntype="Any" hint="Populate a named or instantiated model (java/cfc) from the request collection items">
		<cfargument name="model" 			required="true"  type="any" 	hint="The name of the model to get and populate or the acutal model object. If you already have an instance of a model, then use the populateBean() method">
		<cfargument name="scope" 			required="false" type="any"  	default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean" colddoc:generic="Boolean"/>
		<cfargument name="include"  		required="false" type="any"  	default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="any" 	default="" hint="A list of keys to exclude in the population">
		<cfargument name="ignoreEmpty" 		required="false" type="boolean" default="false" hint="Ignore empty values on populations, great for ORM population"/>
		<cfargument name="nullEmptyInclude"	required="false" type="string"  default="" hint="A list of keys to NULL when empty" />
		<cfargument name="nullEmptyExclude"	required="false" type="string"  default="" hint="A list of keys to NOT NULL when empty" />
		<cfargument name="composeRelationships" required="false" type="boolean" default="false" hint="Automatically attempt to compose relationships from memento" />
		<cfscript>
			// Get memento
			arguments.memento = controller.getRequestService().getContext().getCollection();
			// Do we have a model or name
			if( isSimpleValue(arguments.model) ){
				arguments.target = getModel(model);
			}
			else{
				arguments.target = arguments.model;
			}
			// populate
			return controller.getWireBox().getObjectPopulator().populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- View Rendering Facades --->
	<cffunction name="renderView" access="public" hint="Renders all kinds of views" output="false" returntype="Any">
		<cfargument name="view" 					required="true"  type="any">
		<cfargument name="cache" 					required="false" type="any" hint="True if you want to cache the view.">
		<cfargument name="cacheTimeout" 			required="false" type="any" hint="The cache timeout">
		<cfargument name="cacheLastAccessTimeout" 	required="false" type="any" hint="The last access timeout">
		<cfargument name="cacheSuffix" 				required="false" type="any" hint="Add a cache suffix to the view cache entry. Great for multi-domain caching or i18n caching."/>
		<cfargument name="module" 					required="false" type="any" hint="Explicitly render a layout from this module"/>
		<cfargument name="args"   					required="false" type="struct" default="#structNew()#" hint="An optional set of arguments that will be available to this layouts/view rendering ONLY"/>
		<cfargument name="collection" 				required="false" type="any" hint="A collection to use by this Renderer to render the view as many times as the items in the collection"/>
		<cfargument name="collectionAs" 			required="false" type="any"	hint="The name of the collection variable in the partial rendering.  If not passed, we will use the name of the view by convention"/>
		<cfreturn controller.getPlugin("Renderer").renderView(argumentCollection=arguments)>
	</cffunction>
	<cffunction name="renderExternalView" access="public" hint="Renders external views" output="false" returntype="Any">
		<cfargument name="view" 					required="true"  type="any"  hint="The full path to the view. This can be an expanded path or relative. Include extension.">
		<cfargument name="cache" 					required="false" type="any"  hint="True if you want to cache the view.">
		<cfargument name="cacheTimeout" 			required="false" type="any"  hint="The cache timeout">
		<cfargument name="cacheLastAccessTimeout" 	required="false" type="any"  hint="The last access timeout">
		<cfargument name="cacheSuffix" 				required="false" type="any"  hint="Add a cache suffix to the view cache entry. Great for multi-domain caching or i18n caching."/>
		<cfargument name="args"   					required="false" type="struct" default="#structNew()#" hint="An optional set of arguments that will be available to this layouts/view rendering ONLY"/>
		<cfreturn controller.getPlugin("Renderer").renderExternalView(argumentCollection=arguments)>
	</cffunction>

	<!--- Render layout --->
	<cffunction name="renderLayout" access="Public" hint="Renders a layout with view combinations" output="false" returntype="any">
		<cfargument name="layout" required="false" type="any" hint="The explicit layout to use in rendering."/>
		<cfargument name="view"   required="false" type="any" hint="The name of the view to passthrough as an argument so you can refer to it as arguments.view"/>
		<cfargument name="module" required="false" type="any" hint="Explicitly render a layout from this module"/>
		<cfargument name="args"   required="false" type="struct" default="#structNew()#" hint="An optional set of arguments that will be available to this layouts/view rendering ONLY"/>
		<cfreturn controller.getPlugin("Renderer").renderLayout(argumentCollection=arguments)>
	</cffunction>

	<!--- Plugin Facades --->
	<cffunction name="getMyPlugin" access="public" hint="Facade" returntype="any" output="false">
		<cfargument name="plugin" 		type="any"  required="true" hint="The plugin name as a string" >
		<cfargument name="newInstance"  type="any"  required="false" default="false" colddoc:generic="Boolean">
		<cfargument name="module" 		type="any" 	required="false" default="" hint="The module to retrieve the plugin from"/>
		<cfargument name="init" 		type="any"  required="false" default="true" hint="Auto init() the plugin upon construction" colddoc:generic="Boolean"/>
		<cfset arguments.customPlugin = true>
		<cfreturn controller.getPlugin(argumentCollection=arguments)>
	</cffunction>
	<cffunction name="getPlugin"   access="public" hint="Facade" returntype="any" output="false">
		<cfargument name="plugin"       type="any" hint="The Plugin object's name to instantiate, as a string" >
		<cfargument name="customPlugin" type="any"  required="false" default="false" colddoc:generic="Boolean">
		<cfargument name="newInstance"  type="any"  required="false" default="false" colddoc:generic="Boolean">
		<cfargument name="module" 		type="any" 	required="false" default="" hint="The module to retrieve the plugin from"/>
		<cfargument name="init" 		type="any"  required="false" default="true" hint="Auto init() the plugin upon construction" colddoc:generic="Boolean"/>
		<cfreturn controller.getPlugin(argumentCollection=arguments)>
	</cffunction>

	<!--- Interceptor Facade --->
	<cffunction name="getInterceptor" access="public" output="false" returntype="any" hint="Get an interceptor">
		<cfargument name="interceptorName" 	required="false" type="any" hint="The name of the interceptor to search for"/>
		<cfargument name="deepSearch" 		required="false" type="any" default="false" hint="By default we search the cache for the interceptor reference. If true, we search all the registered interceptor states for a match." colddoc:generic="Boolean"/>
		<cfreturn controller.getInterceptorService().getInterceptor(argumentCollection=arguments)>
	</cffunction>

	<!--- Announce Interception --->
	<cffunction name="announceInterception" access="public" returntype="any" hint="Announce an interception to the system. If you use the asynchronous facilities, you will get a thread structure report as a result." output="true" >
		<cfargument name="state" 			required="true"  type="any" hint="The interception state to execute">
		<cfargument name="interceptData" 	required="false" type="any" hint="A data structure used to pass intercepted information.">
		<cfargument name="async" 			required="false" type="boolean" default="false" hint="If true, the entire interception chain will be ran in a separate thread."/>
		<cfargument name="asyncAll" 		required="false" type="boolean" default="false" hint="If true, each interceptor in the interception chain will be ran in a separate thread and then joined together at the end."/>
		<cfargument name="asyncAllJoin"		required="false" type="boolean" default="true" hint="If true, each interceptor in the interception chain will be ran in a separate thread and joined together at the end by default.  If you set this flag to false then there will be no joining and waiting for the threads to finalize."/>
		<cfargument name="asyncPriority" 	required="false" type="string"	default="NORMAL" hint="The thread priority to be used. Either LOW, NORMAL or HIGH. The default value is NORMAL"/>
		<cfargument name="asyncJoinTimeout"	required="false" type="numeric"	default="0" hint="The timeout in milliseconds for the join thread to wait for interceptor threads to finish.  By default there is no timeout."/>
		<cfreturn controller.getInterceptorService().processState(argumentCollection=arguments)>
	</cffunction>

	<!---Cache Facades --->
	<cffunction name="getColdboxOCM" access="public" output="false" returntype="any" hint="Get a CacheBox Cache of type: coldbox.system.cache.IColdboxApplicationCache" colddoc:generic="coldbox.system.cache.IColdboxApplicationCache">
		<cfargument name="cacheName" type="any" required="false" default="default" hint="The cache name to retrieve"/>
		<cfreturn controller.getColdboxOCM(arguments.cacheName)/>
	</cffunction>

	<!--- Setting Facades --->
	<cffunction name="getSettingStructure"  hint="Facade" access="public"  returntype="struct"   output="false">
		<cfargument name="FWSetting"  	type="boolean" 	 required="false"  default="false">
		<cfargument name="DeepCopyFlag" type="boolean"   required="false"  default="false">
		<cfreturn controller.getSettingStructure(argumentCollection=arguments)>
	</cffunction>
	<cffunction name="getSetting" 	hint="Facade" access="public" returntype="any"      output="false">
		<cfargument name="name" 	    type="any"  	required="true">
		<cfargument name="FWSetting"  	type="boolean" 	required="false" default="false">
		<cfargument name="defaultValue"	type="any" 		required="false" hint="Default value to return if not found.">
		<cfreturn controller.getSetting(argumentCollection=arguments)>
	</cffunction>
	<cffunction name="settingExists" 		hint="Facade" access="public" returntype="boolean"  output="false">
		<cfargument name="name" 		type="any"  	required="true">
		<cfargument name="FWSetting"  	type="boolean"  required="false"  default="false">
		<cfreturn controller.settingExists(argumentCollection=arguments)>
	</cffunction>
	<cffunction name="setSetting" 		    hint="Facade" access="public"  returntype="void"     output="false">
		<cfargument name="name"  type="any" required="true" >
		<cfargument name="value" type="any" required="true" >
		<cfset controller.setSetting(argumentCollection=arguments)>
	</cffunction>

	<!--- getModuleSettings --->
	<cffunction name="getModuleSettings" output="false" access="public" returntype="any" hint="Get a module's setting structure if it exists">
		<cfargument name="module" type="any" required="true" hint="The module name"/>
		<cfscript>
			var mConfig = controller.getSetting("modules");

			if( structKeyExists(mConfig,arguments.module) ){
				return mConfig[arguments.module];
			}
			$throw(message="The module you passed #arguments.module# is invalid.",detail="The loaded modules are #structKeyList(mConfig)#",type="FrameworkSuperType.InvalidModuleException");
		</cfscript>
	</cffunction>

	<!--- Event Facades --->
	<cffunction name="setNextEvent" access="public" returntype="void" hint="Facade"  output="false">
		<cfargument name="event"  				required="false" type="string"  hint="The name of the event to run, if not passed, then it will use the default event found in your configuration file.">
		<cfargument name="queryString"  		required="false" type="string"  hint="The query string to append, if needed. If in SES mode it will be translated to convention name value pairs">
		<cfargument name="addToken"				required="false" type="boolean" hint="Wether to add the tokens or not. Default is false">
		<cfargument name="persist" 				required="false" type="string"  hint="What request collection keys to persist in flash ram">
		<cfargument name="persistStruct" 		required="false" type="struct"  hint="A structure key-value pairs to persist in flash ram.">
		<cfargument name="ssl"					required="false" type="boolean" hint="Whether to relocate in SSL or not">
		<cfargument name="baseURL" 				required="false" type="string"  hint="Use this baseURL instead of the index.cfm that is used by default. You can use this for ssl or any full base url you would like to use. Ex: https://mysite.com/index.cfm"/>
		<cfargument name="postProcessExempt"    required="false" type="boolean" hint="Do not fire the postProcess interceptors">
		<cfargument name="URL"  				required="false" type="string"  hint="The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'"/>
		<cfargument name="URI"  				required="false" type="string"  hint="The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'"/>
		<cfargument name="statusCode" 			required="false" type="numeric" hint="The status code to use in the relocation"/>
		<cfset controller.setNextEvent(argumentCollection=arguments)>
	</cffunction>

	<!--- setNextRoute --->
	<cffunction name="setNextRoute" access="public" returntype="void" hint="This method is now deprecated, please use setNextEvent(). This method will be removed later on"  output="false">
		<cfargument name="route"  			required="true"	 type="string" hint="The route to relocate to, do not prepend the baseURL or /.">
		<cfargument name="persist" 			required="false" type="string" default="" hint="What request collection keys to persist in the relocation">
		<cfargument name="persistStruct" 	required="false" type="struct" hint="A structure key-value pairs to persist.">
		<cfargument name="addToken"			required="false" type="boolean" default="false"	hint="Wether to add the tokens or not. Default is false">
		<cfargument name="ssl"				required="false" type="boolean" default="false"	hint="Whether to relocate in SSL or not">
		<cfscript>
			arguments.event = arguments.route;
			controller.setNextEvent(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- runEvent --->
	<cffunction name="runEvent" access="public" returntype="any" hint="Facade to controller's runEvent() method." output="false">
		<cfargument name="event" 			type="any"  	required="false" default="">
		<cfargument name="prepostExempt" 	type="any" 		required="false" default="false" hint="If true, pre/post handlers will not be fired. Boolean" colddoc:generic="boolean">
		<cfargument name="private" 		 	type="any" 		required="false" default="false" hint="Execute a private event or not, default is false" colddoc:generic="boolean">
		<cfargument name="default" 			type="any" 		required="false" default="false" hint="The flag that let's this service now if it is the default set event running or not. USED BY THE FRAMEWORK ONLY" colddoc:generic="boolean">
		<cfargument name="eventArguments" 	type="any"  	required="false" default="#structNew()#" hint="A collection of arguments to passthrough to the calling event handler method. struct" colddoc:generic="struct">
		<cfset var refLocal = structnew()>
		<cfset reflocal.results = controller.runEvent(argumentCollection=arguments)>
		<cfif structKeyExists(refLocal,"results")>
			<cfreturn refLocal.results>
		</cfif>
	</cffunction>

	<!--- Flash Perist variables. --->
	<cffunction name="persistVariables" access="public" returntype="void" hint="Persist variables for flash redirections" output="false" >
		<cfargument name="persist" 			required="false" type="string" default="" hint="What request collection keys to persist in the relocation">
		<cfargument name="persistStruct" 	required="false" type="struct" hint="A structure key-value pairs to persist.">
		<cfset controller.persistVariables(argumentCollection=arguments)>
	</cffunction>

	<!--- Debug Mode Facades --->
	<cffunction name="getDebugMode" access="public" hint="Facade to get your current debug mode" returntype="boolean"  output="false">
		<cfreturn controller.getDebuggerService().getDebugMode()>
	</cffunction>
	<cffunction name="setDebugMode" access="public" hint="Facade to set your debug mode" returntype="void"  output="false">
		<cfargument name="mode" type="boolean" required="true" >
		<cfset controller.getDebuggerService().setDebugMode(arguments.mode)>
	</cffunction>

	<!--- getController --->
	<cffunction name="getController" access="public" output="false" returntype="any" hint="Get controller: coldbox.system.web.Controller">
		<cfreturn variables.controller/>
	</cffunction>

<!------------------------------------------- UTILITY METHODS ------------------------------------------->

	<!--- locateFilePath --->
	<cffunction name="locateFilePath" output="false" access="public" returntype="string" hint="Locate the real path location of a file in a coldbox application. 3 checks: 1) inside of coldbox app, 2) expand the path, 3) Absolute location. If path not found, it returns an empty path">
		<cfargument name="pathToCheck" type="any"  required="true" hint="The path to check"/>
		<cfscript>
			var foundPath = "";
			var appRoot = controller.getAppRootPath();

			//Check 1: Inside of App Root
			if ( fileExists(appRoot & arguments.pathToCheck) ){
				foundPath = appRoot & arguments.pathToCheck;
			}
			//Check 2: Expand the Path
			else if( fileExists( ExpandPath(arguments.pathToCheck) ) ){
				foundPath = ExpandPath( arguments.pathToCheck );
			}
			//Check 3: Absolute Path
			else if( fileExists( arguments.pathToCheck ) ){
				foundPath = arguments.pathToCheck;
			}

			//Return
			return foundPath;
		</cfscript>
	</cffunction>

	<!--- locateFilePath --->
	<cffunction name="locateDirectoryPath" output="false" access="public" returntype="string" hint="Locate the real path location of a directory in a coldbox application. 3 checks: 1) inside of coldbox app, 2) expand the path, 3) Absolute location. If path not found, it returns an empty path">
		<cfargument name="pathToCheck" type="any"  required="true" hint="The path to check"/>
		<cfscript>
			var foundPath = "";
			var appRoot = controller.getAppRootPath();

			//Check 1: Inside of App Root
			if ( directoryExists(appRoot & arguments.pathToCheck) ){
				foundPath = appRoot & arguments.pathToCheck;
			}
			//Check 2: Expand the Path
			else if( directoryExists( ExpandPath(arguments.pathToCheck) ) ){
				foundPath = ExpandPath( arguments.pathToCheck );
			}
			//Check 3: Absolute Path
			else if( directoryExists( arguments.pathToCheck ) ){
				foundPath = arguments.pathToCheck;
			}

			//Return
			return foundPath;
		</cfscript>
	</cffunction>

	<!--- addAsset --->
	<cffunction name="addAsset" output="false" access="public" returntype="any" hint="Add a js/css asset(s) to the html head section. You can also pass in a list of assets.">
		<cfargument name="asset" type="any" required="true" hint="The asset to load, only js or css files. This can also be a comma delimmited list."/>
		<cfscript>
			return controller.getPlugin("HTMLHelper").addAsset(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Include UDF --->
	<cffunction name="includeUDF" access="public" hint="Injects a UDF Library (*.cfc or *.cfm) into the target object.  It does not however, put the mixins on any of the cfc scopes. Therefore they can only be called internally." output="false" returntype="void">
		<cfargument name="udflibrary" required="true" type="any" hint="The UDF library to inject.">
		<cfscript>
			var appMapping		= controller.getSetting("AppMapping");
			var UDFFullPath 	= ExpandPath( arguments.udflibrary );
			var UDFRelativePath = ExpandPath("/" & appMapping & "/" & arguments.udflibrary);

			// Relative Checks First
			if( fileExists( UDFRelativePath ) ){
				$include( "/" & appMapping & "/" & arguments.udflibrary );
			}
			// checks if no .cfc or .cfm where sent
			else if( fileExists(UDFRelativePath & ".cfc") ){
				$include( "/" & appMapping & "/" & arguments.udflibrary & ".cfc" );
			}
			else if( fileExists(UDFRelativePath & ".cfm") ){
				$include( "/" & appMapping & "/" & arguments.udflibrary & ".cfm" );
			}
			// Absolute Checks
			else if( fileExists( UDFFullPath ) ){
				$include("#udflibrary#");
			}
			else if( fileExists(UDFFullPath & ".cfc") ){
				$include("#udflibrary#.cfc");
			}
			else if( fileExists(UDFFullPath & ".cfm") ){
				$include("#udflibrary#.cfm");
			}
			else{
				$throw(message="Error loading UDFLibraryFile: #arguments.udflibrary#",
					  detail="The UDF library was not found.  Please make sure you verify the file location.",
					  type="FrameworkSupertype.UDFLibraryNotFoundException");
			}
		</cfscript>
	</cffunction>

	<!--- loadGlobalUDFLibraries --->
    <cffunction name="loadGlobalUDFLibraries" output="false" access="public" returntype="any" hint="Load the global UDF libraries defined in the UDFLibraryFile Setting">
    	<cfscript>
			// Inject global helpers
			var udfs	= controller.getSetting("UDFLibraryFile");
			var udfLen 	= arrayLen( udfs );
			var x		= 1;

			for(x=1; x lte udfLen; x++){
				includeUDF( udfs[x] );
			}

			return this;
    	</cfscript>
    </cffunction>

	<!--- CFLOCATION Facade --->
	<cffunction name="relocate" access="public" hint="This method will be deprecated, please use setNextEvent() instead." returntype="void" output="false">
		<cfargument name="url" 		required="true" 	type="string">
		<cfargument name="addtoken" required="false" 	type="boolean" default="false">
		<cfargument name="postProcessExempt"  type="boolean" required="false" default="false" hint="Do not fire the postProcess interceptors">
		<cfset controller.setNextEvent(argumentCollection=arguments)>
	</cffunction>

	<!--- cfhtml head facade --->
	<cffunction name="$htmlhead" access="public" returntype="void" hint="Facade to cfhtmlhead" output="false" >
		<cfargument name="content" required="true" type="string" hint="The content to send to the head">
		<cfhtmlhead text="#arguments.content#">
	</cffunction>

	<!--- Throw Facade --->
	<cffunction name="$throw" access="public" hint="Facade for cfthrow" output="false">
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>

	<!--- Dump facade --->
	<cffunction name="$dump" access="public" hint="Facade for cfmx dump" returntype="void" output="true">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>
		<cfdump var="#arguments.var#">
		<cfif arguments.isAbort><cfabort></cfif>
	</cffunction>

	<!--- Rethrow Facade --->
	<cffunction name="$rethrow" access="public" returntype="void" hint="Rethrow facade" output="false" >
		<cfargument name="throwObject" required="true" type="any" hint="The cfcatch object">
		<cfthrow object="#arguments.throwObject#">
	</cffunction>

	<!--- Abort Facade --->
	<cffunction name="$abort" access="public" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>

	<!--- Include Facade --->
	<cffunction name="$include" access="public" hint="Facade for cfinclude" returntype="void" output="true">
		<cfargument name="template" type="string"><cfinclude template="#arguments.template#">
	</cffunction>

</cfcomponent>