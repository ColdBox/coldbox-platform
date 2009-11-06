<!-----------------------------------------------------------------------
Template : MessageBox.cfc
Author 	 : Luis Majano
Date     : 3/13/2007 8:28:31 AM
Description :
	This is a Timer plugin

Modification History:
3/13/2007 - Created Template
---------------------------------------------------------------------->
<cfcomponent hint="This is the Timer plugin. It is used to time executions. Facade for request variable"
			 extends="coldbox.system.Plugin"
			 output="false"
			 cache="true"
			 cachetimeout="5">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="Timer" output="false" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			super.init(arguments.controller);
			setpluginName("Timer");
			setpluginVersion("1.0");
			setpluginDescription("A useful code Timer plugin.");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			
			// ID: FRIGGING CF7 SUPPORT, JUST DIE!!!
			if( controller.oCFMLEngine.isMT() ){
				instance.uuid = createobject("java", "java.util.UUID");
			}
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="start" access="public" returntype="void" output="false" hint="Start the Timer with label.">
		<cfargument name="Label" 	 required="true" type="string">
		<cfscript>
			var timerStruct = structnew();
			timerStruct.stime = getTickcount();
			timerStruct.label = arguments.label;
			
			request[hash(arguments.label)] = timerStruct;
		</cfscript>
	</cffunction>

	<cffunction name="stop" access="public" returntype="void" output="false" hint="Stop the timer with label">
		<cfargument name="Label" 	 required="true" type="string">
		<cfscript>
			var stopTime = getTickcount();
			var timerStruct = "";
			var labelhash = hash(arguments.label);
			
			if ( structKeyExists(request,labelhash) ){
				timerStruct = request[labelhash];
				addRow(timerStruct.label,stopTime - timerStruct.stime);
			}
			else{
				addRow("#arguments.label# invalid",0);
			}
		</cfscript>
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
			var id = "";
			
			// Prepare ID
			// ID: FRIGGING CF7 SUPPORT, JUST DIE!!!
			if( controller.oCFMLEngine.isMT() ){
				id = instance.uuid.randomUUID().toString();
			}
			else{
				id = hash(arguments.label & now());
			}
			
			QueryAddRow(qTimers,1);
			QuerySetCell(qTimers, "ID", id);
			QuerySetCell(qTimers, "Method", arguments.label);
			QuerySetCell(qTimers, "Time", arguments.tickcount);
			QuerySetCell(qTimers, "Timestamp", now());
			QuerySetCell(qTimers, "RC", '');
		</cfscript>
	</cffunction>


</cfcomponent>