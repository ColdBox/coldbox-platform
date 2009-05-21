<cfcomponent name="debuggerConfigBeanTest" extends="coldbox.system.testing.BaseTestCase">
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			debug = createObject("component","coldbox.system.beans.DebuggerConfigBean");	
			
			debug.init();
			
			memento.PersistentRequestProfiler = true;
			memento.PersistentTracers = true;
			memento.maxPersistentRequestProfilers = 10;
			memento.maxRCPanelQueryRows = 10;
			memento.showTracerPanel = true;
			memento.expandedTracerPanel =true;
			memento.showInfoPanel = true;
			memento.expandedInfoPanel = true;
			memento.showCachePanel = true;
			memento.expandedCachePanel = true;
			memento.showRCPanel = true;
			memento.expandedRCPanel = true;
			
			debug.populate(debug);	
		</cfscript>
	</cffunction>

	<cffunction name="tearDown">
		
	</cffunction>
	
	<cffunction name="testGetterSetters" access="public" returnType="void">
		<cfscript>
			for(key in memento){
				evaluate("debug.set#key#( memento[key] )");
			}
			
			for(key in memento){
				AssertEquals( memento[key] , evaluate("debug.get#key#( key )" ) );
			}
						
		</cfscript>
	</cffunction>	
	
	<cffunction name="testgetmemento" access="public" returnType="void">
		<cfscript>
			debug.setMemento(memento);
			assertEquals( debug.getMemento(), memento);
		</cfscript>
	</cffunction>		
	
	<cffunction name="testpopulate" access="public" returnType="void">
		<cfscript>
			debug.populate(debug);	
		</cfscript>
	</cffunction>		
	
	<cffunction name="testsetmemento" access="public" returnType="void">
		<cfscript>
			debug.setMemento(memento);
			assertEquals( debug.getMemento(), memento);
		</cfscript>
	</cffunction>		
	

</cfcomponent>

