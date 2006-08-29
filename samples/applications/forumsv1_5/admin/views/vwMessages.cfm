<cfsetting enablecfoutputonly=true>
<!---
	Name         : messages.cfm
	Author       : Raymond Camden 
	Created      : July 5, 2004
	Last Updated : September 9, 2005
	History      : Removed mappings (rkc 8/27/05)
				   Changed cols (rkc 9/9/05)
	Purpose		 : 
--->
<cfoutput>
<!--- Messagebox --->
#getPlugin("messagebox").render()#
</cfoutput>
<cfmodule template="../../tags/datatable.cfm" 
		  data="#getValue("messages")#" list="title,posted,threadname,forumname,conferencename,username" 
		  editlink="?event=ehForums.dspMessagesEdit" linkcol="title" label="Message" />


<cfsetting enablecfoutputonly=false>