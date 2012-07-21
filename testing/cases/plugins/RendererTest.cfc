<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	November 10, 2008
Description :
	securityTest
----------------------------------------------------------------------->
<cfcomponent name="AntiSamyTest" extends="coldbox.system.testing.BaseTestCase" output="false" appMapping="/coldbox/testharness">

	<cfscript>
		function setup(){
			super.setup();
		}

		function testRenderViewWithCache(){
			var r = getController().getPlugin("Renderer");
			results = r.renderView(view="simpleView",cache=true,cacheTimeout="5");
			debug( results );
			results2 = r.renderView(view="simpleView",cache=true,cacheTimeout="5");
			assertEquals( results, results2 );
		}

		function testRenderViewWithCacheProviders(){
			var r = getController().getPlugin("Renderer");
			results = r.renderView(view="navigation",cache=true,cacheTimeout="5", cacheProvider="default");
			debug( results );
			results2 = r.renderView(view="navigation",cache=true,cacheTimeout="5", cacheProvider="default");
			assertEquals( results, results2 );
			assertTrue( getCacheBox().getCache("default").lookup("cbox_view-:navigation") );
		}

		function testRenderExternalView(){
			var r = getController().getPlugin("Renderer");
			results = r.renderExternalView("/coldbox/testing/testviews/externalview");
			assertTrue( findnocase("external",results) );
		}

		function testRenderExternalViewWithCaching(){
			var r = getController().getPlugin("Renderer");
			results = r.renderExternalView(view="/coldbox/testing/testviews/externalview",cache="true",cacheTimeout="5");
			results2 = r.renderExternalView(view="/coldbox/testing/testviews/externalview",cache="true",cacheTimeout="5");
			assertEquals( results, results2 );
		}

		function testRenderExternalViewWithCachingProviders(){
			var r = getController().getPlugin("Renderer");
			results = r.renderExternalView(view="/coldbox/testing/testviews/externalview", cache="true", cacheTimeout="5", cacheProvider="default");
			results2 = r.renderExternalView(view="/coldbox/testing/testviews/externalview", cache="true", cacheTimeout="5", cacheProvider="default");
			assertEquals( results, results2 );
			debug( getCacheBox().getCache("default").getKeys() );
			assertTrue( getCacheBox().getCache("default").lookup("cbox_view-external-/coldbox/testing/testviews/externalView") );
		}

	</cfscript>

</cfcomponent>
