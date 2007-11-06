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
	
	For this proxy, you will call a method on the proxy that matches an event in
	your coldbox application. However, instead of using dot notation you will
	use underscore (_) notation.
	
	Example:
	coldbox event : ehflex.getArray
	coldbox proxy event : ehflex_getArray
	
----------------------------------------------------------------------->
<cfcomponent name="cf8ColdboxRemoteProxy" extends="ColdboxProxy" output="false" hint="This component is the coldbox remote proxy used for model operation using ColdFusion 8's on missing method." >
	
<!------------------------------------------- PUBLIC ------------------------------------------->	
	
	<!--- The main entry point for processing --->
	<cffunction name="onMissingMethod" output="false" access="remote" returntype="Any" hint="Process a remote call and return data/objects back. Call the method with a _ instead of a .">
    	<!--- ************************************************************* --->
		<cfargument name="missingMethodName"		type="string" required="true"/>
      	<cfargument name="missingMethodArguments"   type="struct" required="true"/>
      	<!--- ************************************************************* --->
		<cfscript>
			var cbController = "";
			var event = "";
			var results = "";
			
			//Verify the coldbox app is ok, else throw
			if ( verifyColdBox() ){
				cbController = application.cbController;
			}
			
			try{
				//Add the called event to the arguments as the app's event
				arguments.missingMethodArguments[cbController.getSetting("EventName")] = replace(arguments.missingMethodName,"_",".","all");
				
				//Create the request context
				Event = cbController.getRequestService().requestCapture();
				//Append the arguments to the collection
				Event.collectionAppend(arguments.missingMethodArguments,true);
				//Set that this is a proxy request.
				Event.setProxyRequest();
				
				//Execute the app start handler if not fired already
				if ( cbController.getSetting("ApplicationStartHandler") neq "" and (not cbController.getAppStartHandlerFired()) ){
					cbController.runEvent(cbController.getSetting("ApplicationStartHandler"),true);
					cbController.setAppStartHandlerFired(true);
				}
				
				//Execute a pre process interception.
				cbController.getInterceptorService().processState("preProcess");
				
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
				cbController.getInterceptorService().processState("postProcess");
			}
			catch(Any e){
				//Log Exception
				cbController.getService("exception").ExceptionHandler(e,"coldboxproxy","Process Exception");
				throw(e.message,e.detail & e.stacktrace,e.type);
			}
			
			//Determine what to return via the setting
			if ( cbController.getSetting("ProxyReturnCollection") ){
				//Return request collection
				return Event.getCollection();
			}
			else{
				//Return results from handler
				return results;
			}
		</cfscript>
   </cffunction>
	
</cfcomponent>