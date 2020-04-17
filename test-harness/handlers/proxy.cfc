component {

	function getIntroArraysCollection( event, rc, prc ){
		rc.myarray = [ 1, 2, 3, 4, 5 ];
	}

	function getIntroArrays( event, rc, prc ){
		return [ 1, 2, 3 ];
	}

	function getIntroStructure( event, rc, prc ){
		return { name : "Luis", when : now() };
	}

}
