<cfoutput>
<div class="fw_debugTitleCell">
  Performance
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
<cfinclude template="/coldbox/system/includes/panels/CacheCharting.cfm">

<!--- Cache Configuration --->
<h3>Cache Configuration
	<input type="button" value="Show/Hide Configuration" 
		   name="cboxbutton_cacheproperties"
		   style="font-size:10px" 
		   title="View Cache Properties" 
		   onClick="fw_toggleDiv('fw_cacheConfigurationTable','table')" />
</h3>
<div id="fw_cacheConfiguration">
	<table border="0" cellpadding="0" cellspacing="1" class="fw_debugTables" id="fw_cacheConfigurationTable" style="display:none">
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
</div>

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
<div class="fw_cacheContentReport">
	#renderCacheContentReport()#
</div>
</cfoutput>