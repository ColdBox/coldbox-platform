<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : /client/admin/entries.cfm
	Author       : Raymond Camden
	Created      : 04/26/06
	Last Updated :
	History      :
--->

<cfset tbs = Event.getValue("tbs")>

	<cfoutput>
	<p>
	Your blog currently has
		<cfif tbs.recordCount>
		#tbs.recordcount# trackbacks
		<cfelseif tbs.recordCount is 1>
		1 trackback
		<cfelse>
		0 trackbacks
		</cfif>.
	</p>
	</cfoutput>

	<cfmodule template="../tags/datatable.cfm" data="#tbs#" editlink="?event=#Event.getValue("xehTrackback")#" label="Trackbacks"
			  linkcol="" defaultsort="created" defaultdir="desc" showAdd="false"
			  deleteEvent="#Event.getValue("xehDeleteTrackbacks")#">
		<cfmodule template="../tags/datacol.cfm" colname="title" label="Title" width="300" />
		<cfmodule template="../tags/datacol.cfm" colname="blogname" label="Blog Name" width="250" />
		<cfmodule template="../tags/datacol.cfm" colname="created" label="Posted" format="datetime" width="150" />
		<cfmodule template="../tags/datacol.cfm" colname="excerpt" label="Excerpt" left="75"/>
	</cfmodule>

<cfsetting enablecfoutputonly=false>
