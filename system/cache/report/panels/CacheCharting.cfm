<cfscript>
	if( structKeyExists(server,"railo") ){
		show3d = false;	
	}
	else{
		show3d = true;
	}
</cfscript>
<div>
<table align="center" width="100%" border="1" cellpadding="0" cellspacing="0" style="background:white">
	<tr>
		<td align="center">
			<cfchart format="png" show3d="#show3d#" backgroundcolor="##ffffff" chartheight="350" chartwidth="400">
				<cfchartseries type="pie" colorlist="green, black, gray" >
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
				   	   onClick="fw_cacheGC('#URLBase#','#arguments.cacheName#',this.id)" />
				</cfoutput>
			</div>
		
		</td>
		<td align="center">
		<cfchart format="png" show3d="#show3d#" backgroundcolor="##ffffff" 
				 chartwidth="350" chartheight="350" showlegend="true">
			<cfchartseries type="bar" colorlist="131cd7,ED2939,black,d47f00">
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