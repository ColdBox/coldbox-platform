component{

	property name="isWorking";

	function init(){
		variables.isWorking = false;
		return this;
	}

	function work(){
		variables.isWorking = true;
		return this;
	}

	function vacation(){
		variables.isWorking = false;
		return this;
	}

	function sayHello(){
		return $parent.getOutput();
	}

}
