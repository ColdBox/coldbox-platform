<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This service takes cares of exceptions

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent name="exceptionService" output="false" hint="The ColdBox exception service" extends="baseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="exceptionService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController(arguments.controller);
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="ExceptionHandler" access="public" hint="I handle a framework/application exception. I return a framework exception bean" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="Exception" 	 type="any"  	required="true"  hint="The exception structure. Passed as any due to CF glitch">
		<cfargument name="ErrorType" 	 type="string" 	required="false" default="application">
		<cfargument name="ExtraMessage"  type="string"  required="false" default="">
		<!--- ************************************************************* --->
		<cfscript>
		var BugReport = "";
		var ExceptionBean = controller.getPlugin("beanFactory").create("coldbox.system.beans.exceptionBean").init(errorStruct=arguments.Exception,extramessage=arguments.extraMessage,errorType=arguments.ErrorType);
		var requestContext = controller.getRequestService().getContext();
		// Test Error Type
		if ( not reFindnocase("(application|framework)",arguments.errorType) )
			arguments.errorType = "application";

		if ( arguments.ErrorType eq "application" ){
			//Run custom Exception handler if Found, else run default
			if ( controller.getSetting("ExceptionHandler") neq "" ){
				try{
					requestContext.setValue("ExceptionBean",ExceptionBean);
					controller.runEvent(controller.getSetting("Exceptionhandler"));
				}
				catch(Any e){
					ExceptionBean = controller.getPlugin("beanFactory").create("coldbox.system.beans.exceptionBean").init(errorStruct=e,extramessage="Error Running Custom Exception handler",errorType="application");
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

	<cffunction name="renderBugReport" access="public" hint="Render a Bug Report." output="false" returntype="Any">
		<cfargument name="ExceptionBean" type="any" required="true">
		<cfset var BugReport = "">
		<cfset var Exception = arguments.ExceptionBean>
		<cfset var Event = controller.getRequestService().getContext()>
		<!--- test for custom bug report --->
		<cfif Exception.getErrortype() eq "application" and controller.getSetting("CustomErrorTemplate") neq "">
			<cftry>
				<!--- Place exception in the requset Collection --->
				<Cfset Event.setvalue("ExceptionBean",Exception)>
				<!--- Save the Custom Report --->
				<cfsavecontent variable="BugReport"><cfinclude template="/#controller.getSetting("AppMapping")#/#controller.getSetting("CustomErrorTemplate")#"></cfsavecontent>
				<cfcatch type="any">
					<cfset Exception = ExceptionHandler(cfcatch,"Application","Error creating custom error template.")>
					<!--- Save the Bug Report --->
					<cfsavecontent variable="BugReport"><cfinclude template="../includes/BugReport.cfm"></cfsavecontent>
				</cfcatch>
			</cftry>
		<cfelse>
			<!--- Save the Bug Report --->
			<cfsavecontent variable="BugReport"><cfinclude template="../includes/BugReport.cfm"></cfsavecontent>
		</cfif>
		<cfreturn BugReport>
	</cffunction>
		
<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>