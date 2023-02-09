/**
 * My Event Handler Hint
 */
component extends="coldbox.system.EventHandler"{

	/**
	 * Index
	 */
	any function index( event, rc, prc ){
		var sTime = getTickCount();
		var aUsers = entityLoad( "User", {}, { maxResults : 500 } );

		//writeOutput( aUsers[ 2 ].versionsGet() );
		writeOutput( server.coldfusion.productVersion );

		return "<Br>Loaded #aUsers.len()# entities in #getTickCount() - sTime#ms";
	}

	function seed( event, rc, prc ){
		var count = 100;
		var mockdata = getInstance( "testbox.system.modules.mockdatacfc.models.MockData" );
		mockData.mock(
			$num :  count,
			firstName : "fname",
			lastName : "lname",
			username : "string:25",
			password : "string:20",
			role : "num:5"
		).each( function( item ){
			entitySave(
				populateModel(
					model : entitynew( "User" ),
					memento = item,
					ignoreTargetLists = true,
					composeRelationships = true
				)
			);
		} );
		ormFlush();
		return "Seeded #count# records";
	}

}
