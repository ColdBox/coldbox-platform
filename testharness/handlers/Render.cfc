<cfcomponent extends="coldbox.system.eventhandler" output="false">
<cfscript>

	function wddx(){
		event.renderdata(type="wddx",data=server);
	}
	
	function plain(){
		event.renderdata(type="plain",data="<h1>Hello HTML</h1>");
	}
	
	function json(){
		event.renderdata(type="json",data=server,jsonCase="upper",jsonAsText=true);
	}
	
	function xml(){
		q = queryNew("ID,NAME");
		queryAddRow(q,1);
		querySetCell(q,"ID", createUUID(),1);
		querySetCell(q,"name", 'luis',1);
		queryAddRow(q,1);
		querySetCell(q,"ID", createUUID(),2);
		querySetCell(q,"name", 'henrik',2);
		
		event.renderdata(type="xml",data=q);
	}
	

</cfscript>			 
</cfcomponent>