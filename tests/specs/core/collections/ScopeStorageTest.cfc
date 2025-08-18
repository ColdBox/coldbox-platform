component extends="coldbox.system.testing.BaseModelTest"{

	function setup(){
		this.loadColdbox = false;
		variables.scope            = new coldbox.system.core.collections.ScopeStorage();
	}

	function testPut(){
		scope.put( "test", true, "session" );
		assertTrue( scope.exists( "test", "session" ) );
		structDelete( session, "test" );
	}

	function testDelete(){
		server.luis = "cool";
		assertTrue( scope.delete( "luis", "server" ) );
		assertFalse( scope.delete( "luis", "server" ) );
	}

	function testExists(){
		assertFalse( scope.exists( "test", "session" ) );
		application.test = "test";
		assertTrue( scope.exists( key = "test", scope = "application" ) );
		structDelete( application, "test" );
	}

	function testGet(){
		application.test = "test";

		assertEquals( scope.get( key = "test", scope = "application" ), "test" );
		structDelete( application, "test" );
		assertEquals( scope.get( "test", "session", "false" ), false );

		try {
			scope.get( "test", "session" );
			fail( "fails" );
		} catch ( Any e ) {
			// debug(e);
			if ( e.type neq "ScopeStorage.KeyNotFound" ) {
				fail( "failed exception #e.type#" );
			}
		}

	}


	private function getScope(){
		scope.getScope( "session" );
		scope.getScope( "application" );
		scope.getScope( "server" );
		scope.getScope( "client" );
		scope.getScope( "cookie" );
	}

	private function isLucee6(){
		return server.keyExists( "lucee" ) && left( server.lucee.version, 1 ) == 6;
	}

}