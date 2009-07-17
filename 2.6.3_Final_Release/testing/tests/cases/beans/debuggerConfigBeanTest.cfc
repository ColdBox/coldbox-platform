<cfcomponent name="debuggerConfigBeanTest" extends="coldbox.testing.tests.resources.baseMockCase">
	
	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.debug = createObject("component","coldbox.system.beans.debuggerConfigBean");	
			
			this.debug.init();
			
			this.memento.PersistentRequestProfiler = true;
			this.memento.maxPersistentRequestProfilers = 10;
			this.memento.maxRCPanelQueryRows = 10;
			this.memento.showTracerPanel = true;
			this.memento.expandedTracerPanel =true;
			this.memento.showInfoPanel = true;
			this.memento.expandedInfoPanel = true;
			this.memento.showCachePanel = true;
			this.memento.expandedCachePanel = true;
			this.memento.showRCPanel = true;
			this.memento.expandedRCPanel = true;
			
			this.debug.populate(this.debug);	
		</cfscript>
	</cffunction>

	<cffunction name="tearDown" returntype="void" access="public">
		<!--- Any code needed to return your environment to normal goes here --->
	</cffunction>

	
	<!--- Begin specific tests --->
	
	<cffunction name="testGetterSetters" access="public" returnType="void">
		<cfscript>
			for(key in this.memento){
				evaluate("this.debug.set#key#( this.memento[key] )");
			}
			
			for(key in this.memento){
				AssertEquals( this.memento[key] , evaluate("this.debug.get#key#( key )" ) );
			}
						
		</cfscript>
	</cffunction>	
	
	<cffunction name="testgetmemento" access="public" returnType="void">
		<cfscript>
			this.debug.setMemento(this.memento);
			assertEquals( this.debug.getMemento(), this.memento);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testpopulate" access="public" returnType="void">
		<cfscript>
			this.debug.populate(this.debug);	
		</cfscript>
	</cffunction>		
	
	<cffunction name="testsetmemento" access="public" returnType="void">
		<cfscript>
			this.debug.setMemento(this.memento);
			assertEquals( this.debug.getMemento(), this.memento);
		</cfscript>
	</cffunction>		
	

</cfcomponent>

