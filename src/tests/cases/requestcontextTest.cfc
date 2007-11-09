<cfcomponent name="requestcontextTest" extends="coldbox.system.extras.baseTest" output="false">

	<cffunction name="setUp" returntype="void" access="private" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetCollection" returntype="void" access="Public" output="false">
		<cfscript>
			var event = getRequestContext();
			
			assertTrue( isStruct(event.getCollection()) );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testsetCollection" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			
			event.setCollection(structnew());
			
			AssertEqualsStruct( structnew(), event.getCollection() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testclearCollection" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();
			
			event.setCollection(test);
			event.clearCollection();
			
			AssertEqualsStruct( structnew(), event.getCollection() );
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
			
			AssertEqualsStruct( test, event.getCollection() );
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
			
			AssertEqualsNumber( 1, event.getSize() );
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
			
			AssertEqualsString( test.today , event.getValue("today") );
			
			AssertEqualsString( "null", event.getValue("invalidVar", "null") );
			
			assertTrue( isArray(event.getValue("invalidVar", "[array]") ) );
			
			assertTrue( isQuery ( event.getValue("invalidVar", "[query]")  )) ;
			
			assertTrue( isStruct( event.getValue("invalidVar", "[struct]") ) );
			
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
			
			AssertEqualsString(test.today, event.getValue("test") );
			
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
			AssertEqualsString(test.today, event.getValue("test") );
			
			event.removeValue("test");
			assertEqualsBoolean( false, event.getValue("test", false) );
			
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
			AssertEqualsString( view, event.getCurrentView() );
			
			event.clearCollection();
			
			event.setView(view, true);
			AssertEqualsString( view, event.getCurrentView() );
			AssertEqualsString( '', event.getCurrentLayout() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testCurrentLayout" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var layout = "layout.pdf";
			
			event.clearCollection();
			
			event.setLayout(layout);
			AssertEqualsString( layout, event.getCurrentLayout() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testgetCurrentEventHandlerAction" access="public"returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var defaultEvent = "ehTest.doSomething";
			
			event.setValue("event", defaultEvent);
			
			AssertEqualsString( defaultEvent, event.getCurrentEvent() );
			AssertEqualsString( "ehTest", event.getCurrentHandler() );
			AssertEqualsString( "doSomething", event.getCurrentAction() );
			
			defaultEvent = "blog.content.doSomething";
			
			event.setValue("event", defaultEvent);
			
			AssertEqualsString( defaultEvent, event.getCurrentEvent() );
			AssertEqualsString( "content", event.getCurrentHandler() );
			AssertEqualsString( "doSomething", event.getCurrentAction() );
			
			defaultEvent = "blog.content.security.doSomething";
			
			event.setValue("event", defaultEvent);
			
			AssertEqualsString( defaultEvent, event.getCurrentEvent() );
			AssertEqualsString( "security", event.getCurrentHandler() );
			AssertEqualsString( "doSomething", event.getCurrentAction() );
			
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
			
			AssertEqualsString( newEvent , event.getCurrentEvent() );
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
			
			event.NoRender(true);
			AssertTrue( event.isNoRender() );
			
			event.NoRender(false);
			AssertFalse( event.isNoRender() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testgetEventName" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var test = getController().getSetting("EventName");

			assertEqualsString( test, event.getEventName() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testgetSelf" access="public" output="false" returntype="void">
		<cfscript>
			var event = getRequestContext();
			var test = getController().getSetting("EventName");

			assertEqualsString( "index.cfm?#test#=", event.getSelf() );
			
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
			AssertEqualsStruct(centry, event.getEventCacheableEntry() );
			
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
			AssertEqualsStruct(centry, event.getViewCacheableEntry() );
			
		</cfscript>
	</cffunction>
	

</cfcomponent>