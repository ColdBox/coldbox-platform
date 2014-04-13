<cfcomponent name="testService" output="false" >

	<cfscript>
		instance = structnew();
		instance.testGateway = 0;
	</cfscript>
	
	<cffunction name="gettestGateway" access="public" output="false" returntype="any" hint="Get testGateway">
		<cfreturn instance.testGateway/>
	</cffunction>
	
	<cffunction name="settestGateway" access="public" output="false" returntype="void" hint="Set testGateway">
		<cfargument name="testGateway" type="any" required="true"/>
		<cfset instance.testGateway = arguments.testGateway/>
	</cffunction>

</cfcomponent>