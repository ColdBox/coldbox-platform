<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	Request service Test
----------------------------------------------------------------------->
<cfcomponent name="requestserviceTest" extends="coldbox.system.testing.BaseTestCase" output="false" appMapping="/coldbox/test-harness">
	<cfscript>
		function setup(){
			// load virtual aplication.
			super.setup();
			proxy = CreateObject("component","coldbox.test-harness.coldboxproxy");
		}

		function testRemotingUtil(){
			makePublic(proxy, "getRemotingUtil");
			util = proxy.getRemotingUtil();
			assertTrue( isObject(util) );
		}

		function testNoEvent(){
			//Test With default ProxyReturnCollection = false
			expectException("ColdBoxProxy.NoEventDetected");
			results = proxy.process();
		}

		function testProxyNoCollection(){
			var results = "";

			//Test With default ProxyReturnCollection = false
			results = proxy.process(event='ehProxy.getIntroArrays');
			AssertTrue( isArray(results), "Getting Array");

			//test other process
			results = proxy.process(event='ehProxy.getIntroStructure');
			AssertTrue( isStruct(results), "Getting Structure");
		}

		function testProxyWithCollection(){
			var results = "";

			//Set return setting
			application.cbController.setSetting("ProxyReturnCollection",true);

			//Test With default ProxyReturnCollection = false
			results = proxy.process(event='ehProxy.getIntroArraysCollection');
			AssertTrue( isStruct(results), "Collection Test");
			AssertTrue( isArray(results.myArray), "Getting Array From Collection");

			application.cbController.setSetting("ProxyReturnCollection",false);
		}

		function testProxyInterceptions(){
			var results = "";

			//Announce interception
			makePublic(proxy,"announceInterception");
			results = proxy.announceInterception(state='onLog');
			AssertTrue(results,"onLog intercepted");
		}

		function testTracer(){
			getController().getDebuggerService().resetTracers();
			makePublic(proxy, "tracer");
			proxy.tracer("ProxyTest",{});
			//debug( getController().getDebuggerService().getDebugMode() );
			assertTrue( arrayLen(getController().getDebuggerService().getTracers()) );
		}

		function testVerifyColdBox(){
			makePublic( proxy, "verifyColdBox" );
			assertTrue( proxy.verifyColdBox() );
			structDelete(application, "cbController");
			expectException("ColdBoxProxy.ControllerIllegalState");
			proxy.verifyColdBox();
		}

		function testGetCacheBox(){
			makePublic(proxy,"getCacheBox");
			assertTrue( isObject( proxy.getCacheBox() ) );
		}

		function testGetWireBox(){
			makePublic(proxy,"getWireBox");
			assertTrue( isObject( proxy.getWireBox() ) );
		}

		function testGetInstance(){
			makePublic(proxy,"getModel");
			makePublic(proxy,"getInstance");
			assertTrue( isObject( proxy.getInstance("testModel") ) );
			assertTrue( isObject( proxy.getModel("testModel") ) );
		}

		function testIOCMethods(){
			var local = structnew();

			mockObject  = getMockBox().createStub();
			mockFactory = getMockBox().createEmptyMock("coldbox.system.ioc.adapters.ColdSpringAdapter");
			ioc = getMockBox().prepareMock( getController().getPlugin("IOC") )
				.$("getBean", mockObject)
				.$("getIoCFactory", mockFactory);

			/* Get IOCFactory */
			makePublic(proxy, "getIoCFactory");
			local.obj = proxy.getIoCFactory();

			/* Get Bean */
			makePublic(proxy, "getBean");
			local.obj = proxy.getBean(beanName="testModel");
		}

		function testProxyAppLoading(){
			var local = structnew();

			createObject("component","coldbox.system.core.dynamic.MixerUtil").init().start(proxy);

			local.load = structnew();
			local.load.appMapping = "/coldbox/test-harness";
			local.load.configLocation = "coldbox.test-harness.config.Coldbox";
			local.load.reloadApp = true;
			proxy.invokerMixin(method='loadColdbox',argCollection=local.load);

			local.load = structnew();
			local.load.appMapping = "/coldbox/test-harness";
			local.load.reloadApp = true;

			proxy.invokerMixin(method='loadColdbox',argCollection=local.load);
		}

		function testLogBox(){
			makePublic(proxy,"getLogBox");
			makePublic(proxy,"getRootLogger");
			makePublic(proxy,"getLogger");
			assertEquals(getController().getLogBox(), proxy.getLogBox());
			assertEquals(getController().getLogBox().getRootLogger(), proxy.getRootLogger());
			assertEquals(getController().getLogBox().getLogger('unittest'), proxy.getLogger('unittest'));
		}

		function testGetPlugin(){
			makePublic(proxy,"getPlugin");
			assertTrue( isObject( proxy.getPlugin("Renderer") ) );
			assertTrue( isObject( proxy.getPlugin("date", true) ) );
			assertTrue( isObject( proxy.getPlugin(plugin="ModPlugin",module="test1") ) );
		}

		function testGetInterceptor(){
			makePublic(proxy,"getInterceptor");
			assertTrue( isObject( proxy.getInterceptor("SES") ) );
		}

		function testGetColdBoxOCM(){
			makePublic(proxy,"getColdBoxOCM");
			assertTrue( isObject( proxy.getColdBoxOCM() ) );
			assertTrue( isObject( proxy.getColdBoxOCM("template") ) );

		}
	</cfscript>
</cfcomponent>