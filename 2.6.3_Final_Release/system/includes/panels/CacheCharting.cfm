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
		<cfchart format="png" show3d="false" backgroundcolor="##ffffff" gridlines="true" 
				 chartwidth="275" >
			<cfchartseries type="pie" colorlist="85ca0F,172A7F" >
				<cfchartdata item="Free Memory (KB)"  value="#JVMFreeMemory#">
				<cfchartdata item="Used Memory (KB)" value="#JVMMaxMemory-JVMFreeMemory#">
			</cfchartseries>
		</cfchart>
		</td>
		<td align="center">
		<cfchart format="png" show3d="#show3d#" backgroundcolor="##ffffff" 
				 chartwidth="200" chartheight="300" showlegend="true">
			<cfchartseries type="bar" colorlist="93C2DD,ED2939,FF6F9D" >
				<cfchartdata item="Hits" value="#controller.getColdboxOCM().getCacheStats().getHits()#">
				<cfchartdata item="Misses" value="#controller.getColdboxOCM().getCacheStats().getMisses()#">
				<cfchartdata item="Garbage Collections" value="#controller.getColdboxOCM().getCacheStats().getGarbageCollections()#">
				<cfchartdata item="Evictions" value="#controller.getColdboxOCM().getCacheStats().getEvictionCount()#">
			</cfchartseries>
		</cfchart>
		</td>
		<td align="center">
		<cfchart format="png" show3d="#show3d#" backgroundcolor="##ffffff" gridlines="true" chartwidth="275">
			<cfchartseries type="pie" colorlist="AA0000" >
				<cfchartdata item="Plugins" value="#itemTypes.plugins#">
				<cfchartdata item="Handlers" value="#itemTypes.handlers#">
				<cfchartdata item="Events" value="#itemTypes.events#">
				<cfchartdata item="Views" value="#itemTypes.views#">
				<cfchartdata item="Interceptors" value="#itemTypes.interceptors#">
				<cfchartdata item="IoC Objects" value="#itemTypes.ioc_beans#">
				<cfchartdata item="Other Objects" value="#itemTypes.other#">
			</cfchartseries>
		</cfchart>
		</td>
	</tr>
</table>
</div>