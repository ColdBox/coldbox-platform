component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Framework Super Type", function(){
			beforeEach( function( currentSpec ){
				setup();

				target = prepareMock( new coldbox.system.FrameworkSupertype() ).setController( getController() );
			} );

			it( "can retrieve the async manager", function(){
				expect( target.async() ).toBeComponent();
			} );

			story( "it can use the back() function to return to the previous URI", function(){
				given( "no previous referer", function(){
					then( "it should use the fallback", function(){
						var fallback = "main.dashboard";
						var mockContext = getMockRequestContext();
						mockContext.getHTTPHeader = function( header, defaultValue ){
							return defaultValue;
						};
						target.$( "relocate" ).$( "getRequestContext", mockContext );
						target.back( fallback );
						expect( target.$callLog().relocate[ 1 ].url ).toInclude( "dashboard" );
					});
				});
				given( "a previous referer", function(){
					then( "it should use the referer", function(){
						var mockContext = getMockRequestContext();
						mockContext.getHTTPHeader = function( header, defaultValue ){
							return "http://localhost/luis/majano";
						};
						target.$( "relocate" ).$( "getRequestContext", mockContext );
						target.back();
						expect( target.$callLog().relocate[ 1 ].url ).toInclude( "majano" );
					});
				});
			});

			story( "should encode data for binding to html attributes", function(){
				given( "a simple value", function(){
					then( "it should encode it", function(){
						var data = "Welcome's you to > appreciation < of ^&+ life.""";
						expect( target.forAttribute( data ) ).toBe( encodeForHTMLAttribute( data ) );
					} );
				} );
				given( "a complex value", function(){
					then( "it should encode it", function(){
						var data = {
							now  : now(),
							data : "hello's welcome <html>data</html>"""
						};
						expect( target.forAttribute( data ) ).toBe(
							encodeForHTMLAttribute( serializeJSON( data ) )
						);
					} );
				} );
			} );

			story( "can do object population from many input sources", function(){
				it( "from the request collection", function(){
					var rc   = getRequestContext().getCollection();
					rc.fname = "luis";
					rc.lname = "majano";

					var target = getInterceptor( "Test1" );
					var oBean  = target.populateModel( "formBean" );
					expect( oBean.getFname() ).toBe( "luis" );
					expect( oBean.getLname() ).toBe( "majano" );
				} );

				it( "from inline structs", function(){
					var test = { fname : "luis", lname : "majano" };

					var target = getInterceptor( "Test1" );
					var oBean  = target.populateModel( model = "formBean", memento = test );
					expect( oBean.getFname() ).toBe( "luis" );
					expect( oBean.getLname() ).toBe( "majano" );
				} );

				it( "from json", function(){
					var test = serializeJSON( { "fname" : "luis", "lname" : "majano" } );

					var target = getInterceptor( "Test1" );
					var oBean  = target.populateModel( model = "formBean", jsonstring = test );
					expect( oBean.getFname() ).toBe( "luis" );
					expect( oBean.getLname() ).toBe( "majano" );
				} );

				it( "from xml", function(){
					var test = "<root><fname>luis</fname><lname>majano</lname></root>";

					var target = getInterceptor( "Test1" );
					var oBean  = target.populateModel( model = "formBean", xml = test );
					expect( oBean.getFname() ).toBe( "luis" );
					expect( oBean.getLname() ).toBe( "majano" );
				} );

				it( "from query", function(){
					var test = querySim(
						"fname,lname
						luis | majano"
					);

					var target = getInterceptor( "Test1" );
					var oBean  = target.populateModel( model = "formBean", qry = test );
					expect( oBean.getFname() ).toBe( "luis" );
					expect( oBean.getLname() ).toBe( "majano" );
				} );
			} );
		} );
	}

}
