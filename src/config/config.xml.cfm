<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="../system/config/config.xsd">
	<Settings>
		<Setting name="AppName" 					value="coldbox"/>
		<Setting name="AppMapping"					value="/coldbox" />
		<Setting name="DebugMode" 					value="true"/>
		<Setting name="DebugPassword" 				value="coldbox"/>
		<Setting name="ReinitPassword" 				value=""/>
		<!--This feature is enabled, by default-->
		<Setting name="EnableDumpVar" 				value="true"/>
		<Setting name="EnableColdfusionLogging" 	value="true"/>
		<Setting name="EnableColdboxLogging" 		value="true"/>
		<!--Absolute path to where you want your log files to be stored-->
		<Setting name="ColdboxLogsLocation"			value="../testing" />
		<Setting name="DefaultEvent" 				value="ehGeneral.dspHello"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler"		value="ehGeneral.onApplicationStart" />
		<Setting name="OwnerEmail" 					value="lmajano@gmail.com"/>
		<Setting name="EnableBugReports" 			value="true"/>
		<Setting name="UDFLibraryFile" 				value="includes/udf.cfm" />
		<Setting name="CustomErrorTemplate"			value="" />
		<Setting name="MessageboxStyleClass"		value="mymessagebox" />
		<Setting name="HandlersIndexAutoReload"   	value="false" />
		<Setting name="ConfigAutoReload"			value="false" />
		<Setting name="ExceptionHandler"     		value="" />
		<Setting name="onInvalidEvent" 				value="" />
		<!--Base Path to plugins, as if to instantiate them. -->
		<Setting name="MyPluginsLocation" 			value="coldbox.myplugins"/>
		<Setting name="HandlerCaching" 				value="true"/>
	</Settings>

	<YourSettings>
		<Setting name="MyArray"  value="{1,2,3,4,5,6}"/>
		<Setting name="MyStruct" value="[name:luis majano, email: info@coldboxframework.com, active: true]"/>
	</YourSettings>

	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer></MailServer>
		<MailUsername></MailUsername>
		<MailPassword></MailPassword>
	</MailServerSettings>

	<BugTracerReports>
		<BugEmail>lmajano@gmail.com</BugEmail>
	</BugTracerReports>

	<DevEnvironments>
		<url>dev</url>
		<url>lmajano</url>
	</DevEnvironments>

	<WebServices >
		<WebService URL="http://www.test.com/test.cfc?wsdl" name="TestWS"/>
		<WebService URL="http://www.coldbox.com/testit.cfc?wsdl" name="AnotherTestWS" DevURL="http://test.coldbox.com/test.cfm?wsdl"/>
	</WebServices>

	<Layouts>
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
		<Layout file="Layout.Login.cfm" name="login">
			<View>vwLogin</View>
		</Layout>
	</Layouts>

	<i18N>
		<!--Default Resource Bundle without locale and properties extension-->
		<DefaultResourceBundle>includes/main</DefaultResourceBundle>
		<!--Java Standard Locale-->
		<DefaultLocale>en_US</DefaultLocale>
		<!--session or client-->
		<LocaleStorage>session</LocaleStorage>
	</i18N>

	<Datasources>
		<Datasource alias="mysite" name="mysite" dbtype="mysql"  username="root" password="pass" />
		<Datasource alias="blog_dsn" name="myblog" dbtype="oracle" username="root" password="pass" />
	</Datasources>
	
	<Cache>
		<ObjectDefaultTimeout>15</ObjectDefaultTimeout>
		<ObjectDefaultLastAccessTimeout>5</ObjectDefaultLastAccessTimeout>
		<ReapFrequency>1</ReapFrequency>
		<MaxObjects>15</MaxObjects>
		<FreeMemoryPercentageThreshold>0</FreeMemoryPercentageThreshold>
	</Cache>

</Config>
