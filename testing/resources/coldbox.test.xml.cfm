<?xml version="1.0" encoding="UTF-8"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:noNamespaceSchemaLocation="../system/web/config/config.xsd">
	<Settings>
		<Setting name="AppName" 					value="ColdBox TestHarness"/>
		<Setting name="AppMapping"					value="/coldbox/testharness" />
		
		<Setting name="DebugMode" 					value="false"/>
		<Setting name="DebugPassword" 				value=""/>
		<Setting name="ReinitPassword" 				value=""/>
		
		<Setting name="DefaultEvent" 				value="ehGeneral.dspHello"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="ApplicationStartHandler"		value="ehGeneral.onApplicationStart" />
		<Setting name="SessionStartHandler"		    value="ehGeneral.onSessionStart" />
		<Setting name="SessionEndHandler"		    value="" />
		
		<Setting name="UDFLibraryFile" 				value="" />
		<Setting name="CustomErrorTemplate"			value="" />
		<Setting name="HandlersIndexAutoReload"   	value="false" />
		<Setting name="ConfigAutoReload"			value="false" />
		<Setting name="ExceptionHandler"     		value="" />
		<Setting name="onInvalidEvent" 				value="" />
		
		<Setting name="PluginsExternalLocation" 	value="coldbox.testing.testplugins"/>
		<Setting name="ViewsExternalLocation"		value="/coldbox/testing/testviews" />
		<Setting name="HandlersExternalLocation" 	value="coldbox.testing.testhandlers"/>
		<Setting name="ModelsExternalLocation"   	value="coldbox.testing.testmodel" />
		
		<Setting name="HandlerCaching" 				value="false"/>
		<Setting name="EventCaching" 				value="false"/>
		
		<Setting name="RequestContextDecorator"		value="coldbox.testharness.model.myRequestContextDecorator" />
		<Setting name="ProxyReturnCollection" 		value="false"/>
	</Settings>

	<IOC>
		<Framework type="lightwire" reload="false">config/coldspring.xml.cfm</Framework>
	</IOC>
	
	<YourSettings>
		<Setting name="MyStruct" value="{name:'luis majano', email:'info@email.com', active:'true'}"/>
		<Setting name="MyArray"  value="[1,2,3,4,5,6]"/>
		<Setting name="MyBaseURL"  value="apps.jfetmac" />
		
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

	<Layouts>
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
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
		<Interceptor class="coldbox.system.interceptors.EnvironmentControl">
			<Property name="configFile">config/environments.xml.cfm</Property>
			<Property name="fireOnInit">true</Property>
		</Interceptor>
		<Interceptor class="coldbox.system.interceptors.Autowire">
			<Property name="debugMode">false</Property>
			<Property name="enableSetterInjection">false</Property>
		</Interceptor>
	</Interceptors>

</Config>
