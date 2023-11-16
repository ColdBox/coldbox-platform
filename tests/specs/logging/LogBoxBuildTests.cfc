/**
 * This tests the struct literal construction of LogBox
 */
import coldbox.system.logging.*;

component extends="testbox.system.BaseSpec" {

	this.loadColdbox = false;

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "LogBox can be built using different configuration strategies", function(){
			it( "can load with the default config", function(){
				var logBox = new LogBox();
				expect( logBox ).toBeInstanceOf( "LogBox" );
				expect( logbox.getRootLogger() ).toBeInstanceOf( "Logger" );
			} );

			it( "can load with the default config given an empty config string", function(){
				var logBox = new LogBox( config: "" );
				expect( logBox ).toBeInstanceOf( "LogBox" );
				expect( logbox.getRootLogger() ).toBeInstanceOf( "Logger" );
			} );

			it( "can load with a custom config cfc path", function(){
				var logBox = new LogBox( config: "tests.specs.logging.config.LogBoxConfig" );
				expect( logBox ).toBeInstanceOf( "LogBox" );
				expect( logbox.getRootLogger() ).toBeInstanceOf( "Logger" );
				expect(
					logbox
						.getConfig()
						.getCategories()
						.keyArray()
				).toInclude( "yes.wow.wow" );
			} );


			it( "can load with a custom struct LogBox DSL literal", function(){
				var logBox = new LogBox(
					config: {
						appenders : { myConsoleLiteral : { class : "ConsoleAppender" } },
						root      : { levelmax : "FATAL", appenders : "*" },
						info      : [ "hello.model", "yes.wow.wow" ],
						warn      : [ "hello.model", "yes.wow.wow" ],
						error     : [ "hello.model", "yes.wow.wow" ]
					}
				);
				expect( logBox ).toBeInstanceOf( "LogBox" );
				expect( logbox.getRootLogger() ).toBeInstanceOf( "Logger" );
				expect(
					logbox
						.getConfig()
						.getCategories()
						.keyArray()
				).toInclude( "hello.model" ).toInclude( "yes.wow.wow" );
			} );
		} );
	}

}
