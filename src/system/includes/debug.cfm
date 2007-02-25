<cfsetting enablecfoutputonly=true>
<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------

Template :  debug.cfm
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :
	Debugging template for the application

Modification History:
10/13/2005 - Moved reqCollection from session to request.
12/23/2005 - Eliminated ConfigStruct Dump
01/06/2006 - Eliminated controller references.
01/16/2006 - Added support for child applications.
06/08/2006 - Updated for coldbox.
06/09/2006 - Changed isDefined to StructkeyExists
07/12/2006 - Tracer now shows first expanded.
02/01/2007 - Updated context references
----------------------------------------------------------------------->
<!--- ************************************************************* --->

<!--- Setup Local Variables --->
<cfset debugStartTime = GetTickCount()>
<cfset RequestCollection = RequestContext.getCollection()>

<cfset JVMFreeMemory = getPlugin("fileUtilities").getJVMfreeMemory()/1024>
<cfset JVMTotalMemory = getPlugin("fileUtilities").getJVMTotalMemory()/1024>

<cfoutput>
<!--- Style --->
<style>
<cfinclude template="style.css">
</style>
<script  language="javascript" type="text/javascript">
<cfoutput>
function toggle(divid){
	if ( document.getElementById(divid).className == "fw_debugContent"){
		document.getElementById(divid).className = "fw_debugContentView";
		document.getElementById(divid + "_img").src = "/coldbox/system/includes/images/arrow_down.gif";
	}
	else{
		document.getElementById(divid).className = "fw_debugContent";
		document.getElementById(divid + "_img").src = "/coldbox/system/includes/images/arrow_right.gif";
	}
}
</cfoutput>
</script>
<br><br><br>
<div class="fw_debugPanel">
	
	<cfif structkeyExists(RequestCollection, "tracerStack")>
	<cfoutput>
		<!--- <cfinclude template="style.cfm"> --->
		<div class="fw_titles" onClick="toggle('fw_tracer')"><img src="/coldbox/system/includes/images/arrow_down.gif" id="fw_tracer_img"/>&nbsp;Tracer Messages </div>
		<div id="fw_tracer" class="fw_info">
		<cfloop from="1" to="#arrayLen(RequestCollection.tracerStack)#" index="i">
		<div class="fw_tracerMessage">
		<strong>Message:</strong><br>
		#RequestCollection.tracerStack[i].message#<br>
		<strong>ExtraInformation:<br></strong>
		<cfif not isSimpleValue(RequestCollection.tracerStack[i].extrainfo)>
			<cfdump var="#RequestCollection.tracerStack[i].extrainfo#">
		<cfelseif RequestCollection.tracerStack[i].extrainfo neq "">
			#RequestCollection.tracerStack[i].extrainfo#
		<cfelse>
			{Not Sent}
		</cfif>
		</div>
		</cfloop>
		</div>
	</cfoutput>
	</cfif>

	<div class="fw_titles" onClick="toggle('fw_info')" >
		 <img src="/coldbox/system/includes/images/arrow_down.gif" id="fw_info_img"/>&nbsp;Debugging Information
	</div>

	<div class="fw_debugContentView" id="fw_info">
		<div class="fw_debugTitleCell">
		  Framework Info:
		</div>
		<div class="fw_debugContentCell">
		#getController().getSetting("Codename",true)# #getController().getSetting("Version",true)# #getController().getSetting("Suffix",true)#
		</div>
		<div class="fw_debugTitleCell">
		  Application Name:
		</div>
		<div class="fw_debugContentCell">
		#getController().getSetting("AppName")#
		</div>
		
		<div class="fw_debugTitleCell">
		  JVM Memory
		</div>
		<div class="fw_debugContentCell">
		#NumberFormat(JVMFreeMemory)# KB / #NumberFormat(JVMTotalMemory)#	KB (Free/Total)	
		</div>

		<div class="fw_debugTitleCell">
		  TimeStamp:
		</div>
		<div class="fw_debugContentCell">
		#dateformat(now(), "MMM-DD-YYYY")# #timeFormat(now(), "hh:MM:SS tt")#
		</div>

		<div class="fw_debugTitleCell">
		  Browser:
		</div>
		<div class="fw_debugContentCell">
		#cgi.HTTP_USER_AGENT#
		</div>

		<div class="fw_debugTitleCell">
		  Query String:
		</div>
		<div class="fw_debugContentCell">
		<cfif cgi.QUERY_STRING eq ""><span class="fw_redText">N/A</span></cfif>#cgi.QUERY_STRING#
		</div>

		<div class="fw_debugTitleCell">
		  Remote IP:
		</div>
		<div class="fw_debugContentCell">
		#cgi.REMOTE_ADDR#
		</div>

		<div class="fw_debugTitleCell">
		  Server Instance:
		</div>
		<div class="fw_debugContentCell">
	    #getPlugin("fileUtilities").getInetHost()#
		</div>

		<div class="fw_debugTitleCell">
		  Current Event:
		</div>
		<div class="fw_debugContentCell">
		<cfif requestContext.getValue("event","") eq ""><span class="fw_redText">N/A</span><cfelse>#requestContext.getValue("event")#</cfif>
		</div>

		<div class="fw_debugTitleCell">
		  Current Layout:
		</div>
		<div class="fw_debugContentCell">
		<cfif requestContext.getValue("currentlayout","") eq ""><span class="fw_redText">N/A</span><cfelse>#requestContext.getValue("currentlayout")#</cfif>
		</div>

		<div class="fw_debugTitleCell">
		  Current View:
		</div>
		<div class="fw_debugContentCell">
		<cfif requestContext.getValue("currentview","") eq ""><span class="fw_redText">N/A</span><cfelse>#requestContext.getValue("currentview")#</cfif>
		</div>

		<em><p>Method execution times in execution order.</p></em>

		<table border="0" align="center" cellpadding="0" cellspacing="1" class="fw_debugTables">
		  <tr >
		  	<td width="13%" align="center" class="fw_debugTablesTitles">Timestamp</td>
			<td width="10%" align="center" class="fw_debugTablesTitles">Execution Time</td>
			<td class="fw_debugTablesTitles">Framework Method</td>
		  </tr>
		  <cfloop query="request.DebugTimers">
		  <cfif findnocase("render", method)>
		  	<cfset color = "fw_redText">
		  <cfelseif findnocase("runEvent", method)>
		  	<cfset color = "fw_blueText">
		  <cfelse>
		  	<cfset color = "fw_greenText">
		  </cfif>
		  <tr >
		  	<td align="center" class="fw_debugTablesCells">#TimeFormat(timestamp,"hh:MM:SS.l tt")#</td>
			<td align="center" class="fw_debugTablesCells">#Time# ms</td>
			<td class="fw_debugTablesCells"><span class="#color#">#Method#</span></td>
		  </tr>
		  </cfloop>
		  <tr>
			<td colspan="3" class="fw_debugTablesTitles">Total Framework Request Execution Time: #request.fwExecTime# ms</td>
		  </tr>
		</table><br>
		
		<hr>
		
		<!--- Cache Performance --->
		<div class="fw_debugTitleCell">
		  Cache Performance
		</div>
		<div class="fw_debugContentCell">
		 <em>Ratio:</em> #NumberFormat(getColdboxOCM().getCachePerformanceRatio(),"999.99")#%  ==>
		 <em>Hits:</em> #getColdboxOCM().getCachePerformance().hits# |
		 <em>Misses:</em> #getColdboxOCM().getCachePerformance().misses#
		</div>
		
		<div class="fw_debugTitleCell">
		  Last Reap
		</div>
		<div class="fw_debugContentCell">
		 #DateFormat(getColdboxOCM().getlastReapDatetime(),"MMM-DD-YYYY")# 
		 #TimeFormat(getColdboxOCM().getlastReapDatetime(),"hh:mm:ss tt")#
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
		
		<cfif server.ColdFusion.ProductName eq "Coldfusion Server">
		<div>
		<table align="center" >
			<tr>
				<td>
				<cfchart format="png" show3d="true" backgroundcolor="##eeeeee" gridlines="true">
					<cfchartseries type="pie" colorlist="85ca0a,1e3aca" >
						<cfchartdata item="Free Memory (KB)"  value="#JVMFreeMemory#">
						<cfchartdata item="Total Memory (KB)" value="#JVMTotalMemory#">
					</cfchartseries>
				</cfchart>
				</td>
				<td>
				<cfchart format="png" show3d="true" backgroundcolor="##eeeeee">
					<cfchartseries type="bar" colorlist="93C2FF,ED2939" >
						<cfchartdata item="Hits" value="#getColdboxOCM().getCachePerformance().hits#">
						<cfchartdata item="Misses" value="#getColdboxOCM().getCachePerformance().misses#">
					</cfchartseries>
				</cfchart>
				</td>
				<td>
				<cfset itemTypes = getColdboxOCM().getItemTypes()>
				<cfchart format="png" show3d="true" backgroundcolor="##eeeeee" gridlines="true">
					<cfchartseries type="pie" colorlist="93C2FF" >
						<cfchartdata item="Plugins" value="#itemTypes.plugins#">
						<cfchartdata item="Handlers" value="#itemTypes.handlers#">
						<cfchartdata item="Other Objects" value="#itemTypes.other#">
					</cfchartseries>
				</cfchart>
				</td>
			</tr>
		</table>
		</div>
		</cfif>
	</div>

	<cfif getController().getSetting("EnableDumpVar")>
		<cfset dumpList = RequestContext.getValue("dumpvar",0)>
		<cfif dumplist neq 0>
		<!--- Dump Var --->
		<div class="fw_titles" onClick="toggle('fw_dumpvar')"><img src="/coldbox/system/includes/images/arrow_right.gif" id="fw_dumpvar_img" />&nbsp;Dumpvar </div>
		<div class="fw_debugContent" id="fw_dumpvar">
			<cfloop list="#dumplist#" index="i">
				<cfif isDefined("#i#")>
					<cfdump var="#evaluate(i)#" label="#i#">
				</cfif>
			</cfloop>
		</div>
		</cfif>
	</cfif>

	<!--- Request Collection Debug --->
	<div class="fw_titles"  onClick="toggle('fw_reqCollection')" >
	<img src="/coldbox/system/includes/images/arrow_right.gif"  id="fw_reqCollection_img" />&nbsp;Request Collection Structure
	</div>
	<div class="fw_debugContent" id="fw_reqCollection">
		<table border="0" cellpadding="0" cellspacing="1" class="fw_debugTables" width="100%">
		  <cfloop collection="#RequestCollection#" item="vars">
		  <tr>
			<td align="right" width="15%" class="fw_debugTablesTitles">#lcase(vars)#:</td>
			<td  class="fw_debugTablesCells">
			<cfif isSimpleValue(RequestContext.getValue(vars)) >
				<cfif RequestContext.getValue(vars) eq ""><span class="fw_redText">N/A</span></cfif> #RequestContext.getValue(vars)#
			<cfelse>
				<cfdump var="#RequestContext.getValue(vars)#">
			</cfif>
			</td>
		  </tr>
		  </cfloop>
		</table>
	</div>

	<br />
	<em><strong>Approximate Debug Rendering Time: #GetTickCount()-DebugStartTime# ms</strong></em>
	<br /><br />

	
</div>
	</cfoutput>
<cfsetting enablecfoutputonly=false>