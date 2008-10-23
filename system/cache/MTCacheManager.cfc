<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	The multi-threaded cache manager.

Modification History:
01/18/2007 - Created

----------------------------------------------------------------------->
<cfcomponent name="MTCacheManager" 
			 hint="The multi-threaded cache manager." 
			 extends="coldbox.system.cache.CacheManager" 
			 output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- reap the cache --->
	<cffunction name="reap" access="public" output="false" returntype="void" hint="Reap the cache.">
		<cfset var ThreadName = "coldbox.cache.reap_#replace(createUUID(),"-","","all")#">
		
		<!--- Reap only if in frequency --->
		<cfif dateDiff("n", getCacheStats().getlastReapDatetime(), now() ) gte getCacheConfigBean().getCacheReapFrequency() >
			
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
		<cfset var ThreadName = "coldbox.cache.expireAll_#replace(createUUID(),"-","","all")#">
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
	
	<!--- Expire an Object --->
	<cffunction name="expireKey" access="public" returntype="void" hint="Expire an Object. Use this instead of clearKey() from within handlers or any cached object, this sets the metadata for the objects to expire in the next request. Note that this is not an inmmediate expiration. Clear should only be used from outside a cached object" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="objectKey" type="string" required="true">
		<cfargument name="async" 	 type="boolean" required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.expireKey_#replace(createUUID(),"-","","all")#">
		<cfif arguments.async>
			<cfthread name="#threadName#"
					  objectKey="#arguments.objectKey#">  
				<cfscript>  
					super.expireKey(Attributes.objectKey); 
				</cfscript>
			</cfthread>
		<cfelse>
			<cfscript>
				super.expireKey(argumentCollection=arguments);
			</cfscript>
		</cfif>
	</cffunction>
	
	<!--- Expire an Object --->
	<cffunction name="expireByKeySnippet" access="public" returntype="void" hint="Same as expireKey but can touch multiple objects depending on the keysnippet that is sent in." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="keySnippet" type="string" required="true" hint="The key snippet to use">
		<cfargument name="regex" 	  type="boolean" required="false" default="false" hint="Use regex or not">
		<cfargument name="async" 	 type="boolean" required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.expireByKeySnippet_#replace(createUUID(),"-","","all")#">
		<cfif arguments.async>
			<cfthread name="#threadName#"
					  keySnippet="#arguments.keySnippet#"
					  regex="#arguments.regex#">  
				<cfscript>  
					super.expireByKeySnippet(Attributes.objectKey,Attributes.regex); 
				</cfscript>
			</cfthread>
		<cfelse>
			<cfscript>
				super.expireByKeySnippet(argumentCollection=arguments);
			</cfscript>
		</cfif>
	</cffunction>
	
	<!--- Clear by Key Snippet --->
	<cffunction name="clearByKeySnippet" access="public" returntype="void" hint="Clears keys using the passed in object key snippet" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="keySnippet" 	type="string" 	required="true" hint="The key snippet to use to clear keys. It matches using findnocase">
		<cfargument name="regex" 		type="boolean"  required="false" default="false" hint="Use regex or not">
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not, defaults to true"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.clearByKeySnippet_#replace(createUUID(),"-","","all")#">
		<cfif arguments.async>
			<cfthread name="#threadName#"
					  keySnippet="#arguments.keySnippet#"
					  regex="#arguments.regex#">  
				<cfscript>  
					super.clearByKeySnippet(Attributes.keySnippet,Attributes.regex); 
				</cfscript>
			</cfthread>
		<cfelse>
			<cfscript>
				super.clearByKeySnippet(argumentCollection=arguments);
			</cfscript>
		</cfif>
	</cffunction>
	
	<!--- Clear an event --->
	<cffunction name="clearEvent" access="public" output="false" returntype="void" hint="Clears all the event permuations from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="eventsnippet" type="string" required="true" hint="The event snippet to clear on. Can be partial or full">
		<cfargument name="queryString" 	type="string" 	required="false" default="" hint="If passed in, it will create a unique hash out of it. For purging purposes"/>
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.clearEvent_#replace(createUUID(),"-","","all")#">
		<cfif arguments.async>
			<cfthread name="#threadName#"
					  eventsnippet="#arguments.eventsnippet#"
					  queryString="#arguments.queryString#">  
				<cfscript>  
					super.clearEvent(Attributes.eventsnippet,Attributes.queryString); 
				</cfscript>
			</cfthread>
		<cfelse>
			<cfscript>
				super.clearEvent(argumentCollection=arguments);
			</cfscript>
		</cfif>
	</cffunction>
	
	<!--- Clear All Events --->
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.clearAllEvents_#replace(createUUID(),"-","","all")#">
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
	
	<!--- Clear a view --->
	<cffunction name="clearView" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<!--- ************************************************************* --->
		<cfargument name="viewSnippet"  required="true" type="string" hint="The view name snippet to purge from the cache">
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.clearView_#replace(createUUID(),"-","","all")#">
		<cfif arguments.async>
			<cfthread name="#threadName#"
					  viewSnippet="#arguments.viewSnippet#">  
				<cfscript>  
					super.clearView(Attributes.viewSnippet); 
				</cfscript>
			</cfthread>
		<cfelse>
			<cfscript>
				super.clearView(argumentCollection=arguments);
			</cfscript>
		</cfif>
	</cffunction>
	
	<!--- Clear All Views --->
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<!--- ************************************************************* --->
		<cfargument name="async" 		type="boolean"  required="false" default="true" hint="Run asynchronously or not"/>
		<!--- ************************************************************* --->
		<cfset var ThreadName = "coldbox.cache.clearAllViews_#replace(createUUID(),"-","","all")#">
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
			instance.objectPool = CreateObject("component","coldbox.system.cache.MTObjectPool").init();
		</cfscript>
	</cffunction>
	
</cfcomponent>