component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Framework Super Type", function(){
			beforeEach( function( currentSpec ){
				setup();

				target = new coldbox.system.FrameworkSupertype();
				target.setController( getController() );
			} );


			it( "can do when statements with no failures", function(){
				var result = false;
				target.when( true, function(){
					result = true;
				} );
				expect( result ).toBeTrue();
			} );

			it( "can do when statements with failures", function(){
				var result = true;
				target.when(
					false,
					function(){
						result = true;
					},
					function(){
						result = false;
					}
				);
				expect( result ).toBeFalse();
			} );

			describe( "Can do population", function(){
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
