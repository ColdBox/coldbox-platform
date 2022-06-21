component{

	property name="data";

	function init(){
		variables.data = [
			{ id : 1, name = "maria" },
			{ id : 2, name = "alexia" },
			{ id : 3, name = "veronica" }
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
