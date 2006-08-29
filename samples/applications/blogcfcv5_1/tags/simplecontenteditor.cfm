<cfsetting enablecfoutputonly="true">
<!---
	Name:			C:\Apache\htdocs\testingzone\simplecontenteditor\simplecontenteditor.cfm
	Author:			Raymond Camden
	Created:		05/11/05
	Last Updated:	05/25/05	
	History:		bug when editmode=true and file doesn't exist. bug with N instances on the page (5/21/05)
					Allow scename to set name. This is needed when calling tag as cfmodule (rkc 5/25/05)
--->

<cfif isDefined("attributes.scename")>
	<cfset attributes.name = attributes.scename>
</cfif>

<!--- Name of the data file. --->
<cfparam name="attributes.name" type="string">

<cfif reFindNoCase("[^a-z0-9]", attributes.name)>
	<cfsetting enablecfoutputonly="false">
	<cfthrow type="SimpleContentEditor" message="Name attribute can only contain letters and numbers.">
</cfif>

<!--- Security key. This is a simple boolean that signifies if we have the right to edit. --->
<cfparam name="attributes.editmode" type="boolean" default="false">

<!--- Subfolder to store txt files. --->
<cfset datapath = "data">
<!--- key storing our cache. Use a variable in case, by some miracle, you are using the same name elsewhere --->
<cfset cachekey = "__simplecontenteditor">

<!--- First check to see if we have it in cache --->
<cfset makeCache = false>
<cflock name="#cachekey#" type="readOnly" timeout="30">
	<cfif not structKeyExists(application,cachekey)>
		<cfset makeCache = true>
	</cfif>
</cflock>
<cfif makeCache>
	<cflock name="#cachekey#" type="exclusive" timeout="30">
		<cfif not structKeyExists(application,cachekey)>
			<cfset application[cachekey] = structNew()>
		</cfif>
	</cflock>
</cfif>

<!--- create full filename. / works just fine in Windows --->
<cfset fileName = getDirectoryFromPath(getCurrentTemplatePath()) & datapath & "/" & attributes.name & ".txt">

<!--- create folder if we have too --->
<cfif not directoryExists(getDirectoryFromPath(filename))>
	<cfdirectory action="create" directory="#getDirectoryFromPath(filename)#">
</cfif>


<cfif attributes.editmode>

	<!--- Check to see if a form post is coming in. --->
	<cfif isDefined("form.sce_name") and form.sce_name is attributes.name and isDefined("form.payload")>
		<!--- write the filename --->
		<cffile action="write" file="#filename#" output="#form.payload#">
		<cfset application[cacheKey][attributes.name] = form.payload>
	</cfif>

	<cfif structKeyExists(application[cacheKey], attributes.name)>
		<cfset formContent = application[cacheKey][attributes.name]>
	<cfelse>
		<cfif fileExists(filename)>
			<cffile action="read" file="#filename#" variable="formContent">
		<cfelse>
			<cfset formContent = "">
		</cfif>
		<cflock name="#cachekey#" type="exclusive" timeout="30">
			<cfset application[cachekey][attributes.name] = formContent>
		</cflock>
	</cfif>
	
	<cfsavecontent variable="newwindow">
	<cfoutput>
	<form onSubmit="opener.document.sce.payload.value=this.payload.value;opener.document.sce.submit();window.close();">
	<textarea name="payload" style="width: 450px; height: 450px;" wrap="hard">#formContent#</textarea>
	<input type="submit" value="Save">
	</form>
	</cfoutput>
	</cfsavecontent>
	
	<cfoutput>
	<script>
	function launchEditor(name,value) {
		editor = window.open("","sce", "width=500,height=500,resizeable=yes");
		editor.document.open();
		editor.document.writeln(value);
		editor.document.close();
		document.sce.sce_name.value = name;
	}
	</script>
	<p style="font-size: 8px; font-family: verdana">
	<a href='javaScript:launchEditor("#jsstringformat(attributes.name)#","#jsstringformat(newwindow)#")' style="text-decoration: none;">[Edit this Content: #attributes.name#]</a>
	<cfif not structKeyExists(request,cachekey)>
		<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="sce" style="display: inline; ">
		<textarea name="payload" style="visibility: hidden; height: 0px;width: 0px; display: none;margin: 0px;"></textarea>	
		<input type="hidden" name="sce_name" value="#attributes.name#">
		</form>
		<cfset request[cachekey] = 1>
	</cfif>
	</p>
	</cfoutput>
</cfif>

<!--- Leave if we have it in cache. --->
<cfif structKeyExists(application[cacheKey], attributes.name)>
	<cfoutput>#application[cacheKey][attributes.name]#</cfoutput>
	<cfsetting enablecfoutputonly="false">
	<cfexit method="exitTag">
</cfif>

<!--- Read the file if it exists --->
<cfif fileExists(filename)>
	<cffile action="read" file="#filename#" variable="buffer">
	<cflock name="#cachekey#" type="exclusive" timeout="30">
		<cfset application[cachekey][attributes.name] = buffer>
	</cflock>
	<cfoutput>#application[cacheKey][attributes.name]#</cfoutput>
	<cfsetting enablecfoutputonly="false">
	<cfexit method="exitTag">
<cfelse>
	<!--- otherwise, do nothing for now --->
</cfif>
		
<cfsetting enablecfoutputonly="false">
