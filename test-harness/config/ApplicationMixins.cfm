<cfscript>

	/**
	 * Fixes JAXBContext classloader issue with Lucee running the Hibernate 5.4 extension on CommandBox.
	 * 
	 * Can remove this If and Only If:
	 * a) Lucee gets their act together, or 
	 * b) everyone upgrades to CommandBox 5.8.x or newer.
	 */
	createObject( "java", "java.lang.System" )
			.setProperty(
				"javax.xml.bind.context.factory", 
				"com.sun.xml.bind.v2.ContextFactory"
			);

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
    	eventHandling 	  	= true,
		eventHandler 		= "cbtestharness.models.entities.EventHandler",
    	dialect				= 'MySQL'
    };

</cfscript>
