<!--- display metadata for a component ---->

<cfparam name="attributes.metaData" type="any">
<cfparam name="attributes.path" type="any">
<cfset md = attributes.metaData>

<cfparam name="md.Hint" default="">
<cfparam name="md.Extends" default="#StructNew()#">

<cfset aMethods = md.Functions>

<!--- check if there are any TO DO comments --->
<cffile action="read" file="#attributes.path#" variable="txtFile">
<cfscript>
	aTODO = ArrayNew(1);
	iStartPos = FindNoCase("TO DO:",txtFile);
	while(iStartPos gt 0) {
		iEndPos = FindNoCase("*/", txtFile, iStartPos);
		if(iEndPos gt 0)
			aTODO[ArrayLen(aTODO)+1] = Mid(txtFile,iStartPos+6,iEndPos-iStartPos-6);
		iStartPos = Find("TO DO:",txtFile, iStartPos+6);
	}
</cfscript>

<cfoutput>
	<a name="#md.Name#"></a>
	<table class="tblComponent">
		<tr valign="top">
			<th width="10">#md.Name#</th>
			<td>#md.Hint#</td>
		</tr>
		
		<tr valign="top">
			<td colspan="2">
				<h3>Methods:</h3>
				<table class="tblMethods">
					<tr valign="top">
						<th style="width:20px;">Access</th>
						<th>Name</th>
						<th>Description</th>
					</tr>
					<cfloop from="1" to="#ArrayLen(aMethods)#" index="i">
						<cfset thisMethod = aMethods[i]>
						<cfparam name="thisMethod.Name" default="">
						<cfparam name="thisMethod.Hint" default="">
						<cfparam name="thisMethod.Access" default="public">
						<cfparam name="thisMethod.ReturnType" default="">
						<cfparam name="thisMethod.Parameters" default="#ArrayNew(1)#">

						<cfif thisMethod.Access eq "">
							<cfset thisMethod.Access = "public">
						</cfif>

						<cfset aParams = thisMethod.Parameters>
						<cfset lstParams = "">
						<cfloop from="1" to="#ArrayLen(aParams)#" index="j">
							<cfset thisParam = aParams[j]>
							<cfparam name="thisParam.Name" default="">
							<cfparam name="thisParam.Required" default="true" type="boolean">
							<cfparam name="thisParam.Type" default="">
							<cfparam name="thisParam.Default" default="">
							
							
							<cfset tmpParam = "#thisParam.Type# <b>#thisParam.Name#</b>">
							<cfif Not thisParam.Required>
								<cfset tmpParam = "[#tmpParam# = '#thisParam.Default#']">
							</cfif>
							<cfset tmpParam = "<br>&nbsp;&nbsp;&nbsp;&nbsp;#tmpParam#">
							
							<cfset lstParams = ListAppend(lstParams, tmpParam)>						
						</cfloop>

						<tr valign="top">
							<td>#thisMethod.Access#</td>
							<td nowrap="nowrap">
								<cfif thisMethod.ReturnType neq "">
									#thisMethod.ReturnType#&nbsp;&nbsp;
								</cfif>
								<b>#thisMethod.Name#</b> 
								<cfif lstParams neq "">
									(#lstParams#<br />)
								<cfelse>
									()
								</cfif>
							</td>
							<td>#thisMethod.Hint#</td>
						</tr>
					</cfloop>
				</table>
				<h3>Extends:</h3>
				<cfif IsSimpleValue(md.Extends)>
					<ul><li>#md.Extends#</li></ul>
				<cfelseif IsDefined("md.Extends.Name") and md.Extends.Name neq "WEB-INF.cftags.component">
					<ul><li>#md.Extends.Name#</li></ul>
				<cfelse>
					<ul><li><em>Nothing</em></li></ul>
				</cfif>
				
				<h3>To Do:</h3>
				<ul>
					<cfif ArrayLen(aTODO) gt 0>
						<cfloop from="1" to="#ArrayLen(aTODO)#" index="j">
							<li>#aTODO[j]#</li>
						</cfloop>
					<cfelse>
						<li><em>Nothing</em></li>
					</cfif>
				</ul>
			</td>
		</tr>
	</table>
</cfoutput>
