<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Declare as many tiers as you like with a unique name -->
<environmentcontrol>
	
	<environment name="development">
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

		<Setting name="TierControlFired" value="TRUE" />
	</environment>
	
	<environment name="qa">
		<!--ColdBoxSpecific-->
		<Setting name="EnableDumpVar"			value="true" />
		<Setting name="EnableColdboxLogging"	value="true" />
		<Setting name="DebugPassword" 			value="" />
		<Setting name="ReinitPassword" 			value="" />
		
		<!--
			AppSpecific Settings: <Setting name="MySetting" value="Hello" />
		-->

	</environment>
	
</environmentcontrol>