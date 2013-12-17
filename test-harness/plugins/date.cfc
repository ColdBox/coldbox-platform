<cfcomponent name="date" output="false" extends="coldbox.system.Plugin" autowire="true">

	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" type="coldbox.system.web.Controller">
		<cfset super.Init(arguments.controller) />
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getToday" access="public" returntype="string"  output="false">
		<cfreturn dateFormat(now(),"MM/DD/YYYY")>
	</cffunction>
	
	
	<cffunction name="getmyDatasource" access="public" output="false" returntype="any" hint="Get myDatasource">
		<cfreturn instance.myDatasource/>
	</cffunction>
	
	<cffunction name="setmyDatasource" access="public" output="false" returntype="void" hint="Set myDatasource">
		<cfargument name="myDatasource" type="any" required="true"/>
		<cfset instance.myDatasource = arguments.myDatasource/>
	</cffunction>

</cfcomponent>