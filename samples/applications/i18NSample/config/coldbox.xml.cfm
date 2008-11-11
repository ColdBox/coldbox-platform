<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_2.6.0.xsd">
	<Settings>
		<!--The name of your app-->
		<Setting name="AppName" 					value="i18N Sample"/>
		<Setting name="DebugMode" 					value="true" />
		<Setting name="DebugPassword" 				value="coldbox"/>
		<Setting name="EventName" 					value="event"/>
		<Setting name="EnableColdfusionLogging"		value="false" />
		<Setting name="EnableColdboxLogging"		value="false" />
		<Setting name="ColdboxLogsLocation" 		value="logs"/>
		<Setting name="DefaultEvent" 				value="ehGeneral.dspHome"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler" 	value="ehGeneral.onAppStart" />
		<Setting name="OwnerEmail" 					value="myemail@email.com" />
		<Setting name="EnableBugReports" 			value="false"/>
		<Setting name="UDFLibraryFile" 				value="" />
		<Setting name="CustomErrorTemplate" 		value=""/>
		<Setting name="ExceptionHandler" 			value=""/>
		<Setting name="MessageboxStyleOverride" 		value=""/>
		<Setting name="HandlersIndexAutoReload" 	value="false"/>
		<Setting name="ConfigAutoReload"			value="false"/>
		<Setting name="MyPluginsLocation"			value="" />
		<Setting name="HandlerCaching"				value="true" />
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
		<WebServices></WebServices>
	-->
	<WebServices>
		
	</WebServices>
	
	<!--Declare Layouts for your app here-->
	<Layouts>
		<!--Declare the default layout, mandatory-->
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
	</Layouts>
	
	<i18N >
		<!--Blank bundle, since it is not used -->
		<DefaultResourceBundle></DefaultResourceBundle>
		<DefaultLocale>th_TH</DefaultLocale>
		<LocaleStorage>session</LocaleStorage>
	</i18N>
	
	<Datasources />
	
</Config>
