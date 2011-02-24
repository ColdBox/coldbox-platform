<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Description :
	I model a ColdBox Event Handler
----------------------------------------------------------------------->
<cfcomponent hint="I model a ColdBox event execution" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		variables.instance 			= structnew();
		instance.invocationPath 	= "";
		instance.handler 			= "";
		instance.method 			= "";
		instance.isPrivate 			= false;
		instance.missingAction 		= "";
		instance.module				= "";
		instance.viewDispatch		= false;
	</cfscript>

	<cffunction name="init" access="public" returntype="EventHandlerBean" output="false" hint="Constructor">
		<cfargument name="invocationPath" type="string" required="false" default="" hint="The default invocation path" />
		<cfset setInvocationPath(arguments.invocationPath)>
		<cfreturn this >
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get/Set View Dispatch --->
	<cffunction name="getViewDispatch" access="public" returntype="any" output="false" hint="Get the view dispatch flag: Boolean">
    	<cfreturn instance.viewDispatch>
    </cffunction>
    <cffunction name="setViewDispatch" access="public" returntype="any" output="false" hint="Setup a view dispatch or not">
    	<cfargument name="viewDispatch" type="any" required="true" hint="boolean" colddoc:generic="boolean">
    	<cfset instance.viewDispatch = arguments.viewDispatch>
    	<cfreturn this>
    </cffunction>    
	
	<!--- Get Set Memento --->
	<cffunction name="getMemento" access="public" returntype="struct" output="false" hint="Get the memento">
		<cfreturn variables.instance >
	</cffunction>
	<cffunction name="setMemento" access="public" returntype="void" output="false" hint="Set the memento">
		<cfargument name="memento" type="struct" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>
		
	<!--- Get Full Event Syntax --->
	<cffunction name="getFullEvent" access="public" returntype="any" output="false" hint="Get the full event string">
		<cfscript>
			var event = getHandler() & "." & getMethod();
			if( isModule() ){
				return getModule()  & ":" & event;
			}
			return event;
		</cfscript>
	</cffunction>

	<!--- Getr Runnable object --->
	<cffunction name="getRunnable" access="public" returntype="any" output="false" hint="Get the runnable execution string">
		<cfreturn getInvocationPath() & "." & getHandler()>
	</cffunction>
	
	<!--- Get/Set Method --->
	<cffunction name="setMethod" access="public" returntype="any" output="false" hint="Set the method to execute">
		<cfargument name="method" type="any" required="true" />
		<cfset instance.method = arguments.method>
		<cfreturn this>
	</cffunction>
	<cffunction name="getMethod" access="public" returntype="any" output="false" hint="Get the method to execute">
		<cfreturn instance.method >
	</cffunction>
	
	<!--- Get/Set Private --->
	<cffunction name="getIsPrivate" access="public" returntype="boolean" output="false" hint="Get the private execution flag">
		<cfreturn instance.isPrivate>
	</cffunction>
	<cffunction name="setIsPrivate" access="public" returntype="any" output="false" hint="Set the private execution flag">
		<cfargument name="isPrivate" type="any" required="true" hint="Boolean" colddoc:generic="Boolean">
		<cfset instance.isPrivate = arguments.isPrivate>
		<cfreturn this>
	</cffunction>
	
	<!--- isModule --->
	<cffunction name="isModule" access="public" returntype="boolean" output="false" hint="Checks if we are using a module or not">
		<cfreturn (len(getModule()) GT 0)>
	</cffunction>

	<!--- get/set module --->
	<cffunction name="getModule" access="public" returntype="any" output="false" hint="Get the module to execute">
		<cfreturn instance.module>
	</cffunction>
	<cffunction name="setModule" access="public" returntype="any" output="false" hint="Set the module to execute">
		<cfargument name="module" type="any" required="true">
		<cfset instance.module = arguments.module>
		<cfreturn this>
	</cffunction>

	<!--- Get/Set Handler name --->
	<cffunction name="setHandler" access="public" returntype="any" output="false" hint="Set the handler to execute">
		<cfargument name="handler" type="any" required="true" />
		<cfset instance.handler = arguments.handler >
		<cfreturn this>
	</cffunction>
	<cffunction name="getHandler" access="public" returntype="any" output="false" hint="Get the handler to execute">
		<cfreturn instance.handler >
	</cffunction>

	<!--- Get Set Invocation Path --->
	<cffunction name="setInvocationPath" access="public" returntype="any" output="false" hint="Set the full invocation path">
		<cfargument name="InvocationPath" type="any" required="true" />
		<cfset instance.InvocationPath = arguments.InvocationPath >
		<cfreturn this>
	</cffunction>
	<cffunction name="getInvocationPath" access="public" returntype="any" output="false" hint="Get the full invocation path">
		<cfreturn instance.InvocationPath >
	</cffunction>
	
	<!--- Is missing Action --->
	<cffunction name="isMissingAction" access="public" returntype="boolean" output="false" hint="Verify if in missing action">
		<cfreturn (len(getMissingAction()) GT 0)>
	</cffunction>
	
	<!--- Missing Action item. --->
	<cffunction name="getMissingAction" access="public" returntype="any" output="false" hint="Get the missing action flag">
		<cfreturn instance.missingAction>
	</cffunction>
	<cffunction name="setMissingAction" access="public" returntype="any" output="false" hint="Set the missing action flag">
		<cfargument name="missingAction" type="any" required="true">
		<cfset instance.missingAction = arguments.missingAction>
		<cfreturn this>
	</cffunction>

</cfcomponent>