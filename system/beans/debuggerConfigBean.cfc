<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	This configures the coldbox debugger

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="debuggerConfigBean"
			 hint="I hold a coldbox debugger configuration data."
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfscript>
		variables.instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" hint="constructor" returntype="debuggerConfigBean">
	    <cfscript>
		    return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get memento --->
	<cffunction name="getmemento" access="public" output="false" returntype="struct" hint="Get memento">
		<cfreturn instance/>
	</cffunction>
	<cffunction name="setmemento" access="public" output="false" returntype="void" hint="Set memento">
		<cfargument name="memento" type="struct" required="true"/>
		<cfset instance = arguments.memento/>
	</cffunction>

	<!--- Request Profiler --->
	<cffunction name="getPersistentRequestProfiler" access="public" output="false" returntype="boolean" hint="Get PersistentRequestProfiler">
		<cfreturn instance.PersistentRequestProfiler/>
	</cffunction>
	<cffunction name="setPersistentRequestProfiler" access="public" output="false" returntype="void" hint="Set PersistentRequestProfiler">
		<cfargument name="PersistentRequestProfiler" type="boolean" required="true"/>
		<cfset instance.PersistentRequestProfiler = arguments.PersistentRequestProfiler/>
	</cffunction>
	
	<!--- Max Request Profilers --->
	<cffunction name="getmaxPersistentRequestProfilers" access="public" output="false" returntype="numeric" hint="Get maxPersistentRequestProfilers">
		<cfreturn instance.maxPersistentRequestProfilers/>
	</cffunction>
	<cffunction name="setmaxPersistentRequestProfilers" access="public" output="false" returntype="void" hint="Set maxPersistentRequestProfilers">
		<cfargument name="maxPersistentRequestProfilers" type="numeric" required="true"/>
		<cfset instance.maxPersistentRequestProfilers = arguments.maxPersistentRequestProfilers/>
	</cffunction>
	
	<!--- Max RCPanel query rows --->
	<cffunction name="getmaxRCPanelQueryRows" access="public" output="false" returntype="numeric" hint="Get maxRCPanelQueryRows">
		<cfreturn instance.maxRCPanelQueryRows/>
	</cffunction>
	<cffunction name="setmaxRCPanelQueryRows" access="public" output="false" returntype="void" hint="Set maxRCPanelQueryRows">
		<cfargument name="maxRCPanelQueryRows" type="numeric" required="true"/>
		<cfset instance.maxRCPanelQueryRows = arguments.maxRCPanelQueryRows/>
	</cffunction>
	
	<!--- show Tracer Panel --->
	<cffunction name="getshowTracerPanel" access="public" output="false" returntype="boolean" hint="Get showTracerPanel">
		<cfreturn instance.showTracerPanel/>
	</cffunction>	
	<cffunction name="setshowTracerPanel" access="public" output="false" returntype="void" hint="Set showTracerPanel">
		<cfargument name="showTracerPanel" type="boolean" required="true"/>
		<cfset instance.showTracerPanel = arguments.showTracerPanel/>
	</cffunction>
	
	<!--- expanded Tracer Panel --->
	<cffunction name="getexpandedTracerPanel" access="public" output="false" returntype="boolean" hint="Get expandedTracerPanel">
		<cfreturn instance.expandedTracerPanel/>
	</cffunction>
	<cffunction name="setexpandedTracerPanel" access="public" output="false" returntype="void" hint="Set expandedTracerPanel">
		<cfargument name="expandedTracerPanel" type="boolean" required="true"/>
		<cfset instance.expandedTracerPanel = arguments.expandedTracerPanel/>
	</cffunction>
	
	<!--- Show DebugInfo panel --->
	<cffunction name="getshowInfoPanel" access="public" output="false" returntype="boolean" hint="Get showInfoPanel">
		<cfreturn instance.showInfoPanel/>
	</cffunction>
	<cffunction name="setshowInfoPanel" access="public" output="false" returntype="void" hint="Set showInfoPanel">
		<cfargument name="showInfoPanel" type="boolean" required="true"/>
		<cfset instance.showInfoPanel = arguments.showInfoPanel/>
	</cffunction>
	
	<!--- Expanded info panel --->
	<cffunction name="getexpandedInfoPanel" access="public" output="false" returntype="boolean" hint="Get expandedInfoPanel">
		<cfreturn instance.expandedInfoPanel/>
	</cffunction>
	<cffunction name="setexpandedInfoPanel" access="public" output="false" returntype="void" hint="Set expandedInfoPanel">
		<cfargument name="expandedInfoPanel" type="boolean" required="true"/>
		<cfset instance.expandedInfoPanel = arguments.expandedInfoPanel/>
	</cffunction>
	
	<!--- show CachePanel --->
	<cffunction name="getshowCachePanel" access="public" output="false" returntype="boolean" hint="Get showCachePanel">
		<cfreturn instance.showCachePanel/>
	</cffunction>
	<cffunction name="setshowCachePanel" access="public" output="false" returntype="void" hint="Set showCachePanel">
		<cfargument name="showCachePanel" type="boolean" required="true"/>
		<cfset instance.showCachePanel = arguments.showCachePanel/>
	</cffunction>
	
	<!--- Expanded --->
	<cffunction name="getexpandedCachePanel" access="public" output="false" returntype="boolean" hint="Get expandedCachePanel">
		<cfreturn instance.expandedCachePanel/>
	</cffunction>
	<cffunction name="setexpandedCachePanel" access="public" output="false" returntype="void" hint="Set expandedCachePanel">
		<cfargument name="expandedCachePanel" type="boolean" required="true"/>
		<cfset instance.expandedCachePanel = arguments.expandedCachePanel/>
	</cffunction>
	
	<!--- show --->
	<cffunction name="getshowRCPanel" access="public" output="false" returntype="boolean" hint="Get showRCPanel">
		<cfreturn instance.showRCPanel/>
	</cffunction>
	<cffunction name="setshowRCPanel" access="public" output="false" returntype="void" hint="Set showRCPanel">
		<cfargument name="showRCPanel" type="boolean" required="true"/>
		<cfset instance.showRCPanel = arguments.showRCPanel/>
	</cffunction>
	
	<!--- expanded --->
	<cffunction name="getexpandedRCPanel" access="public" output="false" returntype="boolean" hint="Get expandedRCPanel">
		<cfreturn instance.expandedRCPanel/>
	</cffunction>
	<cffunction name="setexpandedRCPanel" access="public" output="false" returntype="void" hint="Set expandedRCPanel">
		<cfargument name="expandedRCPanel" type="boolean" required="true"/>
		<cfset instance.expandedRCPanel = arguments.expandedRCPanel/>
	</cffunction>
	
	<!--- Populate from struct --->
	<cffunction name="populate" access="public" returntype="void" hint="Populate with a memento">
		<!--- ************************************************************* --->
		<cfargument name="memento"  required="true" type="struct" 	hint="The structure to populate the object with.">
		<!--- ************************************************************* --->
		<cfscript>
			var key = "";
			
			/* Populate Bean */
			for(key in arguments.memento){
				/* Check if setter exists */
				if( structKeyExists(this,"set" & key) ){
					evaluate("set#key#(arguments.memento[key])");
				}
			}
		</cfscript>
	</cffunction>
	
</cfcomponent>