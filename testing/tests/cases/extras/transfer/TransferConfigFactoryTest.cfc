<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Request service Test
----------------------------------------------------------------------->
<cfcomponent name="requestserviceTest" extends="coldbox.testing.tests.resources.baseMockCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Call the super setup method to setup the app.
		super.setup();
		
		TransferConfigFactory = createObject("component","coldbox.system.extras.transfer.TransferConfigFactory").init();
		
		dsnBean = createObject("component","coldbox.system.beans.datasourceBean");		
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