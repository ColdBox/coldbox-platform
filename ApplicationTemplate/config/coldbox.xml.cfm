<?xml version="1.0" encoding="UTF-8"?>
<!-- 
For all possible configuration options please refer to the documentation:
http://ortus.svnrepository.com/coldbox/trac.cgi/wiki/cbConfigGuide
 -->
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldbox.org/schema/config_3.0.0.xsd">
	<Settings>
		
		<!-- Application Setup-->
		<Setting name="AppName"						value="Your App Name here"/>
		<!-- If you are using a coldbox app to power flex/remote apps, you NEED to set the AppMapping also. In Summary,
			 the AppMapping is either a CF mapping or the path from the webroot to this application root. If this setting
			 is not set, then coldbox will try to auto-calculate it for you. Please read the docs.
		<Setting name="AppMapping"					value="/MyApp"/> -->
		<Setting name="EventName"					value="event" />
		<Setting name="OwnerEmail" 					value="" />
		
		<!-- Development Settings -->
		<Setting name="DebugMode" 					value="true"/>
		<Setting name="DebugPassword" 				value=""/>
		<Setting name="ReinitPassword" 				value=""/>
		<Setting name="EnableDumpVar" 				value="true"/>
		<Setting name="HandlersIndexAutoReload" 	value="true"/>
		<Setting name="ConfigAutoReload" 			value="false"/>
		
		<!-- Implicit Events -->
		<Setting name="DefaultEvent" 				value="General.index"/>
		<Setting name="RequestStartHandler" 		value="Main.onRequestStart"/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler" 	value="Main.onAppInit"/>
		<Setting name="SessionStartHandler" 		value=""/>
		<Setting name="SessionEndHandler" 			value=""/>
		
		<!-- Extension Points -->
		<Setting name="UDFLibraryFile" 				value="includes/helpers/ApplicationHelper.cfm" />
		<Setting name="PluginsExternalLocation"   	value="" />
		<Setting name="ViewsExternalLocation" 		value=""/>
		<Setting name="HandlersExternalLocation"   	value="" />
		<Setting name="RequestContextDecorator" 	value=""/>
		
		<!-- Error/Exception Handling -->
		<Setting name="ExceptionHandler" 			value=""/>
		<Setting name="onInvalidEvent" 				value=""/>
		<Setting name="CustomErrorTemplate"			value="" />
		
		<!-- Application Aspects -->
		<Setting name="HandlerCaching" 				value="false"/>
		<Setting name="EventCaching" 				value="false"/>
		<Setting name="EnableBugReports" 			value="false"/>
		<Setting name="MessageboxStyleOverride"		value="false" />
		<Setting name="ProxyReturnCollection" 		value="false"/>
		<Setting name="FlashURLPersistScope" 		value="session"/>
		
		
		<!-- IOC Integration -->
		<Setting name="IOCFramework"				value="" />
		<Setting name="IOCDefinitionFile"			value="" />
		<Setting name="IOCFrameworkReload"			value="false" />
		<Setting name="IOCObjectCaching"			value="false" />
	</Settings>
	
	<!-- Complex Settings follow JSON Syntax. www.json.org.  
		 *IMPORTANT: use single quotes in this xml file for JSON notation, ColdBox will translate it to double quotes.
	 -->
	<YourSettings>
		<!-- @YOURSETTINGS@ -->
	</YourSettings>
	
	<!--Model Integration -->
	<Models>
		<ObjectCaching>true</ObjectCaching>
		<DefinitionFile>config/ModelMappings.cfm</DefinitionFile>
		<SetterInjection>false</SetterInjection>
		<!--
		<ExternalLocation></ExternalLocation>
		<DICompleteUDF>onDIComplete</DICompleteUDF>
		<StopRecursion></StopRecursion>		
		<DebugMode>false</DebugMode>
		<DebugLevel>TRACE</DebugLevel> -->
	</Models>
	
	<!-- 
		ColdBox Logging via LogBox
		Levels: -1=OFF,0=FATAL,1=ERROR,2=WARN,3=INFO,4=DEBUG,5=TRACE
	-->
	<LogBox>
		<!-- Log to console -->
		<Appender name="console" class="coldbox.system.logging.appenders.ConsoleAppender" />
		<!-- Log to ColdBox Files -->
		<Appender name="coldboxfile" class="coldbox.system.logging.appenders.AsyncRollingFileAppender">
			<Property name="filePath">logs</Property>
			<Property name="fileName">${AppName}</Property>
			<Property name="autoExpand">true</Property>
			<Property name="fileMaxSize">2000</Property>
			<Property name="fileMaxArchives">2</Property>		
		</Appender>
		<!-- Root Logger Definition -->
		<Root levelMin="FATAL" levelMax="TRACE" appenders="*" />
		<!-- Category Definitions Below -->
	</LogBox>
	
	<DebuggerSettings>
		<PersistentTracers>true</PersistentTracers>
		<PersistentRequestProfiler>true</PersistentRequestProfiler>
		<maxPersistentRequestProfilers>10</maxPersistentRequestProfilers>
		<maxRCPanelQueryRows>50</maxRCPanelQueryRows>
		<TracerPanel 	show="true" expanded="true" />
		<InfoPanel 		show="true" expanded="true" />
		<CachePanel 	show="true" expanded="false" />
		<RCPanel		show="true" expanded="false" />
	</DebuggerSettings>	
	
	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer></MailServer>
		<MailPort></MailPort>
		<MailUsername></MailUsername>
		<MailPassword></MailPassword>
	</MailServerSettings>

	<!--Emails to Send bug reports, you can create as many as you like -->
	<BugTracerReports>
		<!-- <BugEmail>myemail@gmail.com</BugEmail> -->
	</BugTracerReports>
	
	<WebServices>
		<!-- <WebService name="TESTWS1" URL="http://www.test.com/test1.cfc?wsdl" /> -->
	</WebServices>

	<Layouts>
		<!--Declare the default layout, MANDATORY-->
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
		<!--Default View, OPTIONAL
		<DefaultView>home</DefaultView>
		-->
		<!--
		Declare other layouts, with view/folder assignments if needed, else do not write them
		<Layout file="Layout.Popup.cfm" name="popup">
			<View>vwTest</View>
			<View>vwMyView</View>
			<Folder>tags</Folder>
		</Layout>
		-->
	</Layouts>

	<Datasources>
		<!-- <Datasource alias="MyDSNAlias" name="real_dsn_name"   dbtype="mysql"  username="" password="" /> -->
	</Datasources>
	
	<Cache>
		<ObjectDefaultTimeout>60</ObjectDefaultTimeout>
		<ObjectDefaultLastAccessTimeout>30</ObjectDefaultLastAccessTimeout>
		<UseLastAccessTimeouts>true</UseLastAccessTimeouts>
		<ReapFrequency>1</ReapFrequency>
		<MaxObjects>100</MaxObjects>
		<FreeMemoryPercentageThreshold>0</FreeMemoryPercentageThreshold>
		<EvictionPolicy>LRU</EvictionPolicy>
	</Cache>
	
	<Interceptors>
		<!-- USE ENVIRONMENT CONTROL -->
		<Interceptor class="coldbox.system.interceptors.EnvironmentControl">
			<Property name='configFile'>config/environments.xml.cfm</Property>
		</Interceptor>
		<!-- USE AUTOWIRING -->
		<Interceptor class="coldbox.system.interceptors.Autowire" />
		<!-- USE SES -->
		<Interceptor class="coldbox.system.interceptors.SES">
			<Property name="configFile">config/Routes.cfm</Property>
		</Interceptor>		
		<!-- @SIDEBAR@ -->
	</Interceptors>
	
</Config>