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
				// debug( prc.cbox_eventCacheableEntry );
			} );


			it( "can do cached events with custom provider annotations", function(){
				var event = execute( event = "eventcaching.withProvider", renderResults = true );
				var prc   = event.getPrivateCollection();

				expect( prc.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "provider" );
				expect( prc.cbox_eventCacheableEntry.provider ).toBe( "default" );
			} );

			it( "can handle different RC collections", function(){
				// execute an event and specify a queryString variable
				var event1 = execute(
					event         = "eventcaching",
					renderResults = true,
					queryString   = "id=1"
				);
				var prc1 = event1.getPrivateCollection();

				// reset to simulate another request with a different rc scope
				setup();

				var event2 = execute(
					event         = "eventcaching",
					renderResults = true,
					queryString   = "id=2"
				);

				var prc2 = event2.getPrivateCollection();

				// because the default cache considers the rc scope, the cache keys should be different
				expect( prc1.cbox_eventCacheableEntry.cacheKey ).notToBe( prc2.cbox_eventCacheableEntry.cacheKey );
			} );

			// Cache Includes

			it( "can handle the cacheInclude metadata", function(){
				// execute an event and specify a queryString variable
				var event1 = execute(
					event         = "eventcaching.withIncludeOneRcKey",
					renderResults = true,
					queryString   = "id=1"
				);
				var prc1 = event1.getPrivateCollection();

				expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheInclude" );
				expect( prc1.cbox_eventCacheableEntry.cacheInclude ).toBe( "slug" );
			} );

			it( "can ignore the rc scope with an empty cacheInclude", function(){
				// execute an event and specify a queryString variable
				var event1 = execute(
					event         = "eventcaching.withIncludeNoRcKeys",
					renderResults = true,
					queryString   = "id=1"
				);
				var prc1 = event1.getPrivateCollection();

				expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheInclude" );
				expect( prc1.cbox_eventCacheableEntry.cacheInclude ).toBe( "" );

				// reset to simulate another request
				setup();

				var event2 = execute(
					event         = "eventcaching.withIncludeNoRcKeys",
					renderResults = true,
					queryString   = "id=2"
				);

				var prc2 = event2.getPrivateCollection();

				expect( prc2.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheInclude" );
				expect( prc2.cbox_eventCacheableEntry.cacheInclude ).toBe( "" );

				// because we ignore the RC, the cache key should match
				expect( prc1.cbox_eventCacheableEntry.cacheKey ).toBe( prc2.cbox_eventCacheableEntry.cacheKey );
			} );

			it( "can isolate specific RC scope keys and ignore the rest", function(){
				// execute an event and specify a queryString variable
				var event1 = execute(
					event         = "eventcaching.withIncludeOneRcKey",
					renderResults = true,
					queryString   = "id=1&slug=foo"
				);
				var prc1 = event1.getPrivateCollection();

				expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheInclude" );
				expect( prc1.cbox_eventCacheableEntry.cacheInclude ).toBe( "slug" );

				// reset to simulate another request
				setup();

				var event2 = execute(
					event         = "eventcaching.withIncludeOneRcKey",
					renderResults = true,
					queryString   = "id=2&slug=foo"
				);

				var prc2 = event2.getPrivateCollection();

				expect( prc2.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheInclude" );
				expect( prc2.cbox_eventCacheableEntry.cacheInclude ).toBe( "slug" );

				// because we ignore the RC, the cache key should match
				expect( prc1.cbox_eventCacheableEntry.cacheKey ).toBe( prc2.cbox_eventCacheableEntry.cacheKey );
			} );

			it( "can handle a list of specific RC scope keys and ignore the rest", function(){
				// execute an event and specify a queryString variable
				var event1 = execute(
					event         = "eventcaching.withIncludeRcKeyList",
					renderResults = true,
					queryString   = "id=1&slug=foo&source=google"
				);
				var prc1 = event1.getPrivateCollection();

				expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheInclude" );
				expect( prc1.cbox_eventCacheableEntry.cacheInclude ).toBe( "slug,id" );

				// reset to simulate another request
				setup();

				var event2 = execute(
					event         = "eventcaching.withIncludeRcKeyList",
					renderResults = true,
					queryString   = "id=1&slug=foo&source=bing"
				);

				var prc2 = event2.getPrivateCollection();

				expect( prc2.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheInclude" );
				expect( prc2.cbox_eventCacheableEntry.cacheInclude ).toBe( "slug,id" );

				// because we ignore the RC, the cache key should match
				expect( prc1.cbox_eventCacheableEntry.cacheKey ).toBe( prc2.cbox_eventCacheableEntry.cacheKey );
			} );

			// Cache Excludes

			it( "can handle the cacheExclude metadata", function(){
				// execute an event and specify a queryString variable
				var event1 = execute(
					event         = "eventcaching.withExcludeOneRcKey",
					renderResults = true,
					queryString   = "id=1"
				);
				var prc1 = event1.getPrivateCollection();

				expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheExclude" );
				expect( prc1.cbox_eventCacheableEntry.cacheExclude ).toBe( "slug" );
			} );

			it( "will include the entire rc scope with an empty cacheExclude", function(){
				// execute an event and specify a queryString variable
				var event1 = execute(
					event         = "eventcaching.withExcludeNoRcKeys",
					renderResults = true,
					queryString   = "id=1"
				);
				var prc1 = event1.getPrivateCollection();

				expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheExclude" );
				expect( prc1.cbox_eventCacheableEntry.cacheExclude ).toBe( "" );

				// reset to simulate another request
				setup();

				var event2 = execute(
					event         = "eventcaching.withExcludeNoRcKeys",
					renderResults = true,
					queryString   = "id=2"
				);

				var prc2 = event2.getPrivateCollection();

				expect( prc2.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheExclude" );
				expect( prc2.cbox_eventCacheableEntry.cacheExclude ).toBe( "" );

				// because we allowed the entire RC, the cache key should not match
				expect( prc1.cbox_eventCacheableEntry.cacheKey ).notToBe( prc2.cbox_eventCacheableEntry.cacheKey );
			} );

			it( "can ignore a specific RC scope key and allow the rest", function(){
				// execute an event and specify a queryString variable
				var event1 = execute(
					event         = "eventcaching.withExcludeOneRcKey",
					renderResults = true,
					queryString   = "id=1&slug=foo"
				);
				var prc1 = event1.getPrivateCollection();

				expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheExclude" );
				expect( prc1.cbox_eventCacheableEntry.cacheExclude ).toBe( "slug" );

				// reset to simulate another request
				setup();

				var event2 = execute(
					event         = "eventcaching.withExcludeOneRcKey",
					renderResults = true,
					queryString   = "id=1&slug=bar"
				);

				var prc2 = event2.getPrivateCollection();

				expect( prc2.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheExclude" );
				expect( prc2.cbox_eventCacheableEntry.cacheExclude ).toBe( "slug" );

				// because we ignored 'slug', the cache key should match
				expect( prc1.cbox_eventCacheableEntry.cacheKey ).toBe( prc2.cbox_eventCacheableEntry.cacheKey );
			} );

			it( "can handle a list of specific RC scope keys to exclude", function(){
				// execute an event and specify a queryString variable
				var event1 = execute(
					event         = "eventcaching.withExcludeRcKeyList",
					renderResults = true,
					queryString   = "id=1&slug=foo&source=google"
				);
				var prc1 = event1.getPrivateCollection();

				expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheExclude" );
				expect( prc1.cbox_eventCacheableEntry.cacheExclude ).toBe( "slug,id" );

				// reset to simulate another request
				setup();

				var event2 = execute(
					event         = "eventcaching.withExcludeRcKeyList",
					renderResults = true,
					queryString   = "id=2&slug=bar&source=google"
				);

				var prc2 = event2.getPrivateCollection();

				expect( prc2.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheExclude" );
				expect( prc2.cbox_eventCacheableEntry.cacheExclude ).toBe( "slug,id" );

				// because we ignored 'id and slug', the cache key should match
				expect( prc1.cbox_eventCacheableEntry.cacheKey ).toBe( prc2.cbox_eventCacheableEntry.cacheKey );
			} );

			// includeFilter

			it( "can handle the cacheFilter metadata", function(){
				// execute an event and specify a queryString variable
				var event1 = execute(
					event         = "eventcaching.withFilterClosure",
					renderResults = true,
					queryString   = "id=1&utm_source=google&utm_medium=cpc"
				);
				var prc1 = event1.getPrivateCollection();

				expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheFilter" );
				expect( isCustomFunction( prc1.cbox_eventCacheableEntry.cacheFilter ) ).toBeTrue();
			} );

			it( "requires cacheFilter to be a closure", function(){
				expect( () => {
					execute( event = "eventcaching.withBadCacheFilter", renderResults = true )
				} ).toThrow( type = "HandlerInvalidCacheFilterException" );
			} );


			it( "can filter RC keys based on cacheFilter", function(){
				// execute an event and specify a queryString variable
				var event1 = execute(
					event         = "eventcaching.withFilterClosure",
					renderResults = true,
					queryString   = "id=1&utm_source=google&utm_medium=cpc"
				);
				var prc1 = event1.getPrivateCollection();

				expect( prc1.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheFilter" );
				expect( isCustomFunction( prc1.cbox_eventCacheableEntry.cacheFilter ) ).toBeTrue();

				setup();

				var event2 = execute(
					event         = "eventcaching.withFilterClosure",
					renderResults = true,
					queryString   = "id=1&utm_source=bing&utm_medium=organic"
				);

				var prc2 = event2.getPrivateCollection();

				expect( prc2.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "cacheFilter" );
				expect( isCustomFunction( prc2.cbox_eventCacheableEntry.cacheFilter ) ).toBeTrue();

				// because we ignored 'all utm params in the method', the cache key should match
				expect( prc1.cbox_eventCacheableEntry.cacheKey ).toBe( prc2.cbox_eventCacheableEntry.cacheKey );
			} );


			it( "can filter RC keys based on cacheFilter, cacheInclude, and cacheExclude working together", function(){
				// execute an event and specify a queryString variable
				// in this test we know that the cacheFilter will randomize the slug and id keys
				var event1 = execute(
					event         = "eventcaching.withAllFilters",
					renderResults = true,
					queryString   = "id=1&slug=foo&utm_source=google"
				);
				var prc1 = event1.getPrivateCollection();

				expect( prc1.cbox_eventCacheableEntry )
					.toBeStruct()
					.toHaveKey( "cacheFilter,cacheInclude,cacheExclude" );
				expect( isCustomFunction( prc1.cbox_eventCacheableEntry.cacheFilter ) ).toBeTrue();
				expect( prc1.cbox_eventCacheableEntry.cacheInclude ).toBe( "slug,id" );
				expect( prc1.cbox_eventCacheableEntry.cacheExclude ).toBe( "id" );

				setup();

				var event2 = execute(
					event         = "eventcaching.withAllFilters",
					renderResults = true,
					queryString   = "id=1&slug=foo&utm_source=bing"
				);

				var prc2 = event2.getPrivateCollection();

				expect( prc2.cbox_eventCacheableEntry )
					.toBeStruct()
					.toHaveKey( "cacheExclude,cacheInclude,cacheExclude" );
				expect( isCustomFunction( prc2.cbox_eventCacheableEntry.cacheFilter ) ).toBeTrue();
				expect( prc2.cbox_eventCacheableEntry.cacheInclude ).toBe( "slug,id" );
				expect( prc2.cbox_eventCacheableEntry.cacheExclude ).toBe( "id" );

				// because we forced the cacheFilter to mutate the slug and id keys, the cache key should never match
				expect( prc1.cbox_eventCacheableEntry.cacheKey ).notToBe( prc2.cbox_eventCacheableEntry.cacheKey );
			} );

			// HTTP Caching - Tier 1 (docs/specs/http-caching.md §4.2/§4.4)
			//
			// execute() is a headless request simulator (system/testing/BaseTestCase.cfc) - it
			// runs the handler and render steps directly rather than going through Bootstrap.cfc's
			// actual onRequest cycle, so it never reaches the real event-caching *write* to
			// CacheBox (every other test in this file only ever asserts against
			// cbox_eventCacheableEntry for the same reason - none of them read the cache store
			// back either). These specs are scoped to what execute() can actually observe: that
			// the new annotations flow correctly into that same pre-execution metadata. The
			// write-time hash computation and the conditional-GET short-circuit decision itself
			// are covered directly against RequestContext in RequestContextHTTPCachingTest.cfc.

			it( "flows the etag annotation into the cacheable entry metadata", function(){
				var event = execute( event = "eventcaching.withETag", renderResults = true );
				var prc   = event.getPrivateCollection();

				expect( prc.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "etag,etagWeak,cacheControl" );
				expect( prc.cbox_eventCacheableEntry.etag ).toBeTrue();
				// Neither annotation was set on this action, so both resolve to their defaults
				expect( prc.cbox_eventCacheableEntry.etagWeak ).toBeFalse();
				expect( prc.cbox_eventCacheableEntry.cacheControl ).toBeEmpty();
			} );

			it( "flows the lastModified annotation into the cacheable entry metadata", function(){
				var event = execute( event = "eventcaching.withLastModified", renderResults = true );
				var prc   = event.getPrivateCollection();

				expect( prc.cbox_eventCacheableEntry ).toBeStruct().toHaveKey( "lastModified" );
				expect( prc.cbox_eventCacheableEntry.lastModified ).toBeTrue();
			} );

			it( "defaults etag/etagWeak/lastModified/cacheControl to off for handlers that never set them", function(){
				var event = execute( event = "eventcaching", renderResults = true );
				var prc   = event.getPrivateCollection();

				expect( prc.cbox_eventCacheableEntry )
					.toBeStruct()
					.toHaveKey( "etag,etagWeak,lastModified,cacheControl" );
				expect( prc.cbox_eventCacheableEntry.etag ).toBeFalse();
				expect( prc.cbox_eventCacheableEntry.etagWeak ).toBeFalse();
				expect( prc.cbox_eventCacheableEntry.lastModified ).toBeFalse();
				expect( prc.cbox_eventCacheableEntry.cacheControl ).toBeEmpty();
			} );

			var formats = [ "json", "xml", "pdf" ];
			for ( var thisFormat in formats ) {
				it(
					title = "can do #thisFormat# cached events",
					data  = { format : thisFormat },
					body  = function( data ){
						// TODO: Jon Clausen waiting for a fix on the PDF rendering
						// if ( data.format == "pdf" && isBoxLang() ) {
						// 	// Skip PDF tests
						// 	return;
						// }

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

			describe( "EVENT_CACHE_SUFFIX", function(){
				it( "evaluates a closure suffix on every request producing distinct cache keys", function(){
					getRequestContext().setValue( "slug", "alpha" )
					var event1 = execute( event = "eventcachingSuffix.index", renderResults = true )
					var key1   = event1.getPrivateCollection().cbox_eventCacheableEntry.cacheKey

					expect( key1 ).toInclude( "alpha-present" )

					// reset to simulate another request with a different slug
					setup()
					getRequestContext().setValue( "slug", "beta" )
					var event2 = execute( event = "eventcachingSuffix.index", renderResults = true )
					var key2   = event2.getPrivateCollection().cbox_eventCacheableEntry.cacheKey

					// the closure must re-evaluate per request, not freeze on the first request's value
					expect( key2 ).toInclude( "beta-present" )
					expect( key2 ).notToBe( key1 )
				} );

				it( "produces the same key on the serve-side lookup and the store-side build", function(){
					getRequestContext().setValue( "slug", "gamma" )
					var event    = execute( event = "eventcachingSuffix.index", renderResults = true )
					var storeKey = event.getPrivateCollection().cbox_eventCacheableEntry.cacheKey

					// re-run the real serve-side path: getEventMetadataEntry() -> buildEventKey()
					controller.getRequestService().eventCachingTest( event )
					var serveKey = event.getPrivateCollection().cbox_eventCacheableEntry.cacheKey

					// if lookup and storage keys disagree, cached responses are never served
					expect( serveKey ).toBe( storeKey )
				} );

				it( "keeps the serve-side and store-side keys in sync even with handlerCaching off", function(){
					var handlerService = controller.getHandlerService()
					handlerService.setHandlerCaching( false )

					try {
						getRequestContext().setValue( "slug", "delta" )
						var event    = execute( event = "eventcachingSuffix.index", renderResults = true )
						var storeKey = event.getPrivateCollection().cbox_eventCacheableEntry.cacheKey

						controller.getRequestService().eventCachingTest( event )
						var serveKey = event.getPrivateCollection().cbox_eventCacheableEntry.cacheKey

						// Both keys must resolve the "present" tag, not just agree with each other -
						// otherwise a bean with unloaded action metadata on BOTH sides would still
						// produce two equal-but-wrong ("delta-missing") keys and this test would miss it.
						expect( storeKey ).toInclude( "delta-present" )
						expect( serveKey ).toBe( storeKey )
					} finally {
						handlerService.setHandlerCaching( true )
					}
				} );

				it( "leaves static string suffixes untouched when resolving", function(){
					var handlerService = controller.getHandlerService()
					makePublic( handlerService, "resolveCacheSuffix" )

					var mdEntry  = { "cacheable" : true, "suffix" : "static" }
					var resolved = handlerService.resolveCacheSuffix(
						mdEntry,
						handlerService.getHandlerBean( "eventcachingSuffix.index" ),
						getRequestContext()
					)

					expect( isSimpleValue( resolved.suffix ) ).toBeTrue()
					expect( resolved.suffix ).toBe( "static" )
				} );

				it( "keeps the closure in the memoized dictionary entry after requests", function(){
					getRequestContext().setValue( "slug", "epsilon" )
					execute( event = "eventcachingSuffix.index", renderResults = true )

					var dictionary = prepareMock( controller.getHandlerService() ).$getProperty(
						"eventCacheDictionary",
						"variables"
					)
					var suffix = dictionary[ "eventcachingSuffix.index" ].suffix

					// the dictionary must keep the closure so later requests can re-evaluate it
					expect( isClosure( suffix ) || isCustomFunction( suffix ) ).toBeTrue()
				} );
			} );
		} );
	}

}
