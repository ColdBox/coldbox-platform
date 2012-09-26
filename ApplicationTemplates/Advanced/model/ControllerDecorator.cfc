component extends="coldbox.system.web.ControllerDecorator" {
	
	this.decorator = "true";

	function configure(){
		//writeDump( "In decorator" );abort;	
	}

	function setNextEvent(){
		writeDump("hello");abort;
	}
	
} 