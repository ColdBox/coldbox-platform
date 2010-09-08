<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	January 10, 2010
Description :
The forgebox manager handler

----------------------------------------------------------------------->
<cfcomponent output="false">

	<!--- dependencies --->
	<cfproperty name="forgeService" inject="model:forgeService@forgeBox">

	<!--- preHandler --->
	<cffunction name="preHandler" returntype="void" output="false">
		<cfargument name="Event">
		<cfscript>	
			event.paramValue("typeSlug","");
			event.paramValue("orderBy","POPULAR");
		</cfscript>
	</cffunction>

	<!--- index --->
	<cffunction name="index" returntype="void" output="false">
		<cfargument name="Event">
		<cfscript>	
			var rc = event.getCollection();
			
			// Get info from forgebox
			rc.types   = forgeService.getTypes();
			rc.entries = forgeService.getEntries(orderBy=forgeService[rc.orderBy],typeSlug=rc.typeSlug);
			
			// Get parent installation directories
			rc.qParentListing = forgeService.getParentListing();
			
			// Entries title
			switch(rc.orderBy){
				case "new" : { rc.entriesTitle = "Cool New Stuff!"; break; }
				case "recent" : { rc.entriesTitle = "Recently Updated!"; break; }
				default: { rc.entriesTitle = "Most Popular!"; }
			}
			
			event.setView("manager/index");
		</cfscript>
	</cffunction>
	
	<!--- install --->
	<cffunction name="install" returntype="void" output="false">
		<cfargument name="Event">
		<cfscript>	
			var rc = event.getCollection();
			
			if( NOT len(rc.installURL) ){
				getPlugin("MessageBox").setMessage(type="error", message="Download URL is empty, cannot install");
				setNextEvent("/forgebox");
			}
			
			// Install entry and flash install log
			flash.put("installResults",forgeService.install(rc.installURL,rc.installLocation) );
			
			// Relocate to results
			setNextEvent(event="/forgebox/install/results/#rc.entrySlug#");			
		</cfscript>
	</cffunction>
	
	<!--- installResults --->
	<cffunction name="installResults" returntype="void" output="false">
		<cfargument name="Event">
		<cfscript>	
			var rc = event.getCollection();
			
			// Keep log for refreshes,how awesome are thee flash memory
			flash.keep("logInfo");
			
			// Get entry information
			rc.entry = forgeService.getEntry(rc.entrySlug);	
		</cfscript>
	</cffunction>
	
	
</cfcomponent>