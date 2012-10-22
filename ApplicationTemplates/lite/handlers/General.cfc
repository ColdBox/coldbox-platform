/**
* I am a new handler
*/
component{
	
	function index(event,rc,prc){
		rc.welcomeMessage = "Welcome to ColdBox!";	
		event.setVsiew("General/index");
	}	
	function testReturn(event,rc,prc){
		return "Hello from ColdBox Lite!";
	}
	
	function testRenderData(event,rc,prc){
		event.renderData(type="html", data="hello");
	}
	
	function testRenderData2(event,rc,prc){
		event.paramValue("format", "json");
		var data = { name="Luis", lastName = "Majano", today=now(), children = [ "Alexia" ] };
		event.renderData(type="#rc.format#", data=data);
	}

}
