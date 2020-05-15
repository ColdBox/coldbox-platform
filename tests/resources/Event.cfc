<cfcomponent output="false">
	<cfscript>
	this.logs = arrayNew( 1 );

	function onTest( data ){
		var localData = {
			stat : "onTest",
			data : data
		};
		arrayAppend( this.logs, localData );
	}

	function onCreate( data ){
		var localData = {
			stat : "onCreate",
			data : data
		};
		arrayAppend( this.logs, localData );
	}
	</cfscript>

	<cffunction name="onAnnotation" output="false" interceptionPoint=true>
		<cfargument name="data" type="struct" required="true" default="" hint=""/>
		<cfscript>
		var localData = {
			stat : "onAnnotation",
			data : data
		};
		arrayAppend( this.logs, localData );
		</cfscript>
	</cffunction>
</cfcomponent>
