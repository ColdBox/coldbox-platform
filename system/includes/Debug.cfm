<cfsetting enablecfoutputonly=true>
<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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
<cfinclude template="DebugHeader.cfm">
<div style="margin-top:40px"></div>
<div class="fw_debugPanel">

	<!--- **************************************************************--->
	<!--- TRACER STACK--->
	<!--- **************************************************************--->
	<cfinclude template="/coldbox/system/includes/panels/TracersPanel.cfm">
	

	<!--- **************************************************************--->
	<!--- DEBUGGING PANEL --->
	<!--- **************************************************************--->
	<cfif getDebuggerConfigBean().getShowInfoPanel()>
	<div class="fw_titles" onClick="fw_toggle('fw_info')" >
		&gt; &nbsp;ColdBox Debugging Information
	</div>

	<div class="fw_debugContent<cfif getDebuggerConfigBean().getExpandedInfoPanel()>View</cfif>" id="fw_info">
		
		<div>
			<form name="fw_reinitcoldbox" id="fw_reinitcoldbox" action="index.cfm" method="POST">
				<input type="hidden" name="fwreinit" id="fwreinit" value="">
				<input type="button" value="Reinitialize Framework" name="reinitframework" style="font-size:10px" title="Reinitialize the framework." onClick="fw_reinitframework(#iif(controller.getSetting('ReinitPassword').length(),'true','false')#)">
				<cfif getDebuggerConfigBean().getPersistentRequestProfiler()>
				&nbsp;
				<input type="button" value="Open Profiler Monitor" name="profilermonitor" style="font-size:10px" title="Open the profiler monitor in a new window." onClick="window.open('index.cfm?debugpanel=profiler','profilermonitor','status=1,toolbar=0,location=0,resizable=1,scrollbars=1,height=750,width=800')">
				</cfif>
			</form>
		  <br>
		</div>
		
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
		#controller.getSetting("AppName")# <span class="fw_purpleText">(#lcase(controller.getSetting("Environment"))#)</span>
		</div>
		<div class="fw_debugTitleCell">
		  Template:
		</div>
		<div class="fw_debugContentCell">
			#cgi.PATH_TRANSLATED#
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
	    #controller.getPlugin("Utilities").getInetHost()#
		</div>

		<div class="fw_debugTitleCell">
		  Current Event:
		</div>
		<div class="fw_debugContentCell">
		<cfif Event.getCurrentEvent() eq ""><span class="fw_redText">N/A</span><cfelse>#Event.getCurrentEvent()#</cfif>
		<cfif Event.isEventCacheable()><span class="fw_redText">&nbsp;CACHED EVENT</span></cfif>
		</div>

		<div class="fw_debugTitleCell">
		  Current Layout:
		</div>
		<div class="fw_debugContentCell">
		<cfif Event.getCurrentLayout() eq ""><span class="fw_redText">N/A</span><cfelse>#Event.getCurrentLayout()#</cfif>
		</div>

		<div class="fw_debugTitleCell">
		  Current View:
		</div>
		<div class="fw_debugContentCell">
		<cfif Event.getCurrentView() eq ""><span class="fw_redText">N/A</span><cfelse>#Event.getCurrentView()#</cfif>
		</div>
		
		<!--- **************************************************************--->
		<!--- Method Executions --->
		<!--- **************************************************************--->
		<table border="0" align="center" cellpadding="0" cellspacing="1" class="fw_debugTables">
		  <tr>
		  	<th width="13%" align="center" >Timestamp</th>
			<th width="10%" align="center" >Execution Time</th>
			<th >Framework Method</th>
			<th width="75" align="center" >RC Snapshot</th>
		  </tr>
		  <cfif structKeyExists(request,"DebugTimers")>
			  <cfloop query="request.DebugTimers">
				  <cfif findnocase("rendering", method)>
				  	<cfset color = "fw_redText">
				  <cfelseif findnocase("interception",method)>
				  	<cfset color = "fw_blackText">
				  <cfelseif findnocase("runEvent", method)>
				  	<cfset color = "fw_blueText">
				  <cfelseif findnocase("pre",method) or findnocase("post",method)>
				  	<cfset color = "fw_purpleText">
				  <cfelse>
				  	<cfset color = "fw_greenText">
				  </cfif>
				  <tr <cfif currentrow mod 2 eq 0>class="even"</cfif>>
				  	<td align="center" >#TimeFormat(timestamp,"hh:MM:SS.l tt")#</td>
					<td align="center" >#Time# ms</td>
					<td ><span class="#color#">#Method#</span></td>
					<td align="center" >
						<cfif rc neq ''><a href="javascript:fw_poprc('fw_poprc_#id#')">View</a><cfelse>...</cfif>
					</td>
				  </tr>
				 <tr id="fw_poprc_#id#" class="hideRC">
				  	<td colspan="4" style="padding:5px;" wrap="true">
					  	<div style="overflow:auto;width:98%; height:150px;padding:5px">
						  #replacenocase(rc,",",chr(10) & chr(13),"all")#
						</div>
					</td>
		  		  </tr>
			  </cfloop>
		  <cfelse>
		  	<tr>
			  	<td colspan="4">No Timers Found...</td>			
			</tr>
		  </cfif>
		  <cfif structKeyExists(request,"fwExecTime")>
		  <tr>
			<th colspan="4">Total Framework Request Execution Time: #request.fwExecTime# ms</th>
		  </tr>
		  </cfif>
		</table>		
		<!--- **************************************************************--->
	</div>
	</cfif>

