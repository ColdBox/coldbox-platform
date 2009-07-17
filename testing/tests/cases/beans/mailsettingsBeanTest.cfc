<cfcomponent name="mailsettingsBeanTest" extends="coldbox.testing.tests.resources.baseMockCase">
	
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.mail = createObject("component","coldbox.system.beans.mailsettingsBean");		
			
			this.instance.server = "mail.mail.com";
			this.instance.username = "mail";
		    this.instance.password = "pass" ;
			this.instance.port = "110";
			
			this.mail = this.mail.init(argumentCollection=this.instance);
			
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
		
	<!--- Begin specific tests --->
	
	<cffunction name="testSetters" access="public" returnType="void">
		<cfscript>
			for(key in this.instance){
				evaluate("this.mail.set#key#( this.instance[key] )");
			}	
			assertEquals( this.instance, this.mail.getMemento() );				
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