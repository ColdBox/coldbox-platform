component {

	property name="photosService" inject="PhotosService";

	function configure(){

		task( "photoNumbers" )
			.call( function(){
				var random = variables.photosService.getRandom();
				writeDump( var="xxxxxxx> Photo numbers: #random#", output="console" );
				return random;
			} )
			.every( 5, "seconds" )
			.onEnvironment( "development" );

	}

}