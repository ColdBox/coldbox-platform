<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
			oRC = createObject("component","coldbox.system.web.context.RequestContext");
			
			/* Properties */
			props.DefaultLayout = "Main.cfm";
			props.DefaultView = "";
			props.FolderLayouts = structnew();
			props.ViewLayouts = structnew();
			props.EventName = "event";
			props.isSES = false;
			props.sesBaseURL = "http://jfetmac/applications/coldbox/testharness/index.cfm";
			props.registeredLayouts = structnew();
			props.modules = {
				test1 = {
					mapping = "/coldbox/testharness"
				}
			};
			
			/* Init it */
			oRC.init(props);
		</cfscript>
	</cffunction>
	
	<cffunction name="getRequestContext" access="private" returntype="any" hint="" output="false" >
		<cfreturn oRC>
	</cffunction>
	
	<cffunction name="testgetCollection" returntype="void" access="Public" output="false">
		<cfscript>
			var event = getRequestContext();
			
			assertTrue( isStruct(event.getCollection()) );
		</cfscript>
	</cffunction>

	<cffunction name="testclearCollection" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var test = {today=now()};
			
			event.collectionAppend(test);
			event.clearCollection();
			
			AssertEquals( structnew(), event.getCollection() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testcollectionAppend" access="public" returntype="void" output="false">
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

	<cffunction name="testgetSize" access="public" returntype="void" output="false">
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

	<cffunction name="testgetValue" returntype="void" access="Public" output="false">
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

	<cffunction name="testsetValue" access="Public"  output="false" returntype="void">
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

	<cffunction name="testremoveValue" access="Public" output="false" returntype="void">
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

	<cffunction name="testvalueExists" returntype="void" access="Public" output="false">
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

	<cffunction name="testparamValue" returntype="void" access="Public"	output="false">
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

	<cffunction name="testCurrentView" access="public"  returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var view = "vwHome";
			
			event.clearCollection();
			
			event.setView(view);
			assertEquals( view, event.getCurrentView() );
			
			event.clearCollection();
			
			event.setView(view, true);
			assertEquals(view, event.getCurrentView() );
			assertEquals('', event.getCurrentLayout() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testCurrentLayout" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var layout = "layout.pdf";
			
			event.clearCollection();
			
			event.setLayout(layout);
			assertEquals( layout & ".cfm", event.getCurrentLayout() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testgetCurrentEventHandlerAction" access="public"returntype="void" output="false">
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
	
	<cffunction name="testoverrideEvent" access="Public"  output="false" returntype="void">
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
	
	<cffunction name="testshowdebugpanel" access="public" returntype="void">
		<cfscript>
			var event = getRequestContext();
			
			event.showDebugPanel(true);
			AssertTrue( event.getDebugPanelFlag() );
			
			event.showDebugPanel(false);
			AssertFalse( event.getDebugPanelFlag() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testProxyRequest" access="public" returntype="void" >
		<cfscript>
			var event = getRequestContext();
			
			AssertFalse( event.isProxyRequest() );
			
			event.setProxyRequest();
			AssertTrue( event.isProxyRequest() );
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testNoRender" access="public" returntype="void">
		<cfscript>
			var event = getRequestContext();
			
			event.NoRender(remove=true);
			AssertFalse( event.isNoRender() );
			
			event.NoRender(remove=false);
			AssertTrue( event.isNoRender() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testgetEventName" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var test = props.eventName;

			assertEquals( test, event.getEventName() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testgetSelf" access="public" output="false" returntype="void">
		<cfscript>
			var event = getRequestContext();
			var test = props.eventname;

			assertEquals( "index.cfm?#test#=", event.getSelf() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testEventCacheableEntry" access="public" output="false" returntype="void">
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
	
	<cffunction name="testViewCacheableEntry" access="public" output="false" returntype="void">
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
	
	<cffunction name="testRoutedStruct" access="public" output="false" returntype="void">
		<cfscript>
			var event = getRequestContext();
			var routedStruct = structnew();
			
			routedStruct.page = "aboutus";
			routedStruct.day = "13";
			
			event.setRoutedStruct(routedStruct);
			
			AssertEquals(event.getRoutedStruct(),routedStruct);
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testSES" access="public" output="false" returntype="void">
		<cfscript>
			var event = getRequestContext();
			base = "http://www.luismajano.com/index.cfm";
			
			event.setsesBaseURL(base);
			assertEquals( event.getsesBaseURL(), base );
			
			event.setisSES(true);
			assertEquals( event.isSES(), true );
			
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testBuildLink" access="public" output="false" returntype="void">
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
			testurl = event.buildLink(linkTo='general/index',queryString="page=2&test=4");
			AssertEquals(testurl, base & "/general/index/page/2/test/4" );
			
			/* ssl test */
			event.setisSES(true);
			event.setsesBaseURL(base);
			testurl = event.buildLink(linkto='general/index',ssl=true);
			AssertEquals(testurl, basessl & "/general/index" );	
			
			/* translate */
			event.setisSES(true);
			event.setsesBaseURL(base);
			testurl = event.buildLink(linkto='general.index',translate=false);
			AssertEquals(testurl, base & "/general.index" );	
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testRenderData" access="public" output="false" returntype="void">
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
	
	<cffunction name="testCurrentModule" access="public"  returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			
			event.setValue("event","myModule:test.home");
			
			//debug(event.getCurrentEVent());
			assertEquals("myModule", event.getCurrentModule());
			
			event.setValue("event","test.home");
			assertEquals("", event.getCurrentModule());
			
		</cfscript>
	</cffunction>
	
	
	<cffunction name="testModuleRoot" access="public"  returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			
			
			//debug(event.getCurrentEVent());
			assertEquals("", event.getmoduleRoot());
			event.setValue("event","test1:test.home");
			assertEquals(props.modules.test1.mapping, event.getmoduleRoot());
			
			
		</cfscript>
	</cffunction>
	
	
	<cffunction name="testsetHTTPHeader" access="public"  returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			
			event.setHTTPHeader(statusCode="200",statusText="Hello");
			
			event.setHTTPHeader(name="expires",value="#now()#");
		</cfscript>
	</cffunction>
	
	<cffunction name="testGetHTTPConetnt" access="public"  returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			
			test = event.getHTTPContent();
			
			assertTrue( isSimpleValue(test) );
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testNoLayout" access="public"  returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			
			event.noLayout().setView("test");
			
			//debug( event.getCollection(private=true) );
			assertEquals( true, event.getValue("layoutOverride",false,true) );
			
		</cfscript>
	</cffunction>
	
	
</cfcomponent>