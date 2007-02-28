<cfsetting enablecfoutputonly=true>
<!---
	Name         : threads.cfm
	Author       : Raymond Camden 
	Created      : June 09, 2004
	Last Updated : September 9, 2005
	History      : Removed mappings, changed cols (rkc 8/27/05)
				   Changed cols (rkc 9/9/05)
	Purpose		 : 
--->

<cfoutput>
<!--- Messagebox --->
#getPlugin("messagebox").renderit()#
</cfoutput>
<cfmodule template="../../tags/datatable.cfm" 
		  data="#Context.getValue("threads")#" list="name,lastpost,forum,conference,messagecount,sticky,active" 
		  editlink="?event=#Context.getValue("xehThreadsEdit")#" linkcol="name" label="Thread" />


<cfsetting enablecfoutputonly=false>