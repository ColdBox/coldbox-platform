<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_2.6.0.xsd">
	<Settings>
		<!--The name of your app-->
		<Setting name="AppName" 				value="Sample Login Application"/>
		<Setting name="DebugMode" 				value="true" />
		<Setting name="DebugPassword" 			value="coldbox"/>
		<Setting name="EnableColdfusionLogging" value="false" />
		<Setting name="EventName" 				value="event"/>
		<Setting name="EnableColdboxLogging" 	value="true" />
		<Setting name="ColdboxLogsLocation" 	value="logs"/>
		<Setting name="DefaultEvent" 			value="ehGeneral.dspLogin"/>
		<Setting name="RequestStartHandler" 	value="ehGeneral.onRequestStart"/>
		<Setting name="RequestEndHandler" 		value=""/>
		<Setting name="ApplicationStartHandler" value="" />
		<Setting name="OwnerEmail" 				value="myemail@email.com" />
		<Setting name="EnableBugReports" 		value="true"/>
		<Setting name="UDFLibraryFile" 			value="" />
		<Setting name="CustomErrorTemplate" 	value=""/>
		<Setting name="ExceptionHandler" 		value=""/>
		<Setting name="MessageboxStyleOverride" value=""/>
		<Setting name="HandlersIndexAutoReload" value="false"/>
		<Setting name="ConfigAutoReload" 		value="false"/>
		<Setting name="HandlerCaching" 			value="false"/>
	</Settings>

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
	</DevEnvironments>

	<!--Webservice declarations your use in your app, if not use, leave blank
	<WebServices />
	-->
	<WebServices />

	<!--Declare Layouts for your app here-->
	<Layouts>
		<!--Declare the default layout, mandatory-->
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
		<!--
		No other layouts are used, so they are not declared, else
		declare them here
			<Layout file="Layout.Popup.cfm" name="popup">
			below declare the views used in this layout.
			<View>vwTest</View>
			</Layout>
		-->
	</Layouts>

	<i18N />
	
	<Datasources />
	
	<Interceptors>
		<Interceptor class="coldbox.samples.applications.sampleloginapp.model.securityInterceptor" />
	</Interceptors>
	
</Config>
