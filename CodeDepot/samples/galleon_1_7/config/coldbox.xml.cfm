<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_2.6.0.xsd">
	<Settings>
		<!--The name of your app-->
		<Setting name="AppName" 					value="Galleon"/>
		<Setting name="DebugMode" 					value="true" />
		<Setting name="DebugPassword" 				value="coldbox"/>
		<Setting name="EventName" 					value="event"/>
		<Setting name="EnableDumpVar"				value="true" />
		<Setting name="EnableColdfusionLogging" 	value="false" />
		<Setting name="EnableColdboxLogging" 		value="true"/>
		<Setting name="ColdboxLogsLocation" 		value="logs"/>
		<Setting name="DefaultEvent" 				value="ehForums.dspHome"/>
		<Setting name="RequestStartHandler" 		value="ehForums.onRequestStart"/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler" 	value="ehForums.onAppStart" />
		<Setting name="EnableBugReports" 			value="false"/>
		<Setting name="OwnerEmail" 					value="myemail@email.com" />
		<Setting name="UDFLibraryFile" 				value="includes/udf.cfm" />
		<Setting name="CustomErrorTemplate" 		value=""/>
		<Setting name="ExceptionHandler" 			value=""/>
		<Setting name="MessageboxStyleOverride" 		value=""/>
		<Setting name="HandlersIndexAutoReload" 	value="true"/>
		<Setting name="ConfigAutoReload" 			value="false"/>
		<Setting name="HandlerCaching"				value="true" />
	</Settings>

	<!--Your Settings can go here, if not needed, use <YourSettings />. You can use these for anything you like. -->
	<YourSettings />

	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer></MailServer>
		<MailUsername></MailUsername>
		<MailPassword></MailPassword>
	</MailServerSettings>

	<!--Emails to Send bug reports-->
	<BugTracerReports>
		<!--<BugEmail>cfcoldbox@gmail.com</BugEmail>-->
	</BugTracerReports>

	<!--List url dev environments, this determines your dev/pro environment-->
	<DevEnvironments>
		<url>dev</url>
		<url>lmajano</url>
	</DevEnvironments>

	<!--Webservice declarations your use in your app, if not use, leave blank
	<WebServices></WebServices>
	-->
	<WebServices />

	<!--Declare Layouts for your app here-->
	<Layouts>
		<!--Declare the default layout, mandatory-->
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
		<!--Declare other layouts, with view assignments-->
		<Layout file="Layout.Open.cfm" name="Open">
			<!--You can declare all the views that you want to appear with the above layout-->
			<View>vwRss</View>
		</Layout>
	</Layouts>

	<i18N />
	
	<Datasources />	
	
	
</Config>