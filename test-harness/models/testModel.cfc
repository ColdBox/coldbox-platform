<cfcomponent name="testModel" output="false" singleton="true">
	<cffunction name="init" access="public" returntype="testModel" hint="" output="false">
		<cfscript>
		variables.instance  = structNew();
		instance.controller = "";
		instance.logger     = "";
		instance.datasource = "";
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

	<cffunction name="getcacheManager" access="public" output="false" returntype="any" hint="Get cacheManager">
		<cfreturn instance.cacheManager/>
	</cffunction>

	<cffunction name="setcacheManager" access="public" output="false" returntype="void" hint="Set cacheManager">
		<cfargument name="cacheManager" type="any" required="true"/>
		<cfset instance.cacheManager = arguments.cacheManager/>
	</cffunction>

	<cffunction name="getdatasource" access="public" returntype="any" output="false">
		<cfreturn instance.datasource>
	</cffunction>

	<cffunction name="setdatasource" access="public" returntype="void" output="false">
		<cfargument name="datasource" type="any" required="true">
		<cfset instance.datasource = arguments.datasource>
	</cffunction>

	<cffunction name="getmailSettings" access="public" returntype="any" output="false">
		<cfreturn instance.mailSettings>
	</cffunction>
	<cffunction name="setmailSettings" access="public" returntype="void" output="false">
		<cfargument name="mailSettings" type="any" required="true">
		<cfset instance.mailSettings = arguments.mailSettings>
	</cffunction>

	<cffunction name="getRules" access="public" returntype="query" hint="" output="false">
		<cfscript>
		var qRules = queryNew( "rule_id,securelist,whitelist,roles,redirect" );

		queryAddRow( qRules, 1 );
		querySetCell( qrules, "rule_id", createUUID() );
		querySetCell(
			qrules,
			"securelist",
			"^user\..*, ^admin"
		);
		querySetCell(
			qrules,
			"whitelist",
			"user.login,user.logout,^main.*"
		);
		querySetCell( qrules, "roles", "admin" );
		querySetCell( qrules, "redirect", "user.login" );

		return qRules;
		</cfscript>
	</cffunction>

	<cffunction name="getStringBuffer" access="public" output="false" returntype="any" hint="Get StringBuffer">
		<cfreturn instance.StringBuilder/>
	</cffunction>
	<cffunction name="setStringBuffer" access="public" output="false" returntype="void" hint="Set StringBuffer">
		<cfargument name="StringBuffer" type="any" required="true"/>
		<cfset instance.StringBuilder = arguments.StringBuilder/>
	</cffunction>

	<cffunction name="getupdateWS" access="public" output="false" returntype="any" hint="Get updateWS">
		<cfreturn instance.updateWS/>
	</cffunction>

	<cffunction name="setupdateWS" access="public" output="false" returntype="void" hint="Set updateWS">
		<cfargument name="updateWS" type="any" required="true"/>
		<cfset instance.updateWS = arguments.updateWS/>
	</cffunction>
</cfcomponent>
