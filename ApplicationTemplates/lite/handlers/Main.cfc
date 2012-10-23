/**
* I am a new handler
*/
component{
	
	function index(event,rc,prc){
		rc.welcomeMessage = "Welcome to ColdBox!";	
		event.setView("General/index");
	}	
	
}
