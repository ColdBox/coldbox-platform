component accessors = true{

	property name="testGateway" inject="testGateway";

	function init(){
		variables.testGateway = 0;
		return this;
	}
}
