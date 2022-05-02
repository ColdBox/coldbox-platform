component{

	property name="data";

	function init(){
		variables.data = [
			{ id : 1, name = "luis" },
			{ id : 2, name = "bob" },
			{ id : 3, name = "joe" }
		];
		return this;
	}

	function read( index ){
		return variables.data[ arguments.index ];
	}

	function write( data ){
		variables.data.append( arguments.data );
		return this;
	}

}
