<?xml version="1.0" encoding="ISO-8859-1"?>
<Config>
	<Settings>
		<Setting name="AppName" 					value="Hello World"/>
		<Setting name="AppCFMXMapping" 				value="fwcoldbox.helloworld"/>
		<Setting name="DebugMode" 					value="true"/>
		<Setting name="DebugPassword" 				value="Textus"/>
		<!--This feature is enabled, by default-->
		<Setting name="DumpVarActive" 				value="true"/>
		<Setting name="ColdfusionLogging" 			value="true"/>
		<Setting name="DefaultEvent" 				value="ehGeneral.dspHello"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<!-- From Address in all email communications -->
		<Setting name="OwnerEmail" 					value="lmajano@gmail.com"/>
		<!-- Enable Bug Reports to be emailed, set to true by default -->
		<Setting name="EnableBugReports" 			value="true"/>
		<!--UDF Library To Load on every request for your views and handlers. TeXtus 
will look in the includes directory of your app.-->
		<Setting name="UDFLibraryFile" 				value="" />
		<!--Full path from the application's root to your custom error page, else leave blank-->
		<Setting name="CustomErrorTemplate"			value="" />
		<!--Messagebox Style (css) class. This needs to be in your current displayed layout or view-->
		<Setting name="MessageboxStyleClass"		value="mymessagebox" />
		
	</Settings>
	
	<YourSettings>
	</YourSettings>
	
	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer>mailserverhere</MailServer>
		<MailUsername></MailUsername>
		<MailPassword></MailPassword>
	</MailServerSettings>
	
	<BugTracerReports>
		<BugEmail>lmajano@gmail.com</BugEmail>
	</BugTracerReports>

	<DevEnvironments>
		<url>devj2</url>
		<url>dev1</url>
		<url>dev</url>
	</DevEnvironments>

	<WebServices>
	</WebServices>
	
	<Layouts>
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
		<Layout file="Layout.Popup.cfm" name="popup">
			<View>vwTest</View>
		</Layout>
	</Layouts>
</Config>
