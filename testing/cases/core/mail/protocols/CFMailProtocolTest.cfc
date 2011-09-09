<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setup" access="public" output="false" returntype="void">
		<cfscript>
			// Set any properties this protocol might need.
			props = {};
			
			debug(props);
			
			// Create a mock instance of the protocol.
			protocol =  getMockBox().createMock(className="coldbox.system.core.mail.protocols.CFMailProtocol").init(props);
		</cfscript>
	</cffunction>
	
	<cffunction name="testIsInited" access="public" output="false" returntype="void">
		<cfscript>
			// We only want the key to be local.
			var key = "";

			// We want to check that all the properties we've handed it have been set.
			for (key in props) {
				// Assert that the property has been set.
				assertTrue(protocol.propertyExists(key), "The propery (#key#) doesn't appear to have been set in the protocol.");
			}
		</cfscript>
	</cffunction>	

	<cffunction name="testSend" access="public" output="false" returntype="void">
		<cfscript>
			// 1:Mail with No Params
			payload = getMockBox().createMock(className="coldbox.system.core.mail.Mail").init().config(from="info@coldboxframework.com",to="lmajano@gmail.com",type="html");
			tokens = {name="Luis Majano",time=dateformat(now(),"full")};
			payload.setBodyTokens(tokens);
			payload.setBody("<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>");
			payload.setSubject("Mail NO Params-Hello Luis");
			rtn = protocol.send(payload);
			
		
			// 2:Mail with params
			payload = getMockBox().createMock(className="coldbox.system.core.mail.Mail").init().config(from="info@coldboxframework.com",to="lmajano@gmail.com",subject="Mail With Params - Hello Luis");
			payload.setBody("Hello This is my great unit test");
			payload.addMailParam(name="Disposition-Notification-To",value="info@coldboxframework.com");
			payload.addMailParam(name="Importance",value="High");
			rtn = protocol.send(payload);
			debug(rtn);
			
			// 3:Mail multi-part no params
			payload = getMockBox().createMock(className="coldbox.system.core.mail.Mail").init().config(from="info@coldboxframework.com",to="lmajano@gmail.com",subject="Mail MultiPart No Params - Hello Luis");
			payload.addMailPart(type="text",body="You are reading this message as plain text, because your mail reader does not handle it.");
			payload.addMailPart(type="html",body="This is the body of the message.");
			rtn = protocol.send(payload);
			debug(rtn);
			
			// 4:Mail multi-part with params
			payload = getMockBox().createMock(className="coldbox.system.core.mail.Mail").init().config(from="info@coldboxframework.com",to="lmajano@gmail.com",subject="Mail MultiPart With Params - Hello Luis");
			payload.addMailPart(type="text",body="You are reading this message as plain text, because your mail reader does not handle it.");
			payload.addMailPart(type="html",body="This is the body of the message.");
			payload.addMailParam(name="Disposition-Notification-To",value="info@coldboxframework.com");
			rtn = protocol.send(payload);
			debug(rtn);
		</cfscript>
	</cffunction>

</cfcomponent>