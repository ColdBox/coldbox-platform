<cfcomponent extends="coldbox.system.testing.BaseInterceptorTest" interceptor="coldbox.system.interceptors.Autowire">
<cfscript>

	function setup(){
		super.setup();
		autowire = interceptor;		
	}
	
	function testConfigure(){
		//mocks
		bf = getMockBox().createEmptyMock("coldbox.system.plugins.BeanFactory");
		autowire.$("getPlugin").$args("BeanFactory").$results(bf);
	
		autowire.configure();
		props = autowire.getProperties();
		assertEquals( false, props.annotationCheck );
		assertEquals( "onDIComplete", props.completeDIMethodName );
		assertEquals( false, props.enableSetterInjection );
		assertEquals( '', props.entityExclude );
		assertEquals( '', props.entityInclude );
		assertEquals( false, props.entityInjection);
	}
	
	function testAfterAspectsLoad(){
		//mocks
		ints = { 
			interceptors = [
				{class="coldbox.system.interceptors.SES",name="SES"}
			]
		};
		modules = {
			test1 = {
				interceptors = [
					{class="coldbox.testharness.modules.test1.interceptors.Simple",name="Simple"}
				]
			}
		};
		
		autowire.$("getSetting").$args("InterceptorConfig").$results( ints );
		autowire.$("getSetting").$args("Modules").$results( modules );
		autowire.$("processAutowire");
		autowire.$("getInterceptor",this);
		
		autowire.afterAspectsLoad( getMockRequestContext(), structnew() );
		
		assertTrue( arrayLen(autowire.$callLog().processAutowire) );
	}
	
	function testafterHandlerCreation(){
		autowire.$("processAutowire");
		data = {
			handlerPath = "test.path",
			oHandler = this
		};
		autowire.afterHandlerCreation( getMockRequestContext(), data );
		assertTrue( arrayLen(autowire.$callLog().processAutowire) );
	}
	
	function testafterPluginCreation(){
		autowire.$("processAutowire");
		data = {
			pluginPath = "test.path",
			oPlugin = this,
			custom = false
		};
		autowire.afterPluginCreation( getMockRequestContext(), data );
		assertTrue( arrayLen(autowire.$callLog().processAutowire) );
	}

	function testORMPostNew(){
		autowire.$("processEntityInjection");
		data = {
			entity = this
		};
		autowire.ORMPostNew( getMockRequestContext(), data );
		assertTrue( arrayLen(autowire.$callLog().processEntityInjection) );
	}
	
	function testORMPostLoad(){
		autowire.$("processEntityInjection");
		data = {
			entity = this
		};
		autowire.ORMPostLoad( getMockRequestContext(), data );
		assertTrue( arrayLen(autowire.$callLog().processEntityInjection) );
	}
	
	function testProcessEntityInjection(){
		autowire.$("processAutowire");
		data = {
			entity = this,
			entityName = "AutowireTest"
		};
		
		makePublic(autowire, "processEntityInjection");
		
		// Test Allow
		autowire.setProperty("entityInjection",true);
		autowire.setProperty("entityInclude","");
		autowire.setProperty("entityExclude","");
		autowire.processEntityInjection( getMockRequestContext(), data );
		assertTrue( arrayLen(autowire.$callLog().processAutowire) );
		
		// Test Include Allow
		autowire.setProperty("entityInclude","AutowireTest");
		autowire.processEntityInjection( getMockRequestContext(), data );
		assertTrue( arrayLen(autowire.$callLog().processAutowire) eq 2 );
		
		// Test Exclude Disallow
		autowire.setProperty("entityInclude","");
		autowire.setProperty("entityExclude","AutowireTest");
		autowire.processEntityInjection( getMockRequestContext(), data );
		assertTrue( arrayLen(autowire.$callLog().processAutowire) eq 2 );
	}

</cfscript>
</cfcomponent>
