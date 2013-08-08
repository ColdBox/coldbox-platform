<cfcomponent extends="coldbox.system.testing.BaseTestCase" cool="true">
<cfscript>
	
	function setup(){
		// matcher
		matcher = getMockBox().createMock("coldbox.system.aop.Matcher").init();
	}
	
	function testMatchClass(){
		var mockMapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping")
			.init('UnitTest')
			.setPath( getMetadata(this).name )
			.$("getObjectMetadata", getMetadata(this) );
		
		// any
		matcher.any();
		assertTrue( matcher.matchClass(this,mockMapping) );
		
		// mappings
		matcher.reset().mappings("test,UnitTest");
		assertTrue( matcher.matchClass(this,mockMapping) );
		matcher.reset().mappings("test,Unit");
		assertFalse( matcher.matchClass(this,mockMapping) );
		
		// regex
		matcher.reset().regex("^cold");
		assertTrue( matcher.matchClass(this,mockMapping) );
		
		// instanceOf
		matcher.reset().instanceOf("mxunit.framework.TestCase");
		assertTrue( matcher.matchClass( createObject("component","MatcherTest") ,mockMapping) );
		
		// annotation
		matcher.reset().annotatedWith("cool");
		assertTrue( matcher.matchClass(this,mockMapping) );
		
		// annotation value
		matcher.reset().annotatedWith("cool",false);
		assertfalse( matcher.matchClass(this,mockMapping) );
		matcher.reset().annotatedWith("cool",true);
		assertTrue( matcher.matchClass(this,mockMapping) );
	}
	
	function testMatchClassAndOr(){
		var mockMapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping")
			.init('UnitTest')
			.setPath( getMetadata(this).name )
			.$("getObjectMetadata", getMetadata(this) );
		
		// New AND Matcher
		andM = getMockBox().createMock("coldbox.system.aop.Matcher").init();
		andM.annotatedWith("cool",false);
		matcher.reset().any().andMatch( andM );
		assertFalse( matcher.matchClass(this,mockMapping) );
		
		// New AND Matcher
		andM = getMockBox().createMock("coldbox.system.aop.Matcher").init();
		andM.annotatedWith("cool");
		matcher.reset().any().andMatch( andM );
		assertTrue( matcher.matchClass(this,mockMapping) );
		
		// New OR Matcher
		orM = getMockBox().createMock("coldbox.system.aop.Matcher").init();
		orM.annotatedWith("cool");
		matcher.reset().mappings('luis').orMatch( orM );
		assertTrue( matcher.matchClass(this,mockMapping) );
		
		// New OR Matcher
		orM = getMockBox().createMock("coldbox.system.aop.Matcher").init();
		orM.annotatedWith("nothing");
		matcher.reset().any().orMatch( orM );
		assertTrue( matcher.matchClass(this,mockMapping) );
		
		// New OR Matcher
		orM = getMockBox().createMock("coldbox.system.aop.Matcher").init();
		orM.annotatedWith("nothing");
		matcher.reset().mappings('test').orMatch( orM );
		assertFalse( matcher.matchClass(this,mockMapping) );
	}

	void function testMatchMethod() cool="true"{
		var mockMapping = getMockBox().createMock("coldbox.system.ioc.config.Mapping")
			.init('UnitTest')
			.setPath( getMetadata(this).name )
			.$("getObjectMetadata", getMetadata(this) );
		var fncmd = getMetadata(variables.testMatchMethod) ;
		
		// any
		matcher.any();
		assertTrue( matcher.matchMethod( fncmd) );
		
		// methods
		matcher.reset().methods("testMatchMethod,test");
		assertTrue( matcher.matchMethod( fncmd) );
		matcher.reset().methods("test,Unit");
		assertFalse( matcher.matchMethod( fncmd) );
		
		// regex
		matcher.reset().regex("^test");
		assertTrue( matcher.matchMethod( fncmd) );

		// annotation
		matcher.reset().annotatedWith("cool");
		assertTrue( matcher.matchMethod( fncmd) );
		
		// annotation value
		matcher.reset().annotatedWith("cool",false);
		assertfalse( matcher.matchMethod( fncmd) );
		matcher.reset().annotatedWith("cool",true);
		assertTrue( matcher.matchMethod( fncmd) );
	}
	
	function testAny(){
		matcher.any();
		assertTrue( matcher.getMemento().any );
	}
	
	function testReturns(){
		matcher.returns("numeric");
		assertEquals( "numeric",  matcher.getMemento().returns );
	}
	
	
	function testAnnotatedWith(){
		matcher.annotatedWith("transactional");
		assertEquals( "transactional",  matcher.getMemento().annotation );
		assertFalse( structKeyExists( matcher.getMemento(), "annotationValue") );
		
		matcher.annotatedWith("transactional",true);
		assertEquals( "transactional",  matcher.getMemento().annotation );
		assertEquals( true, matcher.getMemento().annotationValue );
	}
	
	function testMappings(){
		matcher.mappings("test,test2");
		assertEquals( "test,test2", matcher.getMemento().mappings);
		
		matcher.mappings(["test","test2"]);
		assertEquals( "test,test2", matcher.getMemento().mappings);
	}
	
	function testMethods(){
		matcher.methods("test,test2");
		assertEquals( "test,test2", matcher.getMemento().methods);
		
		matcher.methods(["test","test2"]);
		assertEquals( "test,test2", matcher.getMemento().methods);
	}
	
	function testInstanceOf(){
		matcher.instanceOf("coldbox.system.EventHandler");
		assertEquals( "coldbox.system.EventHandler", matcher.getMemento().instanceOf);
	}
	
	function testRegex(){
		matcher.regex("^[a-z]");
		assertEquals( "^[a-z]", matcher.getMemento().regex);
	}
	
</cfscript>
</cfcomponent>