<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:noNamespaceSchemaLocation="http://www.luismajano.com/projects/coldbox/schema/config.xsd">
	<Settings>
		<Setting name="AppName" value="Coldbox Samples Browser"/>
		<Setting name="AppCFMXMapping" value="coldboxSamples"/>
		<Setting name="DebugMode" value="true"/>
		<Setting name="DebugPassword" value="coldbox"/>
		<Setting name="DumpVarActive" value="true"/>
		<Setting name="ColdfusionLogging" value="false"/>
		<Setting name="DefaultEvent" value="ehSamples.dspHome"/>
		<Setting name="RequestStartHandler" value=""/>
		<Setting name="RequestEndHandler" value=""/>
		<Setting name="ApplicationStartHandler" value=""/>
		<Setting name="OwnerEmail" value="myemail@gmail.com"/>
		<Setting name="EnableBugReports" value="true"/>
		<Setting name="UDFLibraryFile" value=""/>
		<Setting name="CustomErrorTemplate" value=""/>
		<Setting name="ExceptionHandler" value=""/>
		<Setting name="MessageboxStyleClass" value=""/>
		<Setting name="HandlersIndexAutoReload" value="false"/>
		<Setting name="ConfigAutoReload" value="false"/>
	</Settings>

	<!-- Your own custom settings -->
	<YourSettings>
		<Setting name="SearchURL" value="http://www.luismajano.com/blog/index.cfm?mode=search"/>
		<Setting name="FourmsURL" value="http://www.luismajano.com/forums/"/>
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
