<cfoutput>
<div class="fw_titles"  onClick="fw_toggle('fw_modules')" >
&nbsp;ColdBox Modules
</div>
<div class="fw_debugContent<cfif getDebuggerConfig().getExpandedModulesPanel()>View</cfif>" id="fw_modules">
	
	<div>
		<!--- Module Commands --->
		<input type="button" value="Reload All" 
			   name="cboxbutton_reloadModules"
			   style="font-size:10px" 
			   title="Reload All Modules" 
			   onClick="location.href='#URLBase#?cbox_command=reloadModules'" />
		<input type="button" value="Unload All" 
			   name="cboxbutton_unloadModules"
			   style="font-size:10px" 
			   title="Unload all modules from the application" 
			   onClick="location.href='#URLBase#?cbox_command=unloadModules'" />
			   
	</div>
	<p>Below you can see the loaded application modules.</p>
	<div>
		<!--- Module Charts --->
		<table border="0" cellpadding="0" cellspacing="1" class="fw_debugTables">
			<tr >
				<th>Module</th>
				<th width="15%">Author</th>
				<th width="50">Version</th>
				<th width="50">V.P.L</th>
				<th width="50">L.P.L</th>
				<th width="75">Load Time</th>
				<th align="center" width="130" >CMDS</th>
			</tr>
			<cfloop from="1" to="#arrayLen(loadedModules)#" index="loc.x">
			<cfset loc.mod = moduleSettings[loadedModules[loc.x]]>
			<tr>
				<td title=" Invocation Path: #loc.mod.invocationPath#">
					<strong>#loc.mod.Title#</strong><br />
					#loc.mod.description# <br /><br />
					<cfif len(moduleSettings[loadedModules[loc.x]].entryPoint)>
					<a href="#event.buildLink(loc.mod.entryPoint)#" title="#event.buildLink(loc.mod.entryPoint)#">Open Module Entry Point</a>
					<cfelse>
						<em>No Entry Point Defined</em>
					</cfif>
				</td>
				<td align="center">
					<a href="#loc.mod.webURL#" title="#loc.mod.webURL#">#loc.mod.Author#</a>
				</td>
				<td align="center">
					#loc.mod.Version#
				</td>
				<td align="center">
					#yesNoFormat(loc.mod.viewParentLookup)#
				</td>
				<td align="center">
					#yesNoFormat(loc.mod.layoutParentLookup)#
				</td>
				<td align="center">
					#dateFormat(loc.mod.loadTime,"mmm-dd")# <br />
					#timeFormat(loc.mod.loadTime,"hh:mm:ss tt")#
				</td>
				<td align="center">
				<input type="button" value="Unload" 
					   name="cboxbutton_unloadModule"
				  	   style="font-size:10px" 
					   title="Unloads This Module Only!" 
				   	   onClick="location.href='#URLBase#?cbox_command=unloadModule&module=#loadedModules[loc.x]#'">
				&nbsp;
				<input type="button" value="Reload" 
					   name="cboxbutton_unloadModule"
				  	   style="font-size:10px" 
					   title="Reloads This Module Only!" 
				   	   onClick="location.href='#URLBase#?cbox_command=reloadModule&module=#loadedModules[loc.x]#'">
				</td>
			</tr>
			</cfloop>
			
		</table>
	
		<p>
		  <em>
			  * V.P.L = View Parent Lookup Order <br />
		  	  * L.P.L = Layout Parent Lookup Order
		  </em>
		</p>
	
	</div>
	
</div>
</cfoutput>