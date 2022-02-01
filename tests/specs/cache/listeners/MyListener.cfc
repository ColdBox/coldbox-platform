component output="false" {

	function configure( any cacheBox, struct properties ){
		variables.cacheBox   = arguments.cacheBox;
		variables.properties = arguments.properties;

		variables.log = variables.cacheBox.getLogBox().getLogger( this );
	}

	any function afterCacheElementInsert( struct data ){
		log.info( "#properties.name# -> afterCacheElementInsert called", arguments.data.toString() );
	}

	any function beforeCacheShutdown( struct data ){
		log.info( "#properties.name# -> beforeCacheShutdown called", arguments.data.toString() );
	}

	any function afterCacheFactoryConfiguration( struct data ){
		log.info( "#properties.name# -> afterCacheFactoryConfiguration called", arguments.data.toString() );
	}

}
