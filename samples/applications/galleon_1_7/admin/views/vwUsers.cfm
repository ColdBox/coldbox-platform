<cfsetting enablecfoutputonly=true>
<!---
	Name         : users.cfm
	Author       : Raymond Camden 
	Created      : July 4, 2004
	Last Updated : August 27, 2005
	History      : Fixed bugs related to sendnotifications change (rkc 8/3/05)
				   Removed mappings (rkc 8/27/05)
	Purpose		 : 
--->
<cfoutput>
<!--- Messagebox --->
#getPlugin("messagebox").renderit()#
</cfoutput>
<cfmodule template="../../tags/datatable.cfm" 
		  data="#Event.getValue("users")#" list="#Event.getValue("list")#" 
		  editlink="?event=#Event.getValue("xehUsersEdit")#" linkcol="username" linkval="username" label="User" />



<cfsetting enablecfoutputonly=false>