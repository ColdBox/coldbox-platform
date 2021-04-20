/**
 * I manage photos
 */
component singleton accessors="true" {

	// Properties


	/**
	 * Constructor
	 */
	PhotosService function init(){
		return this;
	}

	/**
	 * save
	 */
	function save(){
	}

	/**
	 * delete
	 */
	function delete(){
	}

	/**
	 * list
	 */
	function list(){
	}

	/**
	 * get
	 */
	function get(){
	}

	function getRandom(){
		return randRange( 1, 1000 );
	}

}
