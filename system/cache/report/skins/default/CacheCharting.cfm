<div>
<table align="center" width="100%" border="1" cellpadding="0" cellspacing="0" style="background:white">
	<tr>
		<td align="center">
			<cfchart format="png" show3d="false" title="JVM Memory Pie" backgroundcolor="##ffffff" chartheight="275" chartwidth="275">
				<cfchartseries type="pie" colorlist="00ff00, 0000ff, gray" >
					<cfchartdata item="Free Memory (KB)"  value="#JVMFreeMemory#">
					<cfchartdata item="Used Memory (KB)" value="#JVMMaxMemory-JVMFreeMemory#">
					<cfchartdata item="Unallocated Memory (KB)" value="#JVMMaxMemory-JVMTotalMemory#">
				</cfchartseries>
			</cfchart>
			<div>
				<cfoutput>
				<!--- RunGC --->
				<input type="button" value="Run Garbage Collection" 
				   	   name="cboxbutton_gc" id="cboxbutton_gc"
				   	   style="font-size:10px" 
				   	   title="Try to influence a garbage collection." 
				   	   onClick="cachebox_cacheGC('#URLBase#','#arguments.cacheName#',this.id)" />
				</cfoutput>
			</div>
		
		</td>
		<td align="center">
		<cfif structKeyExists( cacheConfig, "maxObjects" )>
		<cfchart format="png" show3d="false" title="Cache Fullness" backgroundcolor="##ffffff" chartheight="250" chartwidth="250">
			<cfchartseries type="pie" colorlist="00ff00, 0000ff" >
				<cfchartdata item="Max Size"  value="#cacheConfig.maxObjects#">
				<cfchartdata item="Used Size" value="#cacheSize#">
			</cfchartseries>
		</cfchart>
		</cfif> 
		
		<cfchart format="png" show3d="false" backgroundcolor="##ffffff" 
				 chartwidth="275" chartheight="275" showlegend="true" title="Cache Performance Report">
			<cfchartseries type="bar" colorlist="131cd7,ED2939,gray,d47f00">
				<cfchartdata item="Hits" value="#cacheStats.getHits()#">
				<cfchartdata item="Misses" value="#cacheStats.getMisses()#">
				<cfchartdata item="Garbage Collections" value="#cacheStats.getGarbageCollections()#">
				<cfchartdata item="Evictions" value="#cacheStats.getEvictionCount()#">
			</cfchartseries>
		</cfchart>
		</td>
	</tr>
</table>
</div>