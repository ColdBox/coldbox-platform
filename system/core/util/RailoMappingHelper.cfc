component{

	/**
	* Railo caches app mappings, but gives us a method to update them via the application "tag"
	*/
	function addMapping( required string name, required string path ) {
		var mappings = getApplicationSettings().mappings;
		mappings[ arguments.name ] = arguments.path;
		application action='update' mappings='#mappings#';
	}

}