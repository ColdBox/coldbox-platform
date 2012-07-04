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

	</cfscript>

</cfcomponent>
