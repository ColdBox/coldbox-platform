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
		event.renderdata(type="xml",data=server,xmlRoot="ServerScope");
	}
	

</cfscript>			 
</cfcomponent>