<cfcomponent name="configBeanTest" extends="coldbox.system.testing.BaseTestCase">
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			mail = createObject("component","coldbox.system.beans.Mail").init();
		</cfscript>
	</cffunction>
	
	<!--- Begin specific tests --->	
	<cffunction name="testConfig" access="public" returnType="void">
		<cfscript>
			mail.config(from="lmajano@mail.com");
			
			assertEquals( "lmajano@mail.com", mail.getFrom() );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testBodyTokens" access="public" returnType="void">
		<cfscript>
			assertTrue( structisEmpty(mail.getBodyTokens()) );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testMailParts" access="public" returnType="void">
		<cfscript>
			assertFalse( arrayLen(mail.getMailParts()) );
			
			mail.addmailPart(type="mypart",body="this is my body");
			
			assertTrue( arrayLen(mail.getMailParts()) );
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testMailParams" access="public" returnType="void">
		<cfscript>
			assertFalse( arrayLen(mail.getMailParams()) );
			
			mail.addMailParam(contentid="123",type="file",file="c:\test.tmp");
			
			assertTrue( arrayLen(mail.getMailParams()) );
			
		</cfscript>
	</cffunction>		

	<cffunction name="testValidate" access="public" returnType="void">
		<cfscript>
			
			assertFalse( mail.validate() );
			
			mail.config(subject="Hello",from='lmajano@mail.com',to="lmajano@mail.com",body="Hello");
			
			assertTrue( mail.validate() );
			
		</cfscript>
	</cffunction>

</cfcomponent>

