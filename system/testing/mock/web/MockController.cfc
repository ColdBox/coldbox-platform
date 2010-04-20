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
		<cfargument name="appRootPath" type="string" required="true" hint="The app Root Path"/>
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
		<cfargument name="event"  			type="string" 	required="false" default="#getSetting("DefaultEvent")#" hint="The name of the event to run.">
		<cfargument name="queryString"  	type="string" 	required="false" default="" hint="The query string to append, if needed.">
		<cfargument name="addToken"			type="boolean" 	required="false" default="false" hint="Wether to add the tokens or not. Default is false">
		<cfargument name="persist" 			type="string" 	required="false" default="" hint="What request collection keys to persist in the relocation">
		<cfargument name="persistStruct" 		type="struct" 	required="false" default="#structNew()#" hint="A structure key-value pairs to persist.">
		<cfargument name="ssl"				type="boolean" required="false" default="false"	hint="Whether to relocate in SSL or not, only used when in SES mode.">
		<cfargument name="baseURL" 			type="string"  required="false" default="" hint="Use this baseURL instead of the index.cfm that is used by default. You can use this for ssl or any full base url you would like to use. Ex: https://mysite.com/index.cfm"/>
		<cfargument name="postProcessExempt"  type="boolean" required="false" default="false" hint="Do not fire the postProcess interceptors">
		<cfargument name="URL"  				required="false" type="string" default="" hint="The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'"/>
		<cfargument name="URI"  				required="false" type="string" default="" hint="The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'"/>
		<cfargument name="statusCode" 			required="false" type="numeric" default="0" hint="The status code to use in the relocation"/>
		<!--- ************************************************************* --->
		<cfset var context = getRequestService().getContext()>
		
		<cfset context.setValue("setNextEvent","#arguments.event#")>
		<cfset context.setValue("setNextEvent_queryString","#arguments.queryString#")>
		<cfset context.setValue("setNextEvent_addToken","#arguments.addToken#")>
		<cfset context.setValue("setNextEvent_persistKeys","#arguments.persist#")>
		<cfset context.setValue("setNextEvent_persistStruct","#arguments.persistStruct#")>
		<cfset context.setValue("setNextEvent_ssl","#arguments.ssl#")>
		<cfset context.setValue("setNextEvent_baseURL","#arguments.baseURL#")>
		<cfset context.setValue("setNextEvent_postProcessExempt","#arguments.postProcessExempt#")>
		<cfset context.setValue("setNextEvent_URL","#arguments.URL#")>
		<cfset context.setValue("setNextEvent_URI","#arguments.URI#")>
		<cfset context.setValue("setNextEvent_statusCode","#arguments.statusCode#")>
		
		<!--- Post Process --->
		<cfif arguments.postProcessExempt>
			<cfset getInterceptorService().processState("postProcess")>
		</cfif>
		
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