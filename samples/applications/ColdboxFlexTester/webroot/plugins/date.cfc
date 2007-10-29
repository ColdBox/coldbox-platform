<cfcomponent name="date" output="false" extends="coldbox.system.plugin">

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" type="coldbox.system.controller">
		<cfset super.Init(arguments.controller) />
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getToday" access="public" returntype="string"  output="false">
		<cfreturn dateFormat(now(),"MM/DD/YYYY")>
	</cffunction>

</cfcomponent>