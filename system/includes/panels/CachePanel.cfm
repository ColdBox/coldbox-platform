<cfoutput>
	<!--- If CacheMonitor render the polling code --->
	<cfif isMonitor>
		<cfsetting showdebugoutput="false">
		<html>
		<head>
			<title>CacheBox Monitor</title>
			<cfif url.frequency gt 0>
			<!--- Meta Tag Refresh --->
			<meta http-equiv="refresh" content="#url.frequency#">
			</cfif>
			<!--- Include Header --->
			<cfinclude template="/coldbox/system/includes/DebugHeader.cfm">
		</head>
		<body>
		<!--- Start of Debug Panel Div --->
		<div class="fw_debugPanel">
	</cfif>

	<!--- Start Rendering the Cache panel  --->
	<div class="fw_titles" onClick="fw_toggle('fw_cache')">&nbsp;CacheBox</div>
	<cfif isMonitor>
		<div class="fw_debugContentView" id="fw_cache">
	<cfelse>
		<div class="fw_debugContent<cfif getDebuggerConfig().getExpandedCachePanel()>View</cfif>" id="fw_cache">
	</cfif>
		
		<!--- ToolBar --->
		<div style="margin-bottom:5px;">
		<cfif NOT isMonitor>
			<input type="button" value="Open Cache Monitor" name="cachemonitor" style="font-size:10px" 
				   title="Open the cache monitor in a new window." 
				   onClick="window.open('#URLBase#?debugpanel=cache','cachemonitor','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=850')">
			
		<cfelse>
			<strong>Refresh Monitor: </strong>
			<select id="frequency" style="font-size:10px" onChange="fw_pollmonitor('cache',this.value,'#URLBase#')" title="Refresh Frequency">
				<option value="0">No Polling</option>
				<cfloop from="5" to="30" index="i" step="5">
				<option value="#i#" <cfif url.frequency eq i>selected</cfif>>#i# sec</option>
				</cfloop>
			</select>
		</cfif>
			<cfif isObject( controller.getCacheBox() )>
			<!--- ExpireAll --->
			<input type="button" value="CacheBox ExpireAll()" 
			   name="cboxbutton_expireAll"
			   style="font-size:10px" 
			   title="Tell CacheBox to run an expireAll() on all caches" 
			   onClick="location.href='#URLBase#?cbox_command=expireAll&debugpanel=#event.getValue('debugPanel','')#'" />
			<!--- Reap All --->
			<input type="button" value="CacheBox ReapAll()" 
			   name="cboxbutton_reapAll"
			   style="font-size:10px" 
			   title="Tell CacheBox to run an reapAll() on all caches" 
			   onClick="location.href='#URLBase#?cbox_command=reapAll&debugpanel=#event.getValue('debugPanel','')#'" />
			  </cfif>
			<hr />
		</div>
		
		<!--- Cache Report --->
		<div class="fw_debugTitleCell">
		  Cache Performance
		</div>
		<div class="fw_debugContentCell">
		 <em>Hit Ratio:</em> #NumberFormat(cacheStats.getCachePerformanceRatio(),"999.99")#%  ==>
		 <em>Hits:</em> #cacheStats.getHits()# |
		 <em>Misses:</em> #cacheStats.getMisses()# |
		 <em>Evictions:</em> #cacheStats.getEvictionCount()# |
		 <em>Garbage Collections:</em> #cacheStats.getGarbageCollections()# |
		 <em>Object Count: </em> #cacheSize#
		</div>
		
		<!--- JVM Memory Stats --->
		<div class="fw_debugTitleCell">
		  JVM Memory Stats
		</div>
		<div class="fw_debugContentCell">
		 <em>#NumberFormat((JVMFreeMemory/JVMMaxMemory)*100,"99.99")# % Free </em> |
		 <em>Total Assigned: </em> #NumberFormat(JVMTotalMemory)# KB |
		 <em>Max: </em> #NumberFormat(JVMMaxMemory)# KB		 
		</div>
		
		<!--- Last Reap --->
		<div class="fw_debugTitleCell">
		  Last Reap
		</div>
		<div class="fw_debugContentCell">
		 #DateFormat(cacheStats.getlastReapDatetime(),"MMM-DD-YYYY")#
		 #TimeFormat(cacheStats.getlastReapDatetime(),"hh:mm:ss tt")#
		</div>
		
		<!--- Cache Charting --->
		<h3>Cache Performance Report</h3>
		<cfinclude template="/coldbox/system/includes/panels/CacheCharting.cfm">
		
		<!--- Cache Properties --->
		<h3>Cache Properties</h3>
		<table border="0" cellpadding="0" cellspacing="1" class="fw_debugTables">
			<thead>
				<tr>
				  	<th width="30%">Property</th>
					<th>Value</th>
				</tr>
			</thead>
			<tbody>
				<cfset x = 1>
				<cfloop collection="#cacheConfig#" item="thisKey">
				<tr <cfif x mod 2 eq 0>class="even"</cfif>>
					<td>#lcase(thisKey)#</td>
					<td>#cacheConfig[thisKey].toString()#</td>
				</tr>
				<cfset x=x+1>
				</cfloop>
			</tbody>
		</table>
		
		<!--- Content Report --->
		<h3>Cache Content Report (Time: #timeformat(now(),"hh:mm:ss tt")#)</h3>
		<!--- Cache Commands --->
		<input type="button" value="Expire All Keys" 
			   name="cboxbutton_expirekeys"
			   style="font-size:10px" 
			   title="Expire all the keys in the cache" 
			   onClick="location.href='#URLBase#?cbox_command=expirecache&debugpanel=#event.getValue('debugPanel','')#'" />
		<input type="button" value="Clear All Events" 
			   name="cboxbutton_clearallevents"
			   style="font-size:10px" 
			   title="Remove all the events in the cache" 
			   onClick="location.href='#URLBase#?cbox_command=clearallevents&debugpanel=#event.getValue('debugPanel','')#'" />
		<input type="button" value="Clear All Views" 
			   name="cboxbutton_clearallviews"
			   style="font-size:10px" 
			   title="Remove all the views in the cache" 
			   onClick="location.href='#URLBase#?cbox_command=clearallviews&debugpanel=#event.getValue('debugPanel','')#'" />
		
		<!--- Object Charts --->
		<div class="fw_cachetable">
		<table border="0" cellpadding="0" cellspacing="1" class="fw_debugTables">
		  <tr >
		  	<th >Object</th>
			<th align="center" width="10%" >Hits</th>
			<th align="center" width="10%" >Timeout <br/>(Min)</th>
			<th align="center" width="10%" >Created</th>
			<th align="center" width="10%" >Last Accessed</th>
			<th align="center" width="10%" >Expires</th>
			<th align="center" width="10%" >Status</th>
			<th align="center" width="5%" >CMDS</th>
		  </tr>
		  <cfloop from="1" to="#cacheKeysLen#" index="x">
		  	<cfset thisKey = cacheKeys[x]>
		  	<cfset expDate = dateadd("n",cacheMetaData[ thisKey ].timeout, cacheMetaData[ thisKey ].created)>
			<tr <cfif x mod 2 eq 0>class="even"</cfif>>
			  	<!--- Link --->
				<td align="left">
				  	<a href="javascript:fw_openwindow('#URLBase#?debugpanel=cacheviewer&key=#urlEncodedFormat( thisKey )#','CacheViewer',650,375,'resizable,scrollbars,status')" title="Dump contents">#listLast(thisKey,"_")#</a></td>
				<!--- Hits --->
				<td align="center" >#cacheMetadata[thisKey].hits#</td>
				<!--- Timeout --->
				<td align="center" >#cacheMetadata[thisKey].Timeout#</td>
				<!--- Created --->
				<td align="center" >#dateformat(cacheMetadata[thisKey].Created,"mmm-dd")# <Br/> #timeformat(cacheMetadata[thisKey].Created,"hh:mm:ss tt")#</td>
				<!--- Last Accessed --->
				<td align="center">#dateformat(cacheMetadata[thisKey].lastaccesed,"mmm-dd")# <br/> #timeformat(cacheMetadata[thisKey].lastaccesed,"hh:mm:ss tt")#</td>
			 	<!--- Timeouts --->
				<td align="center" class="fw_redText" ><cfif cacheMetadata[thisKey].timeout eq 0>---<cfelse>#dateFormat(expDate,"mmm-dd")# <br /> #timeformat(expDate,"hh:mm:ss tt")#</cfif></td>
			 	<!--- isExpired --->
				<td align="center">
					<cfif cacheMetadata[thisKey].isExpired>
						<span class="fw_redText">Expired</span>
					<cfelse>
						<span class="fw_blueText">Alive</span>
					</cfif>
				</td>
				<!--- Commands --->
			 	<td align="center">
					<input type="button" value="DEL" 
						   name="cboxbutton_removeentry"
					  	   style="font-size:10px" 
						   title="Remove this entry from the cache." 
					   	   onClick="location.href='#URLBase#?cbox_command=delcacheentry&cbox_cacheentry=#urlEncodedFormat(thisKey)#&debugpanel=#event.getValue('debugPanel','')#'">
				</td>
			  </tr>
			
		  </cfloop>
		  
		</table>
		</div>
	</div>
	<!--- **************************************************************--->

	<!--- If in CacheMonitor mode, render the close monitor buttons --->
	<cfif isMonitor>
		</div>
		<!--- End debug Panel --->
		<div align="center" style="margin-top:10px"><input type="button" name="close" value="Close Monitor" onClick="window.close()" style="font-size:10px"></div>
		</body>
		</html>
	</cfif>

</cfoutput>