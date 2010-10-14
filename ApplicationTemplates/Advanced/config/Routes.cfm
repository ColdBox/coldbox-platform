<cfscript>
	// Allow unique URL or combination (false)
	setUniqueURLS(false);
	// Auto reload configuration, true in dev makes sense
	//setAutoReload(false);
	// Sets automatic route extension detection and places the extension in the rc.format
	// setExtensionDetection(true)
	// setValidExtensions('xml,json,jsont,rss,html,htm');
	
	// Base URL
	if( len(getSetting('AppMapping') ) lte 1){
		setBaseURL("http://#cgi.HTTP_HOST#/index.cfm");
	}
	else{
		setBaseURL("http://#cgi.HTTP_HOST#/#getSetting('AppMapping')#/index.cfm");
	}
	
	// Module Routing Added
	addModuleRoutes(pattern="/forgebox",module="forgebox");
	
	// Your Application Routes
	addRoute(pattern=":handler/:action?");
</cfscript>