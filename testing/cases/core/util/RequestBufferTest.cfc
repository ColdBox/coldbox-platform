<cfcomponent name="RequestBufferTest" output="false" extends="coldbox.system.testing.BaseTestCase">
	
	<!--- setup --->
	<cffunction name="setup" output="false" access="public" returntype="any" hint="">
		<cfscript>
			rb = CreateObject("component","coldbox.system.core.util.RequestBuffer").init("1.5");
		</cfscript>
	</cffunction>
	
	<cffunction name="testisBufferInScope" output="false">
		<cfscript>
			AssertFalse(rb.isBufferInScope());
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetBufferObject" output="false">
		<cfscript>
			AssertTrue( isObject(rb.getBufferObject()));
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetString" output="false">
		<cfscript>
			rb.getBufferObject().append('luis');
			assertEquals(rb.getString(),'luis');
		</cfscript>
	</cffunction>
	
	<cffunction name="testlength" output="false">
		<cfscript>
			rb.getBufferObject().append('luis');
			assertEquals(rb.length(),4);
		</cfscript>
	</cffunction>
	
	<cffunction name="testappend" output="false">
		<cfscript>
			rb.append('luis');
			assertEquals(rb.length(),4);
			rb.append('majano');
			assertEquals(rb.length(),10);
		</cfscript>
	</cffunction>
	
	<cffunction name="testclear" output="false">
		<cfscript>
			rb.append('luis');
			assertEquals(rb.length(),4);
			rb.clear();
			assertEquals(rb.length(),0);
		</cfscript>
	</cffunction>
	

</cfcomponent>