<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_1.1.0.xsd">
	<Settings>
		<Setting name="AppName" 					value="ColdBoxReader"/>
		<Setting name="AppMapping" 					value="coldbox/samples/applications/ColdBoxReader"/>
		<Setting name="DebugMode" 					value="false"/>
		<Setting name="DebugPassword" 				value="Coldbox"/>
		<Setting name="EnableDumpVar" 				value="true"/>
		<Setting name="EnableColdfusionLogging"		value="false" />
		<Setting name="EnableColdboxLogging" 		value="true"/>
		<Setting name="ColdboxLogsLocation" 		value="logs"/>
		<Setting name="DefaultEvent" 				value="ehGeneral.dspStart"/>
		<Setting name="ApplicationStartHandler"		value="ehGeneral.onAppStart"/>
		<Setting name="RequestStartHandler" 		value="ehGeneral.onRequestStart"/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="OwnerEmail" 					value="myemail@email.com"/>
		<Setting name="EnableBugReports" 			value="false"/>
		<Setting name="UDFLibraryFile" 				value="" />	
		<Setting name="CustomErrorTemplate" 		value=""/>
		<Setting name="ExceptionHandler" 			value="ehGeneral.onException"/>
		<Setting name="MessageboxStyleClass" 		value="myOwnMessagebox"/>
		<Setting name="HandlersIndexAutoReload" 	value="false"/>
		<Setting name="ConfigAutoReload" 			value="false"/>		
	</Settings>

	<YourSettings>
			<Setting name="Version" value="1.1.0" />
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

	<Datasources>
		<Datasource name="coldboxreader" dbtype="mysql" username="" password="" />	
	</Datasources>
	
</Config>
