<cfoutput>
<cfset qryDir = Event.getValue("qryDir")>
<cfset currentRoot = Event.getValue("currentRoot")>
<div id="FileBrowser">
<form name="fileviewer" id="fileviewer" method="post" action="index.cfm">
<div style="width: 550px;margin: 10px; border:1px outset ##ddd;margin-left:auto;margin-right:auto;background-color: ##FFFFFF">
	
	<div style="border-bottom:1px solid ##ddd; background-color: ##f5f5f5;padding: 5px;font-weight:bold;">
	   <a href="javascript:doEvent('#Event.getValue("xehBrowser")#', 'FileBrowser',{dir:'#jsstringFormat(currentroot)#'})" title="Refresh Listing"><img src="images/icons/arrow_refresh.png" align="absmiddle" border="0" title="Refresh Listing."></a>
		You are Here: #currentRoot#</div>
	
	<div style="line-height:20px;padding:3px;overflow:auto;height: 250px;font-weight:bold">
	    #getPlugin("messagebox").renderit()#
		<cfif listlen(currentroot,"/") gte 1>
			<cfset tmpHREF = "javascript:doEvent('#Event.getValue("xehBrowser")#','FileBrowser',{dir:'#JSStringFormat(session.oldRoot)#'})">
			<a href="#tmpHREF#"><img src="images/icons/folder.png" border="0" align="absmiddle" alt="Folder"></a>
			<a href="#tmpHREF#">..</a><br>
		</cfif>
		<cfloop query="qryDir">
			<cfif qryDir.type eq "Dir">
				<cfset vURL = "#currentRoot##iif(currentroot eq "/","''","'/'")##urlEncodedFormat(qryDir.name)#">
				<cfset tmpHREF = "javascript:doEvent('#Event.getValue("xehBrowser")#','FileBrowser',{dir:'#JSStringFormat(vURL)#'})">
				<div id="#JSStringFormat(qryDir.name)#" onClick="selectdirectory('#jsstringFormat(qrydir.name)#','#JSStringFormat(vURL)#')" style="cursor: pointer;" onDblclick="#tmpHREF#">
				<a href="#tmpHREF#"><img src="images/icons/folder.png" border="0" align="absmiddle" alt="Folder"></a>
				<!---<a href="#tmpHREF#">#qryDir.name#</a> --->
				#qryDir.name#
				</div>
			</cfif>
		</cfloop>
	</div>
	
	<div style="font-size:9px;background-color:fffff0;padding:3px;border-top:1px solid ##ddd"><strong>Selected Folder:&nbsp;</strong><span id="span_selectedfolder"></span></div>
	
	<div style="border-top:1px solid ##ddd; background-color: ##f5f5f5;padding: 5px;font-weight:bold; text-align:right">
	<input type="hidden" name="selecteddir" id="selecteddir" value="">
	<input type="hidden" name="currentroot" id="currentroot" value="#currentRoot#">
	<input type="button" id="cancel_btn" value="Cancel" style="font-size: 9xp" onClick="closeBrowser()"> &nbsp;
	<input type="button" id="createdir_btn" value="New Folder" style="font-size: 9xp" onClick="newFolder('#Event.getValue('xehNewFolder')#','#JSStringFormat(currentRoot)#')"> &nbsp;
	<input type="button" id="selectdir_btn" value="Choose Folder" disabled="true" style="font-size: 9xp" onClick="chooseFolder('#session.callbackItem#')">
	</div>
	
</div>
</form>
</div>
</cfoutput>