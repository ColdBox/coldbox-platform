<?xml version="1.0" encoding="UTF-8"?>
<!-- Declare as many tiers as you like with a unique name -->
<environmentcontrol>
	
	<!-- give an environment a name and a comma delimmited list of url snippets to match -->
	<environment name="development" urls="localhost,cf8cboxdev.jfetmac,cf9cboxdev.jfetmac,railocboxdev.jfetmac">
		<!--ColdBoxSpecific Settings -->
		<Setting name="HandlerCaching"			value="false" />
		<Setting name="HandlersIndexAutoReload" value="true" />
		<Setting name="IOCObjectCaching"		value="false" />
		<Setting name="DebugMode"	 			value="true" />
		<Setting name="DebugPassword" 			value="" />
		<Setting name="ReinitPassword" 			value="" />
		
		<Setting name="EnableColdboxLogging"	value="true" />
		<Setting name="onInvalidEvent"			value="" />
		<Setting name="Cachesettings.FreeMemoryPercentageThreshold" value="0" />
		<!--
			AppSpecific Settings: <Setting name="MySetting" value="Hello" />
		-->		
		
		<Setting name="TierControlFired" value="TRUE" />
		<Setting name="MyBaseURL" value="cf8.jfetmac" />
		
		<!--  Dev Interceptors -->
		<Interceptors>
			<!-- Developer's ColdBox Sidebar -->
			<Interceptor class="coldbox.system.interceptors.ColdboxSideBar" />
		</Interceptors>
		
	</environment>
	
	<!-- give an environment a name and a comma delimmited list of url snippets to match -->
	<environment name="qa" urls="qa">
		<!--ColdBoxSpecific-->
		
		<Setting name="EnableColdboxLogging"	value="true" />
		<Setting name="DebugPassword" 			value="" />
		<Setting name="ReinitPassword" 			value="" />
		
		<!--
			AppSpecific Settings: <Setting name="MySetting" value="Hello" />
		-->

	</environment>
	
</environmentcontrol>