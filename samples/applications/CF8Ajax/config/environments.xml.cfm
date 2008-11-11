<?xml version="1.0" encoding="UTF-8"?>
<!-- Declare as many tiers as you like with a unique name -->
<environmentcontrol>
	<environment name="development" urls="localhost,dev.coldbox.com">
		<!--ColdBoxSpecific Settings -->
		<!--Default Debugmode boolean flag (Set to false in production environments)-->
		<Setting name="DebugMode" 					value="true" />
		<!--The Debug Password to use in order to activate/deactivate debugmode,activated by url actions -->
		<Setting name="DebugPassword" 				value=""/>
		<!--The fwreinit password to use in order to reinitialize the framework and application.Optional, else leave blank -->
		<Setting name="ReinitPassword" 				value=""/>
		<!--This feature is enabled by default to permit the url dumpvar parameter-->
		<Setting name="EnableDumpVar"				value="true" />
		
		<Setting name="EnableBugReports" 			value="false"/>
		<!--Flag to Auto reload the internal handlers directory listing. False for production. -->
		<Setting name="HandlersIndexAutoReload"   	value="true" />
		<!--Flag to auto reload the config.xml settings. False for production. -->
		<Setting name="ConfigAutoReload"          	value="true" />
		<!--Flag to cache handlers. Default if left blank is true. -->
		<Setting name="HandlerCaching" 				value="false"/>
		<!--Flag to cache events if metadata declared. Default is true -->
		<Setting name="EventCaching" 				value="false"/>
		<!--IOC Object Caching, true/false. For ColdBox to cache your IoC beans-->
		<Setting name="IOCObjectCaching"			value="false" />
		<!--Request Context Decorator, leave blank if not using. Full instantiation path -->
		<Setting name="RequestContextDecorator" 	value=""/>
		<!--Flag if the proxy returns the entire request collection or what the event handlers return, default is false -->
		<Setting name="ProxyReturnCollection" 		value="false"/>
		<!-- custom settigns  -->

	</environment>

	<environment name="staging" urls="staging.cf8ajax.com">
		<!--ColdBoxSpecific Settings -->
		<Setting name="BaseURL"	value="http://staging.cf8ajax.com/" />
		<!-- custom settigns  -->
	</environment>
	
	<environment name="live" urls="www.cf8ajax.com">
		<!--ColdBoxSpecific Settings -->
		<Setting name="BaseURL"	value="http://www.cf8ajax.com/" />
		<!-- custom settigns  -->
	</environment>
	
</environmentcontrol>
