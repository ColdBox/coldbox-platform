<cfcomponent output="false">
<cfscript>

	function wddx(event){
		event.renderdata(type="wddx",data=server);
	}
	
	function plain(event){
		event.renderdata(type="plain",data="<h1>Hello HTML</h1>");
	}
	function html(event){
		event.renderdata(type="html",data="<h1>Hello HTML</h1>");
	}
	
	function json(event){
		event.renderdata(type="json",data=server,jsonCase="upper",jsonAsText=true);
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

</cfscript>			 
</cfcomponent>