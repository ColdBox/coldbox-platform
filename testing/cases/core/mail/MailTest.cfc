<cfcomponent name="configBeanTest" extends="coldbox.system.testing.BaseTestCase">
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			mail = createObject("component","coldbox.system.core.mail.Mail").init();
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
	
	<cffunction name="testSetHTML" access="public" returnType="void">
		<cfscript>
			
			mail.config(subject="Hello",from='lmajano@mail.com',to="lmajano@mail.com",body="Hello");
			mail.setHTML('What up Dude');
			
			//debug( mail.getMailParts() );
			assertTrue( arrayLen(mail.getMailParts()) );
			parts = mail.getMailParts();
			assertEquals( 'text/html', parts[1].type );
						
		</cfscript>
	</cffunction>
	
	<cffunction name="testSetText" access="public" returnType="void">
		<cfscript>
			
			mail.config(subject="Hello",from='lmajano@mail.com',to="lmajano@mail.com",body="Hello");
			mail.setText('What up Dude');
			
			//debug( mail.getMailParts() );
			assertTrue( arrayLen(mail.getMailParts()) );
			parts = mail.getMailParts();
			assertEquals( 'text/plain', parts[1].type );
						
		</cfscript>
	</cffunction>
	
	<cffunction name="testSetReceipts" access="public" returnType="void">
		<cfscript>
			
			mail.config(subject="Hello",from='lmajano@mail.com',to="lmajano@mail.com",body="Hello");
			mail.setSendReceipt('lmajano@coldbox.org').setReadReceipt('lmajano@coldbox.org');
			
			//debug( mail.getMailParts() );
			assertTrue( arrayLen(mail.getMailParams()) );
			params = mail.getMailParams();
			assertEquals( 'Return-Receipt-To', params[1].name );
			assertEquals( 'Read-Receipt-To', params[2].name );
						
		</cfscript>
	</cffunction>
	
	<cffunction name="testAddAttachements" access="public" returnType="void">
		<cfscript>
			
			mail.config(subject="Hello",from='lmajano@mail.com',to="lmajano@mail.com",body="Hello");
			files = ['file1','file2'];
			mail.addAttachments(files);
			
			debug( mail.getMailParams() );
			assertTrue( arrayLen(mail.getMailParams()) );
			params = mail.getMailParams();
			assertEquals( files[1], params[1].file );
			assertEquals( files[2], params[2].file );
			
							
		</cfscript>
	</cffunction>

</cfcomponent>

