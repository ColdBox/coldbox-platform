<cfcomponent hint="Creates RSS feeds" output="false">
	
<!----------------------------------- CONSTRUCTOR --------------------------------------->	
	
	<cfscript>
		//instance scope
		instance = structnew();
		
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">
        <cfargument name="transfer" type="any">
		<cfargument name="feedGenPlugin" type="any">
		<cfargument name="EntryService" type="any">
		<cfargument name="baseUrl" type="any">
			<cfset instance.transfer = arguments.transfer >
			<cfset instance.feedGenPlugin = arguments.feedGenPlugin >
			<cfset instance.EntryService = arguments.EntryService >
			<cfset instance.baseUrl = arguments.baseUrl >
		
		<!--- Any constructor code here --->
				
		<cfreturn this>
	</cffunction>

<!----------------------------------- PUBLIC METHODS --------------------------------------->

	<cffunction name="getRSS" access="public" returntype="any" output="false">
		<cfargument name="feedType" type="any" default="full" hint="Specify either 'simple' or 'full'">
		
		
		<cfscript>
	    	var entries = instance.EntryService.getLatestEntries();
			var myArray = ArrayNew(1);
			var feedStruct = StructNew();
			var feed = "";
			var columnMap = StructNew();
			var plugin = instance.feedGenPlugin;
			
			columnMap.title = "title";
			columnMap.description = "entryBody";
			columnMap.pubDate = "time";
			columnMap.link = "link";
			
			QueryAddColumn(entries, "link", myArray);
			
			for(i = 1; i <= entries.recordCount; i = i + 1){
				entries.link[i] = instance.baseUrl & "general/viewPost/" & entries.entry_Id[i];
				// if feedType is simple, shorten entryBody lenght
				if (arguments.feedType EQ "simple"){
					entries.entryBody[i] = Left(entries.entryBody[i],400) & "...&nbsp;&nbsp;&nbsp;<a href='#entries.link[i]#'>read more</a>";
				}
			}
			
			feedStruct.title = "Simple Blog 4";
			feedStruct.description = "A blog built with ColdBox in order to learn ColdBox.";
			feedStruct.pubDate = "time";
			feedStruct.link = instance.baseUrl;
			feedStruct.items = entries;
			
			plugin.verifyFeed(feedStruct,columnMap);
			feed = plugin.createFeed(feedStruct,columnMap);
		
			return feed;
		</cfscript>
	</cffunction>
	
</cfcomponent>