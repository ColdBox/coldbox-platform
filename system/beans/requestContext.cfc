<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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
		instance.isSES = false;
		instance.sesBaseURL = "";
		instance.routedStruct = structnew();
	</cfscript>

	<cffunction name="init" access="public" output="false" hint="constructor" returntype="coldbox.system.beans.requestContext">
		<!--- ************************************************************* --->
		<cfargument name="struct1" 		 	type="any"	required="true" hint="Usually the FORM scope">
		<cfargument name="struct2" 		 	type="any"	required="true" hint="Usually the URL scope">
		<cfargument name="properties" 		type="any" 	required="true" hint="The context properties struct">
		<!--- ************************************************************* --->
		<cfscript>
			/* Append Collections */
			collectionAppend(arguments.struct1);
			collectionAppend(arguments.struct2);
			
			/* Setup context properties as they got sent in */
			setDefaultLayout(arguments.properties.DefaultLayout);
			setDefaultView(arguments.properties.DefaultView);
			setViewLayouts(arguments.properties.ViewLayouts);
			setFolderLayouts(arguments.properties.FolderLayouts);
			setEventName(arguments.properties.EventName);
			setisSES(arguments.properties.isSES);
			setsesBaseURL(arguments.properties.sesBaseURL);
			
			/* Return Context */
			return this;
		</cfscript>		
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="getCollection" returntype="any" access="Public" hint="I Get a reference or deep copy of the request Collection: Returns a structure" output="false">
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
		<cfargument name="collection" type="any"  required="true" hint="A collection to append">
		<cfargument name="overwrite"  type="boolean" required="false" default="false" hint="If you need to override data in the collection, set this to true.">
		<cfset structAppend(instance.context,arguments.collection, arguments.overwrite)>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getSize" access="public" returntype="numeric" output="false" hint="The number of elements in the collection">
		<cfreturn structCount(instance.context)>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="getValue" returntype="Any" access="Public" hint="I Get a value from the request collection." output="false">
		<cfargument name="name" hint="Name of the variable to get from the request collection: String" type="any">
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
				throwit("The variable: #arguments.name# is undefined in the request collection.","","Framework.ValueNotInRequestCollectionException");
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
	
	<cffunction name="getTrimValue" returntype="Any" access="Public" hint="I Get a value from the request collection and if simple value, I will trim it." output="false">
		<cfargument name="name" hint="Name of the variable to get from the request collection: String" type="any">
		<cfargument name="defaultValue"
					hint="Default value to return if not found.There are no default values for complex structures. You can send [array][struct][query] and the
						  method will return the empty complex variable.Please remember to include the brackets, syntax sensitive.You can also send complex variables
						  as the defaultValue argument."
					type="any" required="No" default="NONE">
		<!--- ************************************************************* --->
		<cfscript>
			var value = getValue(argumentCollection=arguments);
			/* Verify if Simple */
			if( isSimpleValue(value) ){ value = trim(value); }
			return value;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="setValue" access="Public" hint="I Set a value in the request collection" output="false" returntype="void">
		<cfargument name="name"  hint="The name of the variable to set. String" type="any" >
		<cfargument name="value" hint="The value of the variable to set" type="Any" >
		<!--- ************************************************************* --->
		<cfset "instance.context.#arguments.name#" = arguments.value>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="removeValue" access="Public" hint="I remove a value in the request collection" output="false" returntype="void">
		<cfargument name="name"  hint="The name of the variable to remove." type="string" >
		<!--- ************************************************************* --->
		<cfscript>
			if( valueExists(arguments.name) ){
				structDelete(instance.context,"#arguments.name#");
			}
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="valueExists" returntype="boolean" access="Public"	hint="I Check if a value exists in the request collection." output="false">
		<cfargument name="name" hint="Name of the variable to find in the request collection: String" type="any">
		<!--- ************************************************************* --->
		<cfreturn isDefined("instance.context.#arguments.name#")>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="paramValue" returntype="void" access="Public"	hint="Just like cfparam, but for the request collection" output="false">
		<cfargument name="name" 	hint="Name of the variable to param in the request collection: String" 	type="any">
		<cfargument name="value" 	hint="The value of the variable to set if not found." 			type="Any" >
		<!--- ************************************************************* --->
		<cfscript>
			if ( not valueExists(arguments.name) ){
				setValue(arguments.name, arguments.value);
			}
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
		<!--- ************************************************************* --->
	    <cfargument name="name"     	type="string"  required="true"  hint="The name of the view to set. If a layout has been defined it will assign it, else if will assign the default layout. No extension please">
		<cfargument name="nolayout" 	type="boolean" required="false" default="false" hint="Boolean flag, wether the view sent in will be using a layout or not. Default is false. Uses a pre set layout or the default layout.">
		<cfargument name="cache" 		required="false" type="boolean" default="false" hint="True if you want to cache the view.">
		<cfargument name="cacheTimeout" required="false" type="string" default=""	hint="The cache timeout">
		<cfargument name="cacheLastAccessTimeout" required="false" type="string" default="" hint="The last access timeout">
		<!--- ************************************************************* --->
	    <cfscript>
		    var key = "";
		    var cacheEntry = structnew();
		    
			//If we need a layout or we haven't overriden the current layout enter if...
		    if ( NOT arguments.nolayout AND NOT getValue("layoutoverride",false) ){
		    		
		    	//Verify that the view has a layout in the viewLayouts structure.
			    if ( StructKeyExists(instance.ViewLayouts, lcase(arguments.name)) ){
					setValue("currentLayout",instance.ViewLayouts[lcase(arguments.name)]);
			    }
				else{
					//Check the folders structure
					for( key in instance.FolderLayouts ){
						if ( reFindnocase('^#key#', lcase(arguments.name)) ){
							setValue("currentLayout",instance.FolderLayouts[key]);
							break;
						}
					}//end for loop
				}//end else
				
				//If not layout, then set default
				if( not valueExists("currentLayout") ){
					setValue("currentLayout", instance.defaultLayout);
				}					
			}//end if overridding layout
			
			/* Clean layout if true */
			if( arguments.nolayout ){
				removeValue('currentLayout');
			}
			
			//Do we need to cache the view
			if( arguments.cache ){
				//prepare the cache keys
				cacheEntry.view = arguments.name;
				
				//arg cleanup
				if ( not isNumeric(arguments.cacheTimeout) )
					cacheEntry.Timeout = "";
				else
					cacheEntry.Timeout = arguments.CacheTimeout;
				if ( not isNumeric(arguments.cacheLastAccessTimeout) )
					cacheEntry.LastAccessTimeout = "";
				else
					cacheEntry.LastAccessTimeout = arguments.cacheLastAccessTimeout;
					
				//Save the view cache entry
				setViewCacheableEntry(cacheEntry);
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

	<cffunction name="getCurrentEvent" access="public" hint="Gets the current set event: String" returntype="any" output="false">
		<cfreturn getValue(getEventName(),"")>
	</cffunction>
	
	<cffunction name="getCurrentHandler" access="public" hint="Gets the current handler requested in the current event: String" returntype="any" output="false">
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
	
	<cffunction name="getCurrentAction" access="public" hint="Gets the current action requested in the current event: String" returntype="any" output="false">
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
			if (arguments.remove eq false)
				setValue("coldbox_norender",true);
			else
				removeValue("coldbox_norender");
		</cfscript>		
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="isNoRender" access="public" returntype="boolean" hint="Is this a no render request">
		<cfreturn getValue("coldbox_norender",false)>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getEventName" access="public" returntype="any" output="false" hint="The event name used by the application: String">
		<cfreturn instance.eventName>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getSelf" access="public" output="false" returntype="any" hint="Returns index.cfm?{eventName}= : String">
	   <cfreturn "index.cfm?" & getEventName() & "=">
	</cffunction>
	
	<cffunction name="buildLink" access="public" output="false" returntype="any" hint="Builds a link to a passed event, either SES or normal link. If the ses interceptor is declared it will create routes.">
		<!--- ************************************************************* --->
		<cfargument name="linkto" 		required="true" 	type="string"  hint="The event or route you want to create the link to">
	    <cfargument name="translate"  	required="false" 	type="boolean" default="true" hint="Translate between . and / depending on the ses mode. So you can just use dot notation."/>
	    <cfargument name="ssl" 			required="false"    type="boolean" default="false" hint="If true, it will change http to https if found in the ses base url."/>
	    <cfargument name="baseURL" 		required="false" 	type="string"  default="" hint="If not using SES, you can use this argument to create your own base url apart from the default of index.cfm. Example: https://mysample.com/index.cfm"/>
	    <!--- ************************************************************* --->
		<cfscript>
		var sesBaseURL = getSESbaseURL();
		var frontController = "index.cfm";
		
		/* baseURL */
		if( len(trim(arguments.baseURL)) neq 0 ){
			frontController = arguments.baseURL;
		}
		
		if( isSES() ){
			/* SSL */
			if( arguments.ssl ){
				sesBaseURL = replacenocase(sesBaseURL,"http:","https:");
			}
			/* Translate link */
			if( arguments.translate ){
				arguments.linkto = replace(arguments.linkto,".","/","all");
			}
			/* Prepare link */
			if( right(sesBaseURL,1) eq  "/"){
				return sesBaseURL & arguments.linkto;
			}
			else{
				return sesBaseURL & "/" & arguments.linkto;
			}
		}
		else{
			return "#frontController#?#getEventName()#=#arguments.linkto#";
		}		
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="isEventCacheable" access="public" returntype="boolean" hint="Check wether the incoming event has been flagged for caching" output="false" >
		<cfscript>
			return valueExists("cbox_eventCacheableEntry");
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setEventCacheableEntry" access="public" returntype="void" hint="Set the event cacheable entry" output="false" >
		<cfargument name="mdCacheEntry" required="true" type="any" hint="The cache entry we need to get to cache">
		<cfset setValue("cbox_eventCacheableEntry",arguments.mdCacheEntry)>
	</cffunction>
	<cffunction name="getEventCacheableEntry" access="public" returntype="any" hint="Get the event cacheable entry" output="false" >
		<cfreturn getValue("cbox_eventCacheableEntry",structnew())>
	</cffunction>
	<cffunction name="removeEventCacheableEntry" access="public" returntype="void" hint="Remove the cacheable entry" output="false" >
		<cfset removeValue('cbox_eventCacheableEntry')>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="isViewCacheable" access="public" returntype="boolean" hint="Check wether the incoming view has been flagged for caching" output="false" >
		<cfscript>
			return valueExists("cbox_viewCacheableEntry");
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setViewCacheableEntry" access="public" returntype="void" hint="Set the view cacheable entry" output="false" >
		<cfargument name="mdCacheEntry" required="true" type="any" hint="The cache entry we need to get to cache">
		<cfscript>
			setValue("cbox_viewCacheableEntry",arguments.mdCacheEntry);
		</cfscript>
	</cffunction>
	<cffunction name="getViewCacheableEntry" access="public" returntype="any" hint="Get the event cacheable entry" output="false" >
		<cfreturn getValue("cbox_viewCacheableEntry",structnew())>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="isSES" access="public" output="false" returntype="boolean" hint="Determine if you are in SES mode.">
		<cfreturn instance.isSES/>
	</cffunction>
	<cffunction name="setisSES" access="public" output="false" returntype="void" hint="Set isSES flag">
		<cfargument name="isSES" type="boolean" required="true"/>
		<cfset instance.isSES = arguments.isSES/>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getsesBaseURL" access="public" output="false" returntype="string" hint="Get the sesBaseURL">
		<cfreturn instance.sesBaseURL/>
	</cffunction>
	<cffunction name="setsesBaseURL" access="public" output="false" returntype="void" hint="Set the sesBaseURL">
		<cfargument name="sesBaseURL" type="string" required="true"/>
		<cfset instance.sesBaseURL = arguments.sesBaseURL/>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getroutedStruct" access="public" output="false" returntype="struct" hint="Get the routed structure of key-value pairs. What the ses interceptor could match.">
		<cfreturn instance.routedStruct/>
	</cffunction>	
	<cffunction name="setroutedStruct" access="public" output="false" returntype="void" hint="Set routed struct of key-value pairs. This is used only by the SES interceptor. Not for public use.">
		<cfargument name="routedStruct" type="struct" required="true"/>
		<cfset instance.routedStruct = arguments.routedStruct/>
	</cffunction>
	
<!------------------------------------------- ACCESSORS/MUTATORS ------------------------------------------->

	<!--- ************************************************************* --->
	
	<cffunction name="getDefaultLayout" access="public" returntype="any" output="false" hint="Get's the default layout of the application: String">
		<cfreturn instance.defaultLayout>
	</cffunction>
	<cffunction name="setDefaultLayout" access="public" returntype="void" output="false">
		<cfargument name="DefaultLayout" type="string" required="true">
		<cfset instance.defaultLayout = arguments.DefaultLayout>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getDefaultView" access="public" returntype="any" output="false" hint="Get's the default view of the application: String">
		<cfreturn instance.defaultView>
	</cffunction>
	<cffunction name="setDefaultView" access="public" returntype="void" output="false">
		<cfargument name="DefaultView" type="string" required="true">
		<cfset instance.defaultView = arguments.DefaultView>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getViewLayouts" access="public" returntype="struct" output="false">
		<cfreturn instance.ViewLayouts>
	</cffunction>
	<cffunction name="setViewLayouts" access="public" returntype="void" output="false">
		<cfargument name="ViewLayouts" type="struct" required="true">
		<cfset instance.ViewLayouts = arguments.ViewLayouts>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getFolderLayouts" access="public" returntype="struct" output="false">
		<cfreturn instance.FolderLayouts>
	</cffunction>
	<cffunction name="setFolderLayouts" access="public" returntype="void" output="false">
		<cfargument name="FolderLayouts" type="struct" required="true">
		<cfset instance.FolderLayouts = arguments.FolderLayouts>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setEventName" access="public" returntype="void" output="false">
		<cfargument name="EventName" type="string" required="true">
		<cfset instance.eventName = arguments.EventName>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getmemento" access="public" returntype="any" output="false">
		<cfreturn variables.instance>
	</cffunction>
	<cffunction name="setmemento" access="public" returntype="void" output="false">
		<cfargument name="memento" type="any" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="renderData" access="public" returntype="void" hint="Use this method to tell the framework to render data for you. The framework will take care of marshalling the data for you" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="type" 		required="true" type="string" default="PLAIN" hint="The type of data to render. Valid types are JSON, WDDX, PLAIN. THe deafult is PLAIN. IF an invalid type is sent in, this method will throw an error">
		<cfargument name="data" 		required="true" type="any" 	 hint="The data you would like to marshall and return by the framework">
		<cfargument name="contenttype"  required="true" type="string" default="text/html" hint="The content type of the data. This will be used in the cfcontent tag: text/html, text/plain, text/xml, text/json, etc. The default value is text/html. However, if you choose JSON this method will choose text/plain, if you choose WDDX this method will choose text/xml for you. The default encoding is utf-8"/>
		<!--- ************************************************************* --->
		<cfscript>
			var rd = structnew();
			
			/* Validate */
			if( not reFindnocase("^(JSON|WDDX|PLAIN)$",arguments.type) ){
				throwit("Invalid type","The type you sent #arguments.type# is not a valid type. Valid types are JSON,WDDX and PLAIN","Framework.InvalidRenderTypeException");
			}
			/* Populate */
			rd.type = arguments.type;
			rd.data = arguments.data;
			
			/* Some smart selects */
			if( rd.type eq "JSON" ){
				rd.contenttype = 'text/plain';
			}
			else if( rd.type eq "WDDX" ){
				rd.contenttype = 'text/xml';
			}
			else{
				rd.contenttype = arguments.contenttype;
			}
			
			/* Save */
			setValue('cbox_renderdata',rd);			
		</cfscript>
	</cffunction>
	
	<cffunction name="getrenderData" access="public" output="false" returntype="struct" hint="Get the renderData structure.">
		<cfreturn getValue("cbox_renderdata", structnew() )/>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="throwit" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>

</cfcomponent>