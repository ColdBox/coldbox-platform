<cfoutput>
<cfmodule template="/coldbox/system/cache/report/monitor.cfm"
		  cacheFactory="#controller.getCacheBox()#"
		  baseURL="#event.buildLink( 'main.cachepanel' )#">
</cfoutput>