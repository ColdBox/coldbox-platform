<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	January 10, 2010
Description :
The forgebox module service layer

----------------------------------------------------------------------->
<cfcomponent outut="false" hint="The forgebox module service layer">

	<!--- Dependencies --->
	<cfproperty name="forgeBoxAPI" inject="coldbox:myplugin:ForgeBox@forgebox">
	<cfproperty name="cache"	   inject="coldbox:cacheManager">
	<cfproperty name="appRoot"	   inject="coldbox:setting:applicationPath">

	<!--- init --->
	<cffunction name="init" output="false" access="public" returntype="any" hint="Constructor">
		<cfscript>
			this.POPULAR = "popular";
			this.NEW	 = "new";
			this.RECENT  = "recent";
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- getParentListing --->
	<cffunction name="getParentListing" output="false" access="public" returntype="query" hint="Get the parent listing">
		<cfset var qListing = "">
		<cfdirectory action="list" directory="#appRoot#" type="dir" sort="asc" name="qListing">
		<cfreturn qListing>
	</cffunction>
	
	<!--- getTypes --->
	<cffunction name="getTypes" output="false" access="public" returntype="query" hint="Get the types">
		<cfscript>
			var q = "";
			
			// Cache Lookups
			if( cache.lookup("forge-q-types") ){
				return cache.get("forge-q-types");
			}
			
			q = forgeBoxAPI.getTypes();
			
			// Cache with Defaults
			cache.set("forge-q-types",q);
			
			return q;
		</cfscript>
	</cffunction>
	
	<!--- getEntries --->
	<cffunction name="getEntries" output="false" access="public" returntype="query" hint="Get entries">
		<cfargument name="orderBy"  type="string"  required="false" default="#this.POPULAR#" hint="The type to order by, look at this.ORDERBY"/>
		<cfargument name="maxrows"  type="numeric" required="false" default="0" hint="Max rows to return"/>
		<cfargument name="startRow" type="numeric" required="false" default="1" hint="StartRow"/>
		<cfargument name="typeSlug" type="string" required="false" default="" hint="The type slug to filter on"/>
		<cfscript>
			var q = "";
			var cacheKey = "forge-q-entries-" & hash(arguments.toString());
			
			// Validate order by
			if( NOT reFindNoCase("^(new|popular|recent)$",arguments.orderBy) ){
				arguments.orderby = this.POPULAR;
			}
			
			// Cache Lookups
			if( cache.lookup(cachekey) ){
				return cache.get(cacheKey);
			}
			
			q = forgeBoxAPI.getEntries(argumentCollection=arguments);
		
			// Cache with Defaults
			cache.set(cacheKey,q);
			
			return q;		
		</cfscript>
	</cffunction>
	
	<!--- getEntry --->
	<cffunction name="getEntry" output="false" access="public" returntype="struct" hint="Get a forgebox entry">
		<cfargument name="entrySlug" type="string" required="true" hint="The entry slug"/>
		<cfscript> 
			var entry = "";
			var cacheKey = "forge-q-entry-#arguments.entrySlug#";
			
			if( cache.lookup(cacheKey) ){
				return cache.get(cacheKey);
			}
			
			entry = forgeBoxAPI.getEntry(slug=arguments.entrySlug);
			
			cache.set(cacheKey, entry);
			
			return entry;		
		</cfscript>
	</cffunction>
	
	<!--- install --->
	<cffunction name="install" output="false" access="public" returntype="struct" hint="Install Code Entry">
		<cfargument name="downloadURL"    type="string" required="true" />
		<cfargument name="destinationDir" type="string" required="true" />
		
		<!--- Start Log --->
		<cfset var log 			= createObject("java","java.lang.StringBuffer").init("Starting Download...<br />")>
		<cfset var destination  = appRoot & arguments.destinationDir>
		<cfset var fileName		= getFileFromPath(arguments.downloadURL)>
		<cfset var results 		= {error=true,logInfo=""}>
		
		<cftry>
			<!--- Download File --->
			<cfhttp url="#arguments.downloadURL#"
					method="GET"
					file="#fileName#"
					path="#destination#">
		
			<cfcatch type="any">
				<cfset log.append("<strong>Error downloading file: #cfcatch.message# #cfcatch.detail#</strong><br />")>
				<cfset results.logInfo = log.toString()>
				<cfreturn results>
			</cfcatch>
		</cftry>	
		
		<!--- has file size? --->
		<cfif getFileInfo(destination & "/" & fileName).size LTE 0>	
			<cfset log.append("<strong>Cannot install file as it has a file size of 0.</strong>")>
			<cfset results.logInfo = log.toString()>
			<cfreturn results>
		</cfif>
		
		<cfset log.append("File #fileName# downloaded succesfully at #destination#, checking type for extraction.<br />")>
		
		<!--- Unzip File? --->
		<cfif listLast(filename,".") eq "zip">
			<cfset log.append("Zip archive detected, beginning to uncompress.<br />")>
			<cfzip action="unzip" file="#destination#/#filename#" destination="#destination#" overwrite="true">
			<cfset log.append("Archive uncompressed and installed at #destination#. Performing cleanup.<br />")>
			<cfset fileDelete(destination & "/" & filename)>
		</cfif>
		
		<cfset log.append("Entry: #filename# sucessfully installed at #destination#.<br />")>
		<cfset results = {error=false,logInfo=log.toString()}>
		
		<cfreturn results>		
	</cffunction>
	

</cfcomponent>