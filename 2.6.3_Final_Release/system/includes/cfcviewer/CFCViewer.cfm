<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :
	cfc Viewer rendering helper

Modification History:
10/13/2006 - Updated Oscar's code to filter access types
----------------------------------------------------------------------->
<cfoutput>
<!--- Style Sheet --->
<cfif not instance.styleSheet.length()>
	<style>
	<cfinclude template="/coldbox/system/includes/cfcviewer/CFCViewer.css">
	</style>
<cfelse>
<link rel="stylesheet" href="#instance.styleSheet#" type="text/css" />
</cfif>

<!--- Header Anchor --->
<a name="cfcdocstop"></a>

<!--- Start Content --->
<div class="cfc_content">

	<!--- Title --->
	<div class="cfc_h1">CFC Viewer - #getDirPath()#</div>
	
	<!--- Package & Component Listing --->
	<div class="cfc_componentlisting">
		
		<!--- Packages --->
		<div class="cfc_h3">Available Packages (#arrayLen(instance.aPacks)#)</div>
		<div class="cfc_packagecontent">
		<ul>
			<li><a href="#buildRootLink()#">#getRootPath()#</a></li>
			<ul>
			<cfloop from="1" to="#ArrayLen(instance.aPacks)#" index="i">
				<li><a href="#buildLink(instance.aPacks[i])#">#instance.aPacks[i]#</a></li>
			</cfloop>
			<cfif ArrayLen(instance.aPacks) eq 0>
				<li><em>None Found</em></li>
			</cfif>
			</ul>
		</ul>
		</div>
		
		<!--- Components --->
		<div class="cfc_h3">Package Components (#arrayLen(instance.aCFC)#)</div>
		<div class="cfc_packagecontent">
		<ul>
			<cfloop from="1" to="#ArrayLen(instance.aCFC)#" index="i">
				<li><a href="#getLinkBaseURL()####instance.aCFC[i]#">#instance.aCFC[i]#</a></li>
			</cfloop>
			<cfif ArrayLen(instance.aCFC) eq 0>
				<li><em>None Found</em></li>
			</cfif>
		</ul>
		</div>
	</div>
	</cfoutput>

	<p>&nbsp;</p>
	
	<!--- Loop Over cfcs --->
	<cfloop from="1" to="#ArrayLen(getaCFC())#" index="j">
		<!--- Get MD for CFC --->
		<cfset md = getCFCMetaData(instance.aCFC[j])>
		
		<!--- Param Some Properties --->
		<cfparam name="md.Hint" 		default="">
		<cfparam name="md.Type" 		default="">
		<cfparam name="md.Extends" 		default="#StructNew()#">
		<cfparam name="md.Functions"	default="#ArrayNew(1)#">
		<cfparam name="md.implements" 	default="#structNew()#">
		<cfparam name="md.cache" 		default="">
		<cfparam name="md.cacheTimeout" default="">
		<cfparam name="md.cacheLastAccessTimeout" 	default="">
		<cfparam name="md.Properties"	default="#arrayNew(1)#">
		
		<!--- Get Functions --->
		<cfset aMethods = md.Functions>
		<!--- Verify Functions --->
		<cfif isStruct(aMethods)>
			<cfset aMethods = ArrayNew(1)>
		</cfif>
		
		<!--- Output Methods. --->
		<cfoutput>
			<!--- Title --->
			<a name="#instance.aCFC[j]#"></a>
			<div class="cfc_h1">#listLast(md.name,".")#</div>
			
			<!--- Table Summary --->
			<table class="cfc_componentsummary" width="100%">
				<tr>
					<td nowrap="true"><strong>Object Type</strong></td>
					<td width="100%">#md.Type#</td>
				</tr>
				<tr>
					<td><strong>Package</strong></td>
					<td>#getPlugin("Utilities").ripExtension(md.name)#</td>
				</tr>
				<cfif md.hint.length()>
				<tr>
					<td><strong>Hint</strong></td>
					<td>#md.hint#</td>
				</tr>
				</cfif>
				<cfif md.cache.length()>
				<tr>
					<td><strong>Cache</strong></td>
					<td>#md.cache#</td>
				</tr>
				</cfif>
				<cfif md.cacheTimeout.length()>
				<tr>
					<td><strong>Cache Timeout</strong></td>
					<td>#md.cacheTimeout# Minutes</td>
				</tr>
				</cfif>
				<cfif md.cacheLastAccessTimeout.length()>
				<tr>
					<td><strong>Cache Last Access Timeout</strong></td>
					<td>#md.cacheLastAccessTimeout# Minutes</td>
				</tr>
				</cfif>
				
				<cfif not structIsEmpty(md.implements)>
				<tr>
					<td><strong>Implements</strong></td>
					<td>
					<cfset interfaceIndex = 1>
					<cfloop collection="#md.implements#" item="interface">
						#interface#<cfif interfaceIndex neq structCount(md.implements)>, </cfif>
						<cfset interfaceIndex = interfaceIndex + 1>
					</cfloop>
					</td>
				</tr>
				</cfif>
				
				<cfif ArrayLen(md.InheritanceTree)>
				<tr>
					<td valign="top"><strong>Inheritance</strong></td>
					<td valign="top">
					<cfloop from="#ArrayLen(md.InheritanceTree)#" to="1" index="x" step="-1">
						<p style="padding-left: #(ArrayLen(md.InheritanceTree) - x)*30#px;margin:5px">
							|-----+ #md.InheritanceTree[x].name#
						</p>
					</cfloop>
					<p style="padding-left: #(ArrayLen(md.InheritanceTree))*32#px;margin:5px">|---+ <strong>#md.name#</strong></p>
					</td>
				</tr>
				</cfif>
			</table>
			
			<!--- Table Summary --->
			<table class="cfc_component" width="100%">
				
				<!--- Properties Summary --->
				<tr valign="top">
					<td >
						<div class="cfc_h2">Properties Summary</div>
						<br />

						<cfif arrayLen(md.properties)>
						<table cellspacing="0" width="100%">
							<tr valign="top" >
								<td class="cfc_methodstitle" width="40" align="right">Name</td>
								<td class="cfc_methodstitle" width="40" align="right" >Type</td>
								<td class="cfc_methodstitle" width="40" align="right" >Required</td>
								<td class="cfc_methodstitle" width="40" align="right" >Default</td>
								<td class="cfc_methodstitle" >Hint</td>
							</tr>
							<cfloop from="1" to="#arrayLen(md.properties)#" index="x">
								<cfset thisProperty = md.Properties[x]>
								<!--- Verify Methods --->
								<cfparam name="thisProperty.Name" 		default="">
								<cfparam name="thisProperty.Type" 		default="">
								<cfparam name="thisProperty.Required" 	default="">
								<cfparam name="thisProperty.Default" 	default="">
								<cfparam name="thisProperty.hint" 		default="">
							<tr valign="top" onmouseover="this.className='cfc_methodrowsOn'" onmouseout="this.className='cfc_methodrows'" class="cfc_methodrows">
								<td align="right" class="cfc_methodcells"><strong>#thisProperty.name#</strong></td>
								<td class="cfc_methodcells" align="right">#thisProperty.Type#</td>
								<td class="cfc_methodcells" align="right">#thisProperty.Required#</td>
								<td class="cfc_methodcells" align="right">#thisProperty.Default#</td>
								<td class="cfc_methodcells">
									#thisProperty.Hint#
								</td>
							</tr>
							</cfloop>
						</table>
						<cfelse>
						<em>No properties found.</em>
						</cfif>
					</td>
				</tr>					
				
				<!--- Method Summary --->
				<tr valign="top">
					<td >
						<br /><div class="cfc_h2">Method Summary</div>
						<br />
						
						<cfif arrayLen(aMethods)>						
						<table cellspacing="0" width="100%">
							<tr valign="top" >
								<td class="cfc_methodstitle" width="40" align="right">Access</td>
								<td class="cfc_methodstitle" width="40" align="right" >Returns</td>
								<td class="cfc_methodstitle" >Name</td>
							</tr>

							<cfloop from="1" to="#ArrayLen(aMethods)#" index="i">
								<cfset thisMethod = aMethods[i]>
								<!--- Verify Methods --->
								<cfparam name="thisMethod.Name" default="">
								<cfparam name="thisMethod.Hint" default="">
								<cfparam name="thisMethod.Access" default="public">
								<cfparam name="thisMethod.ReturnType" default="">
								<cfparam name="thisMethod.Parameters" default="#ArrayNew(1)#">
								<cfparam name="thisMethod.cache" 	default="false">
								<cfparam name="thisMethod.cacheTimeout" default="">
								<!--- Verify Access --->
								<cfif thisMethod.Access eq "">
									<cfset thisMethod.Access = "public">
								</cfif>
								
								<!--- Display Methods --->
								<cfif listFindNoCase(instance.lstAccessTypes, thisMethod.Access)>
									<cfset lstParams = "">
									<cfloop from="1" to="#ArrayLen(thisMethod.Parameters)#" index="j">
										<cfset thisParam = thisMethod.Parameters[j]>
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
											<b>#thisMethod.Name#</b><cfif lstParams neq "">(#lstParams# )<cfelse>()</cfif>
											<br><br />
											#thisMethod.Hint#
										</td>
									</tr>
								</cfif>
							</cfloop>
					  </table>
					  <cfelse>
					 	 <em>No Methods found.</em>
					  </cfif>
					</td>
				</tr>
			
				<cfif ArrayLen(md.inheritanceTree)>
				<!--- Inheritance Method Summary --->
				<tr valign="top">
					<td >
						<br /><div class="cfc_h2">Inheritance Summary</div>
						<br />

						<cfloop from="1" to="#arrayLen(md.inheritanceTree)#" index="x">
						<table cellspacing="0" width="100%">
							<tr valign="top">
								<td class="cfc_methodstitle">Inherited Methods From: <strong>#md.inheritanceTree[x].name#</strong></td>
							</tr>
							<tr valign="top" class="cfc_methodrows" >
								<td class="cfc_methodcells" style="line-height:1.3">
									<cfloop from="1" to="#arrayLen(md.inheritanceTree[x].functions)#" index="y">
									#md.inheritanceTree[x].functions[y]#<cfif arrayLen(md.inheritanceTree[x].functions) neq y>, </cfif>
									</cfloop>											
								</td>
							</tr>					
						</table>
						</cfloop>
					</td>
				</tr>					
				</cfif>	
					
			</table>
			<br>
		

		<div align="right"><a href="#getLinkBaseURL()###cfcdocstop">^Top</a></div>
		<hr size="1"><br />
		</cfoutput>
	</cfloop>
</div>
