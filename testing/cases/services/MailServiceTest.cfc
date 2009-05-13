<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
	debugger service tests

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
			this.loadColdbox = false;
			mockController = getMockFactory().createMock("coldbox.system.Controller");
		 	ms = createObject("component","coldbox.system.services.MailService").init(mockController);
		</cfscript>
	</cffunction>
	
	<cffunction name="testnewMail">
		<cfscript>
			mail = ms.newMail();
			
			assertTrue( isObject(mail) );
		</cfscript>
	</cffunction>
	
	<cffunction name="testparseTokens">
		<cfscript>
			mail = ms.newMail();
			tokens = {name="Luis Majano",time=dateformat(now(),"full")};
			mail.setBodyTokens(tokens);
			mail.setBody("Hello @name@, how are you today? Today is the @time@");
			
			makePublic(ms,"parseTokens");
			
			ms.parseTokens(mail);
			
			assertEquals( mail.getBody(), "Hello #tokens.name#, how are you today? Today is the #tokens.time#");
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testSend">
		<cfscript>
			getMockFactory().createMock(objectToMock=ms);
			mockLogger = getMockFactory().createMock("coldbox.system.plugins.Logger");
			ms.mockMethod("getLogger",mockLogger);
			mockLogger.mockMethod("logError");
			
			mail = ms.newMail().config(from="info@coldboxframework.com",to="info@coldboxframework.com");
			tokens = {name="Luis Majano",time=dateformat(now(),"full")};
			mail.setBodyTokens(tokens);
			mail.setBody("Hello @name@, how are you today? Today is the @time@");
			mail.setSubject("Hello Luis");
			mail.addMailParam(name="Disposition-Notification-To",value="info@coldboxframework.com");
			
			//mail.addMailPart(type="text",body="You are reading this message as plain text, because your mail reader does not handle it.");
			//mail.addMailPart(type="html",body=mail.getBody());
			//debug(mail.getmemento());
			//Send it
			rtn = ms.send(mail);
			//debug(rtn);
		</cfscript>
	</cffunction>
	
	
</cfcomponent>