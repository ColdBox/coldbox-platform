<?xml version="1.0" encoding="UTF-8"?>
<!-- Declare as many tiers as you like with a unique name -->
<environmentcontrol>
        
	<!-- give an environment a name and a comma delimited list of url snippets to match -->
	<environment name="development" urls="localhost,cf8apps.lmajano:8080,apps.jfetmac,jfetmac">

		<!--ColdBoxSpecific Settings -->
		<Setting name="HandlerCaching" value="false" />
		<Setting name="HandlersIndexAutoReload" value="false" />
		<Setting name="IOCObjectCaching" value="false" />
		<Setting name="DebugMode" value="false" />
		<Setting name="DebugPassword" value="" />
		<Setting name="ReinitPassword" value="" />
		<Setting name="EnableBugReports" value="false"/>
		<Setting name="EnableDumpVar" value="true" />	
			
		<!-- Show SideBar? true/false, else leave blank. -->
		<Setting name="ColdBoxSideBar" value="true" />
				
	</environment>
        
</environmentcontrol>
