<cfcomponent name="eventhandlerBeanTest" extends="coldbox.testing.tests.resources.baseMockCase">
	
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.ehbean = createObject("component","coldbox.system.beans.eventhandlerBean");	
			
			this.instance.invocationPath = "coldbox.testharness";
			this.instance.handler = "general";
			this.instance.method = "index";
			this.instance.isPrivate = false;
			this.instance.isMissingAction = false;
			this.instance.MissingAction = "nothing";
			
			this.ehbean.init(this.instance.invocationPath);
			this.ehbean.setMemento(this.instance);
			
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>
	
	<!--- Begin specific tests --->
	
	<cffunction name="testSetters" access="public" returnType="void">
		<cfscript>
			for(key in this.instance){
				evaluate("this.ehBean.set#key#( this.instance[key] )");
			}	
			assertEquals( this.instance, this.ehBean.getMemento() );				
		</cfscript>
	</cffunction>	
	
	<cffunction name="testgetmemento" access="public" returnType="void">
		<cfscript>
			this.ehbean.setMemento(this.instance);
			assertEquals( this.ehbean.getMemento(), this.instance);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testsetmemento" access="public" returnType="void">
		<cfscript>
			this.ehbean.setMemento(this.instance);
			assertEquals( this.ehbean.getMemento(), this.instance);
		</cfscript>
	</cffunction>	
	
	<cffunction name="testgetFullEvent" access="public" returnType="void">
		<cfscript>
			assertEquals( this.ehBean.getFullEvent(), this.instance.handler & "." & this.instance.method );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetHandler" access="public" returnType="void">
		<cfscript>
			assertEquals( this.ehBean.getHandler(), this.instance.handler );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetInvocationPath" access="public" returnType="void">
		<cfscript>
			assertEquals( this.ehBean.getInvocationPath(), this.instance.invocationPath);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetisMissingAction" access="public" returnType="void">
		<cfscript>
			assertEquals( this.ehBean.getMissingAction(), this.instance.missingAction);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetisPrivate" access="public" returnType="void">
		<cfscript>
			assertEquals( this.ehBean.getisPrivate(), this.instance.isPrivate );
		</cfscript>
	</cffunction>		
			
	
	<cffunction name="testgetMethod" access="public" returnType="void">
		<cfscript>
			assertEquals( this.ehBean.getMethod(), this.instance.method );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetmissingAction" access="public" returnType="void">
		<cfscript>
			assertEquals( this.ehBean.getMissingAction(), this.instance.missingAction );
		</cfscript>
	</cffunction>		
	
	<cffunction name="testgetRunnable" access="public" returnType="void">
		<cfscript>
			assertEquals( this.ehBean.getRunnable(), this.instance.invocationPath & "." & this.instance.handler );
		</cfscript>
	</cffunction>		
		

</cfcomponent>