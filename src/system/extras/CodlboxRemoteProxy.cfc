<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/16/2007
Description :
	This component is the coldbox remote proxy used for model operation.
	This will convert the framework into a model framework rather than a 
	HTML MVC framework.	
----------------------------------------------------------------------->
<cfcomponent name="ColdboxRemoteProxy" output="false" hint="This component is the coldbox remote proxy used for model operation." >
	
<!------------------------------------------- PUBLIC ------------------------------------------->	

	<!--- process a remote call --->
	<cffunction name="process" output="false" access="public" returntype="any" hint="Process a remote call and return data/objects back.">
		<!--- There are no arguments defined as they come in as a collection of arguments. --->
		<cfscript>
			var cbController = "";
			var event = "";
			var results = "";
			
			//Verify the coldbox app is ok, else throw
			if ( verifyColdBox() ){
				cbController = application.cbController;
			}
			
			//Create the request context
			Event = cbController.getRequestService().requestCapture();
			//Append the arguments to the collection
			Event.collectionAppend(arguments,true);
			//Set that this is a proxy request.
			Event.setProxyRequest();
			
			//Execute the app start handler if not fired already
			if ( cbController.getSetting("ApplicationStartHandler") neq "" and (not cbController.getAppStartHandlerFired()) ){
				cbController.runEvent(cbController.getSetting("ApplicationStartHandler"),true);
				cbController.setAppStartHandlerFired(true);
			}
			
			//Execute a pre process interception.
			cbController.getInterceptorService().processState("preProcess")
			
			//Request Start Handler if defined
			if ( cbController.getSetting("RequestStartHandler") neq "" ){
				cbController.runEvent(cbController.getSetting("RequestStartHandler"),true);
			}
				
			//Execute the Event
			results = cbController.runEvent();
			
			//Request END Handler if defined
			if ( cbController.getSetting("RequestEndHandler") neq "" ){
				cbController.runEvent(cbController.getSetting("RequestEndHandler"),true);
			}
			
			//Execute the post process interceptor
			cbController.getInterceptorService().processState("postProcess")
			
			//Return results
			return results;
		</cfscript>		
	</cffunction>
	
	<!--- process an interception --->
	<cffunction name="announceInterception" output="false" access="public" returntype="any" hint="Process a remote interception.">
		<cfargument name="state" 			type="string" required="true" hint="The intercept state"/>
		<cfargument name="interceptData"    type="any" 	  required="false" default="" hint="The intercept data."/>
		<cfscript>
			var cbController = "";
			var interceptionStructure = structnew();
			
			//Verify the coldbox app is ok, else throw
			if ( verifyColdBox() ){
				cbController = application.cbController;
			}
			
			//Create Interception Structure
			interceptionStructure.data = arguments.interceptData;
			
			//Intercept
			cbController.getInterceptorService().processState(arguments.state,interceptionStructure);
		</cfscript>
	</cffunction>
<!------------------------------------------- PRIVATE ------------------------------------------->	
	
	<!--- verifyColdBox --->
	<cffunction name="verifyColdBox" output="false" access="public" returntype="boolean" hint="Verify the coldbox app">
		<cfscript>
		//Verify the coldbox app is ok, else throw
		if ( not structKeyExists(application,"cbController") ){
			throw("ColdBox Not Found", "The coldbox main controller has not been initialized", "framework.controllerNotFoundException");
		}
		else
			return true;
		</cfscript>
	</cffunction>

	<!--- Throw Facade --->
	<cffunction name="throw" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>
	<!--- Dump facade --->
	<cffunction name="dump" access="private" hint="Facade for cfmx dump" returntype="void">
		<cfargument name="var" required="yes" type="any">
		<cfdump var="#var#">
	</cffunction>
	<!--- Abort Facade --->
	<cffunction name="abort" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>
	
</cfcomponent>