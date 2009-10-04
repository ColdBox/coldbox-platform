<?xml version="1.0" encoding="UTF-8"?>
<!-- Declare as many tiers as you like with a unique name and its corresponding cgi.http_host urls -->
<environmentcontrol>
	
	<environment name="development" urls="dev">
		<!--ColdBoxSpecific Settings to override -->
		
		
		<!--
			AppSpecific Settings to override: <Setting name="MySetting" value="Hello" />
		-->		

		<Setting name="ColdBoxSideBar" value="true" />
	</environment>
	
	<environment name="qa" urls="qa">
		<!--ColdBoxSpecific to override-->
		
		<!--
			AppSpecific Settings to override: <Setting name="MySetting" value="Hello" />
		-->

	</environment>
	
</environmentcontrol>