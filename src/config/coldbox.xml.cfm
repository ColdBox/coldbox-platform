<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="../system/config/config.xsd">
	<Settings>
		<Setting name="AppName" 					value="coldbox tester"/>
		<Setting name="AppMapping"					value="/coldbox" />
		<Setting name="DebugMode" 					value="true"/>
		<Setting name="DebugPassword" 				value="coldbox"/>
		<Setting name="ReinitPassword" 				value=""/>
		<Setting name="EventName" 					value="event"/>
		<Setting name="EnableDumpVar" 				value="true"/>
		<Setting name="EnableColdfusionLogging" 	value="false"/>
		<Setting name="EnableColdboxLogging" 		value="true"/>
		<Setting name="ColdboxLogsLocation"			value="logs" />
		<Setting name="DefaultEvent" 				value="ehGeneral.dspHello"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler"		value="ehGeneral.onApplicationStart" />
		<Setting name="SessionStartHandler"		    value="ehGeneral.onSessionStart" />
		<Setting name="SessionEndHandler"		    value="ehGeneral.onSessionEnd" />
		<Setting name="OwnerEmail" 					value="info@luismajano.com"/>
		<Setting name="EnableBugReports" 			value="false"/>
		<Setting name="UDFLibraryFile" 				value="includes/udf.cfm" />
		<Setting name="CustomErrorTemplate"			value="" />
		<Setting name="CustomEmailBugReport"		value="includes/EmailBugReport.cfm" />
		<Setting name="MessageboxStyleOverride"		value="true" />
		<Setting name="HandlersIndexAutoReload"   	value="false" />
		<Setting name="ConfigAutoReload"			value="true" />
		<Setting name="ExceptionHandler"     		value="" />
		<Setting name="onInvalidEvent" 				value="" />
		<Setting name="MyPluginsLocation" 			value="coldbox.myplugins"/>
		<Setting name="HandlersExternalLocation" 	value="applications.coldbox.testing.testhandlers"/>
		<Setting name="HandlerCaching" 				value="false"/>
		<Setting name="IOCFramework" 				value="coldspring"/>
		<Setting name="IOCDefinitionFile"		 	value="/coldbox/config/coldspring.xml.cfm"/>
		<Setting name="IOCObjectCaching"			value="false"/>
		<Setting name="RequestContextDecorator"		value="coldbox.model.myRequestContextDecorator" />
		<Setting name="ProxyReturnCollection" 		value="false"/>
	</Settings>

	<YourSettings>
		<Setting name="MyArray"  value="[1,2,3,4,5,6]"/>
		<Setting name="MyStruct" value="{ name: 'luis majano', email: 'info@email.com', active= true }"/>
	</YourSettings>

	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings />

	<BugTracerReports>
		<BugEmail>info@coldboxframework.com</BugEmail>
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
		<DefaultView>vwHello</DefaultView>
		<Layout file="Layout.tester.cfm" name="login">
			<View>vwLogin</View>
			<View>test</View>
			<Folder>tags</Folder>
			<Folder>pdf/single</Folder>
		</Layout>
	</Layouts>

	<i18N>
		<!--Default Resource Bundle without locale and properties extension-->
		<DefaultResourceBundle>/coldbox/includes/main</DefaultResourceBundle>
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
		<ReapFrequency>3</ReapFrequency>
		<MaxObjects>100</MaxObjects>
		<FreeMemoryPercentageThreshold>0</FreeMemoryPercentageThreshold>
	</Cache>
	
	<Interceptors>
		<CustomInterceptionPoints>onLog</CustomInterceptionPoints>
		<Interceptor class="coldbox.interceptors.executionTracer">
			<Property name="Simple">Luis</Property>
			<Property name="Complex">[1,2,3,4,5]</Property>
		</Interceptor>
	</Interceptors>

</Config>
