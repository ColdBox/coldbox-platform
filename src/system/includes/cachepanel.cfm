<cfoutput>

	<!--- If cachepanel render the polling code --->
	<cfif renderType eq "cachepanel">
		<!--- Setup the panel --->
		<cfsetting showdebugoutput="false">
		<cfparam name="url.frequency" default="5">
		<!--- Verify Frequency --->
		<cfif not isNumeric(url.Frequency)>
			<cfset url.frequency = 5>
		</cfif>
		<!--- Meta Tag Refresh --->
		<meta http-equiv="refresh" content="#url.frequency#">
		<!--- Include Header --->
		<cfinclude template="debugHeader.cfm">
		<div class="fw_debugPanel">
	</cfif>

	<!--- Start Rendering the Cache panel  --->
	<div class="fw_titles" onClick="fw_toggle('fw_cache')">&gt;&nbsp; ColdBox Cache</div>
	<cfif renderType eq "cachepanel">
		<div class="fw_debugContentView" id="fw_cache">
	<cfelse>
		<div class="fw_debugContent" id="fw_cache">
	</cfif>
		<cfif renderType eq "main">
		<div>
		  <input type="button" value="Open Cache Monitor" name="cachemonitor" style="font-size:10px" title="Open the cache monitor in a new window." onClick="window.open('index.cfm?debugpanel=cache','cachemonitor','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=750')">
		  <br><br>
		</div>
		<cfelse>
		<div>
			<strong>Monitor Refresh Frequency (Seconds): </strong>
			<select id="frequency" style="font-size:10px" onChange="window.location='index.cfm?debugpanel=cache&frequency='+this.value">
				<cfloop from="5" to="30" index="i" step="5">
				<option value="#i#" <cfif url.frequency eq i>selected</cfif>>#i#</option>
				</cfloop>
			</select>
			<hr>
		</div>
		</cfif>

		<div class="fw_debugTitleCell">
		  Cache Performance
		</div>
		<div class="fw_debugContentCell">
		 <em>Ratio:</em> #NumberFormat(controller.getColdboxOCM().getCachePerformanceRatio(),"999.99")#%  ==>
		 <em>Hits:</em> #controller.getColdboxOCM().getCachePerformance().hits# |
		 <em>Misses:</em> #controller.getColdboxOCM().getCachePerformance().misses#
		</div>

		<div class="fw_debugTitleCell">
		  Free Memory
		</div>
		<div class="fw_debugContentCell">
		 <em>#NumberFormat((JVMFreeMemory/JVMTotalMemory)*100,"99.99")# % Free  : Threshold=#controller.getColdboxOCM().getCacheConfigBean().getCacheFreeMemoryPercentageThreshold()#% (0=Unlimited)</em>
		</div>

		<div class="fw_debugTitleCell">
		  Last Reap
		</div>
		<div class="fw_debugContentCell">
		 #DateFormat(controller.getColdboxOCM().getlastReapDatetime(),"MMM-DD-YYYY")#
		 #TimeFormat(controller.getColdboxOCM().getlastReapDatetime(),"hh:mm:ss tt")#
		</div>

		<div class="fw_debugTitleCell">
		  Reap Frequency
		</div>
		<div class="fw_debugContentCell">
		 Every #controller.getColdboxOCM().getCacheConfigBean().getCacheReapFrequency()# Minutes
		</div>

		<div class="fw_debugTitleCell">
		  Default Timeout
		</div>
		<div class="fw_debugContentCell">
		 #controller.getColdboxOCM().getCacheConfigBean().getCacheObjectDefaultTimeout()# Minutes
		</div>

		<div class="fw_debugTitleCell">
		  Last Access Timeout
		</div>
		<div class="fw_debugContentCell">
		 #controller.getColdboxOCM().getCacheConfigBean().getCacheObjectDefaultLastAccessTimeout()# Minutes
		</div>

		<div class="fw_debugTitleCell">
		  Total Objects in Cache
		</div>
		<div class="fw_debugContentCell">
		 #controller.getColdBoxOCM().getSize()# / #controller.getColdboxOCM().getCacheConfigBean().getCacheMaxObjects()# (0=Unlimited)
		</div>
		<!--- **************************************************************--->
		<cfif controller.getSetting("chartingActive",true)>
			<!--- Why use a cfinclude? well, bluedragon would not compile this without it --->
			<cfinclude template="cache_charting.cfm">
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

		<h3>Cache Content Report (Time: #timeformat(now(),"hh:mm:ss tt")#)</h3>
		<div class="fw_cachetable">
		<!--- Object Charts --->
		<table border="0" align="center" cellpadding="0" cellspacing="1" class="fw_debugTables">
		  <tr >
		  	<th >Object</th>
			<th align="center" width="10%" >Hits</th>
			<th align="center" width="10%" >Timeout (Min)</th>
			<th align="center" width="10%" >Created</th>
			<th align="center" width="10%" >Last Accessed</th>
			<th align="center" width="10%" >Expires On</th>
		  </tr>
		  <cfset cacheKeyIndex = 1>
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
			  </tr>
			  <cfset cacheKeyIndex = cacheKeyIndex + 1>
		  </cfloop>
		</table>
		</div>
	</div>
	<!--- **************************************************************--->

	<!--- If in cachepanel mode, render the close monitor buttons --->
	<cfif renderType eq "cachepanel">
		</div>
		<div align="center" style="margin-top:10px"><input type="button" name="close" value="Close Monitor" onClick="window.close()" style="font-size:10px"></div>
	</cfif>

</cfoutput>