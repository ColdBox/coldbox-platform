<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_2.6.0.xsd">
	<Settings>
		<!--The name of your application.-->
		<Setting name="AppName"						value="ofcplugin"/>
		<!-- ColdBox set-up information for J2EE installation.
		     As context-root are actually virtual locations which does not correspond to physical location of files. for example 
		     /openbd   /var/www/html/tomcat/deploy/bluedragon

		     AppMapping setting will adjust physical location of Project/App files and coldbox will load handlers,plugis,config file etc
		     Create a cf mapping and enable this value. 
		     /MyApp /var/www/html/tomcat/deploy/bluedragon/MyAppFolder
		
		If you are using a coldbox app to power flex/remote apps, you NEED to set the AppMapping also. In Summary,
		the AppMapping is either a CF mapping or the path from the webroot to this application root. If this setting
		is not set, then coldbox will try to auto-calculate it for you. Please read the docs.
		
		<Setting name="AppMapping"					value="/MyApp"/>      
		
		-->
		<!--Default Debugmode boolean flag (Set to false in production environments)-->
		<Setting name="DebugMode" 					value="false" />
		<!--The Debug Password to use in order to activate/deactivate debugmode,activated by url actions -->
		<Setting name="DebugPassword" 				value=""/>
		<!--The fwreinit password to use in order to reinitialize the framework and application.Optional, else leave blank -->
		<Setting name="ReinitPassword" 				value=""/>
		<!--Default event name variable to use in URL/FORM etc. -->
		<Setting name="EventName"					value="event" />
		<!--This feature is enabled by default to permit the url dumpvar parameter-->
		<Setting name="EnableDumpVar"				value="true" />
		<!--Log Errors and entries on the coldfusion server logs, disabled by default if not used-->
		<Setting name="EnableColdfusionLogging" 	value="false" />
		<!--Log Errors and entries in ColdBox's own logging facilities. You choose the location, finally per application logging.-->
		<Setting name="EnableColdboxLogging"		value="true" />
		<!--The absolute or relative path to where you want to store your log files for this application-->
		<Setting name="ColdboxLogsLocation"			value="logs" />
		<!--Default Event to run if no event is set or passed. Usually the event to be fired first (NOTE: use event handler syntax)-->
		<Setting name="DefaultEvent" 				value="general.index"/>
		<!--Event Handler to run on the start of a request, leave blank if not used. Emulates the Application.cfc onRequestStart method	-->
		<Setting name="RequestStartHandler" 		value="main.onRequestStart"/>
		<!--Event Handler to run at end of all requests, leave blank if not used. Emulates the Application.cfc onRequestEnd method-->
		<Setting name="RequestEndHandler" 			value="main.onRequestEnd"/>
		<!--Event Handler to run at the start of an application, leave blank if not used. Emulates the Application.cfc onApplicationStart method	-->
		<Setting name="ApplicationStartHandler" 	value="main.onAppInit"/>
		<!--Event Handler to run at the start of a session, leave blank if not used.-->
		<Setting name="SessionStartHandler" 		value="main.onSessionStart"/>
		<!--Event Handler to run at the end of a session, leave blank if not used.-->
		<Setting name="SessionEndHandler" 			value="main.onSessionEnd"/>
		<!--The event handler to execute on all framework exceptions. Event Handler syntax required.-->
		<Setting name="ExceptionHandler"			value="" />
		<!--What event to fire when an invalid event is detected-->
		<Setting name="onInvalidEvent" 				value="" />
		<!--Full path from the application's root to your custom error page, else leave blank. -->
		<Setting name="CustomErrorTemplate"			value="" />
		<!--The Email address from which all outgoing framework emails will be sent. -->
		<Setting name="OwnerEmail" 					value="evdlinden@gmail.com" />
		<!-- Enable Bug Reports to be emailed out, set to true by default if left blank
			A sample template has been provided to you in includes/generic_error.cfm
		 -->
		<Setting name="EnableBugReports" 			value="true"/>
		<!--UDF Library To Load on every request for your views and handlers -->
		<Setting name="UDFLibraryFile" 				value="" />
		<!--Messagebox Style Override. A boolean of wether to override the styles using your own css.-->
		<Setting name="MessageboxStyleOverride"		value="" />
		<!--Flag to Auto reload the internal handlers directory listing. False for production. -->
		<Setting name="HandlersIndexAutoReload"   	value="true" />
		<!--Flag to auto reload the config.xml settings. False for production. -->
		<Setting name="ConfigAutoReload"          	value="false" />
		<!-- Declare the custom plugins base invocation path, if used. You have to use dot notation.Example: mymapping.myplugins	-->
		<Setting name="MyPluginsLocation"   		value="" />
		<!-- Declare the external views location. It can be relative to this app or external. This in turn is used to do cfincludes. -->
		<Setting name="ViewsExternalLocation" 		value=""/>
		<!-- Declare the external handlers base invocation path, if used. You have to use dot notation.Example: mymapping.myhandlers	-->
		<Setting name="HandlersExternalLocation"   	value="" />
		<!--Flag to cache handlers. Default if left blank is true. -->
		<Setting name="HandlerCaching" 				value="false"/>
		<!--Flag to cache events if metadata declared. Default is true -->
		<Setting name="EventCaching" 				value="false"/>
		<!--IOC Framework if Used, else leave blank-->
		<Setting name="IOCFramework"				value="" />
		<!--IOC Definition File Path, relative or absolute -->
		<Setting name="IOCDefinitionFile"			value="" />
		<!--IOC Object Caching, true/false. For ColdBox to cache your IoC beans-->
		<Setting name="IOCObjectCaching"			value="false" />
		<!--Request Context Decorator, leave blank if not using. Full instantiation path -->
		<Setting name="RequestContextDecorator" 	value=""/>
		<!--Flag if the proxy returns the entire request collection or what the event handlers return, default is false -->
		<Setting name="ProxyReturnCollection" 		value="false"/>
		<!-- What scope are flash persistance variables using. -->
		<Setting name="FlashURLPersistScope" 		value="session"/>
	</Settings>

	<!-- Your Settings can go here, if not needed, use <YourSettings />. You can use these for anything you like.
		<YourSettings>
			<Setting name="MySetting" value="My Value"/>
			
			whether to encrypt the values or not
			<Setting name="cookiestorage_encryption" value="true"/>
			
			The encryption seed to use. Else, use a default one (Not Recommened)
			<Setting name="cookiestorage_encryption_seed" value="mykey"/>
			
			The encryption algorithm to use (According to CFML Engine)
			<Setting name="cookiestorage_encryption_algorithm" value="CFMX_COMPAT or BD_DEFAULT"/>
			
			Messagebox Plugin (You can now override the storage scope without affecting all framework applications)
			<Setting name="messagebox_storage_scope" value="session or client" />
			
			Complex Settings follow JSON Syntax. www.json.org.  
			*IMPORTANT: use single quotes in this xml file for JSON notation, ColdBox will translate it to double quotes.
		</YourSettings>
	 -->
	<YourSettings>
		<!-- Show SideBar? true/false, else leave blank. -->
		<Setting name="ColdBoxSideBar" value="false" />
		
		<!-- Path to Spry library, relative from your application root e.g. includes/Spry -->
		<Setting name="spry.relativePath" value="includes/Spry" />		
	</YourSettings>
	
	<!-- Custom Conventions : You can override the framework wide conventions of the locations of the needed objects
	<Conventions>
		<handlersLocation></handlersLocation>
		<pluginsLocation></pluginsLocation>
		<layoutsLocation></layoutsLocation>
		<viewsLocation></viewsLocation>
		<eventAction></eventAction>		
	</Conventions>	
	-->
	
	<!--
	Control the ColdBox Debugger. The panels are self explanatory. The other settings are explained below.
	PersistentRequestProfiler : Activate the event profiler across multiple requests
	maxPersistentRequestProfilers : Max records to keep in the profiler. Don't get gready.
	maxRCPanelQueryRows : If a query is dumped in the RC panel, it will be truncated to this many rows.
	
	<DebuggerSettings>
		<PersistentRequestProfiler>true</PersistentRequestProfiler>
		<maxPersistentRequestProfilers>10</maxPersistentRequestProfilers>
		<maxRCPanelQueryRows>50</maxRCPanelQueryRows>
		
		<TracerPanel 	show="true" expanded="true" />
		<InfoPanel 		show="true" expanded="true" />
		<CachePanel 	show="true" expanded="false" />
		<RCPanel		show="true" expanded="false" />
	</DebuggerSettings>
	-->
	
	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer></MailServer>
		<MailPort></MailPort>
		<MailUsername></MailUsername>
		<MailPassword></MailPassword>
	</MailServerSettings>

	<!--Emails to Send bug reports, you can create as many as you like -->
	<BugTracerReports>
		<!-- <BugEmail>myemail@gmail.com</BugEmail> -->
	</BugTracerReports>
	
	<!--List url dev environments, this determines your dev/pro environment for the framework-->
	<DevEnvironments>
		<url>dev</url>
	</DevEnvironments>

	<!--Webservice declarations your use in your application, if not use, leave blank
	Note that for the same webservice name you can have a development url and a production url.-->
	<WebServices>
		<!-- <WebService name="TESTWS1" URL="http://www.test.com/test1.cfc?wsdl" DevURL="http://dev.test.com/test1.cfc?wsdl" /> -->
		<!-- <WebService name="TESTWS2" URL="http://www.test.com/test2.cfc?wsdl" DevURL="http://dev.test.com/test2.cfc?wsdl" /> -->
	</WebServices>

	<!--Declare Layouts for your application here-->
	<Layouts>
		<!--Declare the default layout, MANDATORY-->
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
		
		<!--Default View, OPTIONAL
		<DefaultView>home</DefaultView>
		-->
		
		<!--
		Declare other layouts, with view/folder assignments if needed, else do not write them
		<Layout file="Layout.Popup.cfm" name="popup">
			<View>vwTest</View>
			<View>vwMyView</View>
			<Folder>tags</Folder>
		</Layout>
		-->
	</Layouts>

	<!--Internationalization and resource Bundle setup:
	<i18N>
		<DefaultResourceBundle>includes/main</DefaultResourceBundle>
		<DefaultLocale>en_US</DefaultLocale>
		<LocaleStorage>session</LocaleStorage>
		<UknownTranslation></UknownTranslation>
	</i18N>
	-->
	<i18N />
	
	<!--Datasource Setup, you can then retreive a datasourceBean via the getDatasource("name") method: -->
	<Datasources>
		<!-- <Datasource alias="MyDSNAlias" name="real_dsn_name"   dbtype="mysql"  username="" password="" /> -->
	</Datasources>
	<!--ColdBox Object Caching Settings Overrides the Framework-wide settings 
	<Cache>
		<ObjectDefaultTimeout>60</ObjectDefaultTimeout>
		<ObjectDefaultLastAccessTimeout>30</ObjectDefaultLastAccessTimeout>
		<UseLastAccessTimeouts>true</UseLastAccessTimeouts>
		<ReapFrequency>1</ReapFrequency>
		<MaxObjects>100</MaxObjects>
		<FreeMemoryPercentageThreshold>1</FreeMemoryPercentageThreshold>
		<EvictionPolicy>LRU</EvictionPolicy>
	</Cache>
	-->
	
	<!-- Interceptor Declarations 
	<Interceptors throwOnInvalidStates="true">
		<CustomInterceptionPoints>comma-delimited list</CustomInterceptionPoints>
		<Interceptor class="full class name">
			<Property name="myProp">value</Property>
			<Property name="myArray">[1,2,3]</Property>
			<Property name="myStruct">{ key1:1, key2:2 }</Property>
		</Inteceptor>
		<Interceptor class="no property" />
	</Interceptors>
	-->
	
	<Interceptors>
		<!-- config file is relative to app root -->
		<Interceptor class="coldbox.system.interceptors.ses">
			<Property name="configFile">config/routes.cfm</Property>
		</Interceptor>
		<!-- Developer's ColdBox Sidebar -->
		<Interceptor class="coldbox.system.interceptors.coldboxSideBar">
			<!-- Y offset: number, else leave blank -->
			<Property name="yOffset"></Property>
			<!-- Scroll: true/false, else leave blank -->
			<Property name="isScroll"></Property>
			<!-- Slide Speed: number, else leave blank -->
			<Property name="slideSpeed"></Property>
			<!-- Wait time before closing: number, else leave blank -->
			<Property name="waitTimeBeforeClose"></Property>
			<!-- Links (JSON array of objects), else leave blank
			e.g. 
				[
				{"desc":"ColdBox API","href":"http:\/\/www.coldboxframework.com\/api\/"}
				,{"desc":"ColdBox Credits","href":"http:\/\/ortus.svnrepository.com\/coldbox\/trac.cgi\/wiki\/cbCredits"}
				,{"desc":"ColdBox SideBar Help","href":"http:\/\/ortus.svnrepository.com\/coldbox\/trac.cgi\/wiki\/cbSideBar"}
				,{"desc":"Transfer Docs","href":"http:\/\/docs.transfer-orm.com\/"}
				,{"desc":"My API","href":"http:\/\/localhost\/myApi/"}
				,{"desc":"My Database Schema","href":"http:\/\/localhost\/myDatabaseSchema.pdf"}
				]			
			 -->
 			<Property name="links">
					[{"desc":"CFC Doc","href":"\/cfcdoc"}]
			</Property>
			<!-- Width of the sidebar including visible width, else leave blank -->
			<Property name="width"></Property>
			<!-- Visible width, else leave blank  -->
			<Property name="visibleWidth"></Property>
			<!--Full path from the application's root, else leave blank. -->
			<Property name="imagePath"></Property>
			<!-- Vertical alignment of the image: top,middle or bottom, else leave blank  -->
			<Property name="imageVAlign"></Property>
			<!--Full path from the application's root, else leave blank -->
			<Property name="cssPath"></Property>
		</Interceptor>
	</Interceptors>
	
</Config>
