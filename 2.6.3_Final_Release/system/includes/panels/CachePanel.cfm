<cfoutput>

	<!--- If CachePanel render the polling code --->
	<cfif renderType eq "CachePanel">
		<!--- Setup the panel --->
		<cfsetting showdebugoutput="false">
		<cfparam name="url.frequency" default="0">
		
		<!--- Verify Frequency --->
		<cfif not isNumeric(url.Frequency)>
			<cfset url.frequency = 0>
		</cfif>
		
		<cfif url.frequency gt 0>
		<!--- Meta Tag Refresh --->
		<meta http-equiv="refresh" content="#url.frequency#">
		</cfif>
		
		<!--- Include Header --->
		<cfinclude template="/coldbox/system/includes/DebugHeader.cfm">
		<div class="fw_debugPanel">
	</cfif>

	<!--- Start Rendering the Cache panel  --->
	<div class="fw_titles" onClick="fw_toggle('fw_cache')">&gt;&nbsp; ColdBox Cache</div>
	<cfif renderType eq "CachePanel">
		<div class="fw_debugContentView" id="fw_cache">
	<cfelse>
		<div class="fw_debugContent<cfif getDebuggerConfigBean().getExpandedCachePanel()>View</cfif>" id="fw_cache">
	</cfif>
		<cfif renderType eq "main">
		<div>
		  <input type="button" value="Open Cache Monitor" name="cachemonitor" style="font-size:10px" title="Open the cache monitor in a new window." onClick="window.open('index.cfm?debugpanel=cache','cachemonitor','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=800')">
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
		 <em>Hit Ratio:</em> #NumberFormat(controller.getColdboxOCM().getCacheStats().getCachePerformanceRatio(),"999.99")#%  ==>
		 <em>Hits:</em> #controller.getColdboxOCM().getCacheStats().gethits()# |
		 <em>Misses:</em> #controller.getColdboxOCM().getCacheStats().getmisses()# |
		 <em>Evictions:</em> #controller.getColdboxOCM().getCacheStats().getEvictionCount()# |
		 <em>Garbage Collections:</em> #controller.getColdboxOCM().getCacheStats().getGarbageCollections()#
		</div>

		<div class="fw_debugTitleCell">
		  JVM Memory Stats
		</div>
		<div class="fw_debugContentCell">
		 <em>#NumberFormat((JVMFreeMemory/JVMMaxMemory)*100,"99.99")# % Free </em> |
		 <em>JVM Threshold</em>:#controller.getColdboxOCM().getCacheConfigBean().getCacheFreeMemoryPercentageThreshold()#% (0=Unlimited) |
		 <em>Total Assigned Memory: </em> #NumberFormat(JVMTotalMemory)# KB |
		 <em>Max JVM Memory: </em> #NumberFormat(JVMMaxMemory)# KB		 
		</div>

		<div class="fw_debugTitleCell">
		  Last Reap
		</div>
		<div class="fw_debugContentCell">
		 #DateFormat(controller.getColdboxOCM().getCacheStats().getlastReapDatetime(),"MMM-DD-YYYY")#
		 #TimeFormat(controller.getColdboxOCM().getCacheStats().getlastReapDatetime(),"hh:mm:ss tt")#
		</div>

		<div class="fw_debugTitleCell">
		  Reap Frequency
		</div>
		<div class="fw_debugContentCell">
		 Every #controller.getColdboxOCM().getCacheConfigBean().getCacheReapFrequency()# Minute(s)
		</div>
		
		<div class="fw_debugTitleCell">
		  Eviction Policy
		</div>
		<div class="fw_debugContentCell">
		 #controller.getColdboxOCM().getCacheConfigBean().getCacheEvictionPolicy()#
		</div>

		<div class="fw_debugTitleCell">
		  Default Timeout
		</div>
		<div class="fw_debugContentCell">
		 #controller.getColdboxOCM().getCacheConfigBean().getCacheObjectDefaultTimeout()# Minutes
		</div>

		<cfif controller.getColdboxOCM().getCacheConfigBean().getCacheUseLastAccessTimeouts()>
		<div class="fw_debugTitleCell">
		  Last Access Timeout
		</div>
		<div class="fw_debugContentCell">
		 #controller.getColdboxOCM().getCacheConfigBean().getCacheObjectDefaultLastAccessTimeout()# Minutes
		</div>
		</cfif>

		<div class="fw_debugTitleCell">
		  Total Objects in Cache
		</div>
		<div class="fw_debugContentCell">
		 <cfif controller.getColdboxOCM().getSize() gte controller.getColdboxOCM().getCacheConfigBean().getCacheMaxObjects()>
		 	<span class="fw_redText">#controller.getColdBoxOCM().getSize()# / #controller.getColdboxOCM().getCacheConfigBean().getCacheMaxObjects()# (0=Unlimited)</span>
		 <cfelse>
		 	#controller.getColdBoxOCM().getSize()# / #controller.getColdboxOCM().getCacheConfigBean().getCacheMaxObjects()# (0=Unlimited) 
		</cfif>
		 
		</div>
		<!--- **************************************************************--->
		<cfif controller.getSetting("chartingActive",true)>
			<!--- Why use a cfinclude? well, bluedragon would not compile this without it --->
			<cfinclude template="/coldbox/system/includes/panels/CacheCharting.cfm">
		<cfelse>
			<div class="fw_debugTitleCell">
			  Objects In Cache:
			</div>
			<div class="fw_debugContentCell">
			 <b>Plugins: </b> #itemTypes.plugins# &nbsp;
			 <b>Handlers: </b> #itemTypes.handlers# &nbsp;
			 <b>Events: </b> #itemTypes.events# &nbsp;
			 <b>Views: </b> #itemTypes.views# &nbsp;
			 <b>IoC Beans: </b> #itemTypes.ioc_beans# &nbsp;
			 <b>Interceptors: </b> #itemTypes.interceptors# &nbsp;
			 <b>Other: </b> #itemTypes.other#
			</div>
			<em>Charting is not supported in your coldfusion engine. Cache Charts skipped.</em>
			<br>
		</cfif>

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
		<table border="0" align="center" cellpadding="0" cellspacing="1" class="fw_debugTables">
		  <tr >
		  	<th >Object</th>
			<th align="center" width="10%" >Hits</th>
			<th align="center" width="10%" >Timeout (Min)</th>
			<th align="center" width="10%" >Created</th>
			<th align="center" width="10%" >Last Accessed</th>
			<th align="center" width="10%" >Expires On</th>
			<th align="center" width="5%" >CMDS</th>
		  </tr>
		  <cfset cacheKeyIndex = 1>
		  <cfset cacheMetaData = controller.getColdboxOCM().getpool_metadata()>
		  <cfset cacheKeyList = listSort(structKeyList(cacheMetaData),"textnocase")>
		  <cfloop list="#cacheKeyList#" index="key">
			  <cfset expDate = dateadd("n",cacheMetaData[key].timeout,cacheMetadata[key].Created)>
			  <tr <cfif cacheKeyIndex mod 2 eq 0>class="even"</cfif>>
			  	<td >
				  	<a href="javascript:fw_openwindow('index.cfm?debugpanel=cacheviewer&key=#urlEncodedFormat(key)#','CacheViewer',650,375,'resizable,scrollbars,status')" title="Dump contents">#listLast(key,"_")#</a></td>
				<td align="center" >#cacheMetadata[key].hits#</td>
				<td align="center" >#cacheMetadata[key].Timeout#</td>
				<td align="center" >#dateformat(cacheMetadata[key].Created,"mmm-dd")# <Br/> #timeformat(cacheMetadata[key].Created,"hh:mm:ss tt")#</td>
				<td align="center">#dateformat(cacheMetadata[key].lastaccesed,"mmm-dd")# <br/> #timeformat(cacheMetadata[key].lastaccesed,"hh:mm:ss tt")#</td>
			 	<td align="center" class="fw_redText" ><cfif cacheMetadata[key].timeout eq 0>---<cfelse>#dateFormat(expDate,"mmm-dd")# <br /> #timeformat(expDate,"hh:mm:ss tt")#</cfif></td>
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
		<div align="center" style="margin-top:10px"><input type="button" name="close" value="Close Monitor" onClick="window.close()" style="font-size:10px"></div>
	</cfif>

</cfoutput>