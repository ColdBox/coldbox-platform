<cfcomponent name="cfmlengine" output="false" extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		util = CreateObject("component","coldbox.system.core.util.Util");
	}
	
	function isInstanceCheck(){
		test = createObject("component","coldbox.testing.testhandlers.BaseTest");
		assertTrue( util.isInstanceCheck( test, "coldbox.system.EventHandler") );
		
		test = createObject("component","coldbox.testing.testhandlers.ehTest");
		assertTrue( util.isInstanceCheck( test, "coldbox.system.EventHandler") );
		
		test = createObject("component","coldbox.testing.testhandlers.TestNoInheritance");
		assertFalse( util.isInstanceCheck( test, "coldbox.system.EventHandler") );		
	}
	
</cfscript>
</cfcomponent>