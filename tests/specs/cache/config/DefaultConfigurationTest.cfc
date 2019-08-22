<cfcomponent extends="coldbox.system.testing.BaseModelTest">
	<cfscript>
	function setup(){
		config = createMock( "coldbox.system.cache.config.DefaultConfiguration" );
	}

	function testConfigure(){
		config.configure();
	}
	</cfscript>
</cfcomponent>
