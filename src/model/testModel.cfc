<cfcomponent name="testModel" output="false">

	<cffunction name="init" access="public" returntype="testModel" hint="" output="false" >
		<cfscript>
		variables.instance = structnew();
		instance.controller = "";
		instance.configBean = "";
		instance.logger = "";
		return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="getlogger" access="public" output="false" returntype="any" hint="Get logger">
		<cfreturn instance.logger/>
	</cffunction>
	
	<cffunction name="setlogger" access="public" output="false" returntype="void" hint="Set logger">
		<cfargument name="logger" type="any" required="true"/>
		<cfset instance.logger = arguments.logger/>
	</cffunction>
	
	<cffunction name="getcontroller" access="public" output="false" returntype="Any" hint="Get controller">
		<cfreturn instance.controller/>
	</cffunction>
	
	<cffunction name="setcontroller" access="public" output="false" returntype="void" hint="Set controller">
		<cfargument name="controller" type="Any" required="true"/>
		<cfset instance.controller = arguments.controller/>
	</cffunction>
	
	<cffunction name="getconfigBean" access="public" output="false" returntype="Any" hint="Get configBean">
		<cfreturn instance.configBean/>
	</cffunction>
	
	<cffunction name="setconfigBean" access="public" output="false" returntype="void" hint="Set configBean">
		<cfargument name="configBean" type="Any" required="true"/>
		<cfset instance.configBean = arguments.configBean/>
	</cffunction>
	
	<cffunction name="getcacheManager" access="public" output="false" returntype="any" hint="Get cacheManager">
		<cfreturn instance.cacheManager/>
	</cffunction>
	
	<cffunction name="setcacheManager" access="public" output="false" returntype="void" hint="Set cacheManager">
		<cfargument name="cacheManager" type="any" required="true"/>
		<cfset instance.cacheManager = arguments.cacheManager/>
	</cffunction>

</cfcomponent>