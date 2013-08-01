<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	January 18, 2007
Description :
	This service takes cares of exceptions

Modification History:
01/18/2007 - Created
----------------------------------------------------------------------->
<cfcomponent output="false" hint="The ColdBox exception service" extends="coldbox.system.web.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="ExceptionService" hint="Constructor">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			setController(arguments.controller);
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- exception handler --->
	<cffunction name="exceptionHandler" access="public" hint="I handle a framework/application exception. I return a framework exception bean" returntype="any" output="false" colddoc:generic="coldbox.system.web.context.ExceptionBean">
		<!--- ************************************************************* --->
		<cfargument name="exception" 	 type="any"  	required="true"  hint="The exception structure. Passed as any due to CF glitch">
		<cfargument name="errorType" 	 type="string" 	required="false" default="application">
		<cfargument name="extraMessage"  type="string"  required="false" default="">
		<!--- ************************************************************* --->
		<cfscript>
		var bugReport 		= "";
		var exceptionBean 	= createObject("component","coldbox.system.web.context.ExceptionBean").init(errorStruct=arguments.exception,extramessage=arguments.extraMessage,errorType=arguments.errorType);
		var requestContext 	= controller.getRequestService().getContext();
		var appLogger 		= controller.getPlugin("Logger");
		
		// Test Error Type
		if ( not reFindnocase("(application|framework|coldboxproxy)",arguments.errorType) ){
			arguments.errorType = "application";
		}
		
		//Run custom Exception handler if Found, else run default exception routines
		if ( len(controller.getSetting("ExceptionHandler")) ){
			try{
				requestContext.setValue("exceptionBean",exceptionBean);
				controller.runEvent(controller.getSetting("Exceptionhandler"));
			}
			catch(Any e){
				// Log Original Error First
				appLogger.logErrorWithBean(exceptionBean);
				// Create new exception bean
				exceptionBean = createObject("component","coldbox.system.web.context.ExceptionBean").init(errorStruct=e,extramessage="Error Running Custom Exception handler",errorType="application");
				// Log it
				appLogger.logErrorWithBean(exceptionBean);
			}
		}
		else{
			// Log Error only
			appLogger.logErrorWithBean(exceptionBean);	
		}
		
		return exceptionBean;
		</cfscript>
	</cffunction>

	<!--- Render a Bug Report --->
	<cffunction name="renderBugReport" access="public" hint="Render a Bug Report." output="false" returntype="string">
		<!--- ************************************************************* --->
		<cfargument name="exceptionBean" type="any" required="true">
		<!--- ************************************************************* --->
		<cfset var cboxBugReport 	= "">
		<cfset var exception 		= arguments.exceptionBean>
		<cfset var event 			= controller.getRequestService().getContext()>
		<cfset var appLocPrefix				= "/">
		<cfset var bugReportTemplatePath	= "">
		<cfset var CustomErrorTemplate		= controller.getSetting("CustomErrorTemplate")>
		
		<!--- test for custom bug report --->
		<cfif Exception.getErrortype() eq "application" and CustomErrorTemplate neq "">
			<cftry>
					
				<!--- App location prefix --->
				<cfif len(controller.getSetting('AppMapping')) >
						<cfset appLocPrefix = appLocPrefix & controller.getSetting('AppMapping') & "/">
				</cfif>
		
				<!--- Setup the bugReport template Path for relative location first. --->
				<cfset bugReportTemplatePath = appLocPrefix & reReplace(CustomErrorTemplate,"^/","")>
					<cfif NOT fileExists(expandPath(bugReportTemplatePath))>
						<!--- Assume absolute location as not found inside our app --->
						<cfset bugReportTemplatePath = CustomErrorTemplate>
						<cfif NOT fileExists(expandPath(bugReportTemplatePath))>
							<cfthrow message="CustomErrorTemplate cannot be found.  #expandPath(bugReportTemplatePath)#">
						</cfif>
					</cfif>

				<!--- Place exception in the requset Collection --->
				<cfset event.setvalue("exceptionBean",Exception)>
				<!--- Save the Custom Report --->
				<cfsavecontent variable="cboxBugReport"><cfinclude template="#bugReportTemplatePath#"></cfsavecontent>
				<cfcatch type="any">
					<cfset exception = ExceptionHandler(cfcatch,"Application","Error creating custom error template.")>
					<!--- Save the Bug Report --->
					<cfsavecontent variable="cboxBugReport"><cfinclude template="/coldbox/system/includes/BugReport.cfm"></cfsavecontent>
				</cfcatch>
			</cftry>
		<cfelse>
			<!--- Save the Bug Report --->
			<cfsavecontent variable="cboxBugReport"><cfinclude template="/coldbox/system/includes/BugReport.cfm"></cfsavecontent>
		</cfif>
		<cfreturn cboxBugReport>
	</cffunction>
		
<!------------------------------------------- PRIVATE ------------------------------------------->


</cfcomponent>