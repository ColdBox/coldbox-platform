<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This cfc acts as an URL facade for event caching

Modification History:
01/18/2007 - Created

----------------------------------------------------------------------->
<cfcomponent name="eventURLFacade" hint="This object acas as an url facade for event caching" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		instance = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" returntype="eventURLFacade" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController( arguments.controller );
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- getUniqueHash --->
	<cffunction name="getUniqueHash" output="false" access="public" returntype="string" hint="Get's the unique incoming URL hash">
		<!--- **************************************************************************** --->
		<cfargument name="event" type="any" required="true" hint="The event request context to incorporate into the hash"/>
		<!--- **************************************************************************** --->
		<cfscript>
			var urlCopy = duplicate(URL);
			var eventName = getController().getSetting('eventName');
			var urlActionsList = "fwReinit,fwCache,debugMode,debugpass,dumpvar,debugpanel";
			var x = 1;
			var routedStruct = arguments.event.getRoutedStruct();
			
			/* Remove event if it exists */
			if( structKeyExists(urlCopy, eventName) ){
				structDelete(urlCopy,eventName);
			}
			
			/* Remove fw URL Actions */
			for(x=1; x lte listLen(urlActionsList); x=x+1){
				if( structKeyExists(urlCopy, listgetAt(urlActionsList,x)) ){
					structDelete(urlCopy,listgetAt(urlActionsList,x));
				}
			}
			
			/* Add incoming event to hash */
			urlCopy[eventName] = arguments.event.getCurrentEvent();
			
			/* Incorporate Routed Structs */
			for( key in routedStruct ){
				urlCopy[key] = routedStruct[key];
			}
			
			/* Get a unique key */
			return hash(urlCopy.toString());			
		</cfscript>
	</cffunction>
	
	<cffunction name="buildHash" output="false" access="public" returntype="string" hint="build a unique hash according to event and args">
		<!--- **************************************************************************** --->
		<cfargument name="event" type="string" required="true" hint="The event to incorporate into the hash"/>
		<cfargument name="args"  type="string" required="true" hint="The string of args to incorporate into the hash"/>
		<!--- **************************************************************************** --->
		<cfscript>
			var mySruct = structnew();
			var x =1;
			
			//add event to structure
			myStruct[getController().getSetting('eventName')] = arguments.event;
			
			//Build structure from arg list
			for(x=1;x lte listlen(arguments.args,"&"); x=x+1){
				myStruct[trim(listFirst(arguments.args,'='))] = urlDecode(trim(listLast(arguments.args,'=')));
			}
			
			//return hash
			return hash(myStruct.toString());
		</cfscript>
	</cffunction>
	


<!------------------------------------------- ACCESSOR MUTATORS ------------------------------------------->

	<cffunction name="getcontroller" access="public" returntype="any" output="false">
		<cfreturn instance.controller>
	</cffunction>
	<cffunction name="setcontroller" access="public" returntype="void" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset instance.controller = arguments.controller>
	</cffunction>

</cfcomponent>