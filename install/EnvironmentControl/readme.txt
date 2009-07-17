********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano & Rob Gonda
Date    	 :	November 8, 2007
License       : 	Licensed under the Apache 2 License
Description :
	This is an environment control interceptor for your usage. You must first create
	an environment control xml file and place it under your config folder, or wherever
	you want.  You must then set it as a property of the interceptor in your config
	file.  The path will be expanded, so please make sure it works.
	
	<Interceptor class="coldbox.system.interceptors.environmentControl">
		<Property name='configFile'>config/environments.xml.cfm</Property>
		<Property name='fireOnInit'>false</Property>
	</Interceptor>
	
	That's it. Just make sure you write up correctly your environment xml file.
	
	For an in-depth guide read: 
	http://ortus.svnrepository.com/coldbox/trac.cgi/wiki/cbEnvironmentControl

Sample:
	
<?xml version="1.0" encoding="UTF-8"?>
<!-- Declare as many tiers as you like with a unique name -->
<environmentcontrol>
	
	<!-- give an environment a name and a comma delimmited list of url snippets to match -->
	<environment name="development" urls="localhost,dev,jfetmac">
		<!--ColdBoxSpecific Settings -->
		<Setting name="HandlerCaching"			value="false" />
		<Setting name="HandlersIndexAutoReload" value="false" />
		<Setting name="IOCObjectCaching"		value="false" />
		<Setting name="DebugMode"	 			value="false" />
		<Setting name="DebugPassword" 			value="" />
		<Setting name="ReinitPassword" 			value="" />
		<Setting name="EnableDumpVar"			value="false" />
		<Setting name="EnableColdboxLogging"	value="false" />
		<Setting name="onInvalidEvent"			value="" />
		
		<!--
			AppSpecific Settings: <Setting name="MySetting" value="Hello" />
		-->		
	</environment>
	
</environmentcontrol>