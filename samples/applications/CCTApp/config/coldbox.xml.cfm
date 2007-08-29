<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="xsd/config.xsd">
	<Settings>
		<!--The name of your application.-->
		<Setting name="AppName"	  					value="CCTApp"/>
		<!--Default Debugmode boolean flag (Set to false in production environments)-->
		<Setting name="DebugMode" 					value="false" />
		<!--The Debug Password to use in order to activate/deactivate debugmode,activated by url actions -->
		<Setting name="DebugPassword" 				value="Coldbox"/>
		<!--The fwreinit password to use in order to reinitialize the framework and application.Optional, else leave blank -->
		<Setting name="ReinitPassword" 				value=""/>
		<!--This feature is enabled by default to permit the url dumpvar parameter-->
		<Setting name="EnableDumpVar"				value="false" />
		<!--Log Errors and entries on the coldfusion server logs, disabled by default if not used-->
		<Setting name="EnableColdfusionLogging" 	value="false" />
		<!--Log Errors and entries in ColdBox's own logging facilities. You choose the location, finally per application logging.-->
		<Setting name="EnableColdboxLogging"		value="false" />
		<!--The absolute or relative path to where you want to store your log files for this application-->
		<Setting name="ColdboxLogsLocation"			value="logs" />
		<!--Default Event to run if no event is set or passed. Usually the event to be fired first (NOTE: use event handler syntax)-->
		<Setting name="DefaultEvent" 				value="ehAppUser.dspAppUsers"/>
		<!--Event Handler to run on the start of a request, leave blank if not used. Emulates the Application.cfc onRequestStart method	-->
		<Setting name="RequestStartHandler" 		value="ehGeneral.onRequestStart"/>
		<!--Event Handler to run at end of all requests, leave blank if not used. Emulates the Application.cfc onRequestEnd method-->
		<Setting name="RequestEndHandler" 			value=""/>
		<!--Event Handler to run at the start of an application, leave blank if not used. Emulates the Application.cfc onApplicationStart method	-->
		<Setting name="ApplicationStartHandler" 	value="ehGeneral.onAppInit"/>
		<!--The Email address from which all outgoing framework emails will be sent. -->
		<Setting name="OwnerEmail" 					value="youremail@gmail.com" />
		<!-- Enable Bug Reports to be emailed out, set to true by default if left blank -->
		<Setting name="EnableBugReports" 			value="true"/>
		<!--UDF Library To Load on every request for your views and handlers -->
		<Setting name="UDFLibraryFile" 				value="includes/udf.cfm" />
		<!--The event handler to execute on all framework exceptions. Event Handler syntax required.-->
		<Setting name="ExceptionHandler"			value="" />
		<!--What event to fire when an invalid event is detected-->
		<Setting name="onInvalidEvent" 				value="ehGeneral.dspDefault" />
		<!--Full path from the application's root to your custom error page, else leave blank. -->
		<Setting name="CustomErrorTemplate"			value="" />
		<!--Messagebox Style (css) class name to use. Look at the messagebox.cfm in the includes directory-->
		<Setting name="MessageboxStyleOverride"		value="false" />
		<!--Flag to Auto reload the internal handlers directory listing. False for production. -->
		<Setting name="HandlersIndexAutoReload"   	value="true" />
		<!--Flag to auto reload the config.xml settings. False for production. -->
		<Setting name="ConfigAutoReload"          	value="true" />
		<!-- Declare the custom plugins base invocation path, if used. You have to use dot notation.Example: mymapping.myplugins	-->
		<Setting name="MyPluginsLocation"   		value="" />
		<!--Flag to cache handlers. Default if left blank is true. -->
		<Setting name="HandlerCaching" 				value="true"/>
		<!--IOC Framework if Used, else leave blank-->
		<Setting name="IOCFramework"				value="coldspring" />
		<!--IOC Definition File Path, relative or absolute -->
		<Setting name="IOCDefinitionFile"			value="config/coldspring.xml.cfm" />
		<!--IOC Object Caching, true/false. For ColdBox to cache your IoC beans-->
		<Setting name="IOCObjectCaching"			value="true" />
	</Settings>

	<!-- -->
	<YourSettings>
		<Setting name="TransferSettings" value="{datasourcePath:config/datasource.xml.cfm, configPath:config/transfer.xml.cfm, definitionPath:/coldbox/samples/applications/CCTApp/config/definitions}"/>
	</YourSettings>
	
	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer></MailServer>
		<MailPort></MailPort>
		<MailUsername></MailUsername>
		<MailPassword></MailPassword>
	</MailServerSettings>

	<!--Emails to Send bug reports, you can create as many as you like-->
	<BugTracerReports>
		<!--<BugEmail>tomdeman@gmail.com</BugEmail>-->
	</BugTracerReports>

	<!--List url dev environments, this determines your dev/pro environment for the framework-->
	<DevEnvironments>
		<url>coldboxtemplate.local</url>
		<url>localhost</url>
	</DevEnvironments>

	<!--Webservice declarations your use in your application, if not use, leave blank
	Note that for the same webservice name you can have a development url and a production url.
	<WebServices />
	-->
	<WebServices>
		<!--<WebService name="TESTWS" URL="http://www.test.com/test.cfc?wsdl" DevURL="http://dev.test.com/test.cfc?wsdl" />-->
	</WebServices>

	<!--Declare Layouts for your application here-->
	<Layouts>
		<!--Declare the default layout, MANDATORY-->
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
		
		<!--Declare other layouts, with view assignments if needed, else do not write them-->
		<Layout file="Layout.Clean.cfm" name="Clean">
			<!--You can declare all the views that you want to appear with the above layout-->
			<View>vwDefault</View>
			<View>account/vwLogin</View>
		</Layout>
	</Layouts>

	<!--Internationalization and resource Bundle setup:

	<i18N>
		<DefaultResourceBundle>includes/main</DefaultResourceBundle>
		<DefaultLocale>en_US</DefaultLocale>
		<LocaleStorage>session</LocaleStorage>
	</i18N>
	-->
	<i18N />
	
	<!--Datasource Setup, you can then retreive a datasourceBean via the getDatasource("name") method: -->
	<Datasources>
		<Datasource alias="CCTApp" name="CCTApp" dbtype="mssql"  username="" password="" />
	</Datasources>
	
	<!--ColdBox Object Caching Settings Overrides the Framework-wide settings 
	<Cache>
		<ObjectDefaultTimeout>20</ObjectDefaultTimeout>
		<ObjectDefaultLastAccessTimeout>5</ObjectDefaultLastAccessTimeout>
		<ReapFrequency>1</ReapFrequency>
		<MaxObjects>0</MaxObjects>
		<FreeMemoryPercentageThreshold>0</FreeMemoryPercentageThreshold>
	</Cache>
	-->
	
</Config>