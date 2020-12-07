component mappedSuperClass="true" {

	property
		name      ="website"
		inject    ="id:WireBoxURL"
		persistent="false";
	property name="testValue" notnull="false";

	function init(){
		return this;
	}

	function getData(){
		return website;
	}

}
