<!-----------------------------------------------------------------------
Template : messagebox.cfc
Author 	 : Luis Majano
Date     : 3/13/2007 8:28:31 AM
Description :
	This is a timer plugin

Modification History:
3/13/2007 - Created Template
---------------------------------------------------------------------->
<cfcomponent name="timer"
			 hint="This is the timer plugin. It is used to time executions. Facade for request variable"
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true"
			 cachetimeout="5">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="timer" output="false" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("Timer Plugin")>
		<cfset setpluginVersion("1.0")>
		<cfset setpluginDescription("A useful code timer plugin.")>
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="start" access="public" returntype="void" output="false" hint="Start the timer with label.">
		<cfargument name="Label" 	 required="true" type="string">
		<!--- Create request timer --->
		<cfset var timerStruct = structnew()>
		<cfset timerStruct.stime = getTickcount()>
		<cfset timerStruct.label = arguments.label>
		<!--- Place timer struct in request scope --->
		<cfset request[hash(arguments.label)] = timerStruct>
	</cffunction>

	<cffunction name="stop" access="public" returntype="void" output="false" hint="Stop the timer with label">
		<cfargument name="Label" 	 required="true" type="string">
		<cfset var stopTime = getTickcount()>
		<cfset var timerStruct = "">
		<cfset var labelhash = hash(arguments.label)>

		<!--- Check if the label exists --->
		<cfif StructKeyExists(request,labelhash)>
			<cfset timerStruct = request[labelhash]>
			<cfset addRow(timerStruct.label,stopTime - timerStruct.stime)>
		<cfelse>
			<cfset addRow("#arguments.label# invalid",0)>
		</cfif>
	</cffunction>

	<cffunction name="logTime" access="public" returntype="void" output="false" hint="Use this method to add a new timer entry to the timers.">
		<cfargument name="Label" 	 required="true" type="string" hint="The lable of the timer.">
		<cfargument name="Tickcount" required="true" type="string" hint="The tickcounts of the time.">
		<cfset addRow(arguments.label,arguments.tickcount)>
	</cffunction>

	<cffunction name="getTimerScope" access="public" returntype="query" output="false" hint="Returns the entire timer query from the request scope.">
		<!---Get the timer scope if it exists, else create it --->
		<cfif not structKeyExists(request,"DebugTimers")>
			<cfset request.DebugTimers = QueryNew("Id,Method,Time,Timestamp,RC")>
		</cfif>
		<cfreturn request.DebugTimers>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="addRow" access="private" returntype="void" output="false" hint="Add a new timer row.">
		<cfargument name="Label" 	 required="true" type="string" hint="The lable of the timer.">
		<cfargument name="Tickcount" required="true" type="string" hint="The tickcounts of the time.">
		<cfscript>
		var qTimer = getTimerScope();
		QueryAddRow(qTimer,1);
		QuerySetCell(qTimer, "Id", createUUID());
		QuerySetCell(qTimer, "Method", arguments.Label);
		QuerySetCell(qTimer, "Time", arguments.Tickcount);
		QuerySetCell(qTimer, "Timestamp", now());
		QuerySetCell(qTimer, "RC", '');
		</cfscript>
	</cffunction>


</cfcomponent>