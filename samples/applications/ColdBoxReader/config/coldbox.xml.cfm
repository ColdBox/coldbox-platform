<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_2.5.0.xsd">
	<Settings>
		<Setting name="AppName" 					value="ColdBoxReader"/>
		<Setting name="DebugMode" 					value="true"/>
		<Setting name="DebugPassword" 				value="Coldbox"/>
		<Setting name="EventName" 					value="event"/>
		<Setting name="EnableDumpVar" 				value="true"/>
		<Setting name="EnableColdfusionLogging"		value="false" />
		<Setting name="EnableColdboxLogging" 		value="true"/>
		<Setting name="ColdboxLogsLocation" 		value="logs"/>
		<Setting name="DefaultEvent" 				value="ehGeneral.dspStart"/>
		<Setting name="ApplicationStartHandler"		value=""/>
		<Setting name="RequestStartHandler" 		value="ehGeneral.onRequestStart"/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="OwnerEmail" 					value="myemail@email.com"/>
		<Setting name="EnableBugReports" 			value="false"/>
		<Setting name="UDFLibraryFile" 				value="" />
		<Setting name="CustomErrorTemplate" 		value=""/>
		<Setting name="ExceptionHandler" 			value="ehGeneral.onException"/>
		<Setting name="MessageboxStyleOverride" 		value="true"/>
		<Setting name="HandlersIndexAutoReload" 	value="false"/>
		<Setting name="ConfigAutoReload" 			value="false"/>
		<Setting name="HandlerCaching"				value="true" />
		<Setting name="IOCFramework" 				value="coldspring"/>
		<Setting name="IOCDefinitionFile" 			value="config/services.xml.cfm"/>
		<Setting name="IOCObjectCaching"			value="true" />
	</Settings>

	<YourSettings>
			<Setting name="Version" value="2.1.0" />
			<Setting name="ModelBasePath" value="coldbox.samples.applications.ColdBoxReader.components" />
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
		<Datasource alias="coldboxreader" name="coldboxreader" dbtype="mysql" username="" password="" />
	</Datasources>

</Config>
