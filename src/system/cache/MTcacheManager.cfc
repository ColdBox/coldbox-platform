<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	The multi-threaded cache manager

Modification History:
01/18/2007 - Created

----------------------------------------------------------------------->
<cfcomponent name="MTCacheManager" hint="The multi-threaded cache manager." extends="cacheManager" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cffunction name="reap" access="public" output="false" returntype="void" hint="Reap the cache.">
		<cfthread action="run" name="coldbox.cache.reap-#createUUID()#">  
			<cfscript>  
				super.reap(); 
			</cfscript>
		</cfthread>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="clearAllEvents" access="public" output="false" returntype="void" hint="Clears all events from the cache.">
		<cfthread action="run" name="coldbox.cache.clearAllEvents-#createUUID()#">  
			<cfscript>  
				super.clearAllEvents();  
			</cfscript>          
		</cfthread>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="clearAllViews" access="public" output="false" returntype="void" hint="Clears all views from the cache.">
		<cfthread action="run" name="coldbox.cache.clearAllViews-#createUUID()#">  
			<cfscript>  
				super.clearAllViews();  
			</cfscript>          
		</cfthread>
	</cffunction>
	
</cfcomponent>