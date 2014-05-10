<cfcomponent name="DebuggerConfigTest" extends="coldbox.system.testing.BaseTestCase">

	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			debugconfig = createObject("component","coldbox.system.web.config.DebuggerConfig");

			debugconfig.init();

			memento.PersistentRequestProfiler = true;
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

			debugconfig.populate(memento);
		</cfscript>
	</cffunction>

	<cffunction name="tearDown">

	</cffunction>

	<cffunction name="testGetterSetters" access="public" returnType="void">
		<cfscript>
			for(key in memento){
				evaluate("debugconfig.set#key#( memento[key] )");
			}

			for(key in memento){
				AssertEquals( memento[key] , evaluate("debugconfig.get#key#( key )" ) );
			}

		</cfscript>
	</cffunction>

	<cffunction name="testgetmemento" access="public" returnType="void">
		<cfscript>
			debugconfig.setMemento(memento);
			assertEquals( debugconfig.getMemento(), memento);
		</cfscript>
	</cffunction>

	<cffunction name="testpopulate" access="public" returnType="void">
		<cfscript>
			debugConfig.setMemento(structnew());
			debugconfig.populate(memento);
			debug(debugconfig.getMemento());
		</cfscript>
	</cffunction>

	<cffunction name="testsetmemento" access="public" returnType="void">
		<cfscript>
			debugconfig.setMemento(memento);
			assertEquals( debugconfig.getMemento(), memento);
		</cfscript>
	</cffunction>


</cfcomponent>

