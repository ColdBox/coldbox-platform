<cfscript>
	// Allow unique URL or combination of URLs, we recommend both enabled
	setUniqueURLS(false);
	
	// This method should work as it is left for comatibility in ColdBox 5
	setAutoReload(false);

	// Sets automatic route extension detection and places the extension in the rc.format variable
	// setExtensionDetection(true);
	// The valid extensions this interceptor will detect
	// setValidExtensions('xml,json,jsont,rss,html,htm');
	// If enabled, the interceptor will throw a 406 exception that an invalid format was detected or just ignore it
	// setThrowOnInvalidExtension(true);
	
	
	// Your Application Routes
	addRoute( pattern=":handler/:action?" );
</cfscript>