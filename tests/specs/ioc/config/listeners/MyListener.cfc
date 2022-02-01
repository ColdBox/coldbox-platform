component {

	function configure( any wireBox, struct properties ){
		variables.wireBox    = arguments.wireBox;
		variables.properties = arguments.properties;

		variables.log = variables.wireBox.getLogBox().getLogger( this );
	}

	any function afterInjectorConfiguration( struct data ){
		log.info( "#properties.name# -> afterInjectorConfiguration called", arguments.data.toString() );
	}

	any function beforeInstanceCreation( struct data ){
		log.info( "#properties.name# -> beforeInstanceCreation called", arguments.data.toString() );
	}

	any function afterInstanceCreation( struct data ){
		log.info( "#properties.name# -> afterInstanceCreation called", arguments.data.toString() );
	}

}
