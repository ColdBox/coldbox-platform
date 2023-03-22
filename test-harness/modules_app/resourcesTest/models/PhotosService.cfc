component singleton{

	function init(){
		variables.data = [
			{ "id" : createUUID(), "title" : "hola.png" },
			{ "id" : createUUID(), "title" : "tests.png" },
			{ "id" : createUUID(), "title" : "asdfasd.png" }
		];
		return this;
	}

	function list(){
		return variables.data;
	}

}
