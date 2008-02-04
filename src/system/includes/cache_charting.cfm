<div>
<table align="center" width="100%" border="1" cellpadding="0" cellspacing="0" style="background:white">
	<tr>
		<td align="center">
		<cfchart format="png" show3d="true" backgroundcolor="##ffffff" gridlines="true" chartwidth="275">
			<cfchartseries type="pie" colorlist="85ca0a,1e3aca" >
				<cfchartdata item="Free Memory (KB)"  value="#JVMFreeMemory#">
				<cfchartdata item="Total Memory (KB)" value="#JVMTotalMemory#">
			</cfchartseries>
		</cfchart>
		</td>
		<td align="center">
		<cfchart format="png" show3d="true" backgroundcolor="##ffffff" chartwidth="125">
			<cfchartseries type="bar" colorlist="93C2FF,ED2939" >
				<cfchartdata item="Hits" value="#controller.getColdboxOCM().getCacheStats().getHits()#">
				<cfchartdata item="Misses" value="#controller.getColdboxOCM().getCacheStats().getMisses()#">
				<cfchartdata item="Evictions" value="#controller.getColdboxOCM().getCacheStats().getEvictionCount()#">
			</cfchartseries>
		</cfchart>
		</td>
		<td align="center">
		<cfchart format="png" show3d="true" backgroundcolor="##ffffff" gridlines="true" chartwidth="275">
			<cfchartseries type="pie" colorlist="800080" >
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