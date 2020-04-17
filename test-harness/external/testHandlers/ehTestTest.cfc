<!-----------------------------------------------------------------------Author 	 :	Luis MajanoDate     :	September 25, 2005Description :	General handler for my hello application. Please remember to alter	your extends base component using the Coldfusion Mapping.	example:		Mapping: fwsample		Argument Type: fwsample.system.EventHandlerModification History:Sep/25/2005 - Luis Majano	-Created the template.-----------------------------------------------------------------------><cfcomponent extends="coldbox.system.testing.BaseHandlerTest" handler="coldbox.test.testHandlers.ehTest">
	<cfscript>
	function setup(){
		super.setup();
	}
	function testdspExternal(){
		handler.dspExternal( mockRequestContext );
	}
	</cfscript>
</cfcomponent>
