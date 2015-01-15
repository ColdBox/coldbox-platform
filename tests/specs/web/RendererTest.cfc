component extends="coldbox.system.testing.BaseTestCase" appMapping="/cbtestharness"{

	function setup(){
		super.setup();
		r = getController().getRenderer();
	}

	function testRenderViewWithCache(){
		var results = r.renderView(view="simpleView",cache=true,cacheTimeout="5");
		debug( results );

		var results2 = r.renderView(view="simpleView",cache=true,cacheTimeout="5");
		assertEquals( results, results2 );
	}

	function testRenderViewWithCacheProviders(){
		var results 	= r.renderView( view="simpleView", cache=true, cacheTimeout="5", cacheProvider="default" );
		var results2 	= r.renderView( view="simpleView", cache=true, cacheTimeout="5", cacheProvider="default" );
		assertEquals( results, results2 );
	}

	function testRenderExternalView(){
		var results = r.renderExternalView("/cbtestharness/external/testViews/externalview");
		assertTrue( findnocase("external",results) );
	}

	function testRenderExternalViewWithCaching(){
		var results = r.renderExternalView(view="/cbtestharness/external/testViews/externalview",cache="true",cacheTimeout="5");
		var results2 = r.renderExternalView(view="/cbtestharness/external/testViews/externalview",cache="true",cacheTimeout="5");
		assertEquals( results, results2 );
	}

	function testRenderExternalViewWithCachingProviders(){
		results = r.renderExternalView(view="/cbtestharness/external/testViews/externalview", cache="true", cacheTimeout="5", cacheProvider="default");
		results2 = r.renderExternalView(view="/cbtestharness/external/testViews/externalview", cache="true", cacheTimeout="5", cacheProvider="default");
		assertEquals( results, results2 );
	}

}