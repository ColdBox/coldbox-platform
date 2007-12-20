<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : /client/admin/comments.cfm
	Author       : Raymond Camden
	Created      : 04/06/06
	Last Updated :
	History      :
--->

<cfset comments = Event.getValue("comments")>

	<cfoutput>
	<p>
	Your blog currently has
		<cfif comments.recordCount>
		#comments.recordcount# comments
		<cfelseif comments.recordCount is 1>
		1 comment
		<cfelse>
		0 comments
		</cfif>.
	</p>
	</cfoutput>

	<cfmodule template="../tags/datatable.cfm" data="#comments#" editlink="?event=#Event.getValue("xehComment")#" label="Comments"
			  linkcol="comment" defaultsort="posted" defaultdir="desc" showAdd="false"
			  deleteEvent="#Event.getValue("xehDeleteComment")#">
		<cfmodule template="../tags/datacol.cfm" colname="name" label="Name" width="150" />
		<cfmodule template="../tags/datacol.cfm" colname="email" label="Email" width="300" />
		<cfmodule template="../tags/datacol.cfm" colname="posted" label="Posted" format="datetime" width="150" />
		<cfmodule template="../tags/datacol.cfm" colname="comment" label="Comment" left="100"/>
	</cfmodule>

<cfsetting enablecfoutputonly=false>