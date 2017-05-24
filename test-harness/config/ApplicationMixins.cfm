<cfscript>
	// Load local env properties, unless running in Ortus Jenkins
	if( !findNoCase( "/integration", getCurrentTemplatePath() ) ){
		loadRuntimeProperties();
	}

	// Lucee 5 Cache Definition
	this.cache.connections[ "default" ] = {
		  "class" = 'lucee.runtime.cache.ram.RamCache'
		, "storage" = false
		, "custom" = {
			"timeToIdleSeconds" = "0",
			"timeToLiveSeconds" = "0"
		}
		, "default" = 'object'
	};
	
	// ORM Settings For Testing
    this.ormEnabled 	  = true;
    this.datasource		  = "coolblog";
    this.ormSettings	  = {
    	cfclocation 		= "/cbtestharness/models/entities",
    	logSQL 				= false,
    	flushAtRequestEnd 	= false,
    	autoManageSession 	= false,
    	eventHandling 	  	=  false
    };

	private void function loadRuntimeProperties(){
    	//Load our Runtime Properties, which will dynamically create our datasource from config/runtime.properties, if it does not exist
		var customProperties 	= COLDBOX_APP_ROOT_PATH & '/config/runtime.properties.cfm';
		var ciProperties 		= COLDBOX_APP_ROOT_PATH & '/config/runtime.ci.cfm';
		
		// Use ci or custom if found
		var target = ciProperties;
		if( fileExists( customProperties ) ){
			target = customProperties;
		}

		var props = createObject( "java", "java.util.Properties" ).init();
		props.load( createObject( "java", "java.io.FileInputStream" ).init( target ) );

		this.datasources[ "coolblog" ] = {
			// Lucee specific
			class 				= props.getProperty( "DB_CLASS" ),
			connectionString	= props.getProperty( 'DB_CONNECTIONSTRING' ),
			username 			= props.getProperty( 'DB_USER' ),
			password 			= props.getProperty( 'DB_PASSWORD' ),
			// Adobe Specific
			database 			= "coolblog",
			driver 				= "MySQL",
			URL 				= props.getProperty( 'DB_CONNECTIONSTRING' ),
			port 				= "3306"
		};

    }
</cfscript>