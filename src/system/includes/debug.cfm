<cfsetting enablecfoutputonly=true>
<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

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
	}
	else{
		document.getElementById(divid).className = "fw_debugContent";
	}
}
</cfoutput>
</script>
<br><br><br>
<div class="fw_debugPanel">

<!--- **************************************************************--->
<!--- TRACER STACK--->
<!--- **************************************************************--->
	<cfif structkeyExists(RequestCollection, "tracerStack")>
	<cfoutput>
		<!--- <cfinclude template="style.cfm"> --->
		<div class="fw_titles" onClick="toggle('fw_tracer')">&gt;&nbsp;Tracer Messages </div>
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
<!--- **************************************************************--->


<!--- **************************************************************--->
<!--- DEBUGGING PANEL --->
<!--- **************************************************************--->
	<div class="fw_titles" onClick="toggle('fw_info')" >
		&gt; &nbsp;ColdBox Debugging Information
	</div>

	<div class="fw_debugContentView" id="fw_info">
		<div class="fw_debugTitleCell">
		  Framework Info:
		</div>
		<div class="fw_debugContentCell">
		#controller.getSetting("Codename",true)# #controller.getSetting("Version",true)# #controller.getSetting("Suffix",true)#
		</div>
		<div class="fw_debugTitleCell">
		  Application Name:
		</div>
		<div class="fw_debugContentCell">
		#controller.getSetting("AppName")#
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
	    #controller.getPlugin("fileUtilities").getInetHost()#
		</div>

		<div class="fw_debugTitleCell">
		  Current Event:
		</div>
		<div class="fw_debugContentCell">
		<cfif Event.getValue("event","") eq ""><span class="fw_redText">N/A</span><cfelse>#Event.getValue("event")#</cfif>
		</div>

		<div class="fw_debugTitleCell">
		  Current Layout:
		</div>
		<div class="fw_debugContentCell">
		<cfif Event.getValue("currentlayout","") eq ""><span class="fw_redText">N/A</span><cfelse>#Event.getValue("currentlayout")#</cfif>
		</div>

		<div class="fw_debugTitleCell">
		  Current View:
		</div>
		<div class="fw_debugContentCell">
		<cfif Event.getValue("currentview","") eq ""><span class="fw_redText">N/A</span><cfelse>#Event.getValue("currentview")#</cfif>
		</div>

		<!--- **************************************************************--->
		<!--- Method Executions --->
		<!--- **************************************************************--->
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
		  <cfelseif findnocase("pre",method) or findnocase("post",method)>
		  	<cfset color = "fw_purpleText">
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
		</table>
		<!--- **************************************************************--->
	</div>


<!--- **************************************************************--->
<!--- Cache Performance --->
<!--- **************************************************************--->
	<div class="fw_titles" onClick="toggle('fw_cache')">&gt;&nbsp; ColdBox Cache </div>
	<div class="fw_debugContentView" id="fw_cache">
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
			<td align="center" width="15%" class="fw_debugTablesTitles">Created</td>
			<td align="center" width="15%" class="fw_debugTablesTitles">Last Accessed</td>
		  </tr>
		  <cfloop collection="#cacheMetadata#" item="key">
		  <tr >
		  	<td class="fw_debugTablesCells">#key#</td>
			<td align="center" class="fw_debugTablesCells">#cacheMetadata[key].hits#</td>
			<td align="center" class="fw_debugTablesCells">#cacheMetadata[key].Timeout#</td>
			<td align="center" class="fw_debugTablesCells">#cacheMetadata[key].Created#</td>
			<td align="center" class="fw_debugTablesCells">#cacheMetadata[key].lastaccesed#</td>
		  </tr>
		  </cfloop>
		</table>
	<!--- **************************************************************--->
	</div>

<!--- **************************************************************--->
<!--- DUMP VAR --->
<!--- **************************************************************--->
	<cfif controller.getSetting("EnableDumpVar")>
		<cfset dumpList = Event.getValue("dumpvar",0)>
		<cfif dumplist neq 0>
		<!--- Dump Var --->
		<div class="fw_titles" onClick="toggle('fw_dumpvar')">&gt;&nbsp;Dumpvar </div>
		<div class="fw_debugContent" id="fw_dumpvar">
			<cfloop list="#dumplist#" index="i">
				<cfif isDefined("#i#")>
					<cfdump var="#evaluate(i)#" label="#i#">
				</cfif>
			</cfloop>
		</div>
		</cfif>
	</cfif>
<!--- **************************************************************--->


<!--- **************************************************************--->
<!--- Request Collection Debug --->
<!--- **************************************************************--->
	<div class="fw_titles"  onClick="toggle('fw_reqCollection')" >
	&gt; &nbsp;Request Collection Structure
	</div>
	<div class="fw_debugContent" id="fw_reqCollection">
		<table border="0" cellpadding="0" cellspacing="1" class="fw_debugTables" width="100%">
		  <cfloop collection="#RequestCollection#" item="vars">
		  <tr>
			<td align="right" width="15%" class="fw_debugTablesTitles">#lcase(vars)#:</td>
			<td  class="fw_debugTablesCells">
			<cfif isSimpleValue(Event.getValue(vars)) >
				<cfif Event.getValue(vars) eq ""><span class="fw_redText">N/A</span></cfif> #Event.getValue(vars)#
			<cfelse>
				<cfdump var="#Event.getValue(vars)#">
			</cfif>
			</td>
		  </tr>
		  </cfloop>
		</table>
	</div>
<!--- **************************************************************--->

	<br />
	<em><strong>Approximate Debug Rendering Time: #GetTickCount()-DebugStartTime# ms</strong></em>
	<br /><br />

</div>
</cfoutput>
<cfsetting enablecfoutputonly=false>