<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseInterceptorTest" interceptor="coldbox.system.interceptors.Security">
<cfscript>
		
	function setup(){
		// setup properties
		super.setup();
		security = interceptor;	
	}

	function testConfigure(){
		props = {
			useRegex = true,
			rulesSource = "xml"
		};
		security.setProperties( props );
		security.$("rulesSourceChecks");
		security.configure();
		
		assertEquals( false, security.getProperty("rulesLoaded") );
		assertEquals( [], security.getProperty("rules") );
	}
	
	function testAfterAspectsLoad(){
		// pre event security check
		security.$("unregister",true).setProperty("preEventSecurity",false);
		security.setProperty("rulesSource","");
		security.afterAspectsLoad( getMockRequestContext(), {} );
		assertTrue( security.$once("unregister") );
		
		// load xml
		security.$("loadXMLRules").setProperty("rulesSource","xml");
		security.afterAspectsLoad( getMockRequestContext(), {} );
		assertTrue( security.$once("loadXMLRules") );
		
		// load db
		security.$("loadDBRules").setProperty("rulesSource","db");
		security.afterAspectsLoad( getMockRequestContext(), {} );
		assertTrue( security.$once("loadDBRules") );
		
		// load ioc
		security.$("loadIOCRules").setProperty("rulesSource","ioc");
		security.afterAspectsLoad( getMockRequestContext(), {} );
		assertTrue( security.$once("loadIOCRules") );
		
		// load model
		security.$("loadModelRules").setProperty("rulesSource","model");
		security.afterAspectsLoad( getMockRequestContext(), {} );
		assertTrue( security.$once("loadModelRules") );
	}
	
	function testRegisterValidator(){
		var validator = CreateObject("component","coldbox.testing.testmodel.security");
		
		/* Register */
		security.registerValidator( validator );
		assertEquals( validator, security.getValidator() );
	}

</cfscript>
	
	<cffunction name="testLoggedInUser" access="public" returntype="void" output="false">
		<!--- Login a user --->
		<cflogout>
		<cflogin>
			<cfloginUser name="Luis" password="luis" roles="admin">
		</cflogin>
		
		<cfscript>
		url.event = 'admin.user.list';
		mockContext = getMockRequestContext();
		//security.preProcess( mockContext, {} );
		
		//Assert Relocation, first test should be blank.
		assertEquals( "", mockContext.getValue("setnextevent",""), "User is in role, no redirection." );
		</cfscript>
		<!--- logout again. --->
		<cflogout>
		<cfreturn>
	</cffunction>
	
	<cffunction name="getRules" access="private" returntype="query" hint="" output="false" >
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
	
</cfcomponent>