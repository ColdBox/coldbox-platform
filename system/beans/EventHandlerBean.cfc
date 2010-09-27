<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model a ColdBox Event Handler

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="EventHandlerBean"
			 hint="I model a ColdBox event handler"
			 output="false">

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

	<cffunction name="init" access="public" returntype="EventHandlerBean" output="false">
		<cfargument name="invocationPath" type="string" required="false" default="" hint="The default invocation path" />
		<cfset setInvocationPath(arguments.invocationPath)>
		<cfreturn this >
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Get/Set View Dispatch --->
	<cffunction name="getViewDispatch" access="public" returntype="boolean" output="false" hint="Get the view dispatch flag">
    	<cfreturn instance.viewDispatch>
    </cffunction>
    <cffunction name="setViewDispatch" access="public" returntype="void" output="false" hint="Setup a view dispatch or not">
    	<cfargument name="viewDispatch" type="boolean" required="true">
    	<cfset instance.viewDispatch = arguments.viewDispatch>
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
	<cffunction name="getFullEvent" access="public" returntype="any" output="false">
		<cfscript>
			var event = getHandler() & "." & getMethod();
			if( isModule() ){
				return getModule()  & ":" & event;
			}
			return event;
		</cfscript>
	</cffunction>

	<!--- Getr Runnable object --->
	<cffunction name="getRunnable" access="public" returntype="any" output="false">
		<cfreturn getInvocationPath() & "." & getHandler()>
	</cffunction>
	
	<!--- Get/Set Method --->
	<cffunction name="setMethod" access="public" returntype="void" output="false">
		<cfargument name="method" type="string" required="true" />
		<cfset instance.method = arguments.method>
	</cffunction>
	<cffunction name="getMethod" access="public" returntype="any" output="false">
		<cfreturn instance.method >
	</cffunction>
	
	<!--- Get/Set Private --->
	<cffunction name="getIsPrivate" access="public" returntype="boolean" output="false">
		<cfreturn instance.isPrivate>
	</cffunction>
	<cffunction name="setIsPrivate" access="public" returntype="void" output="false">
		<cfargument name="isPrivate" type="boolean" required="true">
		<cfset instance.isPrivate = arguments.isPrivate>
	</cffunction>
	
	<!--- isModule --->
	<cffunction name="isModule" access="public" returntype="boolean" output="false" hint="Checks if we are using a module or not">
		<cfreturn (len(getModule()) GT 0)>
	</cffunction>

	<!--- get/set module --->
	<cffunction name="getmodule" access="public" returntype="any" output="false">
		<cfreturn instance.module>
	</cffunction>
	<cffunction name="setmodule" access="public" returntype="void" output="false">
		<cfargument name="module" type="any" required="true">
		<cfset instance.module = arguments.module>
	</cffunction>

	<!--- Get/Set Handler name --->
	<cffunction name="setHandler" access="public" returntype="void" output="false">
		<cfargument name="handler" type="any" required="true" />
		<cfset instance.handler = arguments.handler >
	</cffunction>
	<cffunction name="getHandler" access="public" returntype="any" output="false">
		<cfreturn instance.handler >
	</cffunction>

	<!--- Get Set Invocation Path --->
	<cffunction name="setInvocationPath" access="public" returntype="void" output="false">
		<cfargument name="InvocationPath" type="any" required="true" />
		<cfset instance.InvocationPath = arguments.InvocationPath >
	</cffunction>
	<cffunction name="getInvocationPath" access="public" returntype="any" output="false">
		<cfreturn instance.InvocationPath >
	</cffunction>
	
	<!--- Is missing Action --->
	<cffunction name="isMissingAction" access="public" returntype="boolean" output="false">
		<cfreturn (len(getMissingAction()) GT 0)>
	</cffunction>
	
	<!--- Missing Action item. --->
	<cffunction name="getMissingAction" access="public" returntype="string" output="false">
		<cfreturn instance.missingAction>
	</cffunction>
	<cffunction name="setMissingAction" access="public" returntype="void" output="false">
		<cfargument name="missingAction" type="string" required="true">
		<cfset instance.missingAction = arguments.missingAction>
	</cffunction>

</cfcomponent>