<!--- **************************************************************--->
<!--- Cache Performance --->
<!--- **************************************************************--->
	
	<cfif getDebuggerConfigBean().getShowCachePanel()>
		<cfinclude template="panels/CachePanel.cfm">
	</cfif>
	
<!--- **************************************************************--->
<!--- DUMP VAR --->
<!--- **************************************************************--->
	<cfif controller.getSetting("EnableDumpVar")>
		<cfset dumpList = Event.getValue("dumpvar",0)>
		<cfif dumplist neq 0>
		<!--- Dump Var --->
		<div class="fw_titles" onClick="fw_toggle('fw_dumpvar')">
		&gt; &nbsp;Dumpvar 
		</div>
		<div class="fw_debugContent" id="fw_dumpvar">
			<cfloop list="#dumplist#" index="i">
				<cfif isDefined("#i#")>
					<cfdump var="#evaluate(i)#" label="#i#" expand="false">
				<cfelseif event.valueExists(i)>
					<cfset _tmpvar = event.getValue(i)>
					<cfdump var="#_tmpvar#" label="#i#" expand="false">
				</cfif>
			</cfloop>
		</div>
		</cfif>
	</cfif>
<!--- **************************************************************--->


<!--- **************************************************************--->
<!--- Request Collection Debug --->
<!--- **************************************************************--->
	<cfif getDebuggerConfigBean().getShowRCPanel()>
	<div class="fw_titles"  onClick="fw_toggle('fw_reqCollection')" >
	&gt; &nbsp;Request Collection Structure
	</div>
	<div class="fw_debugContent<cfif getDebuggerConfigBean().getExpandedRCPanel()>View</cfif>" id="fw_reqCollection">
		<table border="0" cellpadding="0" cellspacing="1" class="fw_debugTables" width="100%">
		  <cfloop collection="#RequestCollection#" item="vars">
		  <cfset varVal = event.getValue(vars)>
		  <tr>
			<td align="right" width="15%" class="fw_debugTablesTitles">#lcase(vars)#:</td>
			<td  class="fw_debugTablesCells">
			<cfif isSimpleValue(varVal) >
				<cfif varVal eq "">
					<span class="fw_redText">N/A</span>
				<cfelse>
					#htmlEditFormat(varVal)#
				</cfif>
			<cfelse>
				<!--- Max Display For Queries  --->
				<cfif isQuery(varVal) and (varVal.recordCount gt getDebuggerConfigBean().getmaxRCPanelQueryRows())>
					<cfquery name="varVal" dbType="query" maxrows="#getDebuggerConfigBean().getmaxRCPanelQueryRows()#">
						select * from varVal
					</cfquery>
					<cfdump var="#varVal#" label="Query Truncated to #getDebuggerConfigBean().getmaxRCPanelQueryRows()# records" expand="false">
				<cfelse>
					<cfdump var="#Event.getValue(vars)#" expand="false">
				</cfif>				
			</cfif>
			</td>
		  </tr>
		  </cfloop>
		</table>
	</div>
	</cfif>
<!--- **************************************************************--->

	<div class="fw_renderTime">
	Approximate Debug Rendering Time: #GetTickCount()-DebugStartTime# ms
	</div>

</div>
</cfoutput>
<cfsetting enablecfoutputonly=false>