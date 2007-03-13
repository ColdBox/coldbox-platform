<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : C:\projects\blogcfc5\client\admin\subscribers.cfm
	Author       : Raymond Camden
	Created      : 04/07/06
	Last Updated :
	History      :
--->

<cfset subscribers = Event.getValue("subscribers")>

	<cfoutput>
	<p>
	Your blog currently has
		<cfif subscribers.recordCount>
		#subscribers.recordcount# subscribers
		<cfelseif subscribers.recordCount is 1>
		1 subscriber
		<cfelse>
		0 subscribers
		</cfif>.
	</p>
	</cfoutput>

	<cfmodule template="../tags/datatable.cfm" data="#subscribers#" editlink="" label="Subscribers"
			  linkcol="" linkval="email" showAdd="false" defaultsort="email" deleteEvent="#Event.getValue("xehDeleteSub")#">
		<cfmodule template="../tags/datacol.cfm" colname="email" label="Email" />
	</cfmodule>

<cfsetting enablecfoutputonly=false>