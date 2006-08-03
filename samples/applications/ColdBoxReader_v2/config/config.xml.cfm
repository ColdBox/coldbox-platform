<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="http://www.luismajano.com/projects/coldbox/schema/config.xsd">
	<Settings>
		<Setting name="AppName" 					value="ColdBoxReader"/>
		<Setting name="AppCFMXMapping" 				value="coldboxSamples/applications/ColdBoxReader_v2"/>
		<Setting name="DebugMode" 					value="false"/>
		<Setting name="DebugPassword" 				value="Coldbox"/>
		<Setting name="DumpVarActive" 				value="true"/>
		<Setting name="ColdfusionLogging" 			value="true"/>
		<Setting name="DefaultEvent" 				value="ehGeneral.dspStart"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="OwnerEmail" 					value="cfcoldbox@gmail.com"/>
		<Setting name="EnableBugReports" 			value="true"/>
		<Setting name="UDFLibraryFile" 				value="" />	
		<Setting name="CustomErrorTemplate" value=""/>
		<Setting name="ExceptionHandler" value=""/>
		<Setting name="MessageboxStyleClass" value="myMessagebox"/>
		<Setting name="HandlersIndexAutoReload" value="false"/>
		<Setting name="ConfigAutoReload" value="false"/>		
	</Settings>

	<YourSettings>
	</YourSettings>

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
		<DefaultLayout>Layout.None.cfm</DefaultLayout>
		<Layout file="Layout.Main.cfm" name="clean">
			<View>vwMain</View>
		</Layout>
	</Layouts>

	<i18N />

</Config>
