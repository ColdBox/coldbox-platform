<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_1.2.0.xsd">
	<Settings>
		<Setting name="AppName" value="Coldbox Samples Browser"/>
		<Setting name="AppMapping" value="coldbox/samples"/>
		<Setting name="DebugMode" value="true"/>
		<Setting name="DebugPassword" value="coldbox"/>
		<Setting name="EnableDumpVar" value="true"/>
		<Setting name="EnableColdfusionLogging" value="false"/>
		<Setting name="EnableColdboxLogging"   value="true" />
		<Setting name="ColdboxLogsLocation"	   value="logs" />
		<Setting name="DefaultEvent" value="ehSamples.dspHome"/>
		<Setting name="RequestStartHandler" value=""/>
		<Setting name="RequestEndHandler" value=""/>
		<Setting name="ApplicationStartHandler" value="ehSamples.onAppInit"/>
		<Setting name="OwnerEmail" value="myemail@gmail.com"/>
		<Setting name="EnableBugReports" value="false"/>
		<Setting name="UDFLibraryFile" value=""/>
		<Setting name="CustomErrorTemplate" value=""/>
		<Setting name="ExceptionHandler" value=""/>
		<Setting name="MessageboxStyleClass" value=""/>
		<Setting name="HandlersIndexAutoReload" value="false"/>
		<Setting name="ConfigAutoReload" value="false"/>
		<Setting name="MyPluginsLocation" value="" />
		<Setting name="HandlerCaching" value="true" />
	</Settings>

	<!-- Your own custom settings -->
	<YourSettings>
		<Setting name="SearchURL" value="http://www.luismajano.com/blog/index.cfm?mode=search"/>
		<Setting name="ForumsURL" value="http://www.luismajano.com/forums/index.cfm?event=ehForums.dspForums&amp;conferenceid=C6AFC876-EF7C-63FC-5955ECD6CA587480" />
		<Setting name="AmazonURL" value="http://www.amazon.com/o/registry/7DPYG3RZG3AF"/>
		<Setting name="ColdboxURL" value="http://www.luismajano.com/projects/coldbox"/>
		<Setting name="BlogURL" value="http://www.luismajano.com/blog/index.cfm?mode=cat&amp;catid=C048ADD3-0C45-9C3D-A8F228EFB8C128DA"/>
		<Setting name="ColdboxAPIURL" value="http://www.luismajano.com/projects/coldbox/cfdocs/index.cfm"/>
		<Setting name="TracURL" value="http://trac.luismajano.com/coldbox"/>
		<!---App Versionsettings -->
		<Setting name="BlogcfcApp" value="applications/blogcfcv5_0" />
		<Setting name="ForumsApp" value="applications/galleon_1_7" />
		<Setting name="ColdboxReaderApp" value="applications/ColdBoxReader" />
		<Setting name="cfcGeneratorApp" value="applications/cfcGenerator" />
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

</Config>
