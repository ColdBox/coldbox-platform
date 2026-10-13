component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Framework Super Type", () => {
			beforeEach( ( currentSpec ) => {
				setup();
				target = prepareMock( getInstance( "coldbox.system.FrameworkSupertype" ) );
			} );

			it( "can retrieve the async manager", () => {
				expect( target.async() ).toBeComponent();
			} );

			story( "it can use the back() function to return to the previous URI", () => {
				given( "no previous referer", () => {
					then( "it should use the fallback", () => {
						var fallback              = "main.dashboard";
						var mockContext           = getMockRequestContext();
						mockContext.getHTTPHeader = ( header, defaultValue ) => {
							return defaultValue;
						};
						target.$( "relocate" ).$( "getRequestContext", mockContext );
						target.back( fallback );
						expect( target.$callLog().relocate[ 1 ].url ).toInclude( "dashboard" );
					} );
				} );
				given( "a previous referer", () => {
					then( "it should use the referer", () => {
						var mockContext           = getMockRequestContext();
						mockContext.getHTTPHeader = ( header, defaultValue ) => {
							return "http://localhost/luis/majano";
						};
						target.$( "relocate" ).$( "getRequestContext", mockContext );
						target.back();
						expect( target.$callLog().relocate[ 1 ].url ).toInclude( "majano" );
					} );
				} );
			} );

			story( "should encode data for binding to html attributes", () => {
				given( "a simple value", () => {
					then( "it should encode it", () => {
						var data = "Welcome's you to > appreciation < of ^&+ life.""";
						expect( target.forAttribute( data ) ).toBe( encodeForHTMLAttribute( data ) );
					} );
				} );
				given( "a complex value", () => {
					then( "it should encode it", () => {
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

			story( "can do object population from many input sources", () => {
				it( "from the request collection", () => {
					var rc   = getRequestContext().getCollection();
					rc.fname = "luis";
					rc.lname = "majano";

					var target = getInterceptor( "Test1" );
					var oBean  = target.populate( "formBean" );
					expect( oBean.getFname() ).toBe( "luis" );
					expect( oBean.getLname() ).toBe( "majano" );
				} );

				it( "from inline structs", () => {
					var test = { fname : "luis", lname : "majano" };

					var target = getInterceptor( "Test1" );
					var oBean  = target.populate( model = "formBean", memento = test );
					expect( oBean.getFname() ).toBe( "luis" );
					expect( oBean.getLname() ).toBe( "majano" );
				} );

				it( "from json", () => {
					var test = serializeJSON( { "fname" : "luis", "lname" : "majano" } );

					var target = getInterceptor( "Test1" );
					var oBean  = target.populate( model = "formBean", jsonstring = test );
					expect( oBean.getFname() ).toBe( "luis" );
					expect( oBean.getLname() ).toBe( "majano" );
				} );

				it( "from xml", () => {
					var test = "<root><fname>luis</fname><lname>majano</lname></root>";

					var target = getInterceptor( "Test1" );
					var oBean  = target.populate( model = "formBean", xml = test );
					expect( oBean.getFname() ).toBe( "luis" );
					expect( oBean.getLname() ).toBe( "majano" );
				} );

				it( "from query", () => {
					var test = querySim(
						"fname,lname
						luis | majano"
					);

					var target = getInterceptor( "Test1" );
					var oBean  = target.populate( model = "formBean", qry = test );
					expect( oBean.getFname() ).toBe( "luis" );
					expect( oBean.getLname() ).toBe( "majano" );
				} );
			} );
		} );
	}

}
