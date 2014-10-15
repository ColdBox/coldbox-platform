<cfcomponent extends="coldbox.system.testing.BaseModelTest">

	<cffunction name="setUp">
		<cfscript>
			oRC = createObject("component","coldbox.system.web.context.RequestContext");

			/* Properties */
			props.DefaultLayout = "Main.cfm";
			props.DefaultView = "";
			props.FolderLayouts = structnew();
			props.ViewLayouts = structnew();
			props.EventName = "event";
			props.isSES = false;
			props.sesBaseURL = "http://jfetmac/applications/coldbox/test-harness/index.cfm";
			props.registeredLayouts = structnew();
			props.modules = {
				test1 = {
					mapping = "/coldbox/test-harness"
				}
			};

			/* Init it */
			oRC.init(props, getMockController() );
		</cfscript>
	</cffunction>

	<cffunction name="getRequestContext" access="private">
		<cfreturn oRC>
	</cffunction>

	<cffunction name="testgetCollection">
		<cfscript>
			var event = getRequestContext();

			assertTrue( isStruct(event.getCollection()) );
		</cfscript>
	</cffunction>

	<cffunction name="testclearCollection">
		<cfscript>
			var event = getRequestContext();
			var test = {today=now()};

			event.collectionAppend(test);
			event.clearCollection();

			AssertEquals( structnew(), event.getCollection() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testcollectionAppend">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();

			event.clearCollection();
			event.collectionAppend(test);

			AssertEquals( test, event.getCollection() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testgetSize">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();

			event.clearCollection();
			event.collectionAppend(test);

			AssertEquals( 1, event.getSize() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testgetValue">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();

			event.clearCollection();
			event.collectionAppend(test);

			assertEquals( test.today , event.getValue("today") );

			assertEquals( "null", event.getValue("invalidVar", "null") );

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testsetValue" >
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();

			event.clearCollection();

			event.setValue("test", test.today);

			assertEquals(test.today, event.getValue("test") );

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testremoveValue">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();

			event.clearCollection();

			event.setValue("test", test.today);
			assertEquals(test.today, event.getValue("test") );

			event.removeValue("test");
			assertEquals( false, event.getValue("test", false) );

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testvalueExists">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();

			event.clearCollection();

			event.setValue("test", test.today);
			assertTrue( event.valueExists("test") );

			event.removeValue("test");
			assertFalse( event.valueExists("test") );

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testparamValue"	output="false">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();

			event.clearCollection();

			AssertFalse( event.valueExists("test") );

			event.paramValue("test", test.today);

			assertTrue( event.valueExists("test") );

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testCurrentView" >
		<cfscript>
			var event = getRequestContext();
			var view = "vwHome";

			event.clearCollection();

			event.setView( view=view );
			assertEquals( view, event.getCurrentView() );

			event.clearCollection();

			event.setView(view=view, cache=true);
			assertEquals( view, event.getCurrentView() );
			assertEquals( 'Main.cfm', event.getCurrentLayout() );

			// set view with caching
			event.setView(view="home", cache="True", cacheProvider="luis", cacheTimeout="20", cacheLastAccessTimeout="1", cacheSuffix="test");
			r = event.getViewCacheableEntry();
			//debug( r );

			assertEquals( "home", r.view );
			assertEquals( "20", r.timeout );
			assertEquals( "1", r.lastAccessTimeout );
			assertEquals( "test", r.cacheSuffix );
			assertEquals( "luis", r.cacheProvider );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testCurrentLayout">
		<cfscript>
			var event = getRequestContext();
			var layout = "layout.pdf";

			event.clearCollection();

			event.setLayout(layout);
			assertEquals( layout & ".cfm", event.getCurrentLayout() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testgetCurrentEventHandlerAction"returntype="void">
		<cfscript>
			var event = getRequestContext();
			var defaultEvent = "ehTest.doSomething";

			event.setValue("event", defaultEvent);

			assertEquals( defaultEvent, event.getCurrentEvent() );
			assertEquals( "ehTest", event.getCurrentHandler() );
			assertEquals( "doSomething", event.getCurrentAction() );

			defaultEvent = "blog.content.doSomething";

			event.setValue("event", defaultEvent);

			assertEquals( defaultEvent, event.getCurrentEvent() );
			assertEquals( "content", event.getCurrentHandler() );
			assertEquals( "doSomething", event.getCurrentAction() );

			defaultEvent = "blog.content.security.doSomething";

			event.setValue("event", defaultEvent);

			assertEquals( defaultEvent, event.getCurrentEvent() );
			assertEquals( "security", event.getCurrentHandler() );
			assertEquals( "doSomething", event.getCurrentAction() );

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testoverrideEvent" >
		<cfscript>
			var event = getRequestContext();
			var newEvent = "pio.yea";

			event.clearCollection();
			event.setValue("event","blog.dspEntries");
			event.overrideEvent(newEvent);

			assertEquals( newEvent , event.getCurrentEvent() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testProxyRequest" >
		<cfscript>
			var event = getRequestContext();

			AssertFalse( event.isProxyRequest() );

			event.setProxyRequest();
			AssertTrue( event.isProxyRequest() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testNoRender">
		<cfscript>
			var event = getRequestContext();

			event.NoRender(remove=true);
			AssertFalse( event.isNoRender() );

			event.NoRender(remove=false);
			AssertTrue( event.isNoRender() );

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testgetEventName">
		<cfscript>
			var event = getRequestContext();
			var test = props.eventName;

			assertEquals( test, event.getEventName() );

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testgetSelf">
		<cfscript>
			var event = getRequestContext();
			var test = props.eventname;

			assertEquals( "index.cfm?#test#=", event.getSelf() );

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testEventCacheableEntry">
		<cfscript>
			var event = getRequestContext();
			var centry = structnew();

			AssertFalse( event.isEventCacheable(), "event cacheable");

			centry.cacheable = true;
			centry.test = true;

			event.setEventCacheableEntry(centry);
			AssertTrue( event.isEventCacheable(), "event cacheable 2");
			AssertEquals(centry, event.getEventCacheableEntry() );

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testViewCacheableEntry">
		<cfscript>
			var event = getRequestContext();
			var centry = structnew();

			AssertFalse( event.isViewCacheable(), "view cacheable");

			centry.cacheable = true;
			centry.test = true;

			event.setViewCacheableEntry(centry);
			AssertTrue( event.isViewCacheable(), "view cacheable 2");
			AssertEquals(centry, event.getViewCacheableEntry() );

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testRoutedStruct">
		<cfscript>
			var event = getRequestContext();
			var routedStruct = structnew();

			routedStruct.page = "aboutus";
			routedStruct.day = "13";

			event.setRoutedStruct(routedStruct);

			AssertEquals(event.getRoutedStruct(),routedStruct);

		</cfscript>
	</cffunction>

	<cffunction name="testSES">
		<cfscript>
			var event = getRequestContext();
			base = "http://www.luismajano.com/index.cfm";

			event.setsesBaseURL(base);
			assertEquals( event.getsesBaseURL(), base );

			event.setisSES(true);
			assertEquals( event.isSES(), true );


		</cfscript>
	</cffunction>

	<cffunction name="testBuildLink">
		<cfscript>
			var event = getRequestContext();
			base = "http://www.luismajano.com/index.cfm";
			basessl = "https://www.luismajano.com/index.cfm";

			/* simple setup */
			event.setisSES(false);
			testurl = event.buildLink('general.index');
			AssertEquals(testurl, "index.cfm?event=general.index" );

			/* simple qs */
			event.setisSES(false);
			testurl = event.buildLink(linkTo='general.index',queryString="page=2");
			AssertEquals(testurl, "index.cfm?event=general.index&page=2" );

			/* empty qs */
			event.setisSES(false);
			testurl = event.buildLink(linkTo='general.index',queryString="");
			AssertEquals(testurl, "index.cfm?event=general.index" );

			/* ses test */
			event.setisSES(true);
			event.setsesBaseURL(base);
			testurl = event.buildLink('general/index');
			AssertEquals(testurl, base & "/general/index" );

			/* query string transformation */
			event.setisSES(true);
			event.setsesBaseURL(base);
			testurl = event.buildLink(linkTo='general/index',queryString="page=2&tests=4");
			AssertEquals(testurl, base & "/general/index/page/2/tests/4" );

			/* ssl test */
			event.setisSES(true);
			event.setsesBaseURL(base);
			testurl = event.buildLink(linkto='general/index',ssl=true);
			AssertEquals(testurl, basessl & "/general/index" );
			// SSL OFF
			event.setsesBaseURL(basessl);
			testurl = event.buildLink(linkto='general/index',ssl=false);
			AssertEquals(testurl, base & "/general/index" );

			/* translate */
			event.setisSES(true);
			event.setsesBaseURL(base);
			testurl = event.buildLink(linkto='general.index',translate=false);
			AssertEquals(testurl, base & "/general.index" );

		</cfscript>
	</cffunction>

	<cffunction name="testRenderData">
		<cfscript>
			var event = getRequestContext();

			AssertEquals( event.getRenderData(), structnew());

			// Test JSON
			event.renderData(type='JSON',data="[1,2,3,4]");
			rd = event.getRenderData();
			assertEquals( rd.contenttype, "application/json");
			assertEquals( rd.type, "json");
			assertEquals( rd.jsonQueryFormat, "query");
			assertEquals( rd.statusCode, "200");
			assertEquals( rd.statusText, "");


			event.renderData(type='JSON',data="[1,2,3,4]",jsonQueryFormat="array",jsonCase="upper");
			rd = event.getRenderData();
			assertEquals( rd.jsonQueryFormat, "array");

			//JSONP
			event.renderData(type='JSONP',data="[1,2,3,4]",jsonCallback="testCallback");
			rd = event.getRenderData();
			assertEquals( rd.type, "jsonp");
			assertEquals( rd.jsonCallback, 'testCallback');

			// Test WDDX
			event.renderData(type="WDDX",data=arrayNew(1));
			rd = event.getRenderData();
			assertEquals( rd.contenttype, "text/xml");
			assertEquals( rd.type, "wddx");

			// Test PLAIN
			event.renderData(data="Hello");
			rd = event.getRenderData();
			assertEquals( rd.type, "html");
			assertEquals( rd.contenttype, "text/html");

			// Test XML
			event.renderData(data=structnew(),type="xml");
			rd = event.getRenderData();
			assertEquals( rd.type, "xml");
			assertEquals( rd.contenttype, "text/xml");
			assertEquals( rd.xmlListDelimiter, ",");
			assertEquals( rd.xmlColumnList, "");

			// Test contenttype
			event.renderData(data="Hello",contentType="application/ms-excel");
			rd = event.getRenderData();
			assertEquals( rd.type, "html");
			assertEquals( rd.contenttype, "application/ms-excel");

			// Test StatusCodes
			event.renderData(data="hello",statusCode="400",statusText="Invalid Call!");
			rd = event.getRenderData();
			assertEquals( rd.statusCode, "400");
			assertEquals( rd.statusText, "Invalid Call!");

		</cfscript>
	</cffunction>

	<cffunction name="testNoExecution">
		<cfscript>
			var event = getRequestContext();

			assertFalse( event.isNoExecution() );
			event.noExecution();
			assertTrue( event.isNoExecution() );

		</cfscript>
	</cffunction>

	<cffunction name="testCurrentModule" >
		<cfscript>
			var event = getRequestContext();

			event.setValue("event","myModule:test.home");

			//debug(event.getCurrentEVent());
			assertEquals("myModule", event.getCurrentModule());

			event.setValue("event","test.home");
			assertEquals("", event.getCurrentModule());

		</cfscript>
	</cffunction>


	<cffunction name="testModuleRoot" >
		<cfscript>
			var event = getRequestContext();


			//debug(event.getCurrentEVent());
			assertEquals("", event.getmoduleRoot());
			event.setValue("event","test1:test.home");
			assertEquals(props.modules.test1.mapping, event.getmoduleRoot());


		</cfscript>
	</cffunction>


	<cffunction name="testsetHTTPHeader" >
		<cfscript>
			var event = getRequestContext();

			event.setHTTPHeader(statusCode="200",statusText="Hello");

			event.setHTTPHeader(name="expires",value="#now()#");
		</cfscript>
	</cffunction>

	<cffunction name="testGetHTTPConetnt" >
		<cfscript>
			var event = getRequestContext();

			test = event.getHTTPContent();

			assertTrue( isSimpleValue(test) );

		</cfscript>
	</cffunction>

	<cffunction name="testNoLayout" >
		<cfscript>
			var event = getRequestContext();

			event.noLayout().setView("test");

			//debug( event.getCollection(private=true) );
			assertEquals( true, event.getValue("layoutOverride",false,true) );

		</cfscript>
	</cffunction>


</cfcomponent>