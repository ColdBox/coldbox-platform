<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Declare as many tiers as you like with a unique name -->
<environmentcontrol>
	<environment name="development" urls="localhost,dev.cf8ajax.com">
		<!--ColdBoxSpecific Settings -->
		<Setting name="ReinitPassword"			value="" />
		<Setting name="DebugMode"	 			value="true" />
		<Setting name="EnableDumpVar"			value="true" />
		<Setting name="EnableColdboxLogging"	value="true" />
		<Setting name="ConfigAutoReload"        value="true" />
		<Setting name="HandlerCaching" 			value="false"/>
		
		<!-- custom settigns  -->
	</environment>

	<environment name="staging" urls="staging.realestate.com">
		<!--ColdBoxSpecific Settings -->
		<Setting name="BaseURL"	value="http://staging.cf8ajax.com/" />
		<!-- custom settigns  -->
	</environment>
	
	<environment name="live" urls="www.realestate.com">
		<!--ColdBoxSpecific Settings -->
		<Setting name="BaseURL"	value="http://www.cf8ajax.com/" />
		<!-- custom settigns  -->
	</environment>
	
</environmentcontrol>
