<cfscript>

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
    	eventHandling 	  	=  false,
    	dialect				= 'MySQL'
    };

</cfscript>