<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/28/2007
Description :
	This object models an event pool
----------------------------------------------------------------------->
<cfcomponent hint="This object models an event pool that fires by convetion on its configured name." output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" hint="constructor" returntype="EventPool">
	    <cfargument name="state" type="string" required="true" hint="The event pool state name to model">
	    <cfscript>
			var LinkedHashMap = CreateObject("java","java.util.LinkedHashMap").init(3);
			var Collections   = createObject("java", "java.util.Collections");

			instance = structnew();

			// Create the event pool, start with 3 instead of 16 to save space
			setPool( Collections.synchronizedMap(LinkedHashMap) );
			setState( arguments.state );

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Register a new object with this event pool --->
	<cffunction name="register" access="public" returntype="void" hint="Register an object class with this event pool" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="key" 		required="true" type="string" 	hint="The key of the object">
		<cfargument name="target" 	required="true" type="any" 		hint="The target object to register.">
		<!--- ************************************************************* --->
		<cfset getPool().put(lcase(arguments.key), arguments.target)>
	</cffunction>

	<!--- Remove a target object from the pool state --->
	<cffunction name="unregister" access="public" returntype="boolean" hint="Unregister an object from this event pool" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="key" 	required="true" type="string" 	hint="The key of the object">
		<!--- ************************************************************* --->
		<cfscript>
			if( exists(arguments.key) ){
				getPool().remove(lcase(arguments.key));
				return true;
			}
			return false;
		</cfscript>
	</cffunction>

	<!--- exists --->
	<cffunction name="exists" output="false" access="public" returntype="boolean" hint="Checks if the passed key is registered with this event pool">
		<!--- ************************************************************* --->
		<cfargument name="key" 	required="true" type="string" 	hint="The key of the object">
		<!--- ************************************************************* --->
		<cfreturn structKeyExists(getPool(), lcase(arguments.key))>
	</cffunction>

	<!--- Get Object --->
	<cffunction name="getObject" access="public" returntype="any" hint="Get an object from this event pool. Else return a blank structure if not found" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="key" 	required="true" type="string" 	hint="The key of the object">
		<!--- ************************************************************* --->
		<cfscript>
			var pool = getPool();

			if( exists(arguments.key) ){
				return pool[ lcase(arguments.key) ];
			}

			return structnew();
		</cfscript>
	</cffunction>

	<!--- Process the Pool --->
	<cffunction name="process" access="public" returntype="void" hint="Process this event pool according to it's name." output="false" >
		<!--- ************************************************************* --->
		<cfargument name="interceptData" required="true" 	type="struct" hint="A data structure used to pass information.">
		<!--- ************************************************************* --->
		<cfscript>
		var key = "";
		var stopChain = "";
		var pool = getPool();

		// Loop and execute each target object as registered in order
		for( key in pool ){
			// Invoke the execution point
			stopChain = invoker( pool[key], arguments.interceptData );

			// Check for results
			if( stopChain ){ break; }
		}
		</cfscript>
	</cffunction>

	<!--- getter setter state --->
	<cffunction name="getState" access="public" output="false" returntype="any" hint="Get the event pool's state name">
		<cfreturn instance.state/>
	</cffunction>
	<cffunction name="setState" access="public" output="false" returntype="void" hint="Set the event pool's state name">
		<!--- ************************************************************* --->
		<cfargument name="state" type="any" required="true"/>
		<!--- ************************************************************* --->
		<cfset instance.state = arguments.state/>
	</cffunction>

	<!--- getter setter Pool --->
	<cffunction name="getPool" access="public" output="false" returntype="any" hint="Get the Pool linked hash map">
		<cfreturn instance.pool/>
	</cffunction>


<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- setPool --->
	<cffunction name="setPool" access="private" output="false" returntype="void" hint="Set the Pool linked hash map">
		<!--- ************************************************************* --->
		<cfargument name="Pool" type="any" required="true"/>
		<!--- ************************************************************* --->
		<cfset instance.pool = arguments.Pool/>
	</cffunction>

	<!--- Invoker --->
	<cffunction name="invoker" access="private" returntype="any" hint="Execute an event interception point" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 		  required="true" type="any" 		hint="The target object">
		<cfargument name="interceptData"  required="true" type="any" 		hint="A metadata structure used to pass intercepted information.">
		<!--- ************************************************************* --->
		<cfset var refLocal = structnew()>

		<!--- Invoke the target --->
		<cfinvoke component="#arguments.target#" method="#getState()#" returnvariable="refLocal.results">
			<cfinvokeargument name="interceptData" 	value="#arguments.interceptData#">
		</cfinvoke>

		<!--- Check if we have results --->
		<cfif structKeyExists(refLocal,"results") and isBoolean(refLocal.results)>
			<cfreturn refLocal.results>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

</cfcomponent>
