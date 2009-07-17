<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_2.6.0.xsd">
	<Settings>
		<Setting name="AppName" 				value="Hello World"/>
		<Setting name="DebugMode" 				value="true" />
		<Setting name="DebugPassword" 			value="Coldbox"/>
		<Setting name="EventName" 					value="event"/>
		<Setting name="EnableDumpVar"			value="true" />
		<Setting name="EnableColdfusionLogging" value="false" />
		<Setting name="EnableColdboxLogging" 	value="false" />
		<Setting name="ColdboxLogsLocation"		value="" />
		<Setting name="DefaultEvent" 			value="ehGeneral.dspHello"/>
		<Setting name="RequestStartHandler" 	value=""/>
		<Setting name="RequestEndHandler" 		value=""/>
		<Setting name="OwnerEmail"				value="myemail@email.com" />
		<Setting name="EnableBugReports" 		value="true"/>
		<Setting name="UDFLibraryFile" 			value="" />
		<Setting name="CustomErrorTemplate" 	value=""/>
		<Setting name="ExceptionHandler" 		value=""/>
		<Setting name="MessageboxStyleOverride" 	value=""/>
		<Setting name="HandlersIndexAutoReload" value="false"/>
		<Setting name="ConfigAutoReload" 		value="false"/>		
	</Settings>

	<YourSettings />

	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer></MailServer>
		<MailUsername></MailUsername>
		<MailPassword></MailPassword>
	</MailServerSettings>

	<BugTracerReports>
		<!--<BugEmail>cfcoldbox@gmail.com</BugEmail>-->
	</BugTracerReports>

	<DevEnvironments>
		<url>lmajano</url>
		<url>dev</url>
	</DevEnvironments>

	<WebServices />

	<Layouts>
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
	</Layouts>

	<i18N />
	
	<Datasources>
		
	</Datasources>
	
</Config>
