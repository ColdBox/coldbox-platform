<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Luis Majano
Date     :	June 30, 2006
Description :
	I model a coldbox request. I hold the request's variables and more.

Modification History:

----------------------------------------------------------------------->
<cfcomponent name="requestContext"
			 hint="I am a coldbox request"
			 output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		variables.instance = structnew();
		instance.context = structnew();
		instance.defaultLayout = "";
		instance.defaultView = "";
		instance.ViewLayouts = "";
		instance.eventName = "";
	</cfscript>

	<cffunction name="init" access="public" output="false" hint="constructor" returntype="any">
		<!--- ************************************************************* --->
		<cfargument name="struct1" 		 	type="any" 		required="true" hint="Usually the FORM scope">
		<cfargument name="struct2" 		 	type="any" 		required="true" hint="Usually the URL scope">
		<cfargument name="DefaultLayout" 	type="string" 	required="true">
		<cfargument name="DefaultView" 	 	type="string" 	required="true">
		<cfargument name="EventName" 	 	type="string" 	required="true"/>
		<cfargument name="ViewLayouts"   	type="struct"   required="true">
		<cfargument name="FolderLayouts"   	type="struct"   required="true">		
		<!--- ************************************************************* --->
		<cfscript>
			collectionAppend(arguments.struct1);
			collectionAppend(arguments.struct2);
			setDefaultLayout(arguments.DefaultLayout);
			setDefaultView(arguments.DefaultView);
			setViewLayouts(arguments.ViewLayouts);
			setFolderLayouts(arguments.FolderLayouts);
			setEventName(arguments.EventName);
			return this;
		</cfscript>		
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="getCollection" returntype="struct" access="Public" hint="I Get a reference or deep copy of the request Collection" output="false">
		<cfargument name="DeepCopyFlag" hint="Default is false, gives a reference to the collection. True, creates a deep copy of the collection." type="boolean" required="no" default="false">
		<cfscript>
			if ( arguments.DeepCopyFlag )
				return duplicate(instance.context);
			else
				return instance.context;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setCollection" access="public" returntype="void" output="false" hint="Overwrite the collection with another collection">
		<cfargument name="collection" type="struct" required="true">
		<cfset instance.context = arguments.collection>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="clearCollection" access="public" returntype="void" output="false" hint="Clear the entire collection">
		<cfset structClear(instance.context)>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="collectionAppend" access="public" returntype="void" output="false" hint="Append a structure to the collection, with overwrite or not. Overwrite = false by default">
		<cfargument name="collection" type="struct"  required="true">
		<cfargument name="overwrite"  type="boolean" required="false" default="false" hint="If you need to override data in the collection, set this to true.">
		<cfset structAppend(instance.context,arguments.collection, arguments.overwrite)>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getSize" access="public" returntype="numeric" output="false" hint="The number of elements in the collection">
		<cfreturn structCount(instance.context)>
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
			if ( isDefined("instance.context.#arguments.name#") ){
				return Evaluate("instance.context.#arguments.name#");
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
			"instance.context.#arguments.name#" = arguments.value;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="removeValue" access="Public" hint="I remove a value in the request collection" output="false" returntype="void">
		<cfargument name="name"  hint="The name of the variable to remove." type="string" >
		<!--- ************************************************************* --->
		<cfscript>
			if( valueExists(arguments.name) )
				structDelete(instance.context,"#arguments.name#");
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="valueExists" returntype="boolean" access="Public"	hint="I Check if a value exists in the request collection." output="false">
		<cfargument name="name" hint="Name of the variable to find in the request collection" type="string">
		<!--- ************************************************************* --->
		<cfscript>
			return isDefined("instance.context.#arguments.name#");
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
	
	<!--- ************************************************************* --->
	
	<cffunction name="setView" access="public" returntype="void" hint="I Set the view to render in this request.I am called from event handlers. Request Collection Name: currentView, currentLayout"  output="false">
		<cfargument name="name"     hint="The name of the view to set. If a layout has been defined it will assign it, else if will assign the default layout." type="string">
		<cfargument name="nolayout" type="boolean" required="false" default="false" hint="Boolean flag, wether the view sent in will be using a layout or not. Default is false. Uses a pre set layout or the default layout.">
		<!--- ************************************************************* --->
	    <cfscript>
		    var key = "";
		    
			//If we need a layout or we haven't overriden the current layout enter if...
		    if ( arguments.nolayout eq false and getValue("layoutoverride",false) eq false ){
		    		
			    	//Verify that the view has a layout in the viewLayouts structure, else do the default Layout.
				    if ( StructKeyExists(instance.ViewLayouts, arguments.name) )
						setValue("currentLayout",instance.ViewLayouts[arguments.name]);
					else{
						//Check the folders
						for( key in instance.FolderLayouts ){
							if ( findnocase(key, arguments.name) ){
								setValue("currentLayout",instance.FolderLayouts[key]);
								break;
							}
						}
					}
					
					//If not layout, then set default
					if( not valueExists("currentLayout") ){
						setValue("currentLayout", instance.defaultLayout);
					}
					
			}
			
			//Set the current view to render.
			setValue("currentView",arguments.name);
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getCurrentLayout" access="public" hint="Gets the current set layout" returntype="string" output="false">
		<cfreturn getValue("currentLayout","")>
	</cffunction>

	<cffunction name="setLayout" access="public" returntype="void" hint="I Set the layout to override and render. Layouts are pre-defined in the config file. However I can override these settings if needed. Do not append a the cfm extension. Request Collection name: currentLayout"  output="false">
		<cfargument name="name"  hint="The name of the layout file to set." type="string" >
		<!--- ************************************************************* --->
	  	<cfscript>
			setValue("currentLayout",trim(arguments.name) & ".cfm" );
	  		setValue("layoutoverride",true);
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getCurrentEvent" access="public" hint="Gets the current set event" returntype="string" output="false">
		<cfreturn getValue(getEventName(),"")>
	</cffunction>
	
	<cffunction name="getCurrentHandler" access="public" hint="Gets the current handler requested in the current event." returntype="string" output="false">
		<cfscript>
			var testHandler = reReplace(getCurrentEvent(),"\.[^.]*$","");
			if( listLen(testHandler,".") eq 1){
				return testHandler;
			}
			else{
				return listLast(testHandler,".");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="getCurrentAction" access="public" hint="Gets the current action requested in the current event." returntype="string" output="false">
		<cfreturn listLast(getCurrentEvent(),".")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="overrideEvent" access="Public" hint="I Override the current event in the request collection. This method does not execute the event, it just replaces the event to be executed by the framework's RunEvent() method. This method is usually called from an onRequestStart or onApplicationStart method."  output="false" returntype="void">
		<cfargument name="event" hint="The name of the event to override." type="string">
		<!--- ************************************************************* --->
	    <cfscript>
	    setValue(getEventName(),arguments.event);
	    </cfscript>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="showdebugpanel" access="public" returntype="void" hint="I can override to show or not the debug panel. Very useful in AJAX debugging">
		<cfargument name="show" type="boolean" required="true">
		<cfset setValue("coldbox_debugpanel",arguments.show)>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="getdebugpanelFlag" access="public" returntype="boolean" hint="I return the debugpanel flag for this request.">
		<cfreturn getValue("coldbox_debugpanel",true)>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="isProxyRequest" access="public" returntype="boolean" hint="Is this a coldbox proxy request">
		<cfreturn getValue("coldbox_proxyrequest",false)>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setProxyRequest" access="public" returntype="void" hint="Set that this is a proxy request">
		<cfset setValue("coldbox_proxyrequest",true)>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="NoRender" access="public" returntype="void" hint="Set the flag that tells the framework not to render, just execute">
		<cfargument name="remove" required="false" type="boolean" default="false" hint="If true, it removes the flag, else its set.">
		<cfscript>
			if (arguments.remove)
				setValue("coldbox_norender",true);
			else
				removeValue("coldbox_norender");
		</cfscript>		
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="isNoRender" access="public" returntype="boolean" hint="Is this a no render request">
		<cfreturn getValue("coldbox_norender",false)>
	</cffunction>
	
	
<!------------------------------------------- ACCESSORS/MUTATORS ------------------------------------------->

	<!--- ************************************************************* --->
	
	<cffunction name="getDefaultLayout" access="public" returntype="string" output="false">
		<cfreturn instance.defaultLayout>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setDefaultLayout" access="public" returntype="void" output="false">
		<cfargument name="DefaultLayout" type="string" required="true">
		<cfset instance.defaultLayout = arguments.DefaultLayout>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getDefaultView" access="public" returntype="string" output="false">
		<cfreturn instance.defaultView>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setDefaultView" access="public" returntype="void" output="false">
		<cfargument name="DefaultView" type="string" required="true">
		<cfset instance.defaultView = arguments.DefaultView>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getViewLayouts" access="public" returntype="struct" output="false">
		<cfreturn instance.ViewLayouts>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setViewLayouts" access="public" returntype="void" output="false">
		<cfargument name="ViewLayouts" type="struct" required="true">
		<cfset instance.ViewLayouts = arguments.ViewLayouts>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getFolderLayouts" access="public" returntype="struct" output="false">
		<cfreturn instance.FolderLayouts>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setFolderLayouts" access="public" returntype="void" output="false">
		<cfargument name="FolderLayouts" type="struct" required="true">
		<cfset instance.FolderLayouts = arguments.FolderLayouts>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getEventName" access="public" returntype="string" output="false">
		<cfreturn instance.eventName>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getSelf" access="public" output="false" returntype="string">
	   <cfreturn "index.cfm?" & getEventName() & "=">
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setEventName" access="public" returntype="void" output="false">
		<cfargument name="EventName" type="string" required="true">
		<cfset instance.eventName = arguments.EventName>
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