<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author 	    :	Luis Majano
Description :
	I am the fastest way to cache objects. I am so fast because I dont do anything. I'm really a tool to use when working on caching strategies. When I am in use nothing is cached. It just vanishes.

----------------------------------------------------------------------->
<cfcomponent hint="I am the fastest way to cache objects. I am so fast because I dont do anything. I'm really a tool to use when working on caching strategies. When I am in use nothing is cached. It just vanishes." output="false" implements="coldbox.system.cache.store.IObjectStore">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="BlackholeStore" hint="Constructor">
		<cfargument name="cacheProvider" type="any" required="true" hint="The associated cache provider as coldbox.system.cache.ICacheProvider" colddoc:generic="coldbox.system.cache.ICacheProvider"/>
		<cfscript>
			// Store Fields
			var fields = "hits,timeout,lastAccessTimeout,created,LastAccessed,isExpired,isSimple";
			var config = arguments.cacheProvider.getConfiguration();

			// Prepare instance
			instance = {
				cacheProvider   = arguments.cacheProvider,
				storeID 		= 'blackhole'
			};

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- INTERFACE PUBLIC METHODS ------------------------------------------->

	<!--- flush --->
    <cffunction name="flush" output="false" access="public" returntype="void" hint="Pretends to flush the store to a permanent storage">
    	<cfreturn />
    </cffunction>

	<!--- reap --->
    <cffunction name="reap" output="false" access="public" returntype="void" hint="Pretends to reap the storage, clean it from old stuff.">
		<cfreturn />
	</cffunction>

	<!--- getStoreID --->
    <cffunction name="getStoreID" output="false" access="public" returntype="any" hint="Get this storage's ID">
    	<cfreturn instance.storeID>
    </cffunction>

	<!--- clearAll --->
    <cffunction name="clearAll" output="false" access="public" returntype="void" hint="No work to do. Everything is already in the blackhole.">
		<cfreturn />
	</cffunction>

	<!--- getIndexer --->
	<cffunction name="getIndexer" access="public" returntype="any" output="false" hint="No work to do. Everything is already in the blackhole.">
		<cfreturn>
	</cffunction>

	<!--- getKeys --->
	<cffunction name="getKeys" output="false" access="public" returntype="any" hint="No work to do. Everything is already in the blackhole.">
		<cfreturn>
	</cffunction>

	<!--- lookup --->
	<cffunction name="lookup" access="public" output="false" returntype="any" hint="Returns false. No work to do. Everything is already in the blackhole.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfreturn false>
	</cffunction>

	<!--- get --->
	<cffunction name="get" access="public" output="false" returntype="any" hint="Returns null. This is a blackhole.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfreturn JavaCast('null','')>
	</cffunction>

	<!--- getQuiet --->
	<cffunction name="getQuiet" access="public" output="false" returntype="any" hint="Returns null. This is a blackhole.">
		<cfargument name="objectKey" type="any" required="true" hint="The key of the object">
		<cfreturn JavaCast('null','')>
	</cffunction>

	<!--- expireObject --->
	<cffunction name="expireObject" output="false" access="public" returntype="void" hint="Mark an object for expiration">
		<cfargument name="objectKey" type="any"  required="true" hint="The object key">
		<cfreturn />
	</cffunction>

	<!--- isExpired --->
    <cffunction name="isExpired" output="false" access="public" returntype="any" hint="Test if an object in the store has expired or not">
    	<cfargument name="objectKey" type="any"  required="true" hint="The object key">
		<cfreturn />
    </cffunction>

	<!--- Set an Object in the pool --->
	<cffunction name="set" access="public" output="false" returntype="void" hint="Saves an object in a blackhole. You'll never see it again.">
		<!--- ************************************************************* --->
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		<cfargument name="object"				type="any" 	required="true" hint="The object to save">
		<cfargument name="timeout"				type="any"  required="false" default="" hint="Timeout in minutes">
		<cfargument name="lastAccessTimeout"	type="any"  required="false" default="" hint="Timeout in minutes">
		<cfargument name="extras" 				type="any" default="#structnew()#" hint="A map of extra name-value pairs"/>
		<!--- ************************************************************* --->
		<cfdump var="Blackhole just cached '#arguments.objectKey#'. Good luck getting it out." output='console'>
		<cfreturn />
	</cffunction>

	<!--- Clear an object from the pool --->
	<cffunction name="clear" access="public" output="false" returntype="any" hint="Clears an object from the storage pool">
		<cfargument name="objectKey" 			type="any"  required="true" hint="The object key">
		<cfreturn true />
	</cffunction>

	<!--- Get the size of the pool --->
	<cffunction name="getSize" access="public" output="false" returntype="any" hint="Get the cache's size in items">
		<cfreturn 0>
	</cffunction>

</cfcomponent>