<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_2.5.0.xsd">
	<Settings>
		<!--The name of your application.-->
		<Setting name="AppName"						value="Security Sample"/>
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
		<Setting name="DefaultEvent" 				value="ehGeneral.index"/>
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
		<Setting name="EnableBugReports" 			value="false"/>
		<!--UDF Library To Load on every request for your views and handlers -->
		<Setting name="UDFLibraryFile" 				value="" />
		<!--Messagebox Style Override. A boolean of wether to override the styles using your own css.-->
		<Setting name="MessageboxStyleOverride"		value="" />
		<!--Flag to Auto reload the internal handlers directory listing. False for production. -->
		<Setting name="HandlersIndexAutoReload"   	value="false" />
		<!--Flag to auto reload the config.xml settings. False for production. -->
		<Setting name="ConfigAutoReload"          	value="false" />
		<!-- Declare the custom plugins base invocation path, if used. You have to use dot notation.Example: mymapping.myplugins	-->
		<Setting name="MyPluginsLocation"   		value="" />
		<!-- Declare the external handlers base invocation path, if used. You have to use dot notation.Example: mymapping.myhandlers	-->
		<Setting name="HandlersExternalLocation"   	value="" />
		<!--Flag to cache handlers. Default if left blank is true. -->
		<Setting name="HandlerCaching" 				value="true"/>
		<!--Flag to cache events if metadata declared. Default is true -->
		<Setting name="EventCaching" 				value="true"/>
		<!--IOC Framework if Used, else leave blank-->
		<Setting name="IOCFramework"				value="LightWire" />
		<!--IOC Definition File Path, relative or absolute -->
		<Setting name="IOCDefinitionFile"			value="coldbox.samples.applications.securitysample.config.LightWire" />
		<!--IOC Object Caching, true/false. For ColdBox to cache your IoC beans-->
		<Setting name="IOCObjectCaching"			value="false" />
		<!--Request Context Decorator, leave blank if not using. Full instantiation path -->
		<Setting name="RequestContextDecorator" 	value=""/>
		<!--Flag if the proxy returns the entire request collection or what the event handlers return, default is false -->
		<Setting name="ProxyReturnCollection" 		value="false"/>
	</Settings>

	<!--Your Settings can go here, if not needed, use <YourSettings />. You can use these for anything you like.
		<YourSettings>
			<Setting name="MySetting" value="My Value"/>
		</YourSettings>
	 -->
	<YourSettings>
		<Setting name="TransferSettings.datasourcePath" 	value="config/datasource.xml.cfm" />
		<Setting name="TransferSettings.configPath" 		value="config/transfer.xml.cfm" />
		<Setting name="TransferSettings.definitionPath" 	value="/coldbox/samples/applications/securitysample/config/definitions" />
		
		<!-- Path needed to for LigthWire -->
		<Setting name="cfc.model.root" value="coldbox.samples.applications.securitysample" />
		
	</YourSettings>

	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer></MailServer>
		<MailPort></MailPort>
		<MailUsername></MailUsername>
		<MailPassword></MailPassword>
	</MailServerSettings>

	<!--Emails to Send bug reports, you can create as many as you like
	<BugEmail>myemail@gmail.com</BugEmail>	
	-->
	<BugTracerReports/>

	<!--List url dev environments, this determines your dev/pro environment for the framework-->
	<DevEnvironments>
		<url>localhost</url>
	</DevEnvironments>

	<!--Webservice declarations your use in your application, if not use, leave blank
	Note that for the same webservice name you can have a development url and a production url.
	<WebServices>
		<WebService name="TESTWS1" URL="http://www.test.com/test1.cfc?wsdl" DevURL="http://dev.test.com/test1.cfc?wsdl" />
		<WebService name="TESTWS2" URL="http://www.test.com/test2.cfc?wsdl" DevURL="http://dev.test.com/test2.cfc?wsdl" />
	</WebServices>
	-->
	<WebServices />

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

	<!--Internationalization and resource Bundle setup:-->
	<i18N>
		<DefaultResourceBundle>includes/i18n/main</DefaultResourceBundle>
		<DefaultLocale>en_US</DefaultLocale>
		<LocaleStorage>session</LocaleStorage>
	</i18N>
		
	<!--Datasource Setup, you can then retreive a datasourceBean via the getDatasource("name") method: 
	<Datasource alias="MyDSNAlias" name="real_dsn_name"   dbtype="mysql"  username="" password="" />	
	-->
	<Datasources>
		<Datasource alias="dsn1" name="transfersample" dbtype="mysql" username="" password="" />	
	</Datasources>
	
	<!--ColdBox Object Caching Settings Overrides the Framework-wide settings -->
	<Cache>
		<ObjectDefaultTimeout>45</ObjectDefaultTimeout>
		<ObjectDefaultLastAccessTimeout>15</ObjectDefaultLastAccessTimeout>
		<UseLastAccessTimeouts>true</UseLastAccessTimeouts>
		<ReapFrequency>3</ReapFrequency>
		<MaxObjects>100</MaxObjects>
		<FreeMemoryPercentageThreshold>5</FreeMemoryPercentageThreshold>
		<!-- LFU/LRU -->
		<EvictionPolicy>LFU</EvictionPolicy>
	</Cache>
	
	<!-- Interceptor Declarations 
	<Interceptors throwOnInvalidStates="true">
		<CustomInterceptionPoints>comma-delimited list</CustomInterceptionPoints>
		<Interceptor class="full class name">
			<Property name="myProp">value</Property>
			<Property name="myArray">[1,2,3]</Property>
			<Property name="myStruct">{ key1:1, key2=2 }</Property>
		</Inteceptor>
		<Interceptor class="no property" />
	</Interceptors>
	-->
	
	<Interceptors>
		<!-- config file is relative to app root -->
		<!--
		<Interceptor class="coldbox.system.interceptors.ses">
			<Property name="configFile">config/routes.cfm</Property>
		</Interceptor> -->
		
		<Interceptor class="coldbox.system.interceptors.autowire">
			<Property name="enableSetterInjection">false</Property>
		</Interceptor>
		
		<!-- security -->
		<Interceptor class="coldbox.samples.applications.securitysample.interceptors.ssl">
			<Property name="isSSLCheck">false</Property>
			<Property name="sslEventList">*</Property>
			<!-- <Property name="sslEventList">user.dspUser,user.dspEditUser,general.*</Property> -->
		</Interceptor>

		<Interceptor class="coldbox.system.interceptors.security">
	        <Property name="rulesSource">xml</Property>
	        <Property name="rulesFile">config/securityrules.xml.cfm</Property>
	        <Property name="debugMode">true</Property>
			<Property name="validatorIOC">securityManager</Property>
	    </Interceptor>	
	    	    
		

	</Interceptors>

		<!--
		<Interceptor class="transfersample.interceptors.security">
			<Property name="administratorEventList">user.*</Property>
			<Property name="userEventList">user.dspUsers</Property>
		</Interceptor>		
		-->	
</Config>
