<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:noNamespaceSchemaLocation="http://www.coldboxframework.com/schema/config_3.0.0.xsd">
	<Settings>
		
		<!-- Application Setup-->
		<Setting name="AppName"						value="Your App Name here"/>
		<!-- 
			YOU NEED TO UNCOMMENT AND FILL THIS OUT FOR REMOTE OPERATIONS
		-->		
		<Setting name="AppMapping"					value="/coldbox/ApplicationTemplateRemote"/>
		<Setting name="EventName"					value="event" />
		<Setting name="OwnerEmail" 					value="" />
		
		<!-- Development Settings -->
		<Setting name="DebugMode" 					value="true"/>
		<Setting name="DebugPassword" 				value=""/>
		<Setting name="ReinitPassword" 				value=""/>
		<Setting name="EnableDumpVar" 				value="false"/>
		<Setting name="HandlersIndexAutoReload" 	value="true"/>
		<Setting name="ConfigAutoReload" 			value="false"/>
		
		<!-- Implicit Events -->
		<Setting name="DefaultEvent" 				value="general.index"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler" 	value="main.onAppInit"/>
		<Setting name="SessionStartHandler" 		value=""/>
		<Setting name="SessionEndHandler" 			value=""/>
		
		<!-- Extension Points -->
		<Setting name="UDFLibraryFile" 				value="" />
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
		
		<!--Model Integration -->
		<Setting name="ModelsExternalLocation"   	value="" />
		<Setting name="ModelsObjectCaching"   		value="true" />
		<Setting name="ModelsDefinitionFile" 		value="config/ModelMappings.cfm"/>
		<!-- Uncomment More Model Integration Settings:
			<Setting name="ModelsSetterInjection"   	value="false" />
			<Setting name="ModelsDICompleteUDF"   		value="onDIComplete" />
			<Setting name="ModelsStopRecursion"   		value="" />
			<Setting name="ModelsDebugMode"   			value="true" />
		-->
		
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
		<Root levelMin="0" levelMax="4" appenders="*" />
		<!-- Category Definitions Below -->
	</LogBox>
	
	<!-- Custom Conventions : You can override the framework wide conventions of the locations of the needed objects -->
	<Conventions>
		<handlersLocation>monitor/handlers</handlersLocation>
		<layoutsLocation>monitor/layouts</layoutsLocation>
		<viewsLocation>monitor/views</viewsLocation>
	</Conventions>	
	
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
	<MailServerSettings />
	
	<!--Emails to Send bug reports, you can create as many as you like -->
	<BugTracerReports />
	
	<!-- Web services -->
	<WebServices />
	
	<!-- Layouts -->
	<Layouts>
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
	</Layouts>

	<!-- Datasources -->
	<Datasources />
	
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
	</Interceptors>
	
</Config>