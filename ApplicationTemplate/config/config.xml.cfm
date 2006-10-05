<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_1.1.0.xsd">
	<Settings>
		<!--The name of your application.-->
		<Setting name="AppName"						value="Your App Name here"/>
		<!--The application's mapping either relative to the web root or using a CFMX mapping.-->
		<Setting name="AppMapping" 					value="Your Application Mapping Here" />
		<!--Optional Setting: AppDevMapping, your mapping same as above but for a Development Environment
		    If the framework detects you are in a Development Environment it will replace
		    the AppMapping value with this one -->
		<Setting name="AppDevMapping" 				value=""/>
		<!--Default Debugmode boolean flag (Set to false in production environments)-->
		<Setting name="DebugMode" 					value="true" />
		<!--The Debug Password to use in order to activate/deactivate debugmode,activated by url actions -->
		<Setting name="DebugPassword" 				value="Coldbox"/>
		<!--This feature is enabled by default to permit the url dumpvar parameter-->
		<Setting name="EnableDumpVar"				value="true" />
		<!--Log Errors and entries on the coldfusion server logs, disabled by default if not used-->
		<Setting name="EnableColdfusionLogging" 	value="true" />
		<!--Log Errors and entries in ColdBox's own logging facilities. You choose the location, finally per application logging.-->
		<Setting name="EnableColdboxLogging"		value="true" />
		<!--The absolute or relative path to where you want to store your log files for this application-->
		<Setting name="ColdboxLogsLocation"			value="" />
		<!--Default Event to run if no event is set or passed. Usually the event to be fired first (NOTE: use event handler syntax)-->
		<Setting name="DefaultEvent" 				value="ehGeneral.dspHello"/>
		<!--Event Handler to run on the start of a request, leave blank if not used. Emulates the Application.cfc onRequestStart method
			<Setting name="RequestStartHandler" 	value="ehGeneral.onRequestStart"/>
		-->
		<Setting name="RequestStartHandler" 		value=""/>
		<!--Event Handler to run at end of all requests, leave blank if not used. Emulates the Application.cfc onRequestEnd method
			<Setting name="RequestEndHandler" 		value="ehGeneral.onRequestEnd"/>
		-->
		<Setting name="RequestEndHandler" 			value=""/>
		<!--Event Handler to run at the start of an application, leave blank if not used. Emulates the Application.cfc onApplicationStart method
		    It will fire again on expiration of the application variable or when you reinit the framework using fwreinit=1
			<Setting name="ApplicationStartHandler" 		value="ehGeneral.onAppinit"/>
		-->
		<Setting name="ApplicationStartHandler" 	value=""/>
		<!--The Email address from which all outgoing framework emails will be sent. -->
		<Setting name="OwnerEmail" 					value="myemail@gmail.com" />
		<!-- Enable Bug Reports to be emailed out, set to true by default if left blank -->
		<Setting name="EnableBugReports" 			value="true"/>
		<!--UDF Library To Load on every request for your views and handlers. ex: includes/udf.cfm
		   or You can use a CFMX absolute mapping path, ex: /coldboxCFMXMapping/includes/udf.cfm
		   If not used, leave it blank.
			<Setting name="UDFLibraryFile" 			value="udf.cfm" />
		   -->
		<Setting name="UDFLibraryFile" 				value="" />
		<!--The event handler to execute on all framework exceptions. Event Handler syntax required.-->
		<Setting name="ExceptionHandler"			value="" />
		<!--Full path from the application's root to your custom error page, else leave blank. ColdBox provides you with a custom
		    error template by default.If you use this then you need to display the errors using an
		    exception bean that will be in the request collection getvalue('ExceptionBean')
			<Setting name="CustomErrorTemplate"			value="includes/myerror.cfm" />
		 -->
		<Setting name="CustomErrorTemplate"			value="" />
		<!--Messagebox Style (css) class name to use. Look at the messagebox.cfm in the includes directory to see how to override the
		    style.
			<Setting name="MessageboxStyleClass"		value="mymessagebox" />
		-->
		<Setting name="MessageboxStyleClass"		value="" />
		<!--Flag to Auto reload the internal handlers directory listing. False for production. If not used
			then the handlers will not be found. You will need to reload the framework via fwreinit=1 in the URL -->
		<Setting name="HandlersIndexAutoReload"   	value="true" />
		<!--Flag to auto reload the config.xml settings. False for production. If not used
		    then use the fwreinit=1 to reload the framework -->
		<Setting name="ConfigAutoReload"          	value="true" />
		<!-- Declare the custom plugins base invocation path, if used. You have to use dot notation.
		Example: mymapping.myplugins, myapplication.customplugins
		When plugins are called, this invocation location will be pre-pended.
			<Setting name="MyPluginsLocation"   		value="myapplication.customplugins" />
		-->
		<Setting name="MyPluginsLocation"   		value="" />
	</Settings>

	<!--Your Settings can go here, if not needed, use <YourSettings />. You can use these for anything you like.
		<Setting name="MySetting"  				value="WOW" />
	 -->
	<YourSettings>
		<Setting name="MySetting" value="My Value"/>
	</YourSettings>

	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer></MailServer>
		<MailUsername></MailUsername>
		<MailPassword></MailPassword>
	</MailServerSettings>

	<!--Emails to Send bug reports, you can create as many as you like-->
	<BugTracerReports>
		<!--<BugEmail>myemail@gmail.com</BugEmail>-->
	</BugTracerReports>

	<!--List url dev environments, this determines your dev/pro environment for the framework-->
	<DevEnvironments>
		<url>dev</url>
		<url>dev1</url>
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
		<Layout file="Layout.Popup.cfm" name="popup">
			<!--You can declare all the views that you want to appear with the above layout-->
			<View>vwTest</View>
			<View>vwMyView</View>
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
		<Datasource name="MyDSN"   dbtype="mysql"  username="" password="" />
		<Datasource name="MyBlog"  dbtype="oracle" username="" password="" />
	</Datasources>

</Config>
