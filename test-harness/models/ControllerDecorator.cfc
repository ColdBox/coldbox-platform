component extends="coldbox.system.web.ControllerDecorator" {

	this.decorator = "true";

	function configure(){
	}

	function runEvent(){
		getLogBox().getLogger( this ).info(" Called decorator runEvent(#arguments.toString()#)" );
		return getController().runEvent(argumentCollection=arguments);
	}

}