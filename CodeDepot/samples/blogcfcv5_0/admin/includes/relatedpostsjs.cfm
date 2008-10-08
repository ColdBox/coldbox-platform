<cfsetting showdebugoutput="false">
<cfset relatedCats	= application.blog.getRelatedEntriesSelects() />
<cfif url.id IS NOT "0">
	<cfset getRelatedEntries	= application.blog.getRelatedBlogEntries(url.id) />
</cfif>
<cfset catList = "" />
<cfoutput query="relatedCats" group="categoryName">
	<cfset catList = listAppend(catList, categoryName) />
</cfoutput>

var categoryArray	= new Array(<cfoutput>#listQualify(catList, '"')#</cfoutput>);
var rememberCats	= new Array();	// global array to hold selected options for related entries (categories)
var rememberEntries = new Array();	// global array to hold selected options for related entries (entries)
var originalEntries = new Array();  // global array to hold the -original- selected options for related entries (entries)

<cfif url.id IS NOT "0">
	<cfoutput>
		<cfloop query="getRelatedEntries">
			rememberCats[rememberCats.length] = "#categoryName#";
			rememberEntries[rememberEntries.length] = "#ID#";
			originalEntries[originalEntries.length] = "#ID#";
		</cfloop>
	</cfoutput>
</cfif>

<cfset outercount = 0 />
<cfoutput query="relatedCats" group="categoryName">
	categoryArray["#categoryName#"] = new Array();
	<cfset arrayCounter = 0 />
	<cfoutput>
		<!--- added conditional to prevent current entry from displaying in entries list : 12 january 2005 : cjg --->
		<cfif relatedCats.ID IS NOT url.id>
			categoryArray["#categoryName#"][#arrayCounter#] 		= new Array();
			categoryArray["#categoryName#"][#arrayCounter#].ID		= "#ID#";
			categoryArray["#categoryName#"][#arrayCounter#].posted	= "#dateFormat(posted, 'mm/dd/yyyy')#";
			categoryArray["#categoryName#"][#arrayCounter#].title	= "#jsStringFormat(title)#";

			<cfset arrayCounter = arrayCounter + 1 />
		</cfif>
	</cfoutput>
</cfoutput>