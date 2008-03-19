<cfsetting enablecfoutputonly=true>
<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Template :  timer.cfm
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description :
	This is the framework's timer module. You just need to wrap any piece
	of code with a cfmodule call to this template and it will be timed.

Modification History:
06/08/2006 - Updated for coldbox.
----------------------------------------------------------------------->
<cfparam name="attributes.timertag" default="NO_TIMER_TAG">
<!--- Verify controller exists or debugger service --->
<cfif structkeyExists(application,"cbController") AND application.cbController.getDebuggerService().getDebugMode()>
	<cfscript>
	//Check if DebugTimers is set
	if ( not structKeyExists(request,"DebugTimers") ){
		request.DebugTimers = QueryNew("Id,Method,Time,Timestamp,RC");
	}
	//Start Processing
	if (thisTag.executionMode is "start")
		variables.stime = getTickCount();
	else{
		//In case timer is executed before the debug Mode has been set
		if ( structKeyExists(variables, "stime") )	{
			QueryAddRow(request.DebugTimers,1);
			QuerySetCell(request.DebugTimers, "Id", createUUID());
			QuerySetCell(request.DebugTimers, "Method", attributes.timertag);
			QuerySetCell(request.DebugTimers, "Time", getTickCount() - stime);
			QuerySetCell(request.DebugTimers, "Timestamp", now());
			//Request Context SnapShot
			if ( not findnocase("rendering",attributes.timertag) ){
				rc = application.cbController.getRequestService().getContext().getCollection().toString();
				QuerySetCell(request.DebugTimers, "RC", htmlEditFormat(rc) );
			}
			else{
				QuerySetCell(request.DebugTimers, "RC", '');
			}
		}
	}
	</cfscript>
</cfif>
<cfsetting enablecfoutputonly=false>