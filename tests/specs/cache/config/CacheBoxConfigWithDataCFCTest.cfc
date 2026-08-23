component extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		// cacheBox = createMock(className="coldbox.system.logging.LogBox" );
		dataConfigPath = "coldbox.tests.resources.CacheBoxConfigData";
	}

	function testLoadsMinimalDataDSLThroughPublicAPI(){
		var config = new coldbox.system.cache.config.CacheBoxConfig()
			.init()
			.loadDataDSL( { "defaultCache" : { "coldboxEnabled" : false } } );
		var memento = config.getMemento();

		assertFalse( structIsEmpty( memento.defaultCache ) );
		assertTrue( structIsEmpty( memento.caches ) );
		assertTrue( arrayIsEmpty( memento.listeners ) );
	}

	function testLoader(){
		// My Data Object
		dataConfig = createObject( "component", dataConfigPath );
		// Config LogBox
		config     = createObject( "component", "coldbox.system.cache.config.CacheBoxConfig" ).init(
			CFCConfig = dataConfig
		);
		// Create it
		// cacheBox.init( config );

		memento = config.getMemento();
		// debug(memento);

		assertFalse( structIsEmpty( memento.caches ) );
		assertTrue( structKeyExists( memento.caches, "SampleCache1" ) );
		assertTrue( structKeyExists( memento.caches, "SampleCache2" ) );
		assertTrue( arrayLen( memento.listeners ) );
		assertTrue( len( memento.logBoxConfig ) );
		assertEquals( "cacheBoxAwesome", memento.scopeRegistration.key );
		assertEquals( "coldbox.system.cache.config.LogBox", memento.logBoxConfig );

		config.validate();
	}

	function testLoader2(){
		// Config LogBox
		config = createObject( "component", "coldbox.system.cache.config.CacheBoxConfig" ).init(
			CFCConfigPath = dataConfigPath
		);
		// Create it
		// cacheBox.init( config );

		memento = config.getMemento();
		// debug(memento);

		assertFalse( structIsEmpty( memento.caches ) );
		assertTrue( structKeyExists( memento.caches, "SampleCache1" ) );
		assertTrue( structKeyExists( memento.caches, "SampleCache2" ) );
		assertTrue( arrayLen( memento.listeners ) );
		assertTrue( len( memento.logBoxConfig ) );
		assertEquals( "cacheBoxAwesome", memento.scopeRegistration.key );
		assertEquals( "coldbox.system.cache.config.LogBox", memento.logBoxConfig );


		config.validate();
	}

}
