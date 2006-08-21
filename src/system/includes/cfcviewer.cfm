<cfoutput>
<h1>CFC Viewer - #instance.cfcPath#</h1>
<h3>Components</h3>

<ul>
	<cfloop from="1" to="#ArrayLen(instance.aCFC)#" index="i">
		<li><a href="###instance.aCFC[i]#">#instance.aCFC[i]#</a></li>
	</cfloop>			
	
	<cfif ArrayLen(instance.aCFC) eq 0>
		<li><em>None</em></li>
	</cfif>
</ul>

<h3>Packages / Directories</h3>

<ul>
	<cfloop from="1" to="#ArrayLen(instance.aPacks)#" index="i">
		<li><a href="index.cfm?cfcPath=#instance.cfcPath##instance.aPacks[i]#/">#instance.aPacks[i]#</a></li>
	</cfloop>
	<cfif ArrayLen(instance.aPacks) eq 0>
		<li><em>None</em></li>
	</cfif>
</ul>

</cfoutput>

<h3>To Do:</h3>

<ul>
<cfoutput query="instance.qryTODO" group="Name">
	<li>
	<b>#Name#</b>
	<ul style="padding-left:15px;"><cfoutput><li>#Text#</li></cfoutput></ul>
	</li>
</cfoutput>		

<cfif instance.qryTODO.recordCount eq 0>
	<li><em>None</em></li>
</cfif>
</ul>

<cfloop from="1" to="#ArrayLen(instance.aCFC)#" index="i">
	<cftry>
		<cfset mdpath = instance.cfcPath & "/" & instance.aCFC[i] & ".cfc">
		<cfset md = oCFCViewer.getCFCMetaData(instance.aCFC[i])>
		<cf_displayMetaData metaData="#md#" path="#ExpandPath(mdpath)#">
		
		<cfcatch type="lock">Getting MetaData Failed.</cfcatch>
	</cftry>
</cfloop>
