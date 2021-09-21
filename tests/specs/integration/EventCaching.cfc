component extends="tests.resources.BaseIntegrationTest" {

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "Event Caching", function(){
			beforeEach( function( currentSpec ){
				// Setup as a new ColdBox request, VERY IMPORTANT. ELSE EVERYTHING LOOKS LIKE THE SAME REQUEST.
				setup();
			} );

			afterEach( function( currentSpec ){
				structDelete( url, "format" );
			} );

			it( "can do basic cached events", function(){
				var event = execute( event = "eventcaching", renderResults = true );
				var prc   = event.getPrivateCollection();

				expect( prc.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "provider" );
				expect( prc.cbox_eventCacheableEntry.provider ).toBe( "template" );
				debug( prc.cbox_eventCacheableEntry );
			} );


			it( "can do cached events with custom provider annotations", function(){
				var event = execute( 
                    event = "eventcaching.withProvider", 
                    renderResults = true 
                );
				var prc   = event.getPrivateCollection();

				expect( prc.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "provider" );
				expect( prc.cbox_eventCacheableEntry.provider ).toBe( "default" );
			} );

            it( "can handle different RC collections", function(){
				
                // execute an event and specify a queryString variable
                var event1 = execute( 
                    event = "eventcaching", 
                    renderResults = true,
                    queryString="id=1" 
                );
				var prc1 = event1.getPrivateCollection();

                expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheIncludeRcKeys" );
				expect( prc1.cbox_eventCacheableEntry.cacheIncludeRcKeys ).toBe( "*" );

                // reset to simulate another request with a different rc scope
                setup();

                var event2 = execute( 
                    event = "eventcaching", 
                    renderResults = true,
                    queryString="id=2" 
                );
				
                var prc2 = event2.getPrivateCollection();

                expect( prc2.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheIncludeRcKeys" );
				expect( prc2.cbox_eventCacheableEntry.cacheIncludeRcKeys ).toBe( "*" );

                // because the default cache considers the rc scope, the cache keys should be different
                expect( prc1.cbox_eventCacheableEntry.cacheKey ).notToBe( prc2.cbox_eventCacheableEntry.cacheKey );

			} );

            it( "can handle the cacheIncludeRcKeys metadata", function(){
				
                // execute an event and specify a queryString variable
                var event1 = execute( 
                    event = "eventcaching.withIncludeAllRcKeys", 
                    renderResults = true,
                    queryString="id=1" 
                );
				var prc1 = event1.getPrivateCollection();

                expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheIncludeRcKeys" );
				expect( prc1.cbox_eventCacheableEntry.cacheIncludeRcKeys ).toBe( "*" );

			} );

            it( "can ignore the rc scope", function(){
				
                // execute an event and specify a queryString variable
                var event1 = execute( 
                    event = "eventcaching.withIncludeNoRcKeys", 
                    renderResults = true,
                    queryString="id=1" 
                );
				var prc1 = event1.getPrivateCollection();

                expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheIncludeRcKeys" );
				expect( prc1.cbox_eventCacheableEntry.cacheIncludeRcKeys ).toBe( "" );

                // reset to simulate another request
                setup();

                var event2 = execute( 
                    event = "eventcaching.withIncludeNoRcKeys", 
                    renderResults = true,
                    queryString="id=2" 
                );
				
                var prc2 = event2.getPrivateCollection();

                expect( prc2.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheIncludeRcKeys" );
				expect( prc2.cbox_eventCacheableEntry.cacheIncludeRcKeys ).toBe( "" );

                // because we ignore the RC, the cache key should match
                expect( prc1.cbox_eventCacheableEntry.cacheKey ).toBe( prc2.cbox_eventCacheableEntry.cacheKey );

			} );

            it( "can isolate specific RC scope keys and ignore the rest", function(){
				
                // execute an event and specify a queryString variable
                var event1 = execute( 
                    event = "eventcaching.withIncludeOneRcKey", 
                    renderResults = true,
                    queryString="id=1&slug=foo" 
                );
				var prc1 = event1.getPrivateCollection();

                expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheIncludeRcKeys" );
				expect( prc1.cbox_eventCacheableEntry.cacheIncludeRcKeys ).toBe( "slug" );

                // reset to simulate another request
                setup();

                var event2 = execute( 
                    event = "eventcaching.withIncludeOneRcKey", 
                    renderResults = true,
                    queryString="id=2&slug=foo" 
                );
				
                var prc2 = event2.getPrivateCollection();

                expect( prc2.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheIncludeRcKeys" );
				expect( prc2.cbox_eventCacheableEntry.cacheIncludeRcKeys ).toBe( "slug" );

                // because we ignore the RC, the cache key should match
                expect( prc1.cbox_eventCacheableEntry.cacheKey ).toBe( prc2.cbox_eventCacheableEntry.cacheKey );

			} );

            it( "can handle a list of specific RC scope keys and ignore the rest", function(){
				
                // execute an event and specify a queryString variable
                var event1 = execute( 
                    event = "eventcaching.withIncludeRcKeyList", 
                    renderResults = true,
                    queryString="id=1&slug=foo&source=google" 
                );
				var prc1 = event1.getPrivateCollection();

                expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheIncludeRcKeys" );
				expect( prc1.cbox_eventCacheableEntry.cacheIncludeRcKeys ).toBe( "slug,id" );

                // reset to simulate another request
                setup();

                var event2 = execute( 
                    event = "eventcaching.withIncludeRcKeyList", 
                    renderResults = true,
                    queryString="id=1&slug=foo&source=bing" 
                );
				
                var prc2 = event2.getPrivateCollection();

                expect( prc2.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheIncludeRcKeys" );
				expect( prc2.cbox_eventCacheableEntry.cacheIncludeRcKeys ).toBe( "slug,id" );

                // because we ignore the RC, the cache key should match
                expect( prc1.cbox_eventCacheableEntry.cacheKey ).toBe( prc2.cbox_eventCacheableEntry.cacheKey );

			} );

			var formats = [ "json", "xml", "pdf" ];
			for ( var thisFormat in formats ) {
				it(
					title = "can do #thisFormat# cached events",
					data  = { format : thisFormat },
					body  = function( data ){
						getRequestContext().setValue( "format", data.format );
						var event = execute( event = "eventcaching", renderResults = true );
						var prc   = event.getCollection( private = true );

						expect( prc.cbox_eventCacheableEntry ).toBeStruct();
						expect( prc.cbox_renderData.contenttype ).toMatch( data.format );
					}
				);
			}

			describe( "via runEvent()", function(){
				beforeEach( function( currentSpec ){
					cache = prepareMock( getCache( "template" ) );
					cache.clearAllEvents( async = false );
				} );

				it( "can cache with defaults", function(){
					// should not be there, so should be cached now
					var data  = controller.runEvent( event = "eventcaching.widget", cache = true );
					// run again, and get cached data.
					var data2 = controller.runEvent( event = "eventcaching.widget", cache = true );
					// Make sure they match
					expect( data2 ).toBe( data );
				} );

				it( "can cache with suffixes", function(){
					// should not be there, so should be cached now
					var data = controller.runEvent(
						event       = "eventcaching.widget",
						cache       = true,
						cacheSuffix = "bddtesting"
					);
					// run again, and get cached data.
					var data2 = controller.runEvent(
						event       = "eventcaching.widget",
						cache       = true,
						cacheSuffix = "bddtesting"
					);
					// Make sure they match
					expect( data2 ).toBe( data );

					// find key
					var keys = cache.getKeys();
					expect( keys ).toHavePartialKey( "bddtesting" );
				} );

				it( "can cache with provider", function(){
					// should not be there, so should be cached now
					var data = controller.runEvent(
						event         = "eventcaching.widget",
						cache         = true,
						cacheProvider = "default"
					);
					// run again, and get cached data.
					var data2 = controller.runEvent(
						event         = "eventcaching.widget",
						cache         = true,
						cacheProvider = "default"
					);
					// Make sure they match
					expect( data2 ).toBe( data );

					// find key
					var keys = getCache( "default" ).getKeys();
					expect( keys ).toHavePartialKey( "eventcaching.widget" );
				} );

				it( "can cache differently with event arguments", function(){
					// should not be there, so should be cached now
					var data = controller.runEvent(
						event          = "eventcaching.widget",
						cache          = true,
						eventArguments = { widget : true }
					);
					// run again, and get cached data.
					var data2 = controller.runEvent(
						event         = "eventcaching.widget",
						cache         = true,
						cacheProvider = "default"
					);
					// Make sure they match
					expect( data2 ).notToBe( data );
				} );
			} );
		} );
	}

}
