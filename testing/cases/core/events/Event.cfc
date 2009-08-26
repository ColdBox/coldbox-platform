<cfcomponent output="false">
<cfscript>
	this.logs = arrayNew(1);
	
	function onTest(interceptData){
		arrayAppend(this.logs, interceptData);
	}
	
	function onCreate(interceptData){
		arrayAppend(this.logs, interceptData);
	}
</cfscript>
</cfcomponent>