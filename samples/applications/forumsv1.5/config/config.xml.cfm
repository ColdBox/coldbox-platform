<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.luismajano.com/projects/coldbox/schema/config.xsd">
	<Settings>
		<!--The name of your app-->
		<Setting name="AppName" 			value="Galleon"/>
		<Setting name="AppCFMXMapping" 		value="coldboxSamples/applications/forumsv1.5" />
		<Setting name="DebugMode" 			value="false" />
		<Setting name="DebugPassword" 		value="coldbox"/>
		<Setting name="DumpVarActive"		value="true" />
		<Setting name="ColdfusionLogging" 	value="true" />
		<Setting name="DefaultEvent" 		value="ehForums.dspHome"/>
		<Setting name="RequestStartHandler" value="ehForums.onRequestStart"/>
		<Setting name="RequestEndHandler" 	value=""/>
		<Setting name="ApplicationStartHandler" value="ehForums.onAppStart" />
		<Setting name="EnableBugReports" 	value="true"/>
		<Setting name="OwnerEmail" 			value="cfcoldbox@gmail.com" />
		<Setting name="UDFLibraryFile" 		value="includes/udf.cfm" />
		<Setting name="CustomErrorTemplate" value=""/>
		<Setting name="ExceptionHandler" value=""/>
		<Setting name="MessageboxStyleClass" value=""/>
		<Setting name="HandlersIndexAutoReload" value="false"/>
		<Setting name="ConfigAutoReload" value="false"/>
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
</Config>