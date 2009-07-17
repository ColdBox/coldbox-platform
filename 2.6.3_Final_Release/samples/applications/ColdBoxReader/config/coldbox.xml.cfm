<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_2.6.0.xsd">
	<Settings>
		<Setting name="AppName" 					value="ColdBoxReader"/>
		<Setting name="DebugMode" 					value="false"/>
		<Setting name="DebugPassword" 				value=""/>
		<Setting name="EventName" 					value="event"/>
		<Setting name="EnableDumpVar" 				value="true"/>
		<Setting name="EnableColdfusionLogging"		value="false" />
		<Setting name="EnableColdboxLogging" 		value="true"/>
		<Setting name="ColdboxLogsLocation" 		value="logs"/>
		<Setting name="DefaultEvent" 				value="general.dspStart"/>
		<Setting name="ApplicationStartHandler"		value=""/>
		<Setting name="RequestStartHandler" 		value="main.onRequestStart"/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="OwnerEmail" 					value="myemail@email.com"/>
		<Setting name="EnableBugReports" 			value="false"/>
		<Setting name="UDFLibraryFile" 				value="" />
		<Setting name="CustomErrorTemplate" 		value=""/>
		<Setting name="ExceptionHandler" 			value="main.onException"/>
		<Setting name="MessageboxStyleOverride" 	value="true"/>
		<Setting name="HandlersIndexAutoReload" 	value="false"/>
		<Setting name="ConfigAutoReload" 			value="false"/>
		<Setting name="HandlerCaching"				value="false" />
		<Setting name="IOCFramework" 				value="lightwire"/>
		<Setting name="IOCDefinitionFile" 			value="config/services.xml.cfm"/>
		<Setting name="IOCObjectCaching"			value="true" />
	</Settings>

	<YourSettings>
		<Setting name="Version" value="2.1.0" />
		<Setting name="ModelBasePath" value="coldbox.samples.applications.ColdBoxReader.components" />
		
		<!-- FeedReader Settings -->
		<Setting name="feedReader_useCache" 		value="true" />
		<Setting name="feedReader_cacheType" 		value="file" />
		<Setting name="feedReader_cacheLocation"	value="cache" />
		<Setting name="feedReader_cacheTimeout"		value="30" />
	</YourSettings>

	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings />

	<BugTracerReports />

	<DevEnvironments />

	<WebServices />

	<Layouts>
		<DefaultLayout>Layout.None.cfm</DefaultLayout>
		<Layout file="Layout.Main.cfm" name="clean">
			<View>general/dspstart</View>
		</Layout>
	</Layouts>

	<i18N />

	<Datasources>
		<Datasource alias="coldboxreader" name="coldboxreader" dbtype="mysql" username="" password="" />
	</Datasources>
	
	<Interceptors>
		<Interceptor class="coldbox.system.interceptors.autowire" />
	</Interceptors>

</Config>
