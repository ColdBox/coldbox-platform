<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="../system/config/config.xsd">
	<Settings>
		<Setting name="AppName" 					value="ColdBox TestHarness"/>
		<Setting name="AppMapping"					value="/coldbox/testharness" />
		<Setting name="DebugMode" 					value="false"/>
		<Setting name="DebugPassword" 				value=""/>
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
		<Setting name="SessionEndHandler"		    value="" />
		<Setting name="OwnerEmail" 					value="info@coldboxframework.com"/>
		<Setting name="EnableBugReports" 			value="false"/>
		<Setting name="UDFLibraryFile" 				value="includes/udf.cfm" />
		<Setting name="CustomErrorTemplate"			value="" />
		<Setting name="CustomEmailBugReport"		value="includes/EmailBugReport.cfm" />
		<Setting name="MessageboxStyleOverride"		value="false" />
		<Setting name="HandlersIndexAutoReload"   	value="false" />
		<Setting name="ConfigAutoReload"			value="false" />
		<Setting name="ExceptionHandler"     		value="" />
		<Setting name="onInvalidEvent" 				value="" />
		<Setting name="MyPluginsLocation" 			value="coldbox.testing.testplugins"/>
		<Setting name="ViewsExternalLocation"		value="/coldbox/testing/testviews" />
		<Setting name="HandlersExternalLocation" 	value="coldbox.testing.testhandlers"/>
		<Setting name="ModelsExternalLocation"   	value="coldbox.testing.testmodel" />
		<Setting name="HandlerCaching" 				value="false"/>
		<Setting name="EventCaching" 				value="true"/>
		<Setting name="IOCFramework" 				value="lightwire"/>
		<Setting name="IOCFrameworkReload" 			value="true"/>
		<Setting name="IOCDefinitionFile"		 	value="config/coldspring.xml.cfm"/>
		<Setting name="IOCObjectCaching"			value="false"/>
		<Setting name="RequestContextDecorator"		value="coldbox.testharness.model.myRequestContextDecorator" />
		<Setting name="ProxyReturnCollection" 		value="false"/>
	</Settings>

	<YourSettings>
		<Setting name="MyStruct" value="{name:'luis majano', email:'info@email.com', active:'true'}"/>
		<Setting name="MyArray"  value="[1,2,3,4,5,6]"/>
		<Setting name="MyBaseURL"  value="apps.jfetmac" />
		
		<!-- Log Level -->
		<Setting name="logger_loglevel"  value="2"/>
		
		<!-- RSS REader -->
		<Setting name="feedReader_useCache"  value="true" />
		<Setting name="feedReader_cacheType"  value="ram" />
		<Setting name="feedReader_cacheTimeout"  value="10" />
		
		<!-- Show SideBar? true/false, else leave blank. -->
		<Setting name="ColdBoxSideBar" value="true" />
		
		<!--Testing Model Path -->
		<Setting name="TestingModelPath" value="coldbox.testing.testmodel" />
	</YourSettings>
	
	<!-- Custom Conventions : You can override the framework wide conventions -->
	<Conventions>
		<handlersLocation>handlers</handlersLocation>
		<pluginsLocation>plugins</pluginsLocation>
		<layoutsLocation>layouts</layoutsLocation>
		<viewsLocation>views</viewsLocation>
		<eventAction>index</eventAction>		
	</Conventions>	

	<DebuggerSettings>
		<!--Settings-->
		<PersistentRequestProfiler>true</PersistentRequestProfiler>
		<maxPersistentRequestProfilers>10</maxPersistentRequestProfilers>
		<maxRCPanelQueryRows>50</maxRCPanelQueryRows>
		<!--Panels-->
		<TracerPanel 	show="true" expanded="false" />
		<InfoPanel 		show="true" expanded="false" />
		<CachePanel 	show="true" expanded="false" />
		<RCPanel		show="false" expanded="false" />
	</DebuggerSettings>
	
	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings />

	<BugTracerReports>
		<BugEmail>info@coldboxframework.com</BugEmail>
	</BugTracerReports>

	<DevEnvironments>
		<url>dev</url>
	</DevEnvironments>

	<WebServices >
		<WebService URL="http://www.test.com/test.cfc?wsdl" name="TestWS"/>
		<WebService URL="http://www.coldboxframework.com/distribution/updatews.cfc?wsdl" name="AnotherTestWS" DevURL="http://www.coldboxframework.com/distribution/updatews.cfc?wsdl"/>
	</WebServices>

	<Layouts>
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
		<Layout file="Layout.tester.cfm" name="login">
			<View>vwLogin</View>
			<View>test</View>
			<Folder>tags</Folder>
			<Folder>pdf/single</Folder>
		</Layout>
	</Layouts>

	<i18N>
		<!--Default Resource Bundle without locale and properties extension-->
		<DefaultResourceBundle>includes/main</DefaultResourceBundle>
		<!--Java Standard Locale-->
		<DefaultLocale>en_US</DefaultLocale>
		<!--session or client-->
		<LocaleStorage>session</LocaleStorage>
		<UknownTranslation>nothing</UknownTranslation>
	</i18N>

	<Datasources>
		<Datasource alias="mysite" name="mysite" dbtype="mysql"  username="root" password="pass" />
		<Datasource alias="blog_dsn" name="myblog" dbtype="oracle" username="root" password="pass" />
	</Datasources>
	
	<Cache>
		<ObjectDefaultTimeout>15</ObjectDefaultTimeout>
		<ObjectDefaultLastAccessTimeout>5</ObjectDefaultLastAccessTimeout>
		<ReapFrequency>1</ReapFrequency>
		<MaxObjects>100</MaxObjects>
		<FreeMemoryPercentageThreshold>0</FreeMemoryPercentageThreshold>
		<UseLastAccessTimeouts>false</UseLastAccessTimeouts>
	</Cache>
	
	<Interceptors throwOnInvalidStates="true">
		<CustomInterceptionPoints>onLog</CustomInterceptionPoints>
		
		<Interceptor class="coldbox.system.interceptors.environmentControl">
			<Property name="configFile">config/environments.xml.cfm</Property>
			<Property name="fireOnInit">true</Property>
		</Interceptor>
		<Interceptor class="coldbox.system.interceptors.deploy">
			<Property name="tagFile">config/_deploy.tag</Property>
			<Property name="deployCommandObject">coldbox.testharness.model.DeployCleanup</Property>
		</Interceptor>
		<Interceptor class="coldbox.system.interceptors.autowire">
			<Property name="debugMode">false</Property>
			<Property name="enableSetterInjection">false</Property>
		</Interceptor>
		<Interceptor class="coldbox.system.interceptors.ses">
			<Property name="configFile">/config/routes.cfm</Property>
		</Interceptor>
		
		<Interceptor class="${AppMapping}.interceptors.errorObserver" />
		<Interceptor class="${AppMapping}.interceptors.iocObserver" />
		
		<Interceptor class="coldbox.system.interceptors.security">
	        <Property name="rulesSource">xml</Property>
	        <Property name="rulesFile">config/security.xml.cfm</Property>
	        <Property name="debugMode">true</Property>
	        <Property name="preEventSecurity">true</Property>
		</Interceptor>	
		<!-- Developer's ColdBox Sidebar -->
		<Interceptor class="coldbox.system.interceptors.coldboxSideBar" />
	</Interceptors>

</Config>
