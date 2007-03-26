<cfoutput>
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

	<div class="fw_titles" onClick="toggle('fw_cache')">&gt;&nbsp; ColdBox Cache</div>
	<div class="fw_debugContentView" id="fw_cache">

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
		 <em>#NumberFormat((JVMFreeMemory/JVMTotalMemory)*100,"99.99")# % Free</em>
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
		 Every #controller.getSetting("CacheReapFrequency",1)# Minutes
		</div>

		<div class="fw_debugTitleCell">
		  Default Timeout
		</div>
		<div class="fw_debugContentCell">
		 #controller.getSetting("CacheObjectDefaultTimeout",1)# Minutes
		</div>

		<div class="fw_debugTitleCell">
		  Last Access Timeout
		</div>
		<div class="fw_debugContentCell">
		 #controller.getSetting("CacheObjectDefaultLastAccessTimeout",1)# Minutes
		</div>

		<div class="fw_debugTitleCell">
		  Total Objects in Cache
		</div>
		<div class="fw_debugContentCell">
		 #controller.getColdBoxOCM().getSize()# Objects
		</div>
		<!--- **************************************************************--->
		<cfif server.ColdFusion.ProductName eq "Coldfusion Server">
			<!--- Why use a cfinclude? well, bluedragon would not compile this without it --->
			<cfinclude template="cache_charting.cfm">
		<cfelse>
			<div class="fw_debugTitleCell">
			  Objects In Cache:
			</div>
			<div class="fw_debugContentCell">
			 <b>Plugins: </b> #itemTypes.plugins# &nbsp;
			 <b>Handlers: </b> #itemTypes.handlers# &nbsp;
			 <b>IoC Beans: </b> #itemTypes.ioc_beans# &nbsp;
			 <b>Other: </b> #itemTypes.other#
			</div>
			<em>Charting is not supported in your coldfusion engine. Cache Charts skipped.</em>
			<br>
		</cfif>

		<table border="0" align="center" cellpadding="0" cellspacing="1" class="fw_debugTables">
		  <tr >
		  	<td class="fw_debugTablesTitles">Object</td>
			<td align="center" width="10%" align="center" class="fw_debugTablesTitles">Hits</td>
			<td align="center" width="10%" align="center" class="fw_debugTablesTitles">Timeout (Min)</td>
			<td align="center" width="20%" class="fw_debugTablesTitles">Created</td>
			<td align="center" width="20%" class="fw_debugTablesTitles">Last Accessed</td>
		  </tr>
		  <cfloop collection="#cacheMetadata#" item="key">
		  <tr >
		  	<td class="fw_debugTablesCells">#key#</td>
			<td align="center" class="fw_debugTablesCells">#cacheMetadata[key].hits#</td>
			<td align="center" class="fw_debugTablesCells">#cacheMetadata[key].Timeout#</td>
			<td align="center" class="fw_debugTablesCells">#dateformat(cacheMetadata[key].Created,"mm-dd-yyyy")# #timeformat(cacheMetadata[key].Created,"HH:mm:ss")#</td>
			<td align="center" class="fw_debugTablesCells">#dateformat(cacheMetadata[key].lastaccesed,"mm-dd-yyyy")# #timeformat(cacheMetadata[key].lastaccesed,"HH:mm:ss")#</td>
		  </tr>
		  </cfloop>
		</table>
	</div>
	<!--- **************************************************************--->

	<cfif renderType eq "cachepanel">
	</div>
	<div align="center" style="margin-top:10px"><input type="button" name="close" value="Close Monitor" onClick="window.close()" style="font-size:10px"></div>
	</cfif>
</cfoutput>