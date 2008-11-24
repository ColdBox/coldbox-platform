<cfcomponent hint="Creates RSS feeds" output="false" cache="true" cachetimeout="0">
	
	<!--- Dependencies --->
	<cfproperty name="EntryService" type="model:EntryService" scope="instance">
	<cfproperty name="ConfigBean" 	type="coldbox:configBean" scope="instance">
	
<!----------------------------------- CONSTRUCTOR --------------------------------------->	
	
	<cfscript>
		//instance scope
		instance = structnew();
		
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">
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
				entries.link[i] = instance.ConfigBean.getKey('sesBaseUrl') & "general/viewPost/" & entries.entry_Id[i];
			}
			
			feedStruct.title = "Simple Blog 3";
			feedStruct.description = "A blog built with ColdBox in order to learn ColdBox.";
			feedStruct.pubDate = "time";
			feedStruct.link = instance.ConfigBean.getKey('sesBaseUrl');
			feedStruct.items = entries;
			
			return feedStruct;
		</cfscript>
	</cffunction>
	
</cfcomponent>