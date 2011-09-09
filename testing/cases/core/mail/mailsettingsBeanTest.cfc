<cfcomponent name="mailsettingsBeanTest" extends="coldbox.system.testing.BaseTestCase">
	
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.mail = createObject("component","coldbox.system.core.mail.MailSettingsBean");		
			
			this.instance.server = "mail.mail.com";
			this.instance.username = "mail";
		    this.instance.password = "pass" ;
			this.instance.port = "110";
			this.instance.protocol = structNew();
			this.instance.from = "info@coldbox.org";
						
			this.mail = this.mail.init(argumentCollection=this.instance);
			
		</cfscript>
	</cffunction>
		
	<!--- Begin specific tests --->
	<cffunction name="testExtraValues" access="public" returnType="void">
		<cfscript>
			assertEquals( this.instance.from, this.mail.getValue('from') );
		</cfscript>	
	</cffunction>
	
	<cffunction name="testWithCustomProtocol" access="public" returnType="void">
		<cfscript>
			// Establish the custom protocol we're going to use.
			this.instance.protocol = {
				class="coldbox.system.core.mail.protocols.cfmailProtocol",
				properties = {}
			};
			
			// Init the settings with this protocol.
			this.mail.init(argumentCollection=this.instance);
		</cfscript>
	</cffunction>	
	
	<cffunction name="testWithUnknownCustomProtocol" access="public" returnType="void" mxunit:expectedException="MailSettingsBean.FailLoadProtocolException">
		<cfscript>
			// Establish the custom protocol we're going to use.
			this.instance.protocol = {
				class="coldbox.system.core.mail.protocols.someUnknownProtocol",
				properties = {}
			};
			
			// Init the settings with this protocol.
			this.mail.init(argumentCollection=this.instance);
		</cfscript>
	</cffunction>
	
	<cffunction name="testWithCustomProtocolWithoutProperties" access="public" returnType="void">
		<cfscript>
			// Establish the custom protocol we're going to use.
			this.instance.protocol = {
				class="coldbox.system.core.mail.protocols.cfmailProtocol"
			};
			
			// Init the settings with this protocol.
			this.mail.init(argumentCollection=this.instance);
		</cfscript>
	</cffunction>	
	
	<cffunction name="testgetmemento" access="public" returnType="void">
		<cfscript>
			this.mail.setMemento(this.instance);
			assertEquals( this.mail.getMemento(), this.instance);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testsetmemento" access="public" returnType="void">
		<cfscript>
			this.mail.setMemento(this.instance);
			assertEquals( this.mail.getMemento(), this.instance);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetPassword" access="public" returnType="void">
		<cfscript>
			assertEquals( this.mail.getPassword(), this.instance.password );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetport" access="public" returnType="void">
		<cfscript>
			assertEquals( this.mail.getPort(), this.instance.port);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetserver" access="public" returnType="void">
		<cfscript>
			assertEquals( this.mail.getServer(), this.instance.server );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetUsername" access="public" returnType="void">
		<cfscript>
			assertEquals( this.mail.getUsername(), this.instance.username );
		</cfscript>
	</cffunction>		
	
	

</cfcomponent>