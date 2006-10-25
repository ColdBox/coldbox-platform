<cfsetting enablecfoutputonly=true>
<!-----------------------------------------------------------------------
Copyright 2005 - 2006 ColdBox Framework by Luis Majano
www.coldboxframework.com | www.coldboxframework.org
-------------------------------------------------------------------------
Template :  timer.cfm 
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description : 			
	This is the framework's timer module. You just need to wrap any piece
	of code with a cfmodule call to this template and it will be timed.
				
Modification History:	
06/08/2006 - Updated for coldbox.
----------------------------------------------------------------------->
<!--- ************************************************************* --->
<cfparam name="attributes.timertag" default="NO_TIMER_TAG">
<cfif not structkeyExists(session,"fwController") and not session.fwController.getDebugMode()>
	<cfexit method="exittag">
</cfif>
<cfscript>	
//Check if DebugTimers is set
if ( not structKeyExists(request,"DebugTimers") ){
	request.DebugTimers = QueryNew("Method,Time,Timestamp");
}
//Start Processing
if (thisTag.executionMode is "start")
	variables.stime = getTickCount();
else{
	//In case timer is executed before the debug Mode has been set
	if ( structKeyExists(variables, "stime") )	{
		QueryAddRow(request.DebugTimers,1);
		QuerySetCell(request.DebugTimers, "Method", attributes.timertag);
		QuerySetCell(request.DebugTimers, "Time", getTickCount() - stime);
		QuerySetCell(request.DebugTimers, "Timestamp", now());
	}
}
</cfscript>
<cfsetting enablecfoutputonly=false>