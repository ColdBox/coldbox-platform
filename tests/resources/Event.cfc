<cfcomponent output="false">
<cfscript>
	this.logs = arrayNew(1);
	
	function onTest(interceptData){
		var data ={stat="onTest", data=interceptData};
		arrayAppend(this.logs, data);
	}
	
	function onCreate(interceptData){
		var data ={stat="onCreate", data=interceptData};
		arrayAppend(this.logs, data);
	}
</cfscript>

	<cffunction name="onAnnotation" output="false" interceptionPoint=true>
		<cfargument name="interceptData" type="struct" required="true" default="" hint=""/>
		<cfscript>
		var data ={stat="onAnnotation", data=interceptData};
		arrayAppend(this.logs, data);
		</cfscript>
	</cffunction>
</cfcomponent>