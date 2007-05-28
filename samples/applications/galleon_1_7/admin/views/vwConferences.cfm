<cfsetting enablecfoutputonly=true>
<!---
	Name         : conferences.cfm
	Author       : Raymond Camden 
	Created      : June 01, 2004
	Last Updated : September 9, 2005
	History      : Removed mappings (rkc 8/27/05)
				   Changed cols (rkc 9/9/05)
	Purpose		 : 
--->

<cfoutput>
<!--- Messagebox --->
#getPlugin("messagebox").renderit()#
</cfoutput>

<cfmodule template="../../tags/datatable.cfm" 
		  data="#Event.getValue("conferences")#" list="name,description,lastpost,messagecount,active" 
		  editlink="?event=#Event.getValue("xehConferencesEdit")#" linkcol="name" label="Conference" />


<cfsetting enablecfoutputonly=false>