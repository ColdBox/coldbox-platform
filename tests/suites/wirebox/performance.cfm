<cfscript>
	function cleanup(){
		structDelete( application, "wirebox" );
		structDelete( application, "cachebox" );
	}
	cleanup();

	TOTAL_ITERATIONS = randRange( 3998, 4000 );
	writeOutput( "<h2>Using: #expandPath( '/coldbox' )#; #server.coldfusion.productName#</h2>" );

	iterations = TOTAL_ITERATIONS;
	sTime = getTickCount();

	writeOutput( "<div>Testing for #iterations# iterations...</div><br>" );
	cfflush();

	creationTime = getTickcount();
	injector = new coldbox.system.ioc.Injector(
		"tests.suites.wirebox.WireBoxConfig"
	);
	creationEndTime = getTickCount();
	writeOutput( "<div>Injector creation time: #creationEndTime - creationTime#</div>" );
	cfflush();

	instanceTime = getTickCount();
	while( iterations-- > 0 ){
		//writeOutput( "#iterations#..." );
		injector.getInstance( "CategoryBean" );
		//injector.getInstance( "virtually-inherited-class" );
		injector.getInstance( "categoryDAO" );
	}
	writeOutput( "<div>Injector.getInstance() time: #getTickCount() - instanceTime#</div>" );
	writeOutput( "<br><div>Total Time: #getTickCount() - sTime# ms</div>" );

	iterations = TOTAL_ITERATIONS;
	sTime = getTickCount();
	while( iterations-- > 0 ){
		//writeOutput( "#iterations#..." );
		createObject( "cbtestharness.models.ioc.category.CategoryDAO" );
		createObject( "cbtestharness.models.ioc.category.CategoryBean" );
		createObject( "cbtestharness.models.ioc.category.CategoryService" );
		createObject( "cbtestharness.models.ioc.product.ProductService" );
		createObject( "cbtestharness.models.ioc.product.ProductDAO" );
		createObject( "tests.resources.ChildClass" );
	}
	writeOutput( "<br><div>Createobject Time: #getTickCount() - sTime# ms</div>" );




	// Cleanup
	createObject( "java", "java.lang.Runtime" ).getRuntime().gc();
	cleanup();
</cfscript>
