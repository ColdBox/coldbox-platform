/**
 * InterceptorBuffer tests
 */
component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.web.context.InterceptorBuffer" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
	}

	/**
	 * executes after all suites+specs in the run() method
	 */
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		describe( "InterceptorBuffer Suites", function(){
			beforeEach( function( currentSpec ){
				setup();
				variables.buffer = model.init();
			} );

			it( "starts with no content", function(){
				expect( buffer.hasContent() ).toBeFalse();
				expect( buffer.getString() ).toBe( "" );
				expect( buffer.length() ).toBe( 0 );
			} );

			it( "can lazily create the underlying builder via get()", function(){
				expect( buffer.hasContent() ).toBeFalse();
				var builder = buffer.get();
				expect( isInstanceOf( builder, "java.lang.StringBuilder" ) ).toBeTrue();
				expect( buffer.hasContent() ).toBeTrue();
			} );

			it( "can append content", function(){
				buffer.append( "Hello" );
				expect( buffer.hasContent() ).toBeTrue();
				expect( buffer.getString() ).toBe( "Hello" );
				expect( buffer.length() ).toBe( 5 );
			} );

			it( "can append multiple times", function(){
				buffer.append( "Hello" );
				buffer.append( " " );
				buffer.append( "World" );
				expect( buffer.getString() ).toBe( "Hello World" );
				expect( buffer.length() ).toBe( 11 );
			} );

			it( "can clear buffered content", function(){
				buffer.append( "some content" );
				expect( buffer.hasContent() ).toBeTrue();
				expect( buffer.length() ).toBeGT( 0 );

				buffer.clear();
				// Builder still exists after clear, just emptied
				expect( buffer.hasContent() ).toBeTrue();
				expect( buffer.getString() ).toBe( "" );
				expect( buffer.length() ).toBe( 0 );
			} );

			it( "returns empty string from getString when no content exists", function(){
				expect( buffer.getString() ).toBe( "" );
			} );

			it( "supports keyExists for backwards compatibility", function(){
				// No builder yet, keyExists should be false
				expect( buffer.keyExists( "builder" ) ).toBeFalse();
				expect( buffer.keyExists( "other" ) ).toBeFalse();

				// Create the builder
				buffer.get();
				expect( buffer.keyExists( "builder" ) ).toBeTrue();
				expect( buffer.keyExists( "other" ) ).toBeFalse();
			} );

			it( "supports method chaining on append and clear", function(){
				var result = buffer.append( "test" );
				expect( result ).toBe( buffer );

				result = buffer.clear();
				expect( result ).toBe( buffer );
			} );

			it( "can handle empty string appends", function(){
				buffer.append( "" );
				expect( buffer.hasContent() ).toBeTrue();
				expect( buffer.getString() ).toBe( "" );
				expect( buffer.length() ).toBe( 0 );
			} );
		} );
	}

}
