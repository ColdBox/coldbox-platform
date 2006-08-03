<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.luismajano.com/projects/coldbox/schema/config.xsd">
	<Settings>
		<Setting name="AppName" 					value="Sample UDF Library Usage"/>
		<Setting name="AppCFMXMapping" 				value="coldboxSamples/applications/udf_library_usage"/>
		<Setting name="DebugMode" 					value="true"/>
		<Setting name="DebugPassword" 				value="coldbox"/>
		<Setting name="DumpVarActive" 				value="true"/>
		<Setting name="ColdfusionLogging" 			value="true"/>
		<Setting name="DefaultEvent" 				value="ehGeneral.dspHome"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler"   value="" />
		<Setting name="OwnerEmail" 				value="cfcoldbox@gmail.com"/>
		<Setting name="EnableBugReports" 			value="true"/>
		<Setting name="UDFLibraryFile" 				value="includes/udf.cfm" />
		<Setting name="CustomErrorTemplate" value=""/>
		<Setting name="ExceptionHandler" value=""/>
		<Setting name="MessageboxStyleClass" value=""/>
		<Setting name="HandlersIndexAutoReload" value="false"/>
		<Setting name="ConfigAutoReload" value="false"/>
	</Settings>

	<YourSettings />

	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer />
		<MailUsername/>
		<MailPassword/>
	</MailServerSettings>

	<BugTracerReports>
		<!--<BugEmail>cfcoldbox@gmail.com</BugEmail>-->
	</BugTracerReports>

	<DevEnvironments>
		<url>dev</url>
		<url>localhost</url>
	</DevEnvironments>

	<WebServices />

	<Layouts>
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
	</Layouts>

	<i18N />

</Config>