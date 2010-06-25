<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	The multi-threaded cache manager.

----------------------------------------------------------------------->
<cfcomponent hint="The multi-threaded cache manager." 
			 extends="coldbox.system.cache.archive.CacheManager" 
			 output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<cfscript>
		instance.uuid = createobject("java", "java.util.UUID");
	</cfscript>
	
	<!--- reap the cache --->
	<cffunction name="reap" access="public" output="false" returntype="void" hint="Reap the cache.">
		<cfset var ThreadName = "coldbox.cache.reap_#replace(instance.uuid.randomUUID(),"-","","all")#">
		
		<!--- Reap only if in frequency --->
		<cfif dateDiff("n", getCacheStats().getlastReapDatetime(), now() ) gte getCacheConfig().getReapFrequency() >
			
			<cfthread name="#threadName#">  
				<cfscript>  
					super.reap(); 
				</cfscript>
			</cfthread>
		
		</cfif>
	</cffunction>
	
	<!--- Expire All Objects --->
	<cffunction name="expireAll" access="public" returntype="void" hint="Expire All Objects. Use this instead of clear() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean" required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.expireAll_#replace(instance.uuid.randomUUID(),"-","","all")#">
		<cfif arguments.async>
			<cfthread name="#threadName#">  
				<cfscript>  
					super.expireAll(); 
				</cfscript>
			</cfthread>
		<cfelse>
			<cfscript>
				super.expireAll(argumentCollection=arguments);
			</cfscript>
		</cfif>
	</cffunction>
	
	<!--- Clear All Events --->
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.clearAllEvents_#replace(instance.uuid.randomUUID(),"-","","all")#">
		<cfif arguments.async>
			<cfthread name="#threadName#">  
				<cfscript>  
					super.clearAllEvents();  
				</cfscript>          
			</cfthread>
		<cfelse>
			<cfscript>  
				super.clearAllEvents();  
			</cfscript>
		</cfif>
	</cffunction>
	
	<!--- Clear All Views --->
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.clearAllViews_#replace(instance.uuid.randomUUID(),"-","","all")#">
		<cfif arguments.async>
			<cfthread name="#threadName#">  
				<cfscript>  
					super.clearAllViews();  
				</cfscript>          
			</cfthread>
		<cfelse>
			<cfscript>  
				super.clearAllViews();  
			</cfscript>
		</cfif>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Init the pool --->
	<cffunction name="initPool" access="private" output="false" returntype="void" hint="Initialize and set the internal object Pool">
		<cfscript>
			instance.objectPool = CreateObject("component","coldbox.system.cache.archive.MTObjectPool").init();
		</cfscript>
	</cffunction>
	
</cfcomponent>