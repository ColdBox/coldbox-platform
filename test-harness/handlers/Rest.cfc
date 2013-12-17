<cfcomponent output="false">
<cfscript>

	function show(event){
		event.renderdata(data="SHOW as GET");
	}
	
	function  update(event){
		event.renderdata(data="UPDATE as PUT");
	}
	
	function  delete(event){
		event.renderdata(data="DELETE as DELETE");
	}
	
	function  save(event){
		event.renderdata(data="SAVE as POST");
	} 

</cfscript>			 
</cfcomponent>