<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		// LogBox
		logbox = getMockBox().createMock(className="coldbox.system.logging.LogBox");
	}
	
	function testLoader(){
		// My Data Object
		dataConfig = createObject("component","coldbox.testing.cases.logging.config.LogBoxConfig");
		// Config LogBox
		config = createObject("component","coldbox.system.logging.config.LogBoxConfig").init(CFCConfig=dataConfig);
		// Create it
		logBox.init( config );
	}
	
	function testLoader2(){
		// Config LogBox
		config = createObject("component","coldbox.system.logging.config.LogBoxConfig").init(CFCConfigPath="coldbox.testing.cases.logging.config.LogBoxConfig");
		// Create it
		logBox.init( config );
	}
	
	
</cfscript>
</cfcomponent>