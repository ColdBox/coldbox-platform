<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_2.6.0.xsd">
	<Settings>
		<Setting name="AppName" 					value="Coldbox Samples Browser"/>
		<Setting name="DebugMode" 					value="true"/>
		<Setting name="DebugPassword" 				value=""/>
		<Setting name="EventName" 					value="event"/>
		<Setting name="EnableDumpVar" 				value="true"/>
		<Setting name="EnableColdfusionLogging" 	value="false"/>
		<Setting name="EnableColdboxLogging"   		value="true" />
		<Setting name="ColdboxLogsLocation"	   		value="logs" />
		<Setting name="DefaultEvent" 				value="ehSamples.dspHome"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler" 	value="ehSamples.onAppInit"/>
		<Setting name="OwnerEmail" 					value="myemail@gmail.com"/>
		<Setting name="EnableBugReports" 			value="false"/>
		<Setting name="UDFLibraryFile" 				value=""/>
		<Setting name="CustomErrorTemplate" 		value=""/>
		<Setting name="ExceptionHandler" 			value=""/>
		<Setting name="MessageboxStyleOverride" 	value=""/>
		<Setting name="HandlersIndexAutoReload" 	value="false"/>
		<Setting name="ConfigAutoReload" 			value="false"/>
		<Setting name="MyPluginsLocation" 			value="" />
		<Setting name="HandlerCaching" 				value="false" />
		<Setting name="EventCaching" 				value="false" />
	</Settings>

	<!-- Your own custom settings -->
	<YourSettings>
		<Setting name="ForumsURL" 			value="http://forums.coldboxframework.com" />
		<Setting name="AmazonURL" 			value="http://www.amazon.com/o/registry/7DPYG3RZG3AF"/>
		<Setting name="ColdboxURL" 			value="http://www.coldboxframework.com"/>
		<Setting name="BlogURL" 			value="http://www.coldboxframework.com/index.cfm/about/news"/>
		<Setting name="ColdboxAPIURL" 		value="http://www.coldboxframework.com/api"/>
		<Setting name="TracURL" 			value="http://ortus.svnrepository.com/coldbox/trac.cgi/"/>
		<!-- App Versionsettings -->
		<Setting name="BlogcfcApp" 			value="applications/blogcfcv5_0" />
		<Setting name="ForumsApp" 			value="applications/galleon_1_7" />
		<Setting name="ColdboxReaderApp" 	value="applications/ColdBoxReader" />
		<Setting name="cfcGeneratorApp"  	value="applications/cfcGenerator" />
		<Setting name="TransferApp" 		value="applications/TransferSample" />
		<Setting name="TransferApp2" 		value="applications/TransferSample2" />
	</YourSettings>

	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer/>
		<MailUsername/>
		<MailPassword/>
	</MailServerSettings>

	<!--Emails to Send bug reports-->
	<BugTracerReports>
		<!--<BugEmail>youremailhere</BugEmail>-->
	</BugTracerReports>

	<!--List url dev environments, this determines your dev/pro environment-->
	<DevEnvironments>
		<url>dev</url>
		<url>lmajano</url>
		<url>jeftmac</url>
	</DevEnvironments>

	<!--Webservice declarations your use in your app, if not use, leave blank
		<WebServices />
	-->
	<WebServices/>

	<!--Declare Layouts for your app here-->
	<Layouts>
		<!--Declare the default layout, this is mandatory-->
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
	</Layouts>

	<i18N>
		<!--Default Resource Bundle without locale and properties extension-->
		<DefaultResourceBundle>includes/main</DefaultResourceBundle>
		<!--Java Standard Locale-->
		<DefaultLocale>en_US</DefaultLocale>
		<!--session or client-->
		<LocaleStorage>session</LocaleStorage>
	</i18N>
	
	<Interceptors>
		<Interceptor class="coldbox.system.interceptors.executionTracer" />
	</Interceptors>

</Config>
