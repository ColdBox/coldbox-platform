<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model a coldbox request. I hold the request's variables

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="requestContext"
			 hint="I am a coldbox request"
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<cfscript>
		variables.context = structnew();
		variables.defaultLayout = "";
		variables.ViewLayouts = "";
	</cfscript>

	<cffunction name="init" access="public" output="false" hint="constructor" returntype="coldbox.system.beans.requestContext">
		<!--- ************************************************************* --->
		<cfargument name="struct1" 		 type="any" 	required="true">
		<cfargument name="struct2" 		 type="any" 	required="true">
		<cfargument name="DefaultLayout" type="string" 	required="true">
		<cfargument name="ViewLayouts"   type="struct"  required="true">
		<!--- ************************************************************* --->
		<cfset collectionAppend(arguments.struct1)>
		<cfset collectionAppend(arguments.struct2)>
		<cfset variables.defaultLayout = arguments.DefaultLayout>
		<cfset variables.ViewLayouts = arguments.ViewLayouts>
		<cfreturn this >
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="getCollection" returntype="struct" access="Public" hint="I Get a reference or deep copy of the request Collection" output="false">
		<cfargument name="DeepCopyFlag" hint="Default is false, gives a reference to the collection. True, creates a deep copy of the collection." type="boolean" required="no" default="false">
		<cfscript>
			if ( arguments.DeepCopyFlag )
				return duplicate(variables.context);
			else
				return variables.context;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setCollection" access="public" returntype="void" output="false" hint="Overwrite the collection with another collection">
		<cfargument name="collection" type="struct" required="true">
		<cfset variables.context = arguments.collection>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="clearCollection" access="public" returntype="void" output="false" hint="Clear the entire collection">
		<cfset structClear(variables.context)>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="collectionAppend" access="public" returntype="void" output="false" hint="Append a structure to the collection, with overwrite or not. Overwrite = false by default">
		<cfargument name="collection" type="struct"  required="true">
		<cfargument name="overwrite"  type="boolean" required="false" default="false" hint="If you need to override data in the collection, set this to true.">
		<cfset structAppend(variables.context,arguments.collection, arguments.overwrite)>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getSize" access="public" returntype="numeric" output="false" hint="The number of elements in the collection">
		<cfreturn structCount(variables.context)>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getValue" returntype="Any" access="Public" hint="I Get a value from the request collection." output="false">
		<cfargument name="name" hint="Name of the variable to get from the request collection" type="string">
		<cfargument name="defaultValue"
					hint="Default value to return if not found.There are no default values for complex structures. You can send [array][struct][query] and the
						  method will return the empty complex variable.Please remember to include the brackets, syntax sensitive.You can also send complex variables
						  as the defaultValue argument."
					type="any" required="No" default="NONE">
		<!--- ************************************************************* --->
		<cfscript>
			if ( isDefined("variables.context.#arguments.name#") ){
				return Evaluate("variables.context.#arguments.name#");
			}
			else if ( isSimpleValue(arguments.defaultValue) and arguments.defaultValue eq "NONE" )
				throw("The variable: #arguments.name# is undefined in the request collection.","","Framework.ValueNotInRequestCollectionException");
			else if ( isSimpleValue(arguments.defaultValue) ){
				if ( refind("\[[A-Za-z]*\]", arguments.defaultValue) ){
					if ( findnocase("array", arguments.defaultvalue) )
						return ArrayNew(1);
					else if ( findnocase("struct", arguments.defaultvalue) )
						return StructNew();
					else if ( findnocase("query", arguments.defaultvalue) )
						return QueryNew("");
				}
				else
					return arguments.defaultValue;
			}
			else
				return arguments.defaultValue;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setValue" access="Public" hint="I Set a value in the request collection" output="false" returntype="void">
		<cfargument name="name"  hint="The name of the variable to set." type="string" >
		<cfargument name="value" hint="The value of the variable to set" type="Any" >
		<!--- ************************************************************* --->
		<cfscript>
			"variables.context.#arguments.name#" = arguments.value;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="removeValue" access="Public" hint="I remove a value in the request collection" output="false" returntype="void">
		<cfargument name="name"  hint="The name of the variable to remove." type="string" >
		<!--- ************************************************************* --->
		<cfscript>
			structDelete(variables.context,"#arguments.name#");
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="valueExists" returntype="boolean" access="Public"	hint="I Check if a value exists in the request collection." output="false">
		<cfargument name="name" hint="Name of the variable to find in the request collection" type="string">
		<!--- ************************************************************* --->
		<cfscript>
			return isDefined("variables.context.#arguments.name#");
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="paramValue" returntype="void" access="Public"	hint="Just like cfparam, but for the request collection" output="false">
		<cfargument name="name" 	hint="Name of the variable to param in the request collection" 	type="string">
		<cfargument name="value" 	hint="The value of the variable to set if not found." 			type="Any" >
		<!--- ************************************************************* --->
		<cfscript>
			if ( not valueExists(arguments.name) )
				setValue(arguments.name, arguments.value);
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

