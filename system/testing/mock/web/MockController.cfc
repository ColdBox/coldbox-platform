<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 		: Luis Majano
Date     		: June 6, 2007
Description		: This is a unit test controller that basically overrides the setNextEvent
				  in order to unit test with set next events.
----------------------------------------------------------------------->
<cfcomponent hint="This is the ColdBox Unit Test Front Controller." output="false" extends="coldbox.system.web.Controller">

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="init" returntype="coldbox.system.web.Controller" access="public" hint="Constructor" output="false">
		<cfargument name="appRootPath" 	type="string" 	required="true" hint="The app Root Path"/>
		<cfargument name="appKey"		type="any" 		required="true" hint="The application registered application key"/>
		<cfscript>
			super.init(argumentCollection=arguments);
			
			// Override mocks
			setRequestService( CreateObject("component","coldbox.system.testing.mock.services.MockRequestService").init(this) );
			
			return this;
		</cfscript>
	</cffunction>

	<!--- Event Context Methods --->
	<cffunction name="setNextEvent" access="Public" returntype="void" hint="I Set the next event to run and relocate the browser to that event."  output="false">
		<!--- ************************************************************* --->
		<cfargument name="event"  				required="false" type="string"  default="#getSetting("DefaultEvent")#" hint="The name of the event to run, if not passed, then it will use the default event found in your configuration file.">
		<cfargument name="queryString"  		required="false" type="string"  default="" hint="The query string to append, if needed. If in SES mode it will be translated to convention name value pairs">
		<cfargument name="addToken"				required="false" type="boolean" default="false"	hint="Wether to add the tokens or not. Default is false">
		<cfargument name="persist" 				required="false" type="string"  default="" hint="What request collection keys to persist in flash ram">
		<cfargument name="persistStruct" 		required="false" type="struct"  default="#structnew()#" hint="A structure key-value pairs to persist in flash ram.">
		<cfargument name="ssl"					required="false" type="boolean" hint="Whether to relocate in SSL or not. You need to explicitly say TRUE or FALSE if going out from SSL. If none passed, we look at the even's SES base URL (if in SES mode)">
		<cfargument name="baseURL" 				required="false" type="string"  default="" hint="Use this baseURL instead of the index.cfm that is used by default. You can use this for ssl or any full base url you would like to use. Ex: https://mysite.com/index.cfm"/>
		<cfargument name="postProcessExempt"    required="false" type="boolean" default="false" hint="Do not fire the postProcess interceptors">
		<cfargument name="URL"  				required="false" type="string"  hint="The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'"/>
		<cfargument name="URI"  				required="false" type="string"  hint="The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'"/>
		<cfargument name="statusCode" 			required="false" type="numeric" default="0" hint="The status code to use in the relocation"/>
		<!--- ************************************************************* --->
		<cfscript>
			var context = getRequestService().getContext();
			
			context.setValue("setNextEvent","#arguments.event#");
			context.setValue("setNextEvent_queryString","#arguments.queryString#");
			context.setValue("setNextEvent_addToken","#arguments.addToken#");
			context.setValue("setNextEvent_persistKeys","#arguments.persist#");
			context.setValue("setNextEvent_persistStruct","#arguments.persistStruct#");
			if( structKeyExists(arguments, "ssl") ){
				context.setValue("setNextEvent_ssl","#arguments.ssl#");
			}
			context.setValue("setNextEvent_baseURL","#arguments.baseURL#");
			context.setValue("setNextEvent_postProcessExempt","#arguments.postProcessExempt#");
			if( structKeyExists(arguments, "URL") ){
				context.setValue("setNextEvent_URL","#arguments.URL#");
			}
			if( structKeyExists(arguments, "URI") ){
				context.setValue("setNextEvent_URI","#arguments.URI#");
			}
			context.setValue("setNextEvent_statusCode","#arguments.statusCode#");
		
			// Post Process
			if( arguments.postProcessExempt ){
				getInterceptorService().processState("postProcess");
			}
		</cfscript>
		
		<cfthrow type="TestController.setNextEvent" message="Relocating via setnextevent">
	</cffunction>
	
	<!--- relocate --->
	<cffunction name="relocate" access="public" hint="Facade for cflocation" returntype="void" output="false">
		<cfargument name="url" 		required="true" 	type="string">
		<cfargument name="addtoken" required="false" 	type="boolean" default="false">
		<cfargument name="postProcessExempt"  type="boolean" required="false" default="false" hint="Do not fire the postProcess interceptors">
		<cfset setNextEvent(argumentCollection=arguments)>
	</cffunction>
	
	<!--- Event Context Methods --->
	<cffunction name="setNextRoute" access="Public" returntype="void" hint="I Set the next ses route to relocate to. This method pre-pends the baseURL"  output="false">
		<!--- ************************************************************* --->
		<cfargument name="route"  		required="yes" 	 type="string"  hint="The route to relocate to, do not prepend the baseURL or /.">
		<cfargument name="persist" 		required="false" type="string"  default="" hint="What request collection keys to persist in the relocation">
		<cfargument name="persistStruct" 	required="false" type="struct"  default="#structnew()#" hint="A structure key-value pairs to persist.">
		<cfargument name="addToken"		required="false" type="boolean" default="false"	hint="Wether to add the tokens or not. Default is false">
		<cfargument name="ssl"			required="false" type="boolean" default="false"	hint="Whether to relocate in SSL or not">
		<cfargument name="queryString"  required="false" type="string"  default="" hint="The query string to append, if needed.">
		<cfargument name="postProcessExempt"  type="boolean" required="false" default="false" hint="Do not fire the postProcess interceptors">
		<!--- ************************************************************* --->
		<cfset arguments.event = arguments.route>
		<cfset setNextEvent(argumentCollection=arguments)>
	</cffunction>

</cfcomponent>