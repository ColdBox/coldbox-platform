/**
* I am a new handler
*/
component{
	
	function index(event,rc,prc){
		prc.welcomeMessage = "Welcome to ColdBox!";	
		event.setView("main/index");
	}	
	
}
