<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : C:\projects\blogcfc5\client\admin\entries.cfm
	Author       : Raymond Camden
	Created      : 04/07/06
	Last Updated :
	History      :
--->
<cfset entries = getValue("entries")>
	<cfoutput>
	<p>
	Your blog currently has
		<cfif entries.recordCount>
		#entries.recordcount# entries
		<cfelseif entries.recordCount is 1>
		1 entry
		<cfelse>
		0 entries
		</cfif>.
	</p>

	<p>
	<form action="#cgi.script_name#?event=ehAdmin.dspEntries" method="post">
	<input type="text" name="keywords" value="#getValue("keywords","")#"> <input type="submit" value="Filter by Keyword">
	</form>
	</p>

	</cfoutput>

	<cfmodule template="../tags/datatable.cfm" data="#entries#" editlink="index.cfm?event=ehAdmin.dspEntry" label="Entries"
			  linkcol="title" defaultsort="posted" defaultdir="desc"
			  queryString="keywords=#urlencodedformat(getValue("keywords",""))#"
			  deleteEvent="ehAdmin.doDeleteEntries">
		<cfmodule template="../tags/datacol.cfm" colname="title" label="Title" />
		<cfmodule template="../tags/datacol.cfm" colname="released" label="Released" format="yesno"/>
		<cfmodule template="../tags/datacol.cfm" colname="posted" label="Posted" format="datetime" />
		<cfmodule template="../tags/datacol.cfm" colname="views" label="Views" format="number" />
	</cfmodule>



<cfsetting enablecfoutputonly=false>