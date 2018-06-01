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
		<cfargument name="cacheProvider" type="any" required="true" hint="The cache provider/manager this utility will be associated with as type: coldbox.system.cache.IColdboxApplicationCache" doc_generic="coldbox.system.cache.IColdboxApplicationCache"/>
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
			var incomingHash = hash(
				arguments.event.getCollection().filter( function( key, value ){
					// Remove event, not needed for hashing purposes
					return ( key != "event" );
				} ).toString()
			);
			var targetMixer	= {
				// Get the original incoming context hash
				"incomingHash" 	= incomingHash,
				// Multi-Host support
				"cgihost" 		= cgi.http_host
			};
			
			// Incorporate Routed Structs
			structAppend( targetMixer, arguments.event.getRoutedStruct(), true );
			
			// Return unique identifier
			return hash( targetMixer.toString() );			
		</cfscript>
	</cffunction>
	
	<!--- Build Hash --->
	<cffunction name="buildHash" output="false" access="public" returntype="any" hint="build a unique hash according to event and args">
		<!--- **************************************************************************** --->
		<cfargument name="args"  required="true" hint="The string of args to incorporate into the hash"/>
		<!--- **************************************************************************** --->
		<cfscript>
			var virtualRC = {};
			arguments.args
				.listToArray( "&" )
				.each( function( item ){
					virtualRC[ item.getToken( 1, "=" ).trim() ] = item.getToken( 2, "=" ).trim().urlDecode();
				} );

			writeDump( var = "==> Hash Args Struct: #virtualRC.toString()#", output="console" );

			var myStruct = {
				// Get the original incoming context hash according to incoming arguments
				"incomingHash" 	= hash( virtualRC.toString() ),
				// Multi-Host support
				"cgihost" 		= cgi.http_host
			};

			// return hash from cache key struct
			return hash( myStruct.toString() );
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
			
			key = buildBasicCacheKey( argumentCollection=arguments ) & getUniqueHash( arguments.targetContext );

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
			
			key = buildBasicCacheKey( argumentCollection=arguments ) & buildHash( arguments.targetArgs );
			
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