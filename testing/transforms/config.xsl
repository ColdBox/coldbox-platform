<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
	
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.luismajano.com/projects/coldbox/schema/config_1.1.0.xsd">
	<Settings>
		<Setting name="AppName"						value="Your App Name here"/>
		<Setting name="AppMapping" 					value="Your Application Mapping Here" />
		<Setting name="AppDevMapping" 				value=""/>
		<Setting name="DebugMode" 					value="true" />
		<Setting name="DebugPassword" 				value="Coldbox"/>
		<Setting name="EnableDumpVar"				value="true" />
		<Setting name="EnableColdfusionLogging" 	value="true" />
		<Setting name="EnableColdboxLogging"		value="true" />
		<Setting name="ColdboxLogsLocation"			value="" />
		<Setting name="DefaultEvent" 				value="ehGeneral.dspHello"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler" 	value=""/>
		<Setting name="OwnerEmail" 					value="myemail@gmail.com" />
		<Setting name="EnableBugReports" 			value="true"/>
		<Setting name="UDFLibraryFile" 				value="" />
		<Setting name="ExceptionHandler"			value="" />
		<Setting name="CustomErrorTemplate"			value="" />
		<Setting name="MessageboxStyleClass"		value="" />
		<Setting name="HandlersIndexAutoReload"   	value="true" />
		<Setting name="ConfigAutoReload"          	value="true" />
		<Setting name="MyPluginsLocation"   		value="" />
	</Settings>

	<YourSettings>
		<Setting name="MySetting" value="My Value"/>
	</YourSettings>

	<MailServerSettings>
		<MailServer></MailServer>
		<MailUsername></MailUsername>
		<MailPassword></MailPassword>
	</MailServerSettings>

	<BugTracerReports>
		
	</BugTracerReports>

	<DevEnvironments>
		<url>dev</url>
		<url>dev1</url>
	</DevEnvironments>

	<WebServices>
		
	</WebServices>

	
	<Layouts>
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
		<Layout file="Layout.Popup.cfm" name="popup">
			<View>vwTest</View>
			<View>vwMyView</View>
		</Layout>
	</Layouts>

	<i18N>
		<DefaultResourceBundle>includes/main</DefaultResourceBundle>
		<DefaultLocale>en_US</DefaultLocale>
		<LocaleStorage>session</LocaleStorage>
	</i18N>
	
	<Datasources>
		<Datasource name="MyDSN"   dbtype="mysql"  username="" password="" />
		<Datasource name="MyBlog"  dbtype="oracle" username="" password="" />
	</Datasources>

</Config>

</xsl:template>
</xsl:stylesheet>
