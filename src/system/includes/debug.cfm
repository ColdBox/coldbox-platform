<cfsetting enablecfoutputonly=true>
<!-----------------------------------------------------------------------
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
----------------------------------------------------------------------->
<!--- ************************************************************* --->
<cfset debugStartTime = GetTickCount()>
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
	
	<cfif structkeyExists(getCollection(), "tracerStack")>
	<cfoutput>
		<!--- <cfinclude template="style.cfm"> --->
		<div class="fw_titles" onClick="toggle('fw_tracer')"><img src="/coldbox/system/includes/images/arrow_down.gif" id="fw_tracer_img"/>&nbsp;Tracer Messages </div>
		<div id="fw_tracer" class="fw_info">
		<cfloop from="1" to="#arrayLen(getCollection().tracerStack)#" index="i">
		<div class="fw_tracerMessage">
		<strong>Message:</strong><br>
		#getCollection().tracerStack[i].message#<br>
		<strong>ExtraInformation:<br></strong>
		<cfif not isSimpleValue(getCollection().tracerStack[i].extrainfo)>
			<cfdump var="#getCollection().tracerStack[i].extrainfo#">
		<cfelseif getCollection().tracerStack[i].extrainfo neq "">
			#getCollection().tracerStack[i].extrainfo#
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
		#getSetting("Codename",true)# #getSetting("Version",true)# #getSetting("Suffix",true)#
		</div>

		<div class="fw_debugTitleCell">
		  Application Name:
		</div>
		<div class="fw_debugContentCell">
		#getSetting("AppName")#
		</div>

		<div class="fw_debugTitleCell">
		  Coldfusion ID's:
		</div>
		<div class="fw_debugContentCell">
		<cfif structkeyExists(session,"cfid")>
		CFID=#session.CFID# ;
		<cfelseif structkeyExists(client,"cfid")>
		CFID=#client.CFID# ;
		</cfif>
		<cfif structkeyExists(session,"CFToken")>
		CFToken=#session.CFToken# ;
		<cfelseif structkeyExists(client,"CFToken")>
		CFToken=#client.CFToken# ;
		</cfif>
		<cfif structkeyExists(session,"sessionID")>
		JSessionID=#session.sessionID#
		</cfif>
		</div>

		<div class="fw_debugTitleCell">
		  TimeStamp:
		</div>
		<div class="fw_debugContentCell">
		#dateformat(now(), "MMM-DD-YYYY")# #timeFormat(now(), "HH:MM:SS")#
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
		<cfif getValue("event","") eq ""><span class="fw_redText">N/A</span><cfelse>#getValue("event")#</cfif>
		</div>

		<div class="fw_debugTitleCell">
		  Current Layout:
		</div>
		<div class="fw_debugContentCell">
		<cfif getValue("currentlayout","") eq ""><span class="fw_redText">N/A</span><cfelse>#getValue("currentlayout")#</cfif>
		</div>

		<div class="fw_debugTitleCell">
		  Current View:
		</div>
		<div class="fw_debugContentCell">
		<cfif getValue("currentview","") eq ""><span class="fw_redText">N/A</span><cfelse>#getValue("currentview")#</cfif>
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

	</div>

	<cfif getSetting("EnableDumpVar")>
		<cfset dumpList = getValue("dumpvar",0)>
		<cfif dumplist neq 0>
		<!--- Dump Var --->
		<div class="fw_titles" onClick="toggle('fw_dumpvar')"><img src="/coldbox/system/includes/images/arrow_right.gif" id="fw_dumpvar_img" />&nbsp;Dumpvar </div>
		<div class="fw_debugContent" id="fw_dumpvar">
			<cfloop list="#dumplist#" index="i">
				<cfif isDefined("#i#")>
					<cfdump var="#evaluate(i)#" label="#i#">
				<cfelseif StructKeyExists( request.reqCollection, "#i#")>
					<cfdump var="#request.reqCollection[i]#">
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
		  <cfloop collection="#request.reqCollection#" item="vars">
		  <tr>
			<td align="right" width="15%" class="fw_debugTablesTitles">#lcase(vars)#:</td>
			<td  class="fw_debugTablesCells">
			<cfif isSimpleValue(request.reqCollection[vars]) >
				<cfif request.reqCollection[vars] eq ""><span class="fw_redText">N/A</span></cfif> #request.reqCollection[vars]#
			<cfelse>
				<cfdump var="#request.reqCollection[vars]#">
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