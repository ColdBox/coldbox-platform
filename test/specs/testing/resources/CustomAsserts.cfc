component{

	function assertIsAwesome( expected, actual ){
		return ( expected eq actual ? true : false );
	}

	function assertIsFunky( actual ){
		return ( actual gte 100 ? true : false );
	}

}