<cfcomponent extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setup" access="public" output="false" returntype="void">
		<cfscript>
			// Define the properties for the protocol.
			props = {
				APIKey = "this_is_my_postmark_api_key"
			};
			
			// Output the properties to the debug.
			debug(props);
			
			// Create a mock instance of the protocol.
			protocol =  getMockBox().createMock(className="coldbox.system.core.mail.AbstractProtocol").init(props);
		</cfscript>
	</cffunction>

	<cffunction name="testSend" access="public" output="false" returntype="void" mxunit:expectedException="AbstractProtocol.AbstractMethodException">
		<cfscript>
			// create a mock payload to pass in.
			payload = getMockBox().createMock(className="coldbox.system.core.mail.Mail").init();
			
			// As this is an abstract method that should be overwritten.
			// We we're hoping it'll throw us a nice exception to chew on.
			protocol.send(payload);
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

</cfcomponent>