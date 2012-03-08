<cfcomponent name="configBeanTest" extends="coldbox.system.testing.BaseTestCase">
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.cbean = createObject("component","coldbox.system.core.collections.ConfigBean");		
			
			this.settings = structnew();
			
			this.settings.date = now();
			this.settings.name = "luis";
			
			this.cbean = this.cbean.init(this.settings);
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- Begin specific tests --->
	
	<cffunction name="testgetConfigStruct" access="public" returnType="void">
		<cfscript>
			assertEquals( this.cbean.getConfigStruct(), this.settings);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetKey" access="public" returnType="void">
		<cfscript>
			assertEquals( this.cbean.getKey('date'), this.settings.date);
			
			try{
				this.cbean.getKey('nothing');
				fail('it should have failed');	
			}
			catch(Any e){
			
			}
		</cfscript>
	</cffunction>		
	
	<cffunction name="testkeyExists" access="public" returnType="void">
		<cfscript>
			assertEquals( this.cbean.keyExists('nothing'),false );
			
			assertEquals( this.cbean.keyExists('date'),true );
			
		</cfscript>
	</cffunction>		
	
	<cffunction name="testsetconfigStruct" access="public" returnType="void">
		<cfscript>
			this.cbean.setConfigStruct(this.settings);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testsetKey" access="public" returnType="void">
		<cfscript>
			this.cbean.setKey('dynamic', 1234);
			
			assertEquals( this.cbean.getKey('dynamic'), 1234);
		</cfscript>
	</cffunction>		
	

	

</cfcomponent>

