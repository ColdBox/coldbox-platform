<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_1.1.0.xsd">
	<Settings>
		<Setting name="AppName" 					value="ColdboxDashboard"/>
		<Setting name="AppMapping" 					value="coldbox/system/dashboard"/>
		<Setting name="DebugMode"					value="false"/>
		<Setting name="DebugPassword"				value="coldbox"/>
		<Setting name="EnableDumpVar" 				value="false"/>
		<Setting name="EnableColdfusionLogging" 	value="false"/>
		<Setting name="EnableColdboxLogging" 		value="true"/>
		<Setting name="ColdboxLogsLocation" 		value="logs"/>
		<Setting name="DefaultEvent" 				value="ehColdbox.dspFrameset"/>
		<Setting name="RequestStartHandler" 		value="ehColdbox.onRequestStart"/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler" 	value="ehColdbox.onAppStart"/>
		<Setting name="OwnerEmail" 					value="myemail@email.com"/>
		<Setting name="EnableBugReports" 			value="false"/>
		<Setting name="UDFLibraryFile" 				value="" />		
		<Setting name="CustomErrorTemplate"			value="" />
		<Setting name="MessageboxStyleClass"	    value="" />
		<Setting name="HandlersIndexAutoReload"   	value="true" />
		<Setting name="ConfigAutoReload"			value="false" />
		<Setting name="ExceptionHandler"     		value="" />
	</Settings>
	
	<YourSettings>
		<Setting name="BackupsPath"				value="backups" />
		<Setting name="UpdateTempDir"			value="../../_tempinstall" />
		<Setting name="InstallerDir"			value="installer" />
		<Setting name="Version" 				value="1.1.0"/>
		<Setting name="TracSite"				value="http://ortus.svnrepository.com/coldbox/" />
		<Setting name="OfficialSite"			value="http://www.coldboxframework.com" />
		<Setting name="SchemaDocs" 				value="http://www.coldboxframework.com/documents/SchemaDocs/"/>
	</YourSettings>
	
	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer />
		<MailUsername/>
		<MailPassword/>
	</MailServerSettings>
	
	<BugTracerReports>
		<!--<BugEmail>email@domain.com</BugEmail>-->
	</BugTracerReports>
	
	<DevEnvironments>
		<url>dev</url>
		<url>lmajano</url>
	</DevEnvironments>
	
	<WebServices>
		<WebService name="DistributionWS" URL="http://www.coldboxframework.com/distribution/coldbox.cfc?wsdl" />
	</WebServices>
	
	<Layouts>
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
		<Layout file="Layout.Login.cfm" name="login">
			<View>vwLogin</View>
		</Layout>
	</Layouts>
	
	<i18N />
	
	
	<Datasources />
	
</Config>
