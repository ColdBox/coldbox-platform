<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseInterceptorTest" interceptor="coldbox.system.interceptors.CriteriaBuilder">
<cfscript>

	function setup(){
		super.setup();
		criteria   = getMockBox().createMock("coldbox.system.orm.hibernate.CriteriaBuilder");
		criteria.init("User").startSqlLog( true );
		c = interceptor;
	}
	
	function testOnCriteriaBuilderAddition(){
		// add criteria to criteriabuilder
		criteria.isEq("lastName","M%");
		c.onCriteriaBuilderAddition( getMockRequestContext(), {
			"CriteriaBuilder" = criteria,
			"Type" = "Restriction"
		});
		assertTrue( arrayLen( criteria.getSqlLog() )==1 );
	}
	
</cfscript>
</cfcomponent>

