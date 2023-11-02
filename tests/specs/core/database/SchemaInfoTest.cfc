/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
		dsn        = "coolblog";
		schemaInfo = prepareMock( new coldbox.system.core.database.SchemaInfo() );
	}

	/**
	 * executes after all suites+specs in the run() method
	 */
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Schema Info", function(){
			it( "can be created", function(){
				expect( schemaInfo ).toBeComponent();
			} );

			it( "can get the database info", function(){
				var data = schemaInfo.getDatabaseInfo( dsn );
				expect( data ).notToBeEmpty();
			} );

			it( "can get a date time column type", function(){
				var data = schemaInfo.getDateTimeColumnType( dsn );
				expect( data ).toBe( "DATETIME" );
			} );

			it( "can get a text column type", function(){
				var data = schemaInfo.getTextColumnType( dsn );
				expect( data ).toBe( "LONGTEXT" );
			} );

			it( "can get a query param data/time column type", function(){
				var data = schemaInfo.getQueryParamDateTimeType( dsn );
				expect( data ).toBe( "cf_sql_timestamp" );
			} );

			it( "can get all the tables on the specified datasource", function(){
				var data = schemaInfo.getTables( dsn );
				expect( data ).toBeArray();
			} );

			it( "can get all the tables on the specified datasource with a filter", function(){
				var data = schemaInfo.getTables( dsn, "todo" );
				expect( data ).notToBeEmpty();
			} );

			it( "can verify if a table exists", function(){
				var data = schemaInfo.hasTable( "todo", dsn );
				expect( data ).toBeTrue();
			} );

			it( "can verify if a table exists", function(){
				var data = schemaInfo.hasTable( "ddddddd", dsn );
				expect( data ).toBeFalse();
			} );

			it( "can verify if a table column exists", function(){
				var data = schemaInfo.hasColumn( "todo", "test", dsn );
				expect( data ).toBeFalse();

				var data = schemaInfo.hasColumn( "todo", "name", dsn );
				expect( data ).toBeTrue();
			} );
		} );
	}

}
