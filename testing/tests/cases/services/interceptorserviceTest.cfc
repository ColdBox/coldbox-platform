<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
	plugin service test cases.

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="interceptorserviceTest" extends="coldbox.system.extras.testing.baseMXUnitTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		
		this.iservice = getController().getInterceptorService();
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetrequestBuffer" output="false">
		<cfscript>
			AssertTrue( isObject(this.iService.getRequestBuffer()));
		</cfscript>
	</cffunction>
	
	<cffunction name="testInterceptionPoints" access="public" returntype="void" output="false">
		<cfscript>
		
		//test registration again
		AssertTrue( listLen(this.iservice.getInterceptionPoints()) gt 0 );
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetStateContainer" access="public" returntype="void" output="false">
		<cfscript>
		
		state = this.iservice.getStateContainer('nothing');
		
		AssertFalse( isObject(state) );
		
		state = this.iservice.getStateContainer('preProcess');
		
		AssertTrue( isObject(state) );
				
		</cfscript>
	</cffunction>
	
	<cffunction name="testUnregister" access="public" returntype="void" output="false">
		<cfscript>
		
		state = this.iservice.getStateContainer('preProcess');
		
		this.iservice.unregister('coldbox.system.interceptors.ses','preProcess');
		
		interceptor = state.getInterceptor(this.iservice.INTERCEPTOR_CACHEKEY_PREFIX & 'coldbox.system.interceptors.ses');
		
		AssertFalse( isObject(interceptor) );	
		
		</cfscript>
	</cffunction>
	
	
	<cffunction name="testregisterInterceptors" access="public" returntype="void" output="false">
		<cfscript>
		var states = "";
		
		//test registration again
		makePublic(this.iservice,"createInterceptionStates","_createInterceptionStates");
		this.iservice._createInterceptionStates();
		AssertTrue( structIsEmpty(this.iservice.getInterceptionStates()));
		
		/* Register */
		this.iservice.registerInterceptors();
		states = this.iservice.getinterceptionStates();
		
		AssertFalse( structIsEmpty(states) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testAppendInterceptionPoints" access="public" returntype="void" output="false">
		<cfscript>
		var points = this.iservice.getINterceptionPoints();
		
		this.iservice.appendInterceptionPoints('unitTest');
		
		AssertTrue( listLen(this.iservice.getINterceptionPoints()), listLen(points)+1);
		
		this.iservice.appendInterceptionPoints('unitTest');
		AssertTrue( listLen(this.iservice.getINterceptionPoints()), listLen(points)+1);
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testSimpleProcessInterception" access="public" returntype="void" output="false">
		<cfscript>
		
		this.iservice.processState("preProcess");
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testProcessInterception" access="public" returntype="void" output="false">
		<cfscript>
		var md = structnew();
		
		md.test = "UNIT TESTING";
		md.today = now();
		
		this.iservice.processState("preProcess",md);
		
		this.iservice.getRequestBuffer().append('luis');
		
		this.iservice.processState("preProcess",md);
		</cfscript>
	</cffunction>
	
	<cffunction name="testProcessInterceptionWithBuffer" access="public" returntype="void" output="false">
		<cfscript>
		var md = structnew();
		
		md.test = "UNIT TESTING";
		md.today = now();
			
		this.iservice.getRequestBuffer().append('luis');
		
		this.iservice.processState("preProcess",md);
		
		
		</cfscript>
	</cffunction>
	
	<cffunction name="testProcessInvalidInterception" access="public" returntype="void" output="false">
		<cfscript>
		var md = structnew();
		
		try{
			this.iservice.processState("nada loco",md);
		}
		catch("Framework.InterceptorService.InvalidInterceptionState" e){
			AssertTrue(true);
		}
		catch(Any e){
			fail(e.message & e.detail);
		}
		</cfscript>
	</cffunction>
	
	<cffunction name="testManualRegistration" access="public" returntype="void" output="false">
		<cfscript>
			this.iservice.appendInterceptionPoints('unitTest');
			this.iservice.registerInterceptor(interceptorClass='coldbox.testing.testinterceptors.mock');
			
			AssertTrue( isObject(this.iservice.getStateContainer('unittest')) );
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testManualObjectRegistration" access="public" returntype="void" output="false">
		<cfscript>
			var obj = CreateObject("component","coldbox.testing.testinterceptors.mock");
			
			this.iservice.appendInterceptionPoints('unitTest');
			this.iservice.registerInterceptor(interceptorObject=obj);
			
			AssertTrue( isObject(this.iservice.getStateContainer('unittest')) );
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testManualObjectRegistration2" access="public" returntype="void" output="false">
		<cfscript>
			var obj = CreateObject("component","coldbox.testing.testinterceptors.mock");
			
			this.iservice.registerInterceptor(interceptorObject=obj,customPoints='unitTest');
			
			AssertTrue( isObject(this.iservice.getStateContainer('unittest')) );
			
		</cfscript>
	</cffunction>
	
	
	
	
</cfcomponent>