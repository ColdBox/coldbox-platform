<cfcomponent extends="coldbox.system.testing.BaseInterceptorTest" interceptor="coldbox.system.interceptors.Deploy">
<cfscript>

	function setup(){
		super.setup();
		
		// mocks
		mockController.$("getAppRootPath",expandPath('/coldbox/testharness'));
		interceptor.setProperty("tagFile","config/.deploy_tag");
		interceptor.$("locateFilePath","config/.deploy_tag").$("setSetting");
		
	}

	function testConfigure(){
		interceptor.configure();
	}
	
	function testAfterAspectsLoad(){
		mockLogger.$("info");
		interceptor.afterAspectsLoad(getMockRequestContext());
	}
	
	function testPostProcess(){
	
		//mocks
		mockController.$("getColdboxInitiated",true).$("setColdboxInitiated").$("setAspectsInitiated");
		testDate = now();
		mockLogger.$("info").$("error");
		interceptor.$property("tagFilePath","instance",'config/.deployTag');
		interceptor.$property("deployCommandObject","instance",'');
		
		// Test no setting
		interceptor.$("settingExists",false).$("configure");
		
		interceptor.postProcess(getMockRequestContext());
		assertEquals( 1, arrayLen(interceptor.$callLog().configure) );
		
		// Test setting exists but same date
		interceptor.$("getSetting",testDate).$("fileLastModified",testDate).$("settingExists",true);
		interceptor.postProcess(getMockRequestContext());
		assertEquals( 0, arrayLen(mockController.$callLog().setColdboxInitiated) );
		
		// Test it works
		interceptor.$("getSetting",testDate).$("fileLastModified",testDate+10).$("settingExists",true);
		interceptor.postProcess(getMockRequestContext());
		assertEquals( 1, arrayLen(mockController.$callLog().setColdboxInitiated) );
		
		
	}
	
	
</cfscript>	
</cfcomponent>
