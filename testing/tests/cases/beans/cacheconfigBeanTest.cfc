<cfcomponent name="requestcontextTest" output="false">

	<cffunction name="setup" access="public" output="false" returntype="void">
		<cfscript>
			this.ccbean = CreateObject("component","coldbox.system.beans.cacheConfigBean");
			this.config = {timeout=30,lastaccesstimeout=30,reap=1,maxobjects=100,threshold=1,uselastaccess=true,eviction="LFU"}>
			
			
		</cfscript>
	</cffunction>
	

</cfcomponent>