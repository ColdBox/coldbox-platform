<?xml version="1.0" encoding="UTF-8"?>
<!-- Declare as many tiers as you like with a unique name and its corresponding cgi.http_host urls 
	You can also override the following elements:
	- MailServerSettings, IOC,Models,i18n,WebServices,Datasources,DebuggerSettings,LogBox,Interceptors
	-->
<environmentcontrol>
	
	<environment name="development" urls="dev">
		<!--ColdBoxSpecific Settings to override -->
		<Setting name="ColdBoxSideBar" value="true" />
	</environment>
	
	<environment name="qa" urls="qa">
		
	</environment>
	
</environmentcontrol>