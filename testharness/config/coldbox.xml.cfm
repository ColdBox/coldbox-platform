<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="../system/web/config/config.xsd">
	<Settings>
		<Setting name="AppName" 					value="ColdBox TestHarness"/>
		<Setting name="AppMapping"					value="/coldbox/testharness" />
		<Setting name="DebugMode" 					value="false"/>
		<Setting name="DebugPassword" 				value=""/>
		<Setting name="ReinitPassword" 				value=""/>
		<Setting name="EventName" 					value="event"/>
		<Setting name="DefaultEvent" 				value="ehGeneral.dspHello"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler"		value="main.onApplicationStart" />
		<Setting name="SessionStartHandler"		    value="main.onSessionStart" />
		<Setting name="SessionEndHandler"		    value="main.onSessionEnd" />
		<Setting name="UDFLibraryFile" 				value="includes/udf.cfm" />
		<Setting name="CustomErrorTemplate"			value="" />
		<Setting name="HandlersIndexAutoReload"   	value="false" />
		<Setting name="ConfigAutoReload"			value="false" />
		<Setting name="ExceptionHandler"     		value="" />
		<Setting name="onInvalidEvent" 				value="" />
		
		<Setting name="ColdBoxExtensionsLocation"	value="coldbox.testharness.extensions" />
		<Setting name="PluginsExternalLocation" 	value="coldbox.testing.testplugins"/>
		<Setting name="ViewsExternalLocation"		value="/coldbox/testing/testviews" />
		<Setting name="HandlersExternalLocation" 	value="coldbox.testing.testhandlers"/>
		
		<Setting name="HandlerCaching" 				value="false"/>
		<Setting name="EventCaching" 				value="true"/>
		<Setting name="RequestContextDecorator"		value="coldbox.testharness.model.myRequestContextDecorator" />
		<Setting name="ProxyReturnCollection" 		value="false"/>
		<Setting name="LayoutsExternalLocation"     value="extlayouts" />
	</Settings>

	<YourSettings>
		<Setting name="MyStruct" value="{name:'luis majano', email:'info@email.com', active:'true'}"/>
		<Setting name="MyArray"  value="[1,2,3,4,5,6]"/>
		<Setting name="MyBaseURL"  value="apps.jfetmac" />
		
		<!-- RSS REader -->
		<Setting name="FeedReader_useCache"  value="true" />
		<Setting name="FeedReader_cacheType"  value="ram" />
		<Setting name="FeedReader_cacheTimeout"  value="10" />
		
		<!-- Show SideBar? true/false, else leave blank. -->
		<Setting name="ColdBoxSideBar" value="true" />
		
		<!--Testing Model Path -->
		<Setting name="TestingModelPath" value="coldbox.testing.testmodel" />
		
		<!-- javaloader lib path to load libraries -->
		<Setting name="javaloader_libpath" value="${applicationPath}model/java" />
	</YourSettings>
	
	<!-- IOC Integration -->
	<IOC>
		<Framework reload="true" type="lightwire">config/coldspring.xml.cfm</Framework>
		<ParentFactory type="coldspring">config/parent.xml.cfm</ParentFactory>
	</IOC>
	
	<!--Model Integration -->
	<Models>
		<ObjectCaching>true</ObjectCaching>
		<DefinitionFile>config/modelMappings.cfm</DefinitionFile>
		<ExternalLocation>coldbox.testing.testmodel</ExternalLocation>
	</Models>
	
	<LogBox>
		<!-- Appender Definitions -->
		<Appender name="myconsole" class="coldbox.system.logging.appenders.ConsoleAppender" />
		<Appender name="ColdBoxTracer" class="coldbox.system.logging.appenders.ColdboxTracerAppender" />
		<Appender name="FileAppender" class="coldbox.system.logging.appenders.RollingFileAppender">
			<Property name="filePath">logs</Property>
			<Property name="fileName">${AppName}</Property>
			<Property name="autoExpand">true</Property>		
		</Appender>
		<!-- Root Logger -->
		<Root levelMin="FATAL" levelMax="DEBUG" appenders="*" />
		<!-- ColdBox -->
		<Category name="coldbox.system" levelMax="DEBUG" appenders="*" />
	</LogBox>
	
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
		<TracerPanel 	show="true" expanded="true" />
		<InfoPanel 		show="true" expanded="false" />
		<CachePanel 	show="true" expanded="false" />
		<RCPanel		show="false" expanded="false" />
	</DebuggerSettings>
	
	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer>localhost</MailServer>
		<MailUsername>test</MailUsername>
	</MailServerSettings>

	<BugTracerReports enabled="false">
		<MailFrom>info@coldboxframework.com</MailFrom>
		<CustomEmailBugReport>includes/EmailBugReport.cfm</CustomEmailBugReport>
		<BugEmail>info@coldboxframework.com</BugEmail>
	</BugTracerReports>

	<WebServices >
		<WebService URL="http://www.test.com/test.cfc?wsdl" name="TestWS"/>
		<WebService URL="http://www.coldbox.org/distribution/updatews.cfc?wsdl" name="AnotherTestWS"/>
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
		<UnknownTranslation>nothing</UnknownTranslation>
	</i18N>

	<Datasources>
		<Datasource alias="mysite" name="mysite" dbtype="mysql"  username="root" password="pass" />
		<Datasource alias="blog_dsn" name="myblog" dbtype="oracle" username="root" password="pass" />
	</Datasources>
	
	<!--
	<Cache>
		<ObjectDefaultTimeout>15</ObjectDefaultTimeout>
		<ObjectDefaultLastAccessTimeout>5</ObjectDefaultLastAccessTimeout>
		<ReapFrequency>1</ReapFrequency>
		<MaxObjects>5</MaxObjects>
		<FreeMemoryPercentageThreshold>0</FreeMemoryPercentageThreshold>
		<UseLastAccessTimeouts>false</UseLastAccessTimeouts>
		<EvictCount>2</EvictCount>
		<EvictionPolicy>LFU</EvictionPolicy>
	</Cache>
	-->
	
	<Interceptors throwOnInvalidStates="false">
		
		<Interceptor class="coldbox.system.interceptors.EnvironmentControl">
			<Property name="configFile">config/environments.xml.cfm</Property>
		</Interceptor>
		<Interceptor class="coldbox.system.interceptors.Deploy">
			<Property name="tagFile">config/_deploy.tag</Property>
			<Property name="deployCommandObject">coldbox.testharness.model.DeployCleanup</Property>
			<Property name="deployCommandModel">DeployCommand</Property>
		</Interceptor>
		<Interceptor class="coldbox.system.interceptors.Autowire">
			<Property name="debugMode">true</Property>
		</Interceptor>
		<Interceptor class="coldbox.system.interceptors.SES">
			<Property name="configFile">config/routes.cfm</Property>
		</Interceptor>
		
		<Interceptor class="${AppMapping}.interceptors.errorObserver" />
		<Interceptor class="${AppMapping}.interceptors.iocObserver" />
		
		<Interceptor class="coldbox.system.interceptors.Security">
	        <Property name="rulesSource">xml</Property>
	        <Property name="rulesFile">config/security.xml.cfm</Property>
	        <Property name="debugMode">true</Property>
	        <Property name="preEventSecurity">false</Property>
		</Interceptor>	
		
		<Interceptor class="${AppMapping}.interceptors.executionTracer" />
	</Interceptors>

</Config>
