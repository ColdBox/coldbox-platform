component {

	property name="service" inject="entityService:TestCategory";
	
	function index(event){
		
		cats = service.list();
		
		event.renderData(data=cats,type="json",jsonAsText=true);
		
	}

}
