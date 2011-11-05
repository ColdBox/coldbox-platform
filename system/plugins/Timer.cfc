<!-----------------------------------------------------------------------
Template : MessageBox.cfc
Author 	 : Luis Majano
Date     : 3/13/2007 8:28:31 AM
Description :
	This is a Timer plugin

Modification History:
3/13/2007 - Created Template
---------------------------------------------------------------------->
<cfcomponent name="Timer"
			 hint="This is the Timer plugin. It is used to time executions. Facade for request variable"
			 extends="coldbox.system.Plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="Timer" output="false" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			super.Init(arguments.controller);
			setpluginName("Timer");
			setpluginVersion("1.0");
			setpluginDescription("A useful code Timer plugin.");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="start" access="public" returntype="void" output="false" hint="Start the Timer with label.">
		<cfargument name="Label" 	 required="true" type="string">
		<!--- Create request Timer --->
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
		<cfreturn controller.getDebuggerService().getTimers()>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="addRow" access="private" returntype="void" output="false" hint="Add a new timer row.">
		<cfargument name="label" 	 required="true" type="string" hint="The lable of the timer.">
		<cfargument name="tickcount" required="true" type="string" hint="The tickcounts of the time.">
		<cfscript>
			var qTimers = getTimerScope();
			
			QueryAddRow(qTimers,1);
			QuerySetCell(qTimers, "ID", hash(arguments.label & now()));
			QuerySetCell(qTimers, "Method", arguments.label);
			QuerySetCell(qTimers, "Time", arguments.tickcount);
			QuerySetCell(qTimers, "Timestamp", now());
			QuerySetCell(qTimers, "RC", '');
			QuerySetCell(qTimers, "PRC", '');
		</cfscript>
	</cffunction>


</cfcomponent>