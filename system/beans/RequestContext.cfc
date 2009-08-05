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
<cfcomponent hint="I am a coldbox request" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		variables.instance = structnew();
		
		// Create Properties
		instance.context = structnew();
		instance.privateContext = structnew();
		instance.defaultLayout = "";
		instance.defaultView = "";
		instance.ViewLayouts = "";
		instance.eventName = "";
		instance.isSES = false;
		instance.sesBaseURL = "";
		instance.routedStruct = structnew();
		instance.isViewDispatched = false;
	</cfscript>

	<cffunction name="init" access="public" output="false" hint="constructor" returntype="RequestContext">
		<!--- ************************************************************* --->
		<cfargument name="struct1" 		 	type="any"	required="true" hint="Usually the FORM scope">
		<cfargument name="struct2" 		 	type="any"	required="true" hint="Usually the URL scope">
		<cfargument name="properties" 		type="any" 	required="true" hint="The context properties struct">
		<!--- ************************************************************* --->
		<cfscript>
			// Append incoming Collections
			collectionAppend(arguments.struct1);
			collectionAppend(arguments.struct2);
			
			// Setup context properties as they got sent in
			setDefaultLayout(arguments.properties.DefaultLayout);
			setDefaultView(arguments.properties.DefaultView);
			setViewLayouts(arguments.properties.ViewLayouts);
			setFolderLayouts(arguments.properties.FolderLayouts);
			setEventName(arguments.properties.EventName);
			setisSES(arguments.properties.isSES);
			setsesBaseURL(arguments.properties.sesBaseURL);
			
			return this;
		</cfscript>		
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="getCollection" returntype="any" access="Public" hint="I Get a reference or deep copy of the request Collection: Returns a structure" output="false">
		<cfargument name="DeepCopyFlag" hint="Default is false, gives a reference to the collection. True, creates a deep copy of the collection." type="boolean" required="no" default="false">
		<cfargument name="private" type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			// Private Collection
			if( arguments.private ){ 
				if( arguments.deepCopyFlag ){ return duplicate(instance.privateContext); }
				return instance.privateContext;
			}
			// Public Collection
			if ( arguments.DeepCopyFlag ){ return duplicate(instance.context); }
			return instance.context;
		</cfscript>
	</cffunction>

	<cffunction name="clearCollection" access="public" returntype="void" output="false" hint="Clear the entire collection">
		<cfargument name="private" type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			if( arguments.private ) { structClear(instance.privateContext); }
			else { structClear(instance.context); }
		</cfscript>
	</cffunction>

	<cffunction name="collectionAppend" access="public" returntype="void" output="false" hint="Append a structure to the collection, with overwrite or not. Overwrite = false by default">
		<cfargument name="collection" type="any"  required="true" hint="A collection to append">
		<cfargument name="overwrite"  type="boolean" required="false" default="false" hint="If you need to override data in the collection, set this to true.">
		<cfargument name="private" type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			if( arguments.private ) { structAppend(instance.privateContext,arguments.collection, arguments.overwrite); }
			else { structAppend(instance.context,arguments.collection, arguments.overwrite); }
		</cfscript>
	</cffunction>

	<cffunction name="getSize" access="public" returntype="numeric" output="false" hint="The number of elements in the collection">
		<cfargument name="private" type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			if( arguments.private ){ return structCount(instance.privateContext); }
			return structCount(instance.context);
		</cfscript>
	</cffunction>

	<cffunction name="getValue" returntype="Any" access="Public" hint="I Get a value from the request collection." output="false">
		<cfargument name="name"         type="any" required="true" hint="Name of the variable to get from the request collection">
		<cfargument name="defaultValue"	type="any" required="false" default="NONE" hint="Default value to return if not found.">
		<cfargument name="private" 		type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			var collection = instance.context;
			
			if( arguments.private ){ collection = instance.privateContext; }
			
			if( structKeyExists(collection, arguments.name) ){
				return collection[arguments.name];
			}
			else if ( isSimpleValue(arguments.defaultValue) and arguments.defaultValue eq "NONE" ){
				$throw("The variable: #arguments.name# is undefined in the request collection.",
					   "Default: #arguments.defaultValue#, Private:#arguments.private#, Keys #structKeyList(collection)#","RequestContext.ValueNotFound");
			}
			else{
				return arguments.defaultValue;
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="getTrimValue" returntype="Any" access="Public" hint="I Get a value from the request collection and if simple value, I will trim it." output="false">
		<cfargument name="name"         type="any" required="true" hint="Name of the variable to get from the request collection">
		<cfargument name="defaultValue"	type="any" required="false" default="NONE" hint="Default value to return if not found.">
		<cfargument name="private" 		type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			var value = getValue(argumentCollection=arguments);
			
			// Verify if Simple
			if( isSimpleValue(value) ){ return trim(value); }
			
			return value;
		</cfscript>
	</cffunction>

	<cffunction name="setValue" access="Public" hint="I Set a value in the request collection" output="false" returntype="void">
		<cfargument name="name"  hint="The name of the variable to set. String" type="any" >
		<cfargument name="value" hint="The value of the variable to set" type="Any" >
		<cfargument name="private" 		type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			var collection = instance.context;
			if( arguments.private ) { collection = instance.privateContext; }
		
			collection[arguments.name] = arguments.value;
		</cfscript>
	</cffunction>

	<cffunction name="removeValue" access="Public" hint="I remove a value in the request collection" output="false" returntype="void">
		<cfargument name="name"  hint="The name of the variable to remove." type="string" >
		<cfargument name="private" 		type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			var collection = instance.context;
			if( arguments.private ){ collection = instance.privateContext; }
			
			if( valueExists(arguments.name) ){
				structDelete(collection,arguments.name);
			}
		</cfscript>
	</cffunction>

	<cffunction name="valueExists" returntype="boolean" access="Public"	hint="I Check if a value exists in the request collection." output="false">
		<cfargument name="name" hint="Name of the variable to find in the request collection: String" type="any">
		<cfargument name="private" 		type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			var collection = instance.context;
			if( arguments.private ){ collection = instance.privateContext; }
			return structKeyExists(collection, arguments.name);
		</cfscript>
	</cffunction>

	<cffunction name="paramValue" returntype="void" access="Public"	hint="Just like cfparam, but for the request collection" output="false">
		<cfargument name="name" 	hint="Name of the variable to param in the request collection: String" 	type="any">
		<cfargument name="value" 	hint="The value of the variable to set if not found." 			type="Any" >
		<cfargument name="private" 		type="boolean" required="false" default="false" hint="Use public or private request collection"/>
		<cfscript>
			if ( not valueExists(name=arguments.name,private=arguments.private) ){
				setValue(name=arguments.name,value=arguments.value,private=arguments.private);
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- GET/SET CURRENT REQUEST VARIABLES ------------------------------------------->

	<cffunction name="getCurrentView" access="public" hint="Gets the current set view" returntype="string" output="false">
		<cfreturn getValue("currentView","")>
	</cffunction>
	
	<cffunction name="setView" access="public" returntype="void" hint="I Set the view to render in this request.I am called from event handlers. Request Collection Name: currentView, currentLayout"  output="false">
		<!--- ************************************************************* --->
	    <cfargument name="name"     	type="string"  required="true"  hint="The name of the view to set. If a layout has been defined it will assign it, else if will assign the default layout. No extension please">
		<cfargument name="nolayout" 	type="boolean" required="false" default="false" hint="Boolean flag, wether the view sent in will be using a layout or not. Default is false. Uses a pre set layout or the default layout.">
		<cfargument name="cache" 		required="false" type="boolean" default="false" hint="True if you want to cache the view.">
		<cfargument name="cacheTimeout" required="false" type="string" default=""	hint="The cache timeout">
		<cfargument name="cacheLastAccessTimeout" required="false" type="string" default="" hint="The last access timeout">
		<cfargument name="layout" 		type="string" required="false" hint="You can override the rendering layout of this setView() call if you want to. Else it defaults to implicit resolution or another override.">
		<!--- ************************************************************* --->
	    <cfscript>
		    var key = "";
		    var cacheEntry = structnew();
		    
			// Local Override
			if( structKeyExists(arguments,"layout") ){
				setLayout(arguments.layout);
			}
			// If we need a layout or we haven't overriden the current layout enter if...
		    else if ( NOT arguments.nolayout AND NOT getValue("layoutoverride",false) ){
		    		
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
			
			// No Layout Rendering?
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
			instance.context["currentView"] = arguments.name;
		</cfscript>
	</cffunction>

	<cffunction name="getCurrentLayout" access="public" hint="Gets the current set layout" returntype="string" output="false">
		<cfreturn getValue("currentLayout","")>
	</cffunction>

	<cffunction name="setLayout" access="public" returntype="void" hint="I Set the layout to override and render. Layouts are pre-defined in the config file. However I can override these settings if needed. Do not append a the cfm extension. Request Collection name: currentLayout"  output="false">
		<cfargument name="name"  hint="The name of the layout file to set." type="string" >
		<cfscript>
			instance.context["currentLayout"] = trim(arguments.name) & ".cfm";
	  		instance.context["layoutoverride"] = true;
		</cfscript>
	</cffunction>

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
	
	<cffunction name="overrideEvent" access="Public" hint="I Override the current event in the request collection. This method does not execute the event, it just replaces the event to be executed by the framework's RunEvent() method. This method is usually called from an onRequestStart or onApplicationStart method."  output="false" returntype="void">
		<cfargument name="event" hint="The name of the event to override." type="string">
		 <cfscript>
	    setValue(getEventName(),arguments.event);
	    </cfscript>
	</cffunction>

	<cffunction name="showDebugPanel" access="public" returntype="void" hint="I can override to show or not the debug panel. Very useful in AJAX debugging">
		<cfargument name="show" type="boolean" required="true">
		<cfset setValue(name="coldbox_debugpanel",value=arguments.show,private=true)>
	</cffunction>

	<cffunction name="getDebugPanelFlag" access="public" returntype="boolean" hint="I return the debugpanel flag for this request.">
		<cfreturn getValue(name="coldbox_debugpanel",defaultValue=true,private=true)>
	</cffunction>
	
	<cffunction name="isProxyRequest" access="public" returntype="boolean" hint="Is this a coldbox proxy request">
		<cfreturn getValue(name="coldbox_proxyrequest",defaultValue=false,private=true)>
	</cffunction>
	
	<cffunction name="setProxyRequest" access="public" returntype="void" hint="Set that this is a proxy request">
		<cfset setValue(name="coldbox_proxyrequest",value=true,private=true)>
	</cffunction>
	
	<cffunction name="NoRender" access="public" returntype="void" hint="Set the flag that tells the framework not to render, just execute">
		<cfargument name="remove" required="false" type="boolean" default="false" hint="If true, it removes the flag, else its set.">
		<cfscript>
			if (arguments.remove eq false)
				setValue(name="coldbox_norender",value=true,private=true);
			else
				removeValue(name="coldbox_norender",private=true);
		</cfscript>		
	</cffunction>
	
	<cffunction name="isNoRender" access="public" returntype="boolean" hint="Is this a no render request">
		<cfreturn getValue(name="coldbox_norender",defaultValue=false,private=true)>
	</cffunction>
	
	<cffunction name="getEventName" access="public" returntype="any" output="false" hint="The event name used by the application: String">
		<cfreturn instance.eventName>
	</cffunction>
	
	<cffunction name="getSelf" access="public" output="false" returntype="any" hint="Returns index.cfm?{eventName}= : String">
	   <cfreturn "index.cfm?" & getEventName() & "=">
	</cffunction>
	
	<cffunction name="buildLink" access="public" output="false" returntype="any" hint="Builds a link to a passed event, either SES or normal link. If the ses interceptor is declared it will create routes.">
		<!--- ************************************************************* --->
		<cfargument name="linkto" 		required="true" 	type="string"  hint="The event or route you want to create the link to">
	    <cfargument name="translate"  	required="false" 	type="boolean" default="true" hint="Translate between . and / depending on the ses mode. So you can just use dot notation."/>
	    <cfargument name="ssl" 			required="false"    type="boolean" default="false" hint="If true, it will change http to https if found in the ses base url."/>
	    <cfargument name="baseURL" 		required="false" 	type="string"  default="" hint="If not using SES, you can use this argument to create your own base url apart from the default of index.cfm. Example: https://mysample.com/index.cfm"/>
	    <cfargument name="queryString"  required="false" 	type="string"  default="" hint="The query string to append, if needed.">
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
			/* Query String Append */
			if ( len(trim(arguments.queryString)) ){
				arguments.linkto = arguments.linkto & "/" & replace(arguments.queryString,"&","/","all");
				arguments.linkto = replace(arguments.linkto,"=","/","all");
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
			/* Check if sending in QUery String */
			if( len(trim(arguments.queryString)) eq 0 ){
				return "#frontController#?#getEventName()#=#arguments.linkto#";
			}
			else{
				return "#frontController#?#getEventName()#=#arguments.linkto#&#arguments.queryString#";
			}
		}		
		</cfscript>
	</cffunction>
	
	<cffunction name="isEventCacheable" access="public" returntype="boolean" hint="Check wether the incoming event has been flagged for caching" output="false" >
		<cfscript>
			return valueExists(name="cbox_eventCacheableEntry",private=true);
		</cfscript>
	</cffunction>	
	<cffunction name="setEventCacheableEntry" access="public" returntype="void" hint="Set the event cacheable entry" output="false" >
		<cfargument name="mdCacheEntry" required="true" type="any" hint="The cache entry we need to get to cache">
		<cfset setValue(name="cbox_eventCacheableEntry",value=arguments.mdCacheEntry,private=true)>
	</cffunction>
	<cffunction name="getEventCacheableEntry" access="public" returntype="any" hint="Get the event cacheable entry" output="false" >
		<cfreturn getValue(name="cbox_eventCacheableEntry",defaultValue=structnew(),private=true)>
	</cffunction>
	<cffunction name="removeEventCacheableEntry" access="public" returntype="void" hint="Remove the cacheable entry" output="false" >
		<cfset removeValue(name='cbox_eventCacheableEntry',private=true)>
	</cffunction>
	
	<cffunction name="isViewCacheable" access="public" returntype="boolean" hint="Check wether the incoming view has been flagged for caching" output="false" >
		<cfscript>
			return valueExists(name="cbox_viewCacheableEntry",private=true);
		</cfscript>
	</cffunction>
	
	<cffunction name="setViewCacheableEntry" access="public" returntype="void" hint="Set the view cacheable entry" output="false" >
		<cfargument name="mdCacheEntry" required="true" type="any" hint="The cache entry we need to get to cache">
		<cfscript>
			setValue(name="cbox_viewCacheableEntry",value=arguments.mdCacheEntry,private=true);
		</cfscript>
	</cffunction>
	<cffunction name="getViewCacheableEntry" access="public" returntype="any" hint="Get the event cacheable entry" output="false" >
		<cfreturn getValue(name="cbox_viewCacheableEntry",defaultValue=structnew(),private=true)>
	</cffunction>
	
	<cffunction name="isSES" access="public" output="false" returntype="boolean" hint="Determine if you are in SES mode.">
		<cfreturn instance.isSES/>
	</cffunction>
	<cffunction name="setisSES" access="public" output="false" returntype="void" hint="Set isSES flag">
		<cfargument name="isSES" type="boolean" required="true"/>
		<cfset instance.isSES = arguments.isSES/>
	</cffunction>
	
	<cffunction name="getSESBaseURL" access="public" output="false" returntype="string" hint="Get the sesBaseURL">
		<cfreturn instance.sesBaseURL/>
	</cffunction>
	<cffunction name="setSESBaseURL" access="public" output="false" returntype="void" hint="Set the sesBaseURL">
		<cfargument name="sesBaseURL" type="string" required="true"/>
		<cfset instance.sesBaseURL = arguments.sesBaseURL/>
	</cffunction>
	
	<cffunction name="getRoutedStruct" access="public" output="false" returntype="struct" hint="Get the routed structure of key-value pairs. What the ses interceptor could match.">
		<cfreturn instance.routedStruct/>
	</cffunction>	
	<cffunction name="setRoutedStruct" access="public" output="false" returntype="void" hint="Set routed struct of key-value pairs. This is used only by the SES interceptor. Not for public use.">
		<cfargument name="routedStruct" type="struct" required="true"/>
		<cfset instance.routedStruct = arguments.routedStruct/>
	</cffunction>
	
<!------------------------------------------- ACCESSORS/MUTATORS ------------------------------------------->

	<cffunction name="getDefaultLayout" access="public" returntype="any" output="false" hint="Get's the default layout of the application: String">
		<cfreturn instance.defaultLayout>
	</cffunction>
	<cffunction name="setDefaultLayout" access="public" returntype="void" output="false">
		<cfargument name="DefaultLayout" type="string" required="true">
		<cfset instance.defaultLayout = arguments.DefaultLayout>
	</cffunction>
	
	<cffunction name="getDefaultView" access="public" returntype="any" output="false" hint="Get's the default view of the application: String">
		<cfreturn instance.defaultView>
	</cffunction>
	<cffunction name="setDefaultView" access="public" returntype="void" output="false">
		<cfargument name="DefaultView" type="string" required="true">
		<cfset instance.defaultView = arguments.DefaultView>
	</cffunction>
	
	<cffunction name="getViewLayouts" access="public" returntype="struct" output="false">
		<cfreturn instance.ViewLayouts>
	</cffunction>
	<cffunction name="setViewLayouts" access="public" returntype="void" output="false">
		<cfargument name="ViewLayouts" type="struct" required="true">
		<cfset instance.ViewLayouts = arguments.ViewLayouts>
	</cffunction>
	
	<cffunction name="getFolderLayouts" access="public" returntype="struct" output="false">
		<cfreturn instance.FolderLayouts>
	</cffunction>
	<cffunction name="setFolderLayouts" access="public" returntype="void" output="false">
		<cfargument name="FolderLayouts" type="struct" required="true">
		<cfset instance.FolderLayouts = arguments.FolderLayouts>
	</cffunction>
	
	<cffunction name="setEventName" access="public" returntype="void" output="false">
		<cfargument name="EventName" type="string" required="true">
		<cfset instance.eventName = arguments.EventName>
	</cffunction>
	
	<cffunction name="getmemento" access="public" returntype="any" output="false">
		<cfreturn variables.instance>
	</cffunction>
	<cffunction name="setmemento" access="public" returntype="void" output="false">
		<cfargument name="memento" type="any" required="true">
		<cfset variables.instance = arguments.memento>
	</cffunction>
	
	<cffunction name="renderData" access="public" returntype="void" hint="Use this method to tell the framework to render data for you. The framework will take care of marshalling the data for you" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="type" 		required="true"  type="string" default="PLAIN" hint="The type of data to render. Valid types are JSON, XML, WDDX, PLAIN. THe deafult is PLAIN. If an invalid type is sent in, this method will throw an error">
		<cfargument name="data" 		required="true"  type="any"    hint="The data you would like to marshall and return by the framework">
		<cfargument name="contentType"  required="true"  type="string" default="" hint="The content type of the data. This will be used in the cfcontent tag: text/html, text/plain, text/xml, text/json, etc. The default value is text/html. However, if you choose JSON this method will choose application/json, if you choose WDDX or XML this method will choose text/xml for you. The default encoding is utf-8"/>
		<cfargument name="encoding" 	required="false" type="string" default="utf-8" hint="The default character encoding to use"/>
		<!--- ************************************************************* --->
		<cfargument name="jsonCase" 		type="string" required="false" default="lower" hint="JSON Only: Whether to use lower or upper case translations in the JSON transformation. Lower is default"/>
		<cfargument name="jsonQueryFormat" 	type="string" required="false" default="query" hint="JSON Only: query or array" />
		<cfargument name="jsonAsText" 		type="boolean" required="false" default="false" hint="If set to false, defaults content mime-type to application/json, else will change encoding to plain/text"/>
		<!--- ************************************************************* --->
		<cfargument name="xmlColumnList"    type="string"   required="false" default="" hint="XML Only: Choose which columns to inspect, by default it uses all the columns in the query, if using a query">
		<cfargument name="xmlUseCDATA"  	type="boolean"  required="false" default="false" hint="XML Only: Use CDATA content for ALL values. The default is false">
		<cfargument name="xmlListDelimiter" type="string"   required="false" default="," hint="XML Only: The delimiter in the list. Comma by default">
		<!--- ************************************************************* --->
		<cfscript>
			var rd = structnew();
			/* Validate */
			if( not reFindnocase("^(JSON|WDDX|XML|PLAIN)$",arguments.type) ){
				$throw("Invalid rendering type","The type you sent #arguments.type# is not a valid rendering type. Valid types are JSON,XML,WDDX and PLAIN","RequestContext.InvalidRenderTypeException");
			}
			/* Populate */
			rd.type = arguments.type;
			rd.data = arguments.data;
			rd.encoding = arguments.encoding;
			
			/* XML Properties */
			rd.xmlColumnList = arguments.xmlColumnList;
			rd.xmluseCDATA = arguments.xmlUseCDATA;
			rd.xmlListDelimiter = arguments.xmlListDelimiter;
			
			/* JSON Properties */
			rd.jsonCase = arguments.jsonCase;	
			rd.jsonQueryFormat = arguments.jsonQueryFormat;		
			
			/* contenttype selections */
			if( rd.type eq "JSON" ){
				rd.contenttype = 'application/json';
				if( arguments.jsonAsText ){ rd.contentType = "text/plain"; }
			}
			else if( rd.type eq "WDDX" OR rd.type eq "XML"){
				rd.contentType = 'text/xml';
			}
			else{
				/* If contenttype passed? */
				if( len(trim(arguments.contentType)) ){
					rd.contentType = arguments.contentType;
				}
				else{
					rd.contentType = "text/html";
				}
			}
			
			// Save Rendering data privately.
			setValue(name='cbox_renderdata',value=rd,private=true);			
		</cfscript>
	</cffunction>
	
	<cffunction name="getrenderData" access="public" output="false" returntype="struct" hint="Get the renderData structure.">
		<cfreturn getValue(name="cbox_renderdata",defaultValue=structnew(),private=true)/>
	</cffunction>

	<cffunction name="getHTTPMethod" access="public" returntype="string" hint="Get the HTTP Request Method Type" output="false" >
		<cfreturn cgi.REQUEST_METHOD>
	</cffunction>
	
	<cffunction name="isSSL" access="public" returntype="boolean" hint="Returns boolean result whether current request is in ssl or not" output="false">
	    <cfscript>
			if (isBoolean(cgi.server_port_secure) AND cgi.server_port_secure) { return true; }
			return false;
		</cfscript>
	</cffunction>
	
	<cffunction name="isViewDispatched" access="public" returntype="boolean" hint="Determine if we need to dispatch a view" output="false" >
		<cfreturn instance.isViewDispatched>
	</cffunction>
		
	<cffunction name="setViewDispatched" access="public" returntype="void" hint="Set by the framework to determine if a view is to be dispatched immediately wihout executing an event" output="false" >
		<cfargument name="view"  	 type="string"  required="true" hint="The view to dispatch">
		<cfargument name="noLayout"  type="boolean" required="true" hint="Wether to dispatch a view with an assigned layout or not">
		<cfset instance.isViewDispatched = true>
		<cfset setView(arguments.view,arguments.noLayout)>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="$throw" access="private" hint="Facade for cfthrow" output="false">
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	
	<!--- Dump facade --->
	<cffunction name="$dump" access="private" hint="Facade for cfmx dump" returntype="void">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>
		<cfdump var="#var#">
		<cfif arguments.isAbort><cfabort></cfif>
	</cffunction>
</cfcomponent>