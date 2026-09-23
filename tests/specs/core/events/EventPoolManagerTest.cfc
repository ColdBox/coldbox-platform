component name="cfmlengine" extends="coldbox.system.testing.BaseModelTest" {

	function setup(){
		manager = createMock( "coldbox.system.core.events.EventPoolManager" );
		manager.init( [ "onTest" ] );
	}

	function testProperties(){
		assertEquals( manager.getEventStates(), [ "onTest" ] );
		assertEquals( manager.getStopRecursionClasses(), "" );
		assertTrue( structIsEmpty( manager.getEventPoolContainer() ) );

		manager.appendInterceptionPoints( "onError" );
		assertEquals( manager.getEventStates(), listToArray( "onTest,onError" ) );
	}

	function testRegisterUnregister(){
		var event = new tests.resources.Event();

		// 1
		manager.register( event );
		assertEquals( manager.getObject( "Event" ), event );
		assertTrue( isObject( manager.getEventPool( "onTest" ) ) );
		manager.unregister( "Event" );
		try {
			manager.getObject( "Event" );
			fail( "Event still exists" );
		} catch ( "EventPoolManager.ObjectNotFound" e ) {
		} catch ( Any e ) {
			fail( "wrong throw" );
		}

		manager.register( event );

		// 2 type registration
		manager.register( event, "luis" );
		assertEquals( manager.getObject( "luis" ), event );
		assertTrue( isObject( manager.getEventPool( "onTest" ) ) );
		manager.unregister( "luis" );
		try {
			manager.getObject( "luis" );
			fail( "Event still exists" );
		} catch ( "EventPoolManager.ObjectNotFound" e ) {
		} catch ( Any e ) {
			fail( "wrong throw" );
		}

		// 3 type registration
		manager.register( event, "luis", "onCreate" );
		assertEquals( manager.getObject( "luis" ), event );
		assertTrue( isObject( manager.getEventPool( "onCreate" ) ) );
		manager.unregister( "luis" );
		try {
			manager.getObject( "luis" );
			fail( "Event still exists" );
		} catch ( "EventPoolManager.ObjectNotFound" e ) {
		} catch ( Any e ) {
			fail( "wrong throw" );
		}

		// 4 type registration Annotation
		manager.register( event, "luis" );
		assertEquals( manager.getObject( "luis" ), event );
		assertTrue( isObject( manager.getEventPool( "onAnnotation" ) ) );
		manager.unregister( "luis" );
		try {
			manager.getObject( "luis" );
			fail( "Event still exists" );
		} catch ( "EventPoolManager.ObjectNotFound" e ) {
		} catch ( Any e ) {
			fail( "wrong throw" );
		}
	}

	function testAnnouncements(){
		var event = new tests.resources.Event();
		manager.register( event );

		manager.announce( "onAnnotation" );
		manager.announce( "onCreate" );
		manager.announce( "onTest" );

		debug( event.logs );
		assertTrue( arrayLen( event.logs ) );
	}

	function testEventStateIndex(){
		// Verify index is built on init
		expect( manager.getEventStateIndex() ).toHaveKey( "ontest" );
		expect( manager.getEventStateIndex().ontest ).toBeTrue();

		// Verify eventStatesChanged starts as false
		expect( manager.getEventStatesChanged() ).toBeFalse();
	}

	function testAppendInterceptionPointsUsesIndex(){
		var initialCount = arrayLen( manager.getEventStates() );

		// Add new state
		manager.appendInterceptionPoints( "onNewState" );
		expect( arrayLen( manager.getEventStates() ) ).toBe( initialCount + 1 );
		expect( manager.getEventStateIndex() ).toHaveKey( "onnewstate" );
		expect( manager.getEventStatesChanged() ).toBeTrue();

		// Reset flag
		manager.setEventStatesChanged( false );

		// Try to add duplicate (should not add)
		manager.appendInterceptionPoints( "onNewState" );
		expect( arrayLen( manager.getEventStates() ) ).toBe( initialCount + 1 );
		expect( manager.getEventStatesChanged() ).toBeFalse();

		// Try case-insensitive duplicate (should not add)
		manager.appendInterceptionPoints( "ONNEWSTATE" );
		expect( arrayLen( manager.getEventStates() ) ).toBe( initialCount + 1 );
		expect( manager.getEventStatesChanged() ).toBeFalse();
	}

	function testAppendMultipleStatesWithDuplicates(){
		var initialCount = arrayLen( manager.getEventStates() );

		// Add multiple states with duplicates
		manager.appendInterceptionPoints( [ "onState1", "onState2", "onState1", "onState3" ] );

		// Should only add 3 unique states
		expect( arrayLen( manager.getEventStates() ) ).toBe( initialCount + 3 );
		expect( manager.getEventStateIndex() ).toHaveKey( "onstate1" );
		expect( manager.getEventStateIndex() ).toHaveKey( "onstate2" );
		expect( manager.getEventStateIndex() ).toHaveKey( "onstate3" );
		expect( manager.getEventStatesChanged() ).toBeTrue();
	}

	function testParseMetadataUsesIndex(){
		var event = new tests.resources.Event();

		// Register should use index for O(1) lookups
		manager.register( event );

		// Verify the event was registered in the correct pools
		// onTest is in the initial eventStates, onAnnotation has @interceptionPoint
		expect( isObject( manager.getEventPool( "onTest" ) ) ).toBeTrue();
		expect( isObject( manager.getEventPool( "onAnnotation" ) ) ).toBeTrue();
		// onCreate is NOT in eventStates and has no annotation, so no pool created
		expect( manager.getEventPool( "onCreate" ) ).toBeStruct().toBeEmpty();
	}

}
