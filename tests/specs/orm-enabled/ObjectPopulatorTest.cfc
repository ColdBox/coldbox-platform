component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.core.dynamic.ObjectPopulator" {

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Object Populator", function(){
			beforeEach( function( currentSpec ){
				setup();
				populator = model
					.init()
					.setUtil( new coldbox.system.core.util.Util() )
					.setMixerUtil( new coldbox.system.core.dynamic.MixerUtil() );
			} );

			it( "can create the populator", function(){
				expect( populator ).toBeComponent();
			} );

			it( "can get orm relationship metadata", function(){
				var obj = entityNew( "User" );
				makePublic( populator, "getRelationshipMetaData" );
				var meta = populator.getRelationshipMetaData( obj );
				expect( meta ).toBeStruct().toHaveKey( "role" );
				expect( meta.role ).toHaveKey( "cfc" );
			} );

			it( "can get non related relationship metadata", function(){
				var obj = new cbtestharness.models.Photos();
				makePublic( populator, "getRelationshipMetaData" );
				var meta = populator.getRelationshipMetaData( obj );
				expect( meta ).toBeStruct().toBeEmpty();
			} );

			describe( "Population using structs", function(){
				it( "can populate from a struct and compose many to one relationships", function(){
					var obj      = entityNew( "User" );
					var role     = entityNew( "Role" );
					var myStruct = { firstName : "Luis", lastName : "Majano", role : 1 };

					var user = populator.populateFromStruct(
						target               = obj,
						memento              = myStruct,
						composeRelationships = true
					);
					expect( user.getRole() ).toBeComponent();
				} );

				it( "can populate from a struct and compose one to many relationships", function(){
					var role     = entityNew( "Role" );
					var roleArgs = {
						Users : [
							"4028818e2fb6c893012fe637c5db00a7",
							"88B73A03-FEFA-935D-AD8036E1B7954B76"
						]
					};
					var role = populator.populateFromStruct(
						target               = role,
						memento              = roleArgs,
						composeRelationships = true
					);
					expect( role.getUsers() ).toBeArray().toHaveLength( 2 );
				} );

				it( "can populate from struct with empty null includes", function(){
					var obj      = entityNew( "User" );
					var myStruct = {
						id        : "",
						firstName : "Luis",
						lastName  : "Majano",
						username  : "",
						password  : ""
					};

					var user = populator.populateFromStruct(
						target           = obj,
						memento          = myStruct,
						nullEmptyInclude = ""
					);

					expect( myStruct.firstName ).toBe( user.getFirstName() );
					expect( isNull( user.getUsername() ) ).toBeFalse();
					expect( isNull( user.getPassword() ) ).toBeFalse();

					/* Populate From Struct - One column null*/
					var user = populator.populateFromStruct(
						target           = obj,
						memento          = myStruct,
						nullEmptyInclude = "username"
					);

					expect( myStruct.firstName ).toBe( user.getFirstName() );
					expect( isNull( user.getUsername() ) ).toBeTrue();
					expect( isNull( user.getPassword() ) ).toBeFalse();

					/* Populate From Struct - All columns null*/
					user = populator.populateFromStruct(
						target           = obj,
						memento          = myStruct,
						nullEmptyInclude = "*"
					);

					expect( myStruct.firstName ).toBe( user.getFirstName() );
					expect( isNull( user.getUsername() ) ).toBeTrue();
					expect( isNull( user.getPassword() ) ).toBeTrue();
				} );

				it( "can populate from struct with empty null excludes", function(){
					var obj      = entityNew( "User" );
					var myStruct = {
						id        : "",
						firstName : "Luis",
						lastName  : "Majano",
						username  : "",
						password  : ""
					};

					var user = populator.populateFromStruct(
						target           = obj,
						memento          = myStruct,
						nullEmptyInclude = "*",
						nullEmptyExclude = "username"
					);

					expect( myStruct.firstName ).toBe( user.getFirstName() );
					expect( isNull( user.getUsername() ) ).toBeFalse();
					expect( isNull( user.getPassword() ) ).toBeTrue();

					/* Populate From Struct - One column null*/
					var user = populator.populateFromStruct(
						target           = obj,
						memento          = myStruct,
						nullEmptyExclude = "*"
					);

					expect( myStruct.firstName ).toBe( user.getFirstName() );
					expect( isNull( user.getUsername() ) ).toBeFalse();
					expect( isNull( user.getPassword() ) ).toBeFalse();
				} );

				it( "can populate from struct and ignore empty values", function(){
					var obj      = entityNew( "User" );
					var myStruct = {
						id        : "",
						firstName : "Luis",
						lastName  : "Majano",
						username  : ""
					};

					var user = populator.populateFromStruct(
						target      = obj,
						memento     = myStruct,
						ignoreEmpty = true
					);

					expect( myStruct.firstName ).toBe( user.getFirstName() );
					expect( isNull( user.getId() ) ).toBeTrue();
					expect( isNull( user.getUsername() ) ).toBeTrue();
				} );

				it( "can populate from struct with default values", function(){
					var obj      = createMock( "coldbox.test-harness.models.formBean" );
					var myStruct = {
						fname    : "Luis",
						lname    : "Majano",
						email    : "test@coldboxframework.com",
						initDate : now()
					};
					var obj         = populator.populateFromStruct( obj, myStruct );
					var objInstance = obj.getInstance();

					/* Assert Population */
					for ( var key in objInstance ) {
						assertEquals(
							objInstance[ key ],
							myStruct[ key ],
							"Asserting #key# From Struct"
						);
					}
				} );

				it( "can populate from struct using a direct scope injection", function(){
					var obj      = createMock( "coldbox.test-harness.models.formBean" );
					var myStruct = {
						fname    : "Luis",
						lname    : "Majano",
						email    : "test@coldboxframework.com",
						initDate : now()
					};
					var obj = populator.populateFromStruct(
						target : obj,
						memento: myStruct,
						scope  : "variables.instance"
					);
					var objInstance = obj.getInstance();

					/* Assert Population */
					for ( var key in objInstance ) {
						assertEquals(
							objInstance[ key ],
							myStruct[ key ],
							"Asserting #key# From Struct"
						);
					}
				} );

				it( "can populate from struct using onMissingMethod Injection", function(){
					var obj      = createMock( "coldbox.test-harness.models.formImplicitBean" );
					var myStruct = {
						fname    : "Luis",
						lname    : "Majano",
						email    : "test@coldboxframework.com",
						initDate : now()
					};
					var obj = populator.populateFromStruct(
						target       : obj,
						memento      : myStruct,
						trustedSetter: true
					);
					var objInstance = obj.getInstance();

					/* Assert Population */
					for ( var key in objInstance ) {
						assertEquals(
							objInstance[ key ],
							myStruct[ key ],
							"Asserting #key# From Struct"
						);
					}
				} );

				it( "can populate from struct with a key prefix", function(){
					var obj      = createMock( "coldbox.test-harness.models.formBean" );
					var myStruct = {
						user_fname    : "Luis",
						user_lname    : "Majano",
						user_email    : "test@coldboxframework.com",
						user_initDate : now()
					}

					var obj = populator.populateFromStructWithPrefix(
						target  = obj,
						memento = myStruct,
						prefix  = "user_"
					);
					var objInstance = obj.getInstance();

					/* Assert Population */
					for ( var key in objInstance ) {
						assertEquals(
							objInstance[ key ],
							myStruct[ "user_" & key ],
							"Asserting #key# From Struct"
						);
					}
				} );
			} );

			it( "can populate from json", function(){
				var obj      = createMock( "coldbox.test-harness.models.formBean" );
				var myStruct = {
					fname    : "Luis",
					lname    : "Majano",
					email    : "test@coldboxframework.com",
					initDate : dateFormat( now(), "mm/dd/yyy" )
				}
				var myJSON      = serializeJSON( myStruct );
				var obj         = populator.populateFromJSON( obj, myJSON );
				var objInstance = obj.getInstance();

				/* Assert Population */
				for ( var key in objInstance ) {
					assertEquals(
						objInstance[ key ],
						myStruct[ key ],
						"Asserting #key# From JSON"
					);
				}
			} );

			it( "can populate from xml", function(){
				var obj = createMock( "coldbox.test-harness.models.formBean" );
				var xml = "<root>
					<fname>Luis</fname>
					<lname>Majano</lname>
					<email>test@coldbox.org</email>
					<initDate>#now()#</initDate>
					</root>
					";
				xml             = xmlParse( xml );
				var obj         = populator.populateFromXML( obj, xml );
				var objInstance = obj.getInstance();
				assertEquals( "Luis", obj.getFName() );
				assertEquals( "Majano", obj.getLname() );
				assertEquals( "test@coldbox.org", obj.getEmail() );
			} );

			it( "can populate from query", function(){
				var obj     = createMock( "coldbox.test-harness.models.formBean" );
				var myQuery = queryNew( "fname,lname,email,initDate" );
				queryAddRow( myQuery, 1 );
				querySetCell( myQuery, "fname", "Sana" );
				querySetCell( myQuery, "lname", "Ullah" );
				querySetCell( myQuery, "email", "test13@test13.com" );
				querySetCell( myQuery, "initDate", now() );

				var obj = populator.populateFromQuery( obj, myQuery );
				assertEquals( myQuery[ "fname" ][ 1 ], obj.getfname() );
				assertEquals( myQuery[ "lname" ][ 1 ], obj.getlname() );
				assertEquals( myQuery[ "email" ][ 1 ], obj.getemail() );
			} );
		} ); // end describe
	}

}
