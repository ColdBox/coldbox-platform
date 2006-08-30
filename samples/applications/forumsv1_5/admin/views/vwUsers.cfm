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
#getPlugin("messagebox").render()#
</cfoutput>
<cfmodule template="../../tags/datatable.cfm" 
		  data="#getValue("users")#" list="username,emailaddress,postcount,datecreated" 
		  editlink="?event=#getValue("xehUsersEdit")#" linkcol="username" linkval="username" label="User" />



<cfsetting enablecfoutputonly=false>