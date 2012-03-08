<cfcomponent name="exceptionBeanTest" extends="coldbox.system.testing.BaseTestCase">
	
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.e = createObject("component","coldbox.system.web.context.ExceptionBean");
			
			this.instance.exceptionstruct = structnew();
			this.instance.exceptionstruct.type = "error";
			this.instance.exceptionstruct.message = "unittest";
			this.instance.exceptionstruct.detail = "unittest details";
			this.instance.exceptionstruct.stacktrace = "javax.util.nothing";
			this.instance.exceptionstruct.tagContext = ArrayNew(1);
			this.tagcontext.id = "123";
			this.tagcontext.line = "123";
			this.tagcontext.template = "index.cfm";
			ArrayAppend(this.instance.exceptionstruct.tagContext,this.tagcontext);
			
			this.instance.exceptionstruct.nativeErrorCode = "100";
			this.instance.exceptionstruct.sqlState = "nothing";
			this.instance.exceptionstruct.sql = "select * from nothing";
			this.instance.exceptionstruct.queryError = "Query Error dude";
			this.instance.exceptionstruct.where ="luis = awesome";
			this.instance.exceptionstruct.errNumber = "1234";
			this.instance.exceptionstruct.missingFileName = "luis.cfm";
			this.instance.exceptionstruct.lockName = "luis lock";
			this.instance.exceptionstruct.lockOperation = "read only";
			this.instance.exceptionstruct.errorCode = "123";
			this.instance.exceptionstruct.extendedInfo = "nothing";
			
			this.instance.extraMessage = "Unit Test Error";
			this.instance.extrainfo = "Nothing but testing";
			this.instance.errorType = "application";
	
			this.e.init(this.instance.exceptionStruct, this.instance.extraMessage, this.instance.extraInfo, this.instance.errorType);
		</cfscript>
	</cffunction>
	
	<cffunction name="test$ToString">
		<cfscript>
			r = this.e.$toString();
			assertTrue( len(r) );
			
			// complex extra
			this.e.init(this.instance.exceptionStruct, this.instance.extraMessage, {name="luis",age="10",when=now()}, this.instance.errorType);
			r = this.e.$toString();
			assertTrue( len(r) );
			debug( r );
		</cfscript>
	</cffunction>
	
	<!--- Begin specific tests --->
		
	<cffunction name="testGetters" access="public" returnType="void">
		<cfscript>
			for(key in this.instance){
				evaluate("this.e.get#key#()");
			}	
		</cfscript>
	</cffunction>	
	
	<cffunction name="testgetmemento" access="public" returnType="void">
		<cfscript>
			AssertTrue( isStruct(this.e.getMemento()) );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testsetmemento" access="public" returnType="void">
		<cfscript>
			this.e.setMemento(this.instance);
			assertEquals( this.e.getMemento(), this.instance);
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetType" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getType(), this.instance.exceptionstruct.type );
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetMessage" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getMessage(), this.instance.exceptionstruct.message );
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetDetail" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getDetail(), this.instance.exceptionstruct.detail );
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetStackTrace" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getStackTrace(), this.instance.exceptionstruct.StackTrace );
		</cfscript>
	</cffunction>
	
	<cffunction name="testtagContext" access="public" returnType="void">
		<cfscript>
			tagC = this.e.gettagContext();
			assertEquals( tagC[1].id , this.instance.exceptionstruct.tagContext[1].id );
			assertTrue( isSimpleValue(this.e.getTagContextAsString()) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetNativeErrorCode" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getNativeErrorCode(), this.instance.exceptionstruct.NativeErrorCode );
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetsqlState" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getsqlState(), this.instance.exceptionstruct.sqlState );
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetsql" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getsql(), this.instance.exceptionstruct.sql );
		</cfscript>
	</cffunction>
	<cffunction name="testgetqueryError" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getqueryError(), this.instance.exceptionstruct.queryError );
		</cfscript>
	</cffunction>
	<cffunction name="testgetwhere" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getwhere(), this.instance.exceptionstruct.where );
		</cfscript>
	</cffunction>
	<cffunction name="testgeterrNumber" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.geterrNumber(), this.instance.exceptionstruct.errNumber );
		</cfscript>
	</cffunction>
	<cffunction name="testgetmissingFileName" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getmissingFileName(), this.instance.exceptionstruct.missingFileName );
		</cfscript>
	</cffunction>
	<cffunction name="testgetlockName" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getlockName(), this.instance.exceptionstruct.lockName );
		</cfscript>
	</cffunction>
	<cffunction name="testgetlockOperation" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getlockOperation(), this.instance.exceptionstruct.lockOperation );
		</cfscript>
	</cffunction>
	<cffunction name="testgeterrorCode" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.geterrorCode(), this.instance.exceptionstruct.errorCode );
		</cfscript>
	</cffunction>
	<cffunction name="testextendedInfo" access="public" returnType="void">
		<cfscript>
			assertEquals( this.e.getextendedInfo(), this.instance.exceptionstruct.extendedInfo );
		</cfscript>
	</cffunction>

</cfcomponent>

