﻿<cfcomponent extends="coldbox.system.testing.BaseModelTest">
<cfscript>
	
	function setup(){
		config = createMock( "coldbox.system.ioc.config.DefaultBinder" );
	}

	function testConfigure(){
		config.configure();
	}
</cfscript>
</cfcomponent>