<cfcomponent hint="Creates RSS feeds" output="false">
	
<!----------------------------------- CONSTRUCTOR --------------------------------------->	
	
	<cfscript>
		//instance scope
		instance = structnew();
		
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">
        <cfargument name="transfer" type="any">
		<cfargument name="settings" type="any">
			<cfset instance.transfer = arguments.transfer >
			<cfset instance.settings = arguments.settings >
		
		<!--- Any constructor code here --->
				
		<cfreturn this>
	</cffunction>

<!----------------------------------- PUBLIC METHODS --------------------------------------->

	<cffunction name="getFullRSS" access="public" returntype="any" output="false">
		
		<cfscript>
			var EntryService = CreateObject("component","#instance.settings.appname#.model.entries.EntryService").init(instance.transfer);
	    	var entries = EntryService.getLatestEntries();
			var myArray = ArrayNew(1);
			var feedStruct = StructNew();
			var feed = "";
			
			test = instance.settings;
			
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
		<cfdump var="#test#"><cfabort>
	</cffunction>
	
</cfcomponent>