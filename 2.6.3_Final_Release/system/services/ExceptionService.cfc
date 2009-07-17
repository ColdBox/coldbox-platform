<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This service takes cares of exceptions

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="exceptionService" output="false" hint="The ColdBox exception service" extends="coldbox.system.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="ExceptionService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController(arguments.controller);
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Exception handler --->
	<cffunction name="ExceptionHandler" access="public" hint="I handle a framework/application exception. I return a framework exception bean" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="Exception" 	 type="any"  	required="true"  hint="The exception structure. Passed as any due to CF glitch">
		<cfargument name="ErrorType" 	 type="string" 	required="false" default="application">
		<cfargument name="ExtraMessage"  type="string"  required="false" default="">
		<!--- ************************************************************* --->
		<cfscript>
		var BugReport = "";
		var ExceptionBean = CreateObject("component","coldbox.system.beans.exceptionBean").init(errorStruct=arguments.Exception,extramessage=arguments.extraMessage,errorType=arguments.ErrorType);
		var requestContext = controller.getRequestService().getContext();
		
		/* Test Error Type */
		if ( not reFindnocase("(application|framework|coldboxproxy)",arguments.errorType) )
			arguments.errorType = "application";
		
		/* Test type of error, proxy errors */	
		if ( arguments.ErrorType neq "framework" ){
			
			//Run custom Exception handler if Found, else run default
			if ( controller.getSetting("ExceptionHandler") neq "" ){
				try{
					requestContext.setValue("ExceptionBean",ExceptionBean);
					controller.runEvent(controller.getSetting("Exceptionhandler"));
				}
				catch(Any e){
					ExceptionBean = CreateObject("component","coldbox.system.beans.exceptionBean").init(errorStruct=e,extramessage="Error Running Custom Exception handler",errorType="application");
					controller.getPlugin("logger").logErrorWithBean(ExceptionBean);
				}
			}
			else{
				controller.getPlugin("logger").logErrorWithBean(ExceptionBean);
			}
		}		
		
		//return
		return ExceptionBean;
		</cfscript>
	</cffunction>

	<!--- Render a Bug Report --->
	<cffunction name="renderBugReport" access="public" hint="Render a Bug Report." output="false" returntype="string">
		<!--- ************************************************************* --->
		<cfargument name="ExceptionBean" type="any" required="true">
		<!--- ************************************************************* --->
		<cfset var cboxBugReport = "">
		<cfset var Exception = arguments.ExceptionBean>
		<cfset var Event = controller.getRequestService().getContext()>
		<!--- test for custom bug report --->
		<cfif Exception.getErrortype() eq "application" and controller.getSetting("CustomErrorTemplate") neq "">
			<cftry>
				<!--- Place exception in the requset Collection --->
				<cfset Event.setvalue("ExceptionBean",Exception)>
				<!--- Save the Custom Report --->
				<cfsavecontent variable="cboxBugReport"><cfinclude template="/#controller.getSetting("AppMapping")#/#controller.getSetting("CustomErrorTemplate")#"></cfsavecontent>
				<cfcatch type="any">
					<cfset Exception = ExceptionHandler(cfcatch,"Application","Error creating custom error template.")>
					<!--- Save the Bug Report --->
					<cfsavecontent variable="cboxBugReport"><cfinclude template="../includes/BugReport.cfm"></cfsavecontent>
				</cfcatch>
			</cftry>
		<cfelse>
			<!--- Save the Bug Report --->
			<cfsavecontent variable="cboxBugReport"><cfinclude template="../includes/BugReport.cfm"></cfsavecontent>
		</cfif>
		<cfreturn cboxBugReport>
	</cffunction>
	
	<!--- Render an Email Bug Report --->
	<cffunction name="renderEmailBugReport" access="public" returntype="string" hint="Render an Email Bug Report" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="ExceptionBean" type="any" required="true">
		<!--- ************************************************************* --->
		<cfset var cboxBugReport = "">
		<cfset var Exception = arguments.ExceptionBean>
		<cfset var Event = controller.getRequestService().getContext()>
		<!--- test for custom bug report --->
		<cfif Exception.getErrortype() eq "application" and controller.getSetting("CustomEmailBugReport") neq "">
			<cftry>
				<!--- Place exception in the requset Collection --->
				<cfset Event.setvalue("ExceptionBean",Exception)>
				<!--- Save the Custom Email Bug Report --->
				<cfsavecontent variable="cboxBugReport"><cfinclude template="/#controller.getSetting("AppMapping")#/#controller.getSetting("CustomEmailBugReport")#"></cfsavecontent>
				<cfcatch type="any">
					<cfset Exception = ExceptionHandler(cfcatch,"Application","Error creating custom email bug report.")>
					<!--- Save the Bug Report --->
					<cfsavecontent variable="cboxBugReport"><cfinclude template="../includes/BugReport.cfm"></cfsavecontent>
				</cfcatch>
			</cftry>
		<cfelse>
			<!--- Render the Default Email Bug Report --->
			<cfsavecontent variable="cboxBugReport"><cfinclude template="../includes/BugReport.cfm"></cfsavecontent>
		</cfif>
		<cfreturn cboxBugReport>		
	</cffunction>
		
<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>