<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_2.6.0.xsd">
	<Settings>
		<!--The name of your application.-->
		<Setting name="AppName"						value="TransferSample"/>
		<!--Default Debugmode boolean flag (Set to false in production environments)-->
		<Setting name="DebugMode" 					value="false" />
		<!--The Debug Password to use in order to activate/deactivate debugmode,activated by url actions -->
		<Setting name="DebugPassword" 				value=""/>
		<!--The fwreinit password to use in order to reinitialize the framework and application.Optional, else leave blank -->
		<Setting name="ReinitPassword" 				value=""/>
		<!--This feature is enabled by default to permit the url dumpvar parameter-->
		<Setting name="EnableDumpVar"				value="true" />
		<Setting name="EventName" 					value="event"/>
		<!--Log Errors and entries on the coldfusion server logs, disabled by default if not used-->
		<Setting name="EnableColdfusionLogging" 	value="false" />
		<!--Log Errors and entries in ColdBox's own logging facilities. You choose the location, finally per application logging.-->
		<Setting name="EnableColdboxLogging"		value="false" />
		<!--The absolute or relative path to where you want to store your log files for this application-->
		<Setting name="ColdboxLogsLocation"			value="" />
		<!--Default Event to run if no event is set or passed. Usually the event to be fired first (NOTE: use event handler syntax)-->
		<Setting name="DefaultEvent" 				value="users.dspHome"/>
		<!--Event Handler to run on the start of a request, leave blank if not used. Emulates the Application.cfc onRequestStart method	-->
		<Setting name="RequestStartHandler" 		value="ehGeneral.onRequestStart"/>
		<!--Event Handler to run at end of all requests, leave blank if not used. Emulates the Application.cfc onRequestEnd method-->
		<Setting name="RequestEndHandler" 			value=""/>
		<!--Event Handler to run at the start of an application, leave blank if not used. Emulates the Application.cfc onApplicationStart method	-->
		<Setting name="ApplicationStartHandler" 	value="ehGeneral.onAppinit"/>
		<!--The Email address from which all outgoing framework emails will be sent. -->
		<Setting name="OwnerEmail" 					value="myemail@gmail.com" />
		<!-- Enable Bug Reports to be emailed out, set to true by default if left blank -->
		<Setting name="EnableBugReports" 			value="false"/>
		<!--UDF Library To Load on every request for your views and handlers -->
		<Setting name="UDFLibraryFile" 				value="" />
		<!--The event handler to execute on all framework exceptions. Event Handler syntax required.-->
		<Setting name="ExceptionHandler"			value="" />
		<!--What event to fire when an invalid event is detected-->
		<Setting name="onInvalidEvent" 				value="users.dspHome" />
		<!--Full path from the application's root to your custom error page, else leave blank. -->
		<Setting name="CustomErrorTemplate"			value="" />
		<!--Messagebox Style (css) class name to use. Look at the messagebox.cfm in the includes directory-->
		<Setting name="MessageboxStyleOverride"		value="" />
		<!--Flag to Auto reload the internal handlers directory listing. False for production. -->
		<Setting name="HandlersIndexAutoReload"   	value="false" />
		<!--Flag to auto reload the config.xml settings. False for production. -->
		<Setting name="ConfigAutoReload"          	value="false" />
		<!-- Declare the custom plugins base invocation path, if used. You have to use dot notation.Example: mymapping.myplugins	-->
		<Setting name="MyPluginsLocation"   		value="" />
		<!--Flag to cache handlers. Default if left blank is true. -->
		<Setting name="HandlerCaching" 				value="true"/>
		<!--IOC Framework if Used, else leave blank-->
		<Setting name="IOCFramework"				value="" />
		<!--IOC Definition File Path, relative or absolute -->
		<Setting name="IOCDefinitionFile"			value="" />
		<!--IOC Object Caching, true/false. For ColdBox to cache your IoC beans-->
		<Setting name="IOCObjectCaching"			value="" />
	</Settings>

	<!--Your Settings can go here, if not needed, use <YourSettings />. You can use these for anything you like.-->
	<YourSettings />
	

	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings />
	

	<!--Emails to Send bug reports, you can create as many as you like-->
	<BugTracerReports>
		<!--<BugEmail>myemail@gmail.com</BugEmail>-->
	</BugTracerReports>

	<!--List url dev environments, this determines your dev/pro environment for the framework-->
	<DevEnvironments />
	
	<WebServices />

	<!--Declare Layouts for your application here-->
	<Layouts>
		<!--Declare the default layout, MANDATORY-->
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
	</Layouts>

	<!--Internationalization and resource Bundle setup:-->
	<i18N />
	
	<!--Datasource Setup, you can then retreive a datasourceBean via the getDatasource("name") method: -->
	<Datasources>
		<Datasource alias="MyDSN" name="transfersample" dbtype="mysql"/>
	</Datasources>
	
	<Interceptors>
		<Interceptor class="coldbox.system.interceptors.ses">
			<Property name="configFile">config/routes.cfm</Property>
		</Interceptor>
		<Interceptor class="coldbox.system.interceptors.autowire">
		</Interceptor>
		<!-- Transfer Loader -->
		<Interceptor class="coldbox.system.extras.transfer.TransferLoader">
			<Property name="ConfigPath">/${AppMapping}/config/transfer.xml.cfm</Property>
			<Property name="definitionPath">/${AppMapping}/config/definitions</Property>
			<Property name="datasourceAlias">MyDSN</Property>
		</Interceptor>
	</Interceptors>

</Config>
