<cfcomponent hint="Creates RSS feeds" output="false">
	
<!----------------------------------- CONSTRUCTOR --------------------------------------->	
	
	<cfscript>
		//instance scope
		instance = structnew();
		
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">
    	<cfargument name="entryService" type="any" 	  required="true" hint="The entry service"/>
		<cfargument name="settings" 	type="struct" required="true" hint="The settings Structure">
			
		<cfset instance.entryService = arguments.entryService >
		<cfset instance.settings = arguments.settings >
		
		<cfreturn this>
	</cffunction>

<!----------------------------------- PUBLIC METHODS --------------------------------------->

	<cffunction name="getFullRSS" access="public" returntype="any" output="false">
		
		<cfscript>
			var entries = instance.EntryService.getLatestEntries();
			var myArray = ArrayNew(1);
			var feedStruct = StructNew();
			var feed = "";
			
			QueryAddColumn(entries, "link", myArray);
			
			for(i = 1; i <= entries.recordCount; i = i + 1){
				entries.link[i] = instance.settings.sesBaseUrl & "general/viewPost/" & entries.entry_Id[i];
			}
			
			feedStruct.title = "Simple Blog 3";
			feedStruct.description = "A blog built with ColdBox in order to learn ColdBox.";
			feedStruct.pubDate = "time";
			feedStruct.link = instance.settings.sesBaseUrl;
			feedStruct.items = entries;
			
			return feedStruct;
		</cfscript>
	</cffunction>
	
</cfcomponent>