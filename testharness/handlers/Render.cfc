<cfcomponent output="false">
<cfscript>

	this.aroundHandler_except = "json";

	function wddx(event){
		var data = {
			name="luis",age="33", cool=true
		};
		event.renderdata(type="wddx",data=data);
	}
	
	function plain(event){
		event.renderdata(type="plain",data="<h1>Hello HTML</h1>");
	}
	function html(event){
		event.renderdata(type="html",data="<h1>Hello HTML</h1>");
	}
	
	function json(event){
		var data = {
			name="luis",age="33", cool=true
		};
		event.renderdata(type="json",data=data,jsonCase="upper",jsonAsText=true);
	}
	
	function text(event){
		event.renderdata(type="text",data="this is some cool text");
	}
	
	function xml(event){
		q = queryNew("ID,NAME");
		queryAddRow(q,1);
		querySetCell(q,"ID", createUUID(),1);
		querySetCell(q,"name", 'luis',1);
		queryAddRow(q,1);
		querySetCell(q,"ID", createUUID(),2);
		querySetCell(q,"name", 'henrik',2);
		
		event.renderdata(type="xml",data=q);
	}
	
	function pass(event,name,cool){
		return "Hello #arguments.name#, you are cool=#arguments.cool#!";
	}
	
	function aroundHandler(event,targetAction,eventArguments){
		log.info("calling around handler with:#arguments.toString()#");
		
		// Call original target
		arguments.targetAction(event);
		
		// hijack it
		event.renderdata(type="html",data="<h1>Hello Around HTML</h1>");
	}
	
	function aroundJSON(event,targetAction,eventArguments){
		log.info("calling around handler with:#arguments.toString()#");
		
		// call original
		arguments.targetAction(event);
		
		// Hijack it and add an element
		var rd = event.getValue(name="cbox_renderdata",private=true);
		rd.data.aroundAdvicePerformed = true;		
	}

</cfscript>			 
</cfcomponent>