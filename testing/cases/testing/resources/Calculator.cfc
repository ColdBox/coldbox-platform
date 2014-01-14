component{
	
	function init(){
		return this;
	}

	function add(a,b){
		return a+b;
	}

	function subtract(a,b){
		return a-b;
	}

	function multiply(a,b){
		return a*b;
	}

	function divide(a,b){
		return a/b;
	}

	function divideNoMessage(a,b){
		throw(type="DivideByZero");
	}

	function divideWithDetail(a,b){
		throw(type="DivideByZero", message="Can't divide by zero", detail="This is impossible");
	}

}