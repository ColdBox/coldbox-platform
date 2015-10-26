<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	A ColdBox utility to help clean cached objects for ColdBox Application Caches
----------------------------------------------------------------------->
<cfcomponent output="false" hint="A ColdBox utility to help clean cached objects for ColdBox Application Caches">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="init" access="public" output="false" returntype="ElementCleaner" hint="Constructor">
		<cfargument name="cacheProvider" type="any" required="true" hint="The associated cache manager/provider of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
		<cfscript>
			variables.cacheProvider = arguments.cacheProvider;
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get Associated Cache --->
	<cffunction name="getAssociatedCache" access="public" output="false" returntype="any" hint="Get the associated cache provider/manager of type: coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider">
		<cfreturn cacheProvider>
	</cffunction>
	
	<!--- Clear By Key Snippet --->
	<cffunction name="clearByKeySnippet" access="public" returntype="void" hint="Clears keys using the passed in object key snippet" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="keySnippet"  	required="true"  hint="the cache key snippet to use">
		<cfargument name="regex" 		required="false" default="false" hint="Use regex or not">
		<!--- ************************************************************* --->
		<cfscript>
			var cacheKeys 		= getAssociatedCache().getKeys();
			var cacheKeysLength = arrayLen(cacheKeys);
			var x 		= 1;
			var tester 	= 0;
			var thisKey = "";
			
			// sort array
			arraySort(cacheKeys, "textnocase");
			
			for(x=1; x lte cacheKeysLength; x++){
				// Get List Value
				thisKey = cacheKeys[x];
				
				// Using Regex
				if( arguments.regex ){
					tester = refindnocase( arguments.keySnippet, thisKey );
				}
				else{
					tester = findnocase( arguments.keySnippet, thisKey );
				}
				
				// Test Evaluation
				if ( tester ){
					getAssociatedCache().clear( thisKey );
				}
			}
		</cfscript>
	</cffunction>
	
	<!--- Clear an event --->
	<cffunction name="clearEvent" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to snippet and querystring. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<cfargument name="eventsnippet" required="true" hint="The event snippet to clear on. Can be partial or full">
		<cfargument name="queryString" 	required="false" default="" hint="If passed in, it will create a unique hash out of it. For purging purposes"/>
		<cfscript>
			//.*- = the cache suffix and appendages for regex to match
			var cacheKey = getAssociatedCache().getEventCacheKeyPrefix() & replace(arguments.eventsnippet,".","\.","all") & ".*-.*";
														  
			//Check if we are purging with query string
			if( len(arguments.queryString) neq 0 ){
				cacheKey = cacheKey & "-" & getAssociatedCache().getEventURLFacade().buildHash(arguments.queryString);
			}
			
			// Clear All Events by Criteria
			clearByKeySnippet(keySnippet=cacheKey,regex=true);
		</cfscript>
	</cffunction>
	
	<!--- Clear an event Multi --->
	<cffunction name="clearEventMulti" access="public" output="false" returntype="void" hint="Clears all the event permutations from the cache according to the list of snippets and querystrings. Be careful when using incomplete event name with query strings as partial event names are not guaranteed to match with query string permutations">
		<cfargument name="eventsnippets"    required="true"  hint="The comma-delimmitted list event snippet to clear on. Can be partial or full">
		<cfargument name="queryString"      required="false" default="" hint="The comma-delimmitted list of queryStrings passed in. If passed in, it will create a unique hash out of it. For purging purposes.  If passed in the list length must be equal to the list length of the event snippets passed in."/>
		<cfscript>
			var regexCacheKey 	= "";
			var x 			  	= 1;
			var cacheKey	  	= "";
			var keyPrefix 		= getAssociatedCache().getEventCacheKeyPrefix();
			var eventURLFacade	= getAssociatedCache().getEventURLFacade();
			
			// normalize snippets
			if( isArray(arguments.eventSnippets) ){
				arguments.eventsnippets = arrayToList( arguments.eventsnippets );
			}
			
			// Loop on the incoming snippets
			for(x=1;x lte listLen(arguments.eventsnippets);x=x+1){
			    
				  //.*- = the cache suffix and appendages for regex to match
			      cacheKey = keyPrefix & replace(listGetAt(arguments.eventsnippets,x),".","\.","all") & "-.*";
			      
				  //Check if we are purging with query string
			      if( len(arguments.queryString) neq 0 ){
			            cacheKey = cacheKey & "-" & eventURLFacade.buildHash(listGetAt(arguments.queryString,x));
			      }
			      regexCacheKey = regexCacheKey & cacheKey;
			     
				  //check that we aren't at the end of the list, and the | char to the regex as the OR statement
			      if (x NEQ listLen(arguments.eventsnippets)) {
			            regexCacheKey = regexCacheKey & "|";
			      }
			}
			
			// Clear All Events by Criteria
			clearByKeySnippet(keySnippet=regexCacheKey,regex=true);
		</cfscript>
      </cffunction>
	
	<!--- Clear All the Events form the cache --->
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<cfscript>
			var cacheKey = getAssociatedCache().getEventCacheKeyPrefix();
			
			// Clear All Events
			clearByKeySnippet(keySnippet=cacheKey,regex=false);
		</cfscript>
	</cffunction>

	<!--- clear View --->
	<cffunction name="clearView" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<cfargument name="viewSnippet"  required="true" hint="The view name snippet to purge from the cache">
		<cfscript>
			var cacheKey = getAssociatedCache().getViewCacheKeyPrefix() & arguments.viewSnippet;
			
			// Clear All View snippets
			clearByKeySnippet(keySnippet=cacheKey,regex=false);
		</cfscript>
	</cffunction>
	
	<!--- clearViewMulti --->
	<cffunction name="clearViewMulti" output="false" access="public" returntype="void" hint="Clears all view name permutations from the cache according to the view name.">
		<cfargument name="viewSnippets" required="true"  hint="The comma-delimmitted list or array of view snippet to clear on. Can be partial or full">
		<cfscript>
			var regexCacheKey 	= "";
			var x 			  	= 1;
			var cacheKey	  	= "";
			var keyPrefix 		= getAssociatedCache().getViewCacheKeyPrefix();
			
			// normalize snippets
			if( isArray(arguments.viewSnippets) ){
				arguments.viewSnippets = arrayToList( arguments.viewSnippets );
			}
			
			// Loop on the incoming snippets
			for(x=1;x lte listLen(arguments.viewSnippets);x=x+1){
			    
				  //.*- = the cache suffix and appendages for regex to match
			      cacheKey = keyPrefix & replace(listGetAt(arguments.viewSnippets,x),".","\.","all") & "-.*";
			      
				  //Check if we are purging with query string
			      regexCacheKey = regexCacheKey & cacheKey;
			     
				  //check that we aren't at the end of the list, and the | char to the regex as the OR statement
			      if (x NEQ listLen(arguments.viewSnippets)) {
			            regexCacheKey = regexCacheKey & "|";
			      }
			}
			
			// Clear All Events by Criteria
			clearByKeySnippet(keySnippet=regexCacheKey,regex=true);
		</cfscript>
	</cffunction>	

	<!--- Clear All The Views from the Cache. --->
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<cfscript>
			var cacheKey = getAssociatedCache().getViewCacheKeyPrefix();
			
			// Clear All the views
			clearByKeySnippet(keySnippet=cacheKey,regex=false);
		</cfscript>
	</cffunction>	

</cfcomponent>