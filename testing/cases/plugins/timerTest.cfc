<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	April 04, 2008
Description :
	timerTest
----------------------------------------------------------------------->
<cfcomponent name="timerTest" extends="coldbox.system.testing.BaseTestCase" output="false">
<cfscript>
	function setup(){
		timer = getMockBox().createMock("coldbox.system.plugins.Timer");
		MockController = getMockBox().createMock("coldbox.system.testing.mock.web.MockController").init( expandPath(".") );
	}
	
	function testTimers(){
	
	}

</cfscript>
</cfcomponent>
