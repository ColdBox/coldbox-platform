<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Template : TransferConfigFactory.cfc
Author 	 : Luis Majano
Date     : 7/23/2008
Description :
	
	This is a special transfer configuration object to use ColdBox datasources.
	
---------------------------------------------------------------------->
<cfcomponent displayname="TransferConfigFactory" hint="Creates a Transfer Configuration Bean using ColdBox Data" output="false">

<!---------------------------------------- CONSTRUCTOR --------------------------------------------------->
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<!--- Init --->
	<cffunction name="init" access="public" returntype="any" hint="Constructor.">
		<cfreturn this>
	</cffunction>

<!---------------------------------------- PUBLIC --------------------------------------------------->
	
	<cffunction name="getTransferConfig" hint="Constructor" access="public" returntype="transfer.com.config.Configuration" output="false">
	    <!--- ************************************************************* --->
		<cfargument name="datasourcePath"     type="string"   required="no"   default="" />
		<cfargument name="configPath"         type="string"   required="no"   default="" />
		<cfargument name="definitionPath"     type="string"   required="no"   default="" />
		<cfargument name="dsnBean"            type="coldbox.system.beans.datasourceBean" required="true" />
		<!--- ************************************************************* --->
		<cfscript>
			/* Create Transfer Config */
			var TransferConfig = CreateObject("component","transfer.com.config.Configuration").init(argumentCollection=arguments);
			
			/* Setup the datasource via ColdBox */
			TransferConfig.setDatasourceName(arguments.dsnBean.getName());
			TransferConfig.setDatasourceUsername(arguments.dsnBean.getUsername());
			TransferConfig.setDatasourcePassword(arguments.dsnBean.getPassword());
			
			/* Return Transfer Configuration */
			return TransferConfig;
		</cfscript>
	</cffunction>
	
</cfcomponent>