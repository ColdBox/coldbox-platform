component{

	property name="website" inject="id:WireBoxURL" persistent="false";

	function init(){
		return this;
	}

	function getData(){
		return website;
	}

}