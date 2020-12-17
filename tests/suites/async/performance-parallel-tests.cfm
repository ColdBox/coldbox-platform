<cfscript>
	function injectState( state ){
		structAppend( variables, arguments.state, true );
		return this;
	};
	function getObjectState(){
		return variables.filter( ( k, v ) => !isCustomFunction( v ) || !isClosure( v ) );
	}

	wirebox = new coldbox.system.ioc.Injector();
	mockdata = new testbox.system.modules.mockdatacfc.models.MockData();
	count = 1000;

	// Traditional Approach
	sTime = getTickCount();
	data = mockData.mock(
		$num : count,
		fname : "name",
		lname : "lname",
		dob : "date",
		id : "uuid",
		password : "lorem"
	);

	results = [];
	for( x=1 ; x lte count; x++ ){
		thisItem = wirebox.getInstance( "tests.tmp.User" );
		thisItem.injectState = variables.injectState;

		thisItem.injectState( data[ x ] );

		results.append( thisItem );
	}

	writeDump( var={
		label: "getInstance() for loop",
		value : "#getTickCount() - sTime#ms"
	} );

	/*****************************************************/
	/*****************************************************/
	/*****************************************************/
	// Using State Pattern Injection

	sTime = getTickCount();
	data = mockData.mock(
		$num : count,
		fname : "name",
		lname : "lname",
		dob : "date",
		id : "uuid",
		password : "lorem"
	);

	thisPrototype = wirebox.getInstance( "tests.tmp.User" );
	thisPrototype.injectState = variables.injectState;
	thisPrototype.getObjectState = variables.getObjectState;
	protoTypeState = thisProtoType.getObjectState();

	results = [];
	for( x=1 ; x lte count; x++ ){
		thisItem = new tests.tmp.User();
		thisItem.injectState = variables.injectState;

		// Inject Both States
		thisItem.injectState( protoTypeState );
		thisItem.injectState( data[ x ] );

		results.append( thisItem );
	}

	writeDump( var={
		label: "State Injection for loop",
		value : "#getTickCount() - sTime#ms"
	} );


	/*****************************************************/
	/*****************************************************/
	/*****************************************************/
	// Using State Pattern Injection + Futures with default 20 thread bound executor

	asyncManager = new coldbox.system.async.AsyncManager();

	sTime = getTickCount();
	data = mockData.mock(
		$num : count,
		fname : "name",
		lname : "lname",
		dob : "date",
		id : "uuid",
		password : "lorem"
	);

	thisPrototype = wirebox.getInstance( "tests.tmp.User" );
	thisPrototype.injectState = variables.injectState;
	thisPrototype.getObjectState = variables.getObjectState;
	protoTypeState = thisProtoType.getObjectState();

	results = asyncManager.newFuture().allApply(
		data,
		( record ) => {
			var thisItem = new tests.tmp.User();
			thisItem.injectState = variables.injectState;

			// Inject Both States
			thisItem.injectState( protoTypeState );
			thisItem.injectState( record );

			return thisItem;
		}
	);

	writeDump( var={
		label: "State injection futures allApply()",
		value : "#getTickCount() - sTime#ms"
	} );


	/*****************************************************/
	/*****************************************************/
	/*****************************************************/
	// Using State Pattern Injection + Futures with default 20 thread bound executor

	asyncManager = new coldbox.system.async.AsyncManager();
	executor = asyncManager.$executors.newCachedThreadPool();

	sTime = getTickCount();
	data = mockData.mock(
		$num : count,
		fname : "name",
		lname : "lname",
		dob : "date",
		id : "uuid",
		password : "lorem"
	);

	thisPrototype = wirebox.getInstance( "tests.tmp.User" );
	thisPrototype.injectState = variables.injectState;
	thisPrototype.getObjectState = variables.getObjectState;
	protoTypeState = thisProtoType.getObjectState();

	results = asyncManager.newFuture().allApply(
		data,
		( record ) => {
			var thisItem = new tests.tmp.User();
			thisItem.injectState = variables.injectState;

			// Inject Both States
			thisItem.injectState( protoTypeState );
			thisItem.injectState( record );

			return thisItem;
		},
		executor
	);

	writeDump( var={
		label: "State injections futures allApply() with custom executor",
		value : "#getTickCount() - sTime#ms"
	} );
	executor.shutdown();

	/*****************************************************/
	/*****************************************************/
	/*****************************************************/
	// Using lucee map in parallel

	sTime = getTickCount();
	data = mockData.mock(
		$num : count,
		fname : "name",
		lname : "lname",
		dob : "date",
		id : "uuid",
		password : "lorem"
	);

	thisPrototype = wirebox.getInstance( "tests.tmp.User" );
	thisPrototype.injectState = variables.injectState;
	thisPrototype.getObjectState = variables.getObjectState;
	protoTypeState = thisProtoType.getObjectState();

	results = data.map( ( record ) => {
		var thisItem = new tests.tmp.User();
		thisItem.injectState = variables.injectState;

		// Inject Both States
		thisItem.injectState( protoTypeState );
		thisItem.injectState( record );

		return thisItem;
	}, true );

	writeDump( var={
		label: "State injection with native Lucee Parallel Map",
		value : "#getTickCount() - sTime#ms"
	} );
</cfscript>