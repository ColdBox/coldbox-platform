component{

	function index(event,rc,prc){
		var simple 	= getModel( "Simple@MyConventionsTest" );
		rc.data 	= simple.getData();
		event.setView("test/index");
	}

}