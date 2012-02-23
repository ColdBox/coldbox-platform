<!---
* The base model test case will use the 'model' annotation as the instantiation path
* and then create it, prepare it for mocking and then place it in the variables scope as 'model'. It is your
* responsibility to update the model annotation instantiation path and init your model.
--->
<cfcomponent extends="coldbox.system.testing.BaseModelTest"  model="coldbox.system.aop.aspects.HibernateTransaction">
<cfscript>
	
	function setup(){
		super.setup();
		hTransaction = model.init();
		
		// mocks
		mockMapping = getMockBox().createEmptyMock("coldbox.system.ioc.config.Mapping");
		mockLogger.$("canDebug",false);
		hTransaction.setLog( mockLogger );
	}
	
	function testInvokeMethodInTransaction(){
		// default Datasource mock
		var md = {
			name = "save", access="public", transactional=""
		};
		// mock invocation
		mockInvocation = getMockBox()
			.createMock("coldbox.system.aop.MethodInvocation")
			.$("proceed")
			.init("save",{data="Hello"},serializeJSON(md),this,'Test',mockMapping,[]);
		
		// already in transaction
		request.cbox_aop_transaction = true;
		hTransaction.invokeMethod( mockInvocation );
		assertTrue( mockInvocation.$once("proceed") );
		assertTrue( mockLogger.$once("canDebug") );
	}
	
	function testInvokeMethodNotInTransaction(){
		// default Datasource mock
		var md = {
			name = "save", access="public", transactional=""
		};
		// mock invocation
		mockInvocation = getMockBox()
			.createMock("coldbox.system.aop.MethodInvocation")
			.$("proceed")
			.init("save",{data="Hello"},serializeJSON(md),this,'Test',mockMapping,[]);
		
		// not in transaction
		structdelete(request,"cbox_aop_transaction");
		hTransaction.invokeMethod( mockInvocation );
		assertTrue( mockInvocation.$once("proceed") );
		assertTrue( mockLogger.$once("canDebug") );
	}
	
	function testInvokeMethodNotInTransactionDiffDatasource(){
		// With Datasource mock
		var md = {
			name = "save", access="public", transactional="coolblog"
		};
		// mock invocation
		mockInvocation = getMockBox()
			.createMock("coldbox.system.aop.MethodInvocation")
			.$("proceed")
			.init("save",{data="Hello"},serializeJSON(md),this,'Test',mockMapping,[]);
		
		// not in transaction
		structdelete(request,"cbox_aop_transaction");
		hTransaction.invokeMethod( mockInvocation );
		assertTrue( mockInvocation.$once("proceed") );
		assertTrue( mockLogger.$once("canDebug") );
	}
	
	
	
</cfscript>	
</cfcomponent>
