<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_2.6.0.xsd">
	<Settings>
		<Setting name="AppName"						value="Illudium PU-36 Code Generator"/>
		<Setting name="DebugMode" 					value="false" />
		<Setting name="DebugPassword" 				value=""/>
		<Setting name="EventName" 					value="event"/>
		<Setting name="EnableDumpVar"				value="true" />
		<Setting name="EnableColdfusionLogging" 	value="false" />
		<Setting name="EnableColdboxLogging"		value="true" />
		<Setting name="ColdboxLogsLocation"			value="logs" />
		<Setting name="DefaultEvent" 				value="generator.dspHome"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler" 	value=""/>
		<Setting name="OwnerEmail" 					value="" />
		<Setting name="EnableBugReports" 			value="false"/>
		<Setting name="UDFLibraryFile" 				value="" />
		<Setting name="ExceptionHandler"			value="" />
		<Setting name="CustomErrorTemplate"			value="" />
		<Setting name="MessageboxStyleOverride"		value="" />
		<Setting name="HandlersIndexAutoReload"   	value="false" />
		<Setting name="ConfigAutoReload"          	value="false" />
		<Setting name="MyPluginsLocation"   		value="" />
		<Setting name="HandlerCaching" 				value="true"/>
	</Settings>

	<YourSettings>
		<Setting name="adminPass" 	value="coldfusion"/>
		<Setting name="xslBasePath" value="./model/xsl/" />
	</YourSettings>

	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings />

	<!--Emails to Send bug reports, you can create as many as you like-->
	<BugTracerReports />

	<!--List url dev environments, this determines your dev/pro environment for the framework-->
	<DevEnvironments />

	<WebServices />
	
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

	<i18N />
	
	<Datasources />
	
	<Interceptors>
		<Interceptor class="coldbox.system.interceptors.autowire" />
	</Interceptors>

</Config>
