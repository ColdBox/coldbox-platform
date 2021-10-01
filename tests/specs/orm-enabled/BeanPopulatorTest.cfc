<cfcomponent extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.core.dynamic.BeanPopulator">
	<cffunction name="setup">
		<cfset super.setup()>
		<cfset populator = model.init()>
	</cffunction>

	<cffunction name="testGetRelationshipMetaData" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		stime = getTickCount();
		/* We are using the formBean object: fname,lname,email,initDate */
		obj = entityNew( "User" );
		makePublic( populator, "getRelationshipMetaData" );
		meta = populator.getRelationshipMetaData( target = obj );
		assertTrue( isStruct( meta ) );
		for ( item in meta ) {
			assertTrue( structKeyExists( meta[ item ], "cfc" ) );
		}
		</cfscript>
	</cffunction>

	<cffunction
		name      ="testPopulateFromStructWithComposeRelationships"
		access    ="public"
		returntype="void"
		output    ="false"
	>
		<!--- Now test some events --->
		<cfscript>
		stime = getTickCount();

		/* We are using the formBean object: fname,lname,email,initDate */
		obj  = entityNew( "User" );
		role = entityNew( "Role" );

		/* Struct */
		myStruct           = structNew();
		// myStruct.id = "";
		myStruct.firstName = "Luis";
		myStruct.lastName  = "Majano";
		myStruct.role      = 1;

		/* Populate From Struct - populate role */
		user = populator.populateFromStruct(
			target               = obj,
			memento              = myStruct,
			composeRelationships = true
		);
		expect( user.getRole() ).toBeComponent();

		/* Struct */
		roleArgs = {
			Users : [
				"4028818e2fb6c893012fe637c5db00a7",
				"88B73A03-FEFA-935D-AD8036E1B7954B76"
			]
		};
		/* Populate From Struct - populate role */
		role = populator.populateFromStruct(
			target               = role,
			memento              = roleArgs,
			composeRelationships = true
		);
		/** Have to comment out DI in User.cfc to work!! **/
		</cfscript>
	</cffunction>

	<cffunction name="testPopulateFromStructWithEmptyNullIncludes" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		stime = getTickCount();

		/* We are using the formBean object: fname,lname,email,initDate */
		obj = entityNew( "User" );

		/* Struct */
		myStruct           = structNew();
		myStruct.id        = "";
		myStruct.firstName = "Luis";
		myStruct.lastName  = "Majano";
		myStruct.username  = "";
		myStruct.password  = "";

		/* Populate From Struct - no columns null*/
		user = populator.populateFromStruct(
			target           = obj,
			memento          = myStruct,
			nullEmptyInclude = ""
		);

		assertEquals( myStruct.firstName, user.getFirstName() );
		assertFalse( isNull( user.getUsername() ) );
		assertFalse( isNull( user.getPassword() ) );

		/* Populate From Struct - One column null*/
		user = populator.populateFromStruct(
			target           = obj,
			memento          = myStruct,
			nullEmptyInclude = "username"
		);

		assertEquals( myStruct.firstName, user.getFirstName() );
		assertTrue( isNull( user.getUsername() ) );
		assertFalse( isNull( user.getPassword() ) );

		/* Populate From Struct - All columns null*/
		user = populator.populateFromStruct(
			target           = obj,
			memento          = myStruct,
			nullEmptyInclude = "*"
		);

		assertEquals( myStruct.firstName, user.getFirstName() );
		assertTrue( isNull( user.getUsername() ) );
		assertTrue( isNull( user.getPassword() ) );
		</cfscript>
	</cffunction>

	<cffunction name="testPopulateFromStructWithEmptyNullExcludes" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		stime = getTickCount();

		/* We are using the formBean object: fname,lname,email,initDate */
		obj = entityNew( "User" );

		/* Struct */
		myStruct           = structNew();
		myStruct.id        = "";
		myStruct.firstName = "Luis";
		myStruct.lastName  = "Majano";
		myStruct.username  = "";
		myStruct.password  = "";

		/* Populate From Struct - no columns null*/
		user = populator.populateFromStruct(
			target           = obj,
			memento          = myStruct,
			nullEmptyExclude = ""
		);

		assertEquals( myStruct.firstName, user.getFirstName() );
		assertFalse( isNull( user.getUsername() ) );
		assertFalse( isNull( user.getPassword() ) );

		/* Populate From Struct - One column not null*/
		user = populator.populateFromStruct(
			target           = obj,
			memento          = myStruct,
			nullEmptyInclude = "*",
			nullEmptyExclude = "username"
		);

		assertEquals( myStruct.firstName, user.getFirstName() );
		assertFalse( isNull( user.getUsername() ) );
		assertTrue( isNull( user.getPassword() ) );

		/* Populate From Struct - All columns null*/
		user = populator.populateFromStruct(
			target           = obj,
			memento          = myStruct,
			nullEmptyExclude = "*"
		);

		assertEquals( myStruct.firstName, user.getFirstName() );
		assertFalse( isNull( user.getUsername() ) );
		assertFalse( isNull( user.getPassword() ) );
		</cfscript>
	</cffunction>

	<cffunction name="testPopulateFromStructWithNulls" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		stime = getTickCount();

		/* We are using the formBean object: fname,lname,email,initDate */
		obj = entityNew( "User" );

		/* Struct */
		myStruct           = structNew();
		myStruct.id        = "";
		myStruct.firstName = "Luis";
		myStruct.lastName  = "Majano";
		myStruct.username  = "";

		/* Populate From Struct */
		user = populator.populateFromStruct(
			target      = obj,
			memento     = myStruct,
			ignoreEmpty = true
		);

		assertEquals( myStruct.firstName, user.getFirstName() );
		assertTrue( isNull( user.getID() ) );
		assertTrue( isNull( user.getUsername() ) );
		</cfscript>
	</cffunction>

	<cffunction name="testPopulateFromStruct" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		stime = getTickCount();

		/* We are using the formBean object: fname,lname,email,initDate */
		obj = createMock( "coldbox.test-harness.models.formBean" );

		/* Struct */
		myStruct          = structNew();
		myStruct.fname    = "Luis";
		myStruct.lname    = "Majano";
		myStruct.email    = "test@coldboxframework.com";
		myStruct.initDate = now();

		/* Populate From Struct */
		obj         = populator.populateFromStruct( obj, myStruct );
		objInstance = obj.getInstance();

		// debug( "Timer: #getTickCount()-stime#" );

		/* Assert Population */
		for ( key in objInstance ) {
			assertEquals(
				objInstance[ key ],
				myStruct[ key ],
				"Asserting #key# From Struct"
			);
		}

		/* populate using scope now */
		obj         = createMock( "coldbox.test-harness.models.formBean" );
		obj         = populator.populateFromStruct( obj, myStruct, "variables.instance" );
		objInstance = obj.getInstance();
		/* Assert Population */
		for ( key in objInstance ) {
			assertEquals(
				objInstance[ key ],
				myStruct[ key ],
				"Asserting by Scope #key# From Struct"
			);
		}

		/* Populate using onMissingMethod */
		obj = createMock( "coldbox.test-harness.models.formImplicitBean" );
		obj = populator.populateFromStruct(
			target        = obj,
			memento       = myStruct,
			trustedSetter = true
		);
		objInstance = obj.getInstance();
		/* Assert Population */
		for ( key in objInstance ) {
			assertEquals(
				objInstance[ key ],
				myStruct[ key ],
				"Asserting by Trusted Setter #key# From Struct"
			);
		}
		</cfscript>
	</cffunction>

	<cffunction name="testPopulateFromStructWithPrefix" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		stime = getTickCount();

		/* We are using the formBean object: fname,lname,email,initDate */
		obj = createMock( "coldbox.test-harness.models.formBean" );

		/* Struct */
		myStruct               = structNew();
		myStruct.user_fname    = "Luis";
		myStruct.user_lname    = "Majano";
		myStruct.user_email    = "test@coldboxframework.com";
		myStruct.user_initDate = now();

		/* Populate From Struct */
		obj = populator.populateFromStructWithPrefix(
			target  = obj,
			memento = myStruct,
			prefix  = "user_"
		);
		objInstance = obj.getInstance();

		// debug( "Timer: #getTickCount()-stime#" );

		/* Assert Population */
		for ( key in objInstance ) {
			assertEquals(
				objInstance[ key ],
				myStruct[ "user_" & key ],
				"Asserting #key# From Struct"
			);
		}
		</cfscript>
	</cffunction>

	<!--- testpopulateFromJSON --->
	<cffunction name="testpopulateFromJSON" output="false" access="public" returntype="any" hint="">
		<cfscript>
		/* We are using the formBean object: fname,lname,email,initDate */
		obj = createMock( "coldbox.test-harness.models.formBean" );

		/* Struct */
		myStruct          = structNew();
		myStruct.fname    = "Luis";
		myStruct.lname    = "Majano";
		myStruct.email    = "test@coldboxframework.com";
		myStruct.initDate = dateFormat( now(), "mm/dd/yyy" );
		/* JSON Packet */
		myJSON = serializeJSON( myStruct );
		// debug( myJSON );

		/* Populate From JSON */
		obj         = populator.populateFromJSON( obj, myJSON );
		objInstance = obj.getInstance();
		// debug( objInstance );

		/* Assert Population */
		for ( key in objInstance ) {
			assertEquals(
				objInstance[ key ],
				myStruct[ key ],
				"Asserting #key# From JSON"
			);
		}
		</cfscript>
	</cffunction>

	<cffunction name="testPopulateFromXML" output="false" access="public" returntype="any" hint="">
		<cfscript>
		/* We are using the formBean object: fname,lname,email,initDate */
		obj = createMock( "coldbox.test-harness.models.formBean" );

		/* Struct */
		xml = "<root>
			<fname>Luis</fname>
			<lname>Majano</lname>
			<email>test@coldbox.org</email>
			<initDate>#now()#</initDate>
			</root>
			";
		xml = xmlParse( xml );

		obj         = populator.populateFromXML( obj, xml );
		objInstance = obj.getInstance();

		assertEquals( "Luis", obj.getFName() );
		assertEquals( "Majano", obj.getLname() );
		assertEquals( "test@coldbox.org", obj.getEmail() );
		</cfscript>
	</cffunction>

	<cffunction name="testpopulateFromQuery" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
		// We are using the formBean object: fname,lname,email,initDate
		obj = createMock( "coldbox.test-harness.models.formBean" );

		// Query
		myQuery = queryNew( "fname,lname,email,initDate" );
		queryAddRow( myQuery, 1 );
		querySetCell( myQuery, "fname", "Sana" );
		querySetCell( myQuery, "lname", "Ullah" );
		querySetCell( myQuery, "email", "test13@test13.com" );
		querySetCell( myQuery, "initDate", now() );

		// Populate From Query
		obj = populator.populateFromQuery( obj, myQuery );

		assertEquals( myQuery[ "fname" ][ 1 ], obj.getfname() );
		assertEquals( myQuery[ "lname" ][ 1 ], obj.getlname() );
		assertEquals( myQuery[ "email" ][ 1 ], obj.getemail() );
		</cfscript>
	</cffunction>
</cfcomponent>
