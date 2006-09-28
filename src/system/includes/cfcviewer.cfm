<cfoutput>
<!--- Style Sheet --->
<link rel="stylesheet" href="#instance.styleSheet#" type="text/css" />	
<!--- Start Content --->
<div class="cfc_content">

	<div class="cfc_h1">CFC Viewer - #instance.cfcPath#</div>
	
	<div class="cfc_componentlisting">
	
		<div class="cfc_h3">Packages / Directories</div>
		<ul>
			<cfloop from="1" to="#ArrayLen(instance.aPacks)#" index="i">
				<li>#instance.aPacks[i]#</li>
			</cfloop>
			<cfif ArrayLen(instance.aPacks) eq 0>
				<li><em>None</em></li>
			</cfif>
		</ul>
		
		<div class="cfc_h3">Components</div>
		<ul>
			<cfloop from="1" to="#ArrayLen(instance.aCFC)#" index="i">
				<li><a href="###instance.aCFC[i]#">#instance.aCFC[i]#</a></li>
			</cfloop>			
			
			<cfif ArrayLen(instance.aCFC) eq 0>
				<li><em>None</em></li>
			</cfif>
		</ul>
	</div>
	</cfoutput>
	
	<p>&nbsp;</p>
	
	<cfloop from="1" to="#ArrayLen(instance.aCFC)#" index="j">
		<cftry>
			<cfset mdpath = instance.cfcPath & "/" & instance.aCFC[j] & ".cfc">
			<cfset md = getCFCMetaData(instance.aCFC[j])>
			<cfset path = expandPath(mdpath)>
			<cfparam name="md.Hint" 	default="">
			<cfparam name="md.Extends" 	default="#StructNew()#">
			<cfset aMethods = md.Functions>
			<cfoutput>
				<a name="#instance.aCFC[j]#"></a>
				<div class="cfc_h1">#md.name#</div>
				<table class="cfc_component" width="100%">
					
					<tr>
						<td class="cfc_hint">#md.Hint#</td>
					</tr>
					
					<tr valign="top">
						<td >
							<div class="cfc_h2">Methods:</div>
							<br />
							
							<table cellspacing="0" width="100%">
								
								<tr valign="top" >
									<td class="cfc_methodstitle" width="40" align="right">Access</td>
									<td class="cfc_methodstitle" width="40" align="right" >Returns</td>
									<td class="cfc_methodstitle" >Name</td>
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
											<cfset tmpParam = "<i>[#tmpParam# = '#thisParam.Default#']</i>">
										</cfif>
										<cfset tmpParam = "&nbsp;#tmpParam#">
										
										<cfset lstParams = ListAppend(lstParams, tmpParam)>						
									</cfloop>
			
									<tr valign="top" onmouseover="this.className='cfc_methodrowsOn'" onmouseout="this.className='cfc_methodrows'" class="cfc_methodrows">
										<td align="right" class="cfc_methodcells">#lcase(thisMethod.Access)#</td>
										<td class="cfc_methodcells" align="right">
										<cfif thisMethod.ReturnType neq "">
										#lcase(thisMethod.ReturnType)#
										<cfelse>
										any
										</cfif>
										</td>
										<td class="cfc_methodcells">
											<b>#thisMethod.Name#</b> 
											<cfif lstParams neq "">
												(#lstParams#)
											<cfelse>
												()
											</cfif>
											<br><br />
											#thisMethod.Hint#
										</td>
									</tr>
								</cfloop>
						  </table>
						
						   <br />
							<div class="cfc_h2">Extends:</div>
							<cfif IsSimpleValue(md.Extends)>
								<ul><li>#md.Extends#</li></ul>
							<cfelseif IsDefined("md.Extends.Name") and md.Extends.Name neq "WEB-INF.cftags.component">
								<ul><li>#md.Extends.Name#</li></ul>
							<cfelse>
								<ul><li><em>Nothing</em></li></ul>
							</cfif>
						</td>
					</tr>
				</table>
				<br>
			</cfoutput>
			<cfcatch>
				<cfdump var="#cfcatch#">
			</cfcatch>
		</cftry>
	</cfloop>
</div>
