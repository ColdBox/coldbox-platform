<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	September 3, 2007
Description :
	debugger service tests

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent extends="coldbox.system.testing.BasePluginTest" output="false" plugin="coldbox.system.plugins.MailService">
<cfscript>
	function setup(){
		super.setup();
		
		//namespace the plugin test target
		ms = plugin;
		
		mockSettings = getMockBox().createMock("coldbox.system.core.mail.MailSettingsBean").init();
		ms.$("settingExists",true);
		ms.$("getMailSettings", mockSettings );
		ms.$("getSetting").$args("mailservice_tokenMarker").$results("@");
		
		ms = ms.init();		
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
	function testparseTokensCustom(){
		ms.setTokenMarker("$");
		mail = ms.newMail();
		tokens = {name="Luis Majano",time=dateformat(now(),"full")};
		mail.setBodyTokens(tokens);
		mail.setBody("Hello $name$, how are you today? Today is the $time$");
		
		makePublic(ms,"parseTokens");
		
		ms.parseTokens(mail);
		
		assertEquals( mail.getBody(), "Hello #tokens.name#, how are you today? Today is the #tokens.time#");
	}
	function testSend(){
		// mockings
		mockLogger = getMockBox().createMock(className="coldbox.system.plugins.Logger",clearMethods=true);
		ms.$property("log","variables",mockLogger);
		mockLogger.$("error");
		
		// 1:Mail with No Params
		mail = ms.newMail().config(from="info@coldboxframework.com",to="lmajano@gmail.com",type="html");
		tokens = {name="Luis Majano",time=dateformat(now(),"full")};
		mail.setBodyTokens(tokens);
		mail.setBody("<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>");
		mail.setSubject("Mail NO Params-Hello Luis");
		rtn = ms.send(mail);
		debug(rtn);
		
		// 2:Mail with params
		mail = ms.newMail().config(from="info@coldboxframework.com",to="lmajano@gmail.com",subject="Mail With Params - Hello Luis");
		mail.setBody("Hello This is my great unit test");
		mail.addMailParam(name="Disposition-Notification-To",value="info@coldboxframework.com");
		mail.addMailParam(name="Importance",value="High");
		rtn = ms.send(mail);
		debug(rtn);
		
		// 3:Mail multi-part no params
		mail = ms.newMail().config(from="info@coldboxframework.com",to="lmajano@gmail.com",subject="Mail MultiPart No Params - Hello Luis");
		mail.addMailPart(type="text",body="You are reading this message as plain text, because your mail reader does not handle it.");
		mail.addMailPart(type="html",body="This is the body of the message.");
		rtn = ms.send(mail);
		debug(rtn);
		
		// 4:Mail multi-part with params
		mail = ms.newMail().config(from="info@coldboxframework.com",to="lmajano@gmail.com",subject="Mail MultiPart With Params - Hello Luis");
		mail.addMailPart(type="text",body="You are reading this message as plain text, because your mail reader does not handle it.");
		mail.addMailPart(type="html",body="This is the body of the message.");
		mail.addMailParam(name="Disposition-Notification-To",value="info@coldboxframework.com");
		rtn = ms.send(mail);
		debug(rtn);
	}
</cfscript>
</cfcomponent>