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
<cfinclude template="debugHeader.cfm">
<br><br><br>
<div class="fw_debugPanel">

<!--- **************************************************************--->
<!--- TRACER STACK--->
<!--- **************************************************************--->
	<cfif structkeyExists(RequestCollection, "fw_tracerStack")>
	<cfoutput>
		<!--- <cfinclude template="style.cfm"> --->
		<div class="fw_titles" onClick="fw_toggle('fw_tracer')">&gt;&nbsp;Tracer Messages </div>
		<div id="fw_tracer" class="fw_info">
		<cfloop from="1" to="#arrayLen(RequestCollection.fw_tracerStack)#" index="i">
		<div class="fw_tracerMessage">
		<strong>Message:</strong><br>
		#RequestCollection.fw_tracerStack[i].message#<br>
		<strong>ExtraInformation:<br></strong>
		<cfif not isSimpleValue(RequestCollection.fw_tracerStack[i].extrainfo)>
			<cfdump var="#RequestCollection.fw_tracerStack[i].extrainfo#">
		<cfelseif RequestCollection.fw_tracerStack[i].extrainfo neq "">
			#RequestCollection.fw_tracerStack[i].extrainfo#
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
	<div class="fw_titles" onClick="fw_toggle('fw_info')" >
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
		  TimeStamp:
		</div>
		<div class="fw_debugContentCell">
		#dateformat(now(), "MMM-DD-YYYY")# #timeFormat(now(), "hh:MM:SS tt")#
		</div>

		<div class="fw_debugTitleCell">
		  Query String:
		</div>
		<div class="fw_debugContentCell">
		<cfif cgi.QUERY_STRING eq ""><span class="fw_redText">N/A</span></cfif>#cgi.QUERY_STRING#
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
			<td width="75" align="center" class="fw_debugTablesTitles" >RC Snapshot</td>
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
			<td align="center" class="fw_debugTablesCells">
				<cfif rc neq ''><a href="javascript:fw_poprc('fw_poprc_#id#')">View</a><cfelse>...</cfif>
			</td>
		  </tr>
		  <tr id="fw_poprc_#id#" style="display:none">
		  	<td colspan="4" style="padding:5px;background-color:##fffff0" wrap="true"><pre>#replace(rc,",","<br>","all")#</pre></td>
		  </tr>
		  </cfloop>
		  <tr>
			<td colspan="4" class="fw_debugTablesTitles">Total Framework Request Execution Time: #request.fwExecTime# ms</td>
		  </tr>
		</table>
		<!--- **************************************************************--->
	</div>


<!--- **************************************************************--->
<!--- Cache Performance --->
<!--- **************************************************************--->

	<cfinclude template="cachepanel.cfm">

<!--- **************************************************************--->
<!--- DUMP VAR --->
<!--- **************************************************************--->
	<cfif controller.getSetting("EnableDumpVar")>
		<cfset dumpList = Event.getValue("dumpvar",0)>
		<cfif dumplist neq 0>
		<!--- Dump Var --->
		<div class="fw_titles" onClick="fw_toggle('fw_dumpvar')">&gt;&nbsp;Dumpvar </div>
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
	<div class="fw_titles"  onClick="fw_toggle('fw_reqCollection')" >
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