<!------------------------------------------- GET/SET CURRENT REQUEST VARIABLES ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="getCurrentView" access="public" hint="Gets the current set view" returntype="string" output="false">
		<cfreturn getValue("currentView","")>
	</cffunction>

	<cffunction name="setView" access="public" returntype="void" hint="I Set the view to render in this request.I am called from event handlers. Request Collection Name: currentView, currentLayout"  output="false">
		<cfargument name="name"     hint="The name of the view to set. If a layout has been defined it will assign it, else if will assign the default layout." type="string">
		<cfargument name="nolayout" type="boolean" required="false" default="false" hint="Boolean flag, wether the view sent in will be using a layout or not. Default is false. Uses a pre set layout or the default layout.">
		<!--- ************************************************************* --->
	    <cfscript>
	    if ( not arguments.nolayout ){
		    if ( not getValue("layoutoverride",false) ){
			    if ( StructKeyExists(variables.ViewLayouts, arguments.name) )
					setValue("currentLayout",variables.ViewLayouts[arguments.name]);
				else
					setValue("currentLayout", variables.DefaultLayout);
			}
		}
		setValue("currentView",arguments.name);
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getCurrentLayout" access="public" hint="Gets the current set layout" returntype="string" output="false">
		<cfreturn getValue("currentLayout","")>
	</cffunction>

	<cffunction name="setLayout" access="public" returntype="void" hint="I Set the layout to override and render. Layouts are pre-defined in the config.xml file. However I can override these settings if needed. Do not append a the cfm extension. Request Collection name: currentLayout"  output="false">
		<cfargument name="name"  hint="The name of the layout file to set." type="string" >
		<!--- ************************************************************* --->
	  	<cfscript>
			setValue("currentLayout",trim(arguments.name) & ".cfm" );
	  		setValue("layoutoverride",true);
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getCurrentEvent" access="public" hint="Gets the current set event" returntype="string" output="false">
		<cfreturn getValue("event","")>
	</cffunction>

	<cffunction name="overrideEvent" access="Public" hint="I Override the current event in the request collection. This method does not execute the event, it just replaces the event to be executed by the framework's RunEvent() method. This method is usually called from an onRequestStart or onApplicationStart method."  output="false" returntype="void">
		<cfargument name="event" hint="The name of the event to override." type="string">
		<!--- ************************************************************* --->
	    <cfscript>
	    setValue("event",arguments.event);
	    </cfscript>
	</cffunction>

	<cffunction name="showdebugpanel" access="public" returntype="void" hint="I can override to show or not the debug panel. Very useful in AJAX debugging">
		<cfargument name="show" type="boolean" required="true">
		<cfset setValue("coldbox.debugpanel",arguments.show)>
	</cffunction>
<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="throw" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>


</cfcomponent>