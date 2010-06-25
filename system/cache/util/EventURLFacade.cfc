<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This cfc acts as an URL/FORM facade for event caching.  The associated cache 
	will have to implement the IColdboxApplicationCache in order to retrieve the right
	prefix keys.


----------------------------------------------------------------------->
<cfcomponent hint="This object acts as an url/form facade for CacheBox event caching" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="EventURLFacade" hint="Constructor">
		<cfargument name="cacheProvider" type="coldbox.system.cache.IColdboxApplicationCache" 	required="true" hint="The cache provider/manager this utility will be associated with"/>
		<cfscript>
			instance = {
				cacheProvider = arguments.cacheProvider
			};
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- getUniqueHash --->
	<cffunction name="getUniqueHash" output="false" access="public" returntype="string" hint="Get's the unique incoming URL hash">
		<!--- **************************************************************************** --->
		<cfargument name="event" type="any" required="true" hint="The event request context to incorporate into the hash"/>
		<!--- **************************************************************************** --->
		<cfscript>
			var urlCopy  = duplicate(URL);
			var formCopy = duplicate(FORM);
			var eventName = arguments.event.getEventName();
			var urlActionsList = "fwReinit,fwCache,debugMode,debugpass,dumpvar,debugpanel";
			var urlColdboxExempt = "currentview,currentlayout,currentroute";
			var x = 1;
			var routedStruct = arguments.event.getRoutedStruct();
			
			// Collide the form vars also
			structAppend(urlCopy,formCopy);
			
			// Remove event if it exists
			if( structKeyExists(urlCopy, eventName) ){
				structDelete(urlCopy,eventName);
			}
			
			// Remove fw URL Actions
			for(x=1; x lte listLen(urlActionsList); x=x+1){
				if( structKeyExists(urlCopy, listgetAt(urlActionsList,x)) ){
					structDelete(urlCopy,listgetAt(urlActionsList,x));
				}
			}
			
			// Multi-Host support
			urlCopy['cgihost'] = cgi.http_host;
			
			// Incorporate Routed Structs
			for( key in routedStruct ){
				urlCopy[key] = routedStruct[key];
			}
			
			// Get a unique key
			return hash(urlCopy.toString());			
		</cfscript>
	</cffunction>
	
	<!--- Build Hash --->
	<cffunction name="buildHash" output="false" access="public" returntype="string" hint="build a unique hash according to event and args">
		<!--- **************************************************************************** --->
		<cfargument name="args"  type="string" required="true" hint="The string of args to incorporate into the hash"/>
		<!--- **************************************************************************** --->
		<cfscript>
			var myStruct = structnew();
			var x =1;
			
			// Multi-Host support
			myStruct['cgihost'] = cgi.http_host;
			
			//Build structure from arg list
			for(x=1;x lte listlen(arguments.args,"&"); x=x+1){
				myStruct[trim(listFirst(listGetAt(arguments.args, x, "&"),'='))] = urlDecode(trim(listLast(listGetAt(arguments.args, x, "&"),'=')));
			}
			
			//return hash
			return hash(myStruct.toString());
		</cfscript>
	</cffunction>
	
	<!--- Build Event Key --->
	<cffunction name="buildEventKey" access="public" returntype="any" hint="Build an event key according to passed in params" output="false" >
		<!--- **************************************************************************** --->
		<cfargument name="keySuffix" 	 required="true" type="any" hint="A handler key suffix if used.">
		<cfargument name="targetEvent" 	 required="true" type="any" hint="The target event string">
		<cfargument name="targetContext" required="true" type="any" hint="The target event context to test.">
		<!--- **************************************************************************** --->
		<cfscript>
			var key = "";
			
			key = buildBasicCacheKey(argumentCollection=arguments) & getUniqueHash(arguments.targetContext);
			
			return key;
		</cfscript>		
	</cffunction>
	
	<!--- Build Event Key --->
	<cffunction name="buildEventKeyNoContext" access="public" returntype="any" hint="Build an event key according to passed in params and no Context" output="false" >
		<!--- **************************************************************************** --->
		<cfargument name="keySuffix" 	 required="true" type="any" 	hint="A handler key suffix if used.">
		<cfargument name="targetEvent" 	 required="true" type="any" 	hint="The target event string">
		<cfargument name="targetArgs"  	 required="true" type="string" 	hint="The string of args to incorporate into the hash"/>
		<!--- **************************************************************************** --->
		<cfscript>
			var key = "";
			
			key = buildBasicCacheKey(argumentCollection=arguments) & buildHash(arguments.targetArgs);
			
			return key;
		</cfscript>		
	</cffunction>
	
	<!--- Build Event Key --->
	<cffunction name="buildBasicCacheKey" access="public" returntype="any" hint="Builds a basic cache key" output="false" >
		<!--- **************************************************************************** --->
		<cfargument name="keySuffix" 	 required="true" type="any" hint="A handler key suffix if used.">
		<cfargument name="targetEvent" 	 required="true" type="any" hint="The target event string">
		<!--- **************************************************************************** --->
		<cfscript>
			var key = "";
			
			key = instance.cacheProvider.getEventCacheKeyPrefix() & arguments.targetEvent & "-" & arguments.keySuffix & "-";
			
			return key;
		</cfscript>		
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->
	
	

</cfcomponent>