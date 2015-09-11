<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
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
		<cfargument name="cacheProvider" type="any" required="true" hint="The cache provider/manager this utility will be associated with as type: coldbox.system.cache.IColdboxApplicationCache" colddoc:generic="coldbox.system.cache.IColdboxApplicationCache"/>
		<cfscript>
			instance = {
				cacheProvider = arguments.cacheProvider
			};
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- getUniqueHash --->
	<cffunction name="getUniqueHash" output="false" access="public" returntype="any" hint="Get's the unique incoming URL hash">
		<!--- **************************************************************************** --->
		<cfargument name="event" required="true" hint="The event request context to incorporate into the hash"/>
		<!--- **************************************************************************** --->
		<cfscript>
			var targetMixer		 = structnew();
			var key 			 = "";
			
			// Get the original incoming context hash
			targetMixer['incomingHash'] = arguments.event.getValue(name="cbox_incomingContextHash",private=true);
			
			// Multi-Host support
			targetMixer['cgihost'] = cgi.http_host;
			
			// Incorporate Routed Structs
			structAppend(targetMixer, arguments.event.getRoutedStruct(),true);
			
			// Return unique identifier
			return hash(targetMixer.toString());			
		</cfscript>
	</cffunction>
	
	<!--- Build Hash --->
	<cffunction name="buildHash" output="false" access="public" returntype="any" hint="build a unique hash according to event and args">
		<!--- **************************************************************************** --->
		<cfargument name="args"  required="true" hint="The string of args to incorporate into the hash"/>
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
		<cfargument name="keySuffix" 	 required="true" hint="A handler key suffix if used.">
		<cfargument name="targetEvent" 	 required="true" hint="The target event string">
		<cfargument name="targetContext" required="true" hint="The target event context to test.">
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
		<cfargument name="keySuffix" 	 required="true" 	hint="A handler key suffix if used.">
		<cfargument name="targetEvent" 	 required="true" 	hint="The target event string">
		<cfargument name="targetArgs"  	 required="true" 	hint="The string of args to incorporate into the hash"/>
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
		<cfargument name="keySuffix" 	 required="true" hint="A handler key suffix if used.">
		<cfargument name="targetEvent" 	 required="true" hint="The target event string">
		<!--- **************************************************************************** --->
		<cfscript>
			var key = "";
			
			key = instance.cacheProvider.getEventCacheKeyPrefix() & arguments.targetEvent & "-" & arguments.keySuffix & "-";
			
			return key;
		</cfscript>		
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>