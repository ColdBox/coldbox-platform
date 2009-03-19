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
	<cffunction name="init" access="public" returntype="TransferConfigFactory" hint="Constructor.">
		<cfreturn this>
	</cffunction>

<!---------------------------------------- PUBLIC --------------------------------------------------->
	
	<cffunction name="getTransferConfig" access="public" returntype="any" output="false" hint="Get a Transfer Config Object with ColdBox settings.">
	    <!--- ************************************************************* --->
		<cfargument name="datasourcePath"     type="string"   required="false"  default="" hint="The transfer datasource file path, in our case, not needed."/>
		<cfargument name="configPath"         type="string"   required="false"  default="" hint="The transfer configuration file path"/>
		<cfargument name="definitionPath"     type="string"   required="false"  default="" hint="The transfer definition path"/>
		<cfargument name="dsnBean"            type="coldbox.system.beans.datasourceBean" required="true" hint="The coldbox datasource bean" />
		<cfargument name="configClassPath" 	  type="string"   required="false"	default="transfer.com.config.Configuration" hint="The default transfer configuration object. Alter at will."/>
		<!--- ************************************************************* --->
		<cfscript>
			/* Create Transfer Config */
			var TransferConfig = CreateObject("component",arguments.configClassPath).init(argumentCollection=arguments);
			
			/* Setup the datasource via ColdBox */
			TransferConfig.setDatasourceName(arguments.dsnBean.getName());
			TransferConfig.setDatasourceUsername(arguments.dsnBean.getUsername());
			TransferConfig.setDatasourcePassword(arguments.dsnBean.getPassword());
			
			/* Return Transfer Configuration */
			return TransferConfig;
		</cfscript>
	</cffunction>
	
</cfcomponent>