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
<cfscript>
	function setup(){
		mockController = getMockBox().createMock(className="coldbox.system.Controller",clearMethod=true);
		ms = getMockBox().createMock(className="coldbox.system.services.MailService").init(mockController);
	}
	function testNewMail(){
		mail = ms.newMail();
	}
	function testparseTokens(){
		mail = ms.newMail();
		tokens = {name="Luis Majano",time=dateformat(now(),"full")};
		mail.setBodyTokens(tokens);
		mail.setBody("Hello @name@, how are you today? Today is the @time@");
		
		makePublic(ms,"parseTokens");
		
		ms.parseTokens(mail);
		
		assertEquals( mail.getBody(), "Hello #tokens.name#, how are you today? Today is the #tokens.time#");
	}
	function testSend(){
		// mockings
		mockLogger = getMockBox().createMock(className="coldbox.system.plugins.Logger",clearMethods=true);
		ms.mockMethod("getLogger",mockLogger);
		mockLogger.$("logError");
		
		// 1:Mail with No Params
		mail = ms.newMail().config(from="info@coldboxframework.com",to="info@coldboxframework.com");
		tokens = {name="Luis Majano",time=dateformat(now(),"full")};
		mail.setBodyTokens(tokens);
		mail.setBody("Hello @name@, how are you today? Today is the @time@");
		mail.setSubject("Hello Luis");
		rtn = ms.send(mail);
		debug(rtn);
		
		// 2:Mail with params
		mail = ms.newMail().config(from="info@coldboxframework.com",to="info@coldboxframework.com",subject="Hello Luis");
		mail.setBody("Hello This is my great unit test");
		mail.addMailParam(name="Disposition-Notification-To",value="info@coldboxframework.com");
		rtn = ms.send(mail);
		debug(rtn);
		
		// 3:Mail multi-part no params
		mail = ms.newMail().config(from="info@coldboxframework.com",to="info@coldboxframework.com",subject="Hello Luis");
		mail.addMailPart(type="text",body="You are reading this message as plain text, because your mail reader does not handle it.");
		mail.addMailPart(type="html",body=mail.getBody());
		rtn = ms.send(mail);
		debug(rtn);
		
		// 4:Mail multi-part with params
		mail = ms.newMail().config(from="info@coldboxframework.com",to="info@coldboxframework.com",subject="Hello Luis");
		mail.addMailPart(type="text",body="You are reading this message as plain text, because your mail reader does not handle it.");
		mail.addMailPart(type="html",body=mail.getBody());
		mail.addMailParam(name="Disposition-Notification-To",value="info@coldboxframework.com");
		rtn = ms.send(mail);
		debug(rtn);
	}
</cfscript>


	
	
</cfcomponent>