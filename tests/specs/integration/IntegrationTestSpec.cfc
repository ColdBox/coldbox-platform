component extends="coldbox.system.testing.BaseTestCase" appMapping="/cbTestHarness" {

    function run() {
        describe( "coldbox integration test helpers", function() {
            describe( "whileSwapped WireBox helper", function() {
                it( "can swap out a WireBox mapping inside a closure", function() {
                    var mappingName = "test-mapping";
                    var originalInstance = new tests.resources.Class1();
                    var newInstance = new tests.resources.Class2();
                    getWireBox().getBinder().map( mappingName ).toValue( originalInstance );

                    expect( getWireBox().getInstance( mappingName ) ).toBe( originalInstance );
                    expect( getWireBox().getInstance( mappingName ) ).notToBe( newInstance );

                    whileSwapped( { "#mappingName#" = newInstance }, function() {
                        expect( getWireBox().getInstance( mappingName ) ).toBe( newInstance );
                        expect( getWireBox().getInstance( mappingName ) ).notToBe( originalInstance );
                    } );

                    expect( getWireBox().getInstance( mappingName ) ).toBe( originalInstance );
                    expect( getWireBox().getInstance( mappingName ) ).notToBe( newInstance );
                } );

                it( "verifies the mapping exists before swapping it out", function() {
                    var mappingName = "does-not-exist";
                    var newInstance = new tests.resources.Class2();

                    expect( function() {
                        whileSwapped( { "#mappingName#" = newInstance }, function() {
                            fail( "Test should have failed because the mapping [#mappingName#] does not exist in WireBox." );
                        } );
                    } ).toThrow( regex = "No mapping \[#mappingName#\] already configured in WireBox\." );
                } );

                it( "can skip verifying the mapping exists before swapping it out", function() {
                    var mappingName = "does-not-exist";
                    var newInstance = new tests.resources.Class2();

                    expect( function() {
                        whileSwapped( { "#mappingName#" = newInstance }, function() {
                            expect( getWireBox().getInstance( mappingName ) ).toBe( newInstance );
                        }, false );
                    } ).notToThrow( regex = "No mapping \[#mappingName#\] already configured in WireBox\." );
                } );

                it( "sets back the mappings even if there is an exception inside the closure", function() {
                    var mappingName = "test-mapping";
                    var originalInstance = new tests.resources.Class1();
                    var newInstance = new tests.resources.Class2();
                    getWireBox().getBinder().map( mappingName ).toValue( originalInstance );

                    expect( getWireBox().getInstance( mappingName ) ).toBe( originalInstance );
                    expect( getWireBox().getInstance( mappingName ) ).notToBe( newInstance );

                    try {
                        whileSwapped( { "#mappingName#" = newInstance }, function() {
                            throw( "Boom! Some error" );
                        } );
                    } catch ( any e ) {
                        expect( getWireBox().getInstance( mappingName ) ).toBe( originalInstance );
                        expect( getWireBox().getInstance( mappingName ) ).notToBe( newInstance );
                        return;
                    }

                    fail( "Should have gone in to the catch block and finished the test" );
                } );
            } );
        } );
    }

}
