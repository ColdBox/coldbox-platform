<cfcomponent name="cfmlengine" output="false" extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	function setup(){
		manager = getMockBox().createMock("coldbox.system.core.events.EventPoolManager");
		manager.init( listToArray('onTest') );
	}
	function testProperties(){
		assertEquals( manager.getEventStates(), "onTest");
		assertEquals( manager.getStopRecursionClasses(), "");
		assertTrue( structIsEmpty( manager.getEventPoolContainer() ));
		
		manager.appendCustomStates("onError");
		assertEquals( manager.getEventStates(), "onTest,onError");
	}
	
	function testRegisterUnregister(){
		event = createObject("component","Event");
		
		//1
		manager.register(event);
		assertEquals( manager.getObject("Event"), event);
		assertTrue( isObject(manager.getEventPool("onTest")) );
		manager.unregister("Event");
		try{
			manager.getObject("Event");
			fail("Event still exists"); 
		}
		catch("EventPoolManager.ObjectNotFound" e){
		}
		catch(Any e){ fail("wrong throw"); }
		
		manager.register(event);
		
		// 2 type registration
		manager.register(event,"luis");		
		assertEquals( manager.getObject("luis"), event);
		assertTrue( isObject(manager.getEventPool("onTest")) );
		manager.unregister("luis");
		try{
			manager.getObject("luis");
			fail("Event still exists"); 
		}
		catch("EventPoolManager.ObjectNotFound" e){}
		catch(Any e){ fail("wrong throw"); }
		
		// 3 type registration
		manager.register(event,"luis","onCreate");		
		assertEquals( manager.getObject("luis"), event);
		assertTrue( isObject(manager.getEventPool("onCreate")) );
		manager.unregister("luis");
		try{
			manager.getObject("luis");
			fail("Event still exists"); 
		}
		catch("EventPoolManager.ObjectNotFound" e){}
		catch(Any e){ fail("wrong throw"); }
		
		// 4 type registration Annotation
		manager.register(event,"luis");		
		assertEquals( manager.getObject("luis"), event);
		assertTrue( isObject(manager.getEventPool("onAnnotation")) );
		manager.unregister("luis");
		try{
			manager.getObject("luis");
			fail("Event still exists"); 
		}
		catch("EventPoolManager.ObjectNotFound" e){}
		catch(Any e){ fail("wrong throw"); }
	}
	function testProcessStates(){
		event = createObject("component","Event");
		manager.register(event);
		
		manager.processState("onAnnotation");
		manager.processState("onCreate");
		manager.processState("onTest");
		
		//debug(event.logs);
		assertTrue( arrayLen( event.logs) );
	}
</cfscript>

</cfcomponent>