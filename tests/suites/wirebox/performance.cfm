<cfscript>
	writeOutput( "<h2>Using: #expandPath( '/coldbox' )#; #server.coldfusion.productName#</h2>" );

	structDelete( application, "wirebox" );
	iterations = 1000;
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
		injector.getInstance( "categoryDAO" );
		injector.getInstance( "CategoryBean" );
	}
	writeOutput( "<div>Injector.getInstance() time: #getTickCount() - instanceTime#</div>" );

	writeOutput( "<br><div>Total Time: #getTickCount() - sTime# ms</div>" );

	/**
	 * 2243
	 * 639
	 * 433
	 * 415
	 * 436
	 * 534
	 * 333
	 * 344
	 */
</cfscript>
