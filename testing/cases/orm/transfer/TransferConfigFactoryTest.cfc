<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		
		TransferConfigFactory = createObject("component","coldbox.system.orm.transfer.TransferConfigFactory").init();
		
		dsnBean = createObject("component","coldbox.system.core.db.DatasourceBean");		
		memento.name = "mydsn";
		memento.username = "user";
		memento.password = "pass";
		dsnBean.init(memento);
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetTransferConfig" access="public" returntype="void" output="false">
		<cfscript>
			
			config = TransferConfigFactory.getTransferConfig(configPath='config/transfer.xml.cfm',definitionPath='config/definitions',dsnBean=dsnBean);
			
			AssertTrue( isObject(config) );
			
			AssertEquals( config.getDatasourceName(), memento.name);
			
		</cfscript>
	</cffunction>
	
	
	
</cfcomponent>