<!--- Setup the panel --->
<cfparam name="url.frequency" default="0">

<!--- Verify Frequency --->
<cfif not isNumeric(url.Frequency)>
	<cfset url.frequency = 0>
</cfif>
<cfoutput>
	<!--- If CachePanel render the polling code --->
	<cfif renderType eq "CachePanel">
		<cfsetting showdebugoutput="false">
		<html>
		<head>
			<title>ColdBox Cache Monitor</title>
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
	<div class="fw_titles" onClick="fw_toggle('fw_cache')">&nbsp;ColdBox Cache</div>
	<cfif renderType eq "CachePanel">
		<div class="fw_debugContentView" id="fw_cache">
	<cfelse>
		<div class="fw_debugContent<cfif getDebuggerConfig().getExpandedCachePanel()>View</cfif>" id="fw_cache">
	</cfif>
		<cfif renderType eq "main">
		<div style="margin-bottom:5px;">
		  <input type="button" value="Open Cache Monitor" name="cachemonitor" style="font-size:10px" 
		  		 title="Open the cache monitor in a new window." 
		  		 onClick="window.open('index.cfm?debugpanel=cache','cachemonitor','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=850')">
		  <br>
		</div>
		<cfelse>
		<div>
			<strong>Monitor Refresh Frequency (Seconds): </strong>
			<select id="frequency" style="font-size:10px" onChange="fw_pollmonitor('cache',this.value)">
				<option value="0">No Polling</option>
				<cfloop from="5" to="30" index="i" step="5">
				<option value="#i#" <cfif url.frequency eq i>selected</cfif>>#i# sec</option>
				</cfloop>
			</select>
			<hr>
		</div>
		</cfif>

		<div class="fw_debugTitleCell">
		  Cache Performance
		</div>
		
		<div class="fw_debugContentCell">
		 <em>Hit Ratio:</em> #NumberFormat(cacheStats.getCachePerformanceRatio(),"999.99")#%  ==>
		 <em>Hits:</em> #cacheStats.gethits()# |
		 <em>Misses:</em> #cacheStats.getmisses()# |
		 <em>Evictions:</em> #cacheStats.getEvictionCount()# |
		 <em>Garbage Collections:</em> #cacheStats.getGarbageCollections()#
		</div>

		<div class="fw_debugTitleCell">
		  JVM Memory Stats
		</div>
		<div class="fw_debugContentCell">
		 <em>#NumberFormat((JVMFreeMemory/JVMMaxMemory)*100,"99.99")# % Free </em> |
		 <em>Total Assigned: </em> #NumberFormat(JVMTotalMemory)# KB |
		 <em>Max: </em> #NumberFormat(JVMMaxMemory)# KB		 
		</div>
		
		<div class="fw_debugTitleCell">
		  JVM Threshold
		</div>
		<div class="fw_debugContentCell">
			#cacheConfig.getFreeMemoryPercentageThreshold()#% (0=Unlimited)
		</div>
		
		<div class="fw_debugTitleCell">
		  Last Reap
		</div>
		<div class="fw_debugContentCell">
		 #DateFormat(cacheStats.getlastReapDatetime(),"MMM-DD-YYYY")#
		 #TimeFormat(cacheStats.getlastReapDatetime(),"hh:mm:ss tt")#
		</div>

		<div class="fw_debugTitleCell">
		  Reap Frequency
		</div>
		<div class="fw_debugContentCell">
		 Every #cacheConfig.getReapFrequency()# Minute(s)
		</div>
		
		<div class="fw_debugTitleCell">
		  Eviction Policy
		</div>
		<div class="fw_debugContentCell">
		 #cacheConfig.getEvictionPolicy()# (#cacheConfig.getEvictCount()# evict count)
		</div>

		<div class="fw_debugTitleCell">
		  Default Timeout
		</div>
		<div class="fw_debugContentCell">
		 #cacheConfig.getObjectDefaultTimeout()# Minutes
		</div>

		<cfif cacheConfig.getUseLastAccessTimeouts()>
		<div class="fw_debugTitleCell">
		  Last Access Timeout
		</div>
		<div class="fw_debugContentCell">
		 #cacheConfig.getObjectDefaultLastAccessTimeout()# Minutes
		</div>
		</cfif>

		<div class="fw_debugTitleCell">
		  Cache Contents
		</div>
		<div class="fw_debugContentCell">
		 <cfif controller.getColdboxOCM().getSize() gte cacheConfig.getMaxObjects()>
		 	<span class="fw_redText">#controller.getColdBoxOCM().getSize()# / #cacheConfig.getMaxObjects()# (0=Unlimited)</span>
		 <cfelse>
		 	#controller.getColdBoxOCM().getSize()# / #cacheConfig.getMaxObjects()# (0=Unlimited) 
		</cfif>
		 
		</div>
		
		<!--- Cache Charting --->
		<cfinclude template="/coldbox/system/includes/panels/CacheCharting.cfm">
		
		<!--- Content Report --->
		<br />
		<h3>Cache Content Report (Time: #timeformat(now(),"hh:mm:ss tt")#)</h3>
		<!--- Cache Commands --->
		<input type="button" value="Expire All Keys" 
			   name="cboxbutton_expirekeys"
			   style="font-size:10px" 
			   title="Expire all the keys in the cache" 
			   onClick="location.href='index.cfm?cbox_command=expirecache&debugpanel=#event.getValue('debugPanel','')#'" />
		<input type="button" value="Clear All Events" 
			   name="cboxbutton_clearallevents"
			   style="font-size:10px" 
			   title="Remove all the events in the cache" 
			   onClick="location.href='index.cfm?cbox_command=clearallevents&debugpanel=#event.getValue('debugPanel','')#'" />
		<input type="button" value="Clear All Views" 
			   name="cboxbutton_clearallviews"
			   style="font-size:10px" 
			   title="Remove all the views in the cache" 
			   onClick="location.href='index.cfm?cbox_command=clearallviews&debugpanel=#event.getValue('debugPanel','')#'" />
		
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
		  <cfset cacheKeyIndex = 1>
		  <cfset cacheMetaData = controller.getColdboxOCM().getPoolMetadata()>
		  <cfset cacheKeyList = listSort(structKeyList(cacheMetaData),"textnocase")>
		  <cfloop list="#cacheKeyList#" index="key">
			  <cfset expDate = dateadd("n",cacheMetaData[key].timeout,cacheMetadata[key].Created)>
			  <tr <cfif cacheKeyIndex mod 2 eq 0>class="even"</cfif>>
			  	<td align="left">
				  	<a href="javascript:fw_openwindow('index.cfm?debugpanel=cacheviewer&key=#urlEncodedFormat(key)#','CacheViewer',650,375,'resizable,scrollbars,status')" title="Dump contents">#listLast(key,"_")#</a></td>
				<td align="center" >#cacheMetadata[key].hits#</td>
				<td align="center" >#cacheMetadata[key].Timeout#</td>
				<td align="center" >#dateformat(cacheMetadata[key].Created,"mmm-dd")# <Br/> #timeformat(cacheMetadata[key].Created,"hh:mm:ss tt")#</td>
				<td align="center">#dateformat(cacheMetadata[key].lastaccesed,"mmm-dd")# <br/> #timeformat(cacheMetadata[key].lastaccesed,"hh:mm:ss tt")#</td>
			 	<td align="center" class="fw_redText" ><cfif cacheMetadata[key].timeout eq 0>---<cfelse>#dateFormat(expDate,"mmm-dd")# <br /> #timeformat(expDate,"hh:mm:ss tt")#</cfif></td>
			 	<td align="center">
					<cfif cacheMetadata[key].isExpired>
						<span class="fw_redText">Expired</span>
					<cfelse>
						<span class="fw_blueText">Alive</span>
					</cfif>
				</td>
			 	<td align="center">
					<input type="button" value="DEL" 
						   name="cboxbutton_removeentry"
					  	   style="font-size:10px" 
						   title="Remove this entry from the cache." 
					   	   onClick="location.href='index.cfm?cbox_command=delcacheentry&cbox_cacheentry=#urlEncodedFormat(key)#&debugpanel=#event.getValue('debugPanel','')#'">
				</td>
			  </tr>
			  <cfset cacheKeyIndex = cacheKeyIndex + 1>
		  </cfloop>
		</table>
		</div>
	</div>
	<!--- **************************************************************--->

	<!--- If in CachePanel mode, render the close monitor buttons --->
	<cfif renderType eq "CachePanel">
		</div>
		<!--- End debug Panel --->
		<div align="center" style="margin-top:10px"><input type="button" name="close" value="Close Monitor" onClick="window.close()" style="font-size:10px"></div>
		</body>
		</html>
	</cfif>

</cfoutput>