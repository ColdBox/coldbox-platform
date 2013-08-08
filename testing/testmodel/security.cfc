<cfcomponent output="false" cache="true" cachetimeout="5" cacheLastAccessTimeout="1"> 

<!--- Some Autowire stuff --->
<cfproperty name="myMailSettings" type="ioc">
<cfproperty name="myDatasource" type="ioc" scope="instance">
<cfproperty name="loggerPlugin" type="ioc" scope="this">

	<!--- Setter INjection Test. --->
	<cffunction name="setMyDatasource" access="public" output="false" returntype="void" hint="Set MyDatasource">
		<cfargument name="MyDatasource" type="any" required="true"/>
		<cfset variables.setterInjection.MyDatasource = arguments.MyDatasource/>
	</cffunction>

	<cffunction name="init" access="public" returntype="security" hint="" output="false" >
		<cfscript>
		return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="getRules" access="public" returntype="query" hint="" output="false" >
		<cfscript>
			var qRules = querynew("rule_id,securelist,whitelist,roles,permissions,redirect");
			
			QueryAddRow(qRules,1);
			QuerySetcell(qrules,"rule_id",createUUID());
			QuerySetcell(qrules,"securelist","^user\..*, ^admin");
			QuerySetcell(qrules,"whitelist","user.login,user.logout,^main.*");
			QuerySetcell(qrules,"roles","admin");	
			QuerySetcell(qrules,"permissions","WRITE");	
			QuerySetcell(qrules,"redirect","user.login");
						
			return qRules;
		</cfscript>	
	</cffunction>
	
	
	<cffunction name="userValidator" access="public" returntype="boolean" hint="Validate a user" output="false" >
		<cfargument name="rule" required="true" type="struct" hint="">
		<cfreturn true>
	</cffunction>
</cfcomponent>