component {

	property name="website" inject="id:WireBoxURL";

	function init(){
		return this;
	}

	function getData(){
		return website;
	}

}
