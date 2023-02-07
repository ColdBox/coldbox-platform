component singleton{

	function init(){
		return this;
	}

	function versionsEnable(){}
	function versionsDisable(){}
	function versionsisEnabled(){}
	function versionslist(){
		return [];
	}
	function versionsRollback(){
		return "version rollback";
	}
	function versionsGet(){
		return "version get";
	}
	function versionsRotate(){}

}
