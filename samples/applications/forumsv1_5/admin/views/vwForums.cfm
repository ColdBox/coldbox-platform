<cfsetting enablecfoutputonly=true>
<!---
	Name         : forums.cfm
	Author       : Raymond Camden 
	Created      : June 01, 2004
	Last Updated : September 9, 2005
	History      : Removed mappings (rkc 8/27/05)
				   changed cols (rkc 9/9/05)
	Purpose		 : 
--->

<cfoutput>
<!--- Messagebox --->
#getPlugin("messagebox").renderit()#
</cfoutput>
<cfmodule template="../../tags/datatable.cfm" 
		  data="#getValue("forums")#" list="name,description,conference,messagecount,readonly,active" 
		  editlink="?event=#getValue("xehForumsEdit")#" linkcol="name" label="Forum" />

<cfsetting enablecfoutputonly=false>