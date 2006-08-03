<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.luismajano.com/projects/coldbox/schema/config.xsd">
	<Settings>
		<Setting name="AppName" 			value="Java Loader Example"/>
		<Setting name="AppCFMXMapping" 	value="coldboxSamples/applications/javaloader" />
		<Setting name="DebugMode" 			value="true" />
		<Setting name="DebugPassword" 		value="Coldbox"/>
		<Setting name="DumpVarActive"		value="true" />
		<Setting name="ColdfusionLogging" 	value="true" />
		<Setting name="DefaultEvent" 		value="ehGeneral.dspHello"/>
		<Setting name="RequestStartHandler" value=""/>
		<Setting name="RequestEndHandler" 	value=""/>
		<Setting name="ApplicationStartHandler"  value="ehGeneral.onAppStart" />
		<Setting name="OwnerEmail"			value="cfcoldbox@gmail.com" />
		<Setting name="EnableBugReports" 	value="true"/>
		<Setting name="UDFLibraryFile" 		value="" />
		<Setting name="CustomErrorTemplate" value=""/>
		<Setting name="ExceptionHandler" value=""/>
		<Setting name="MessageboxStyleClass" value=""/>
		<Setting name="HandlersIndexAutoReload" value="false"/>
		<Setting name="ConfigAutoReload" value="false"/>		
	</Settings>

	<YourSettings />

	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer></MailServer>
		<MailUsername></MailUsername>
		<MailPassword></MailPassword>
	</MailServerSettings>

	<BugTracerReports>
		<!--<BugEmail>cfcoldbox@gmail.com</BugEmail>-->
	</BugTracerReports>

	<DevEnvironments>
		<url>lmajano</url>
		<url>dev</url>
	</DevEnvironments>

	<WebServices />

	<Layouts>
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
	</Layouts>

	<i18N />
</Config>
