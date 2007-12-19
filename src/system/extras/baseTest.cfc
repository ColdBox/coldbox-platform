<!-----------------------------------------------------------------------
Template : baseTest.cfc
Author 	  : Luis Majano
Date        : 5/25/2007
Description :
	Base Unit Test Component based on CFCUnit.

	If you would like to change this to CFUnit, then change the extends
	portion to net.sourceforge.cfunit.framework.TestCase

	This is a base test component for testing coldbox handlers. All you need
	to do is add the extends portions of your test cases to this base test
	and you will have a coldbox handler test.  The setup method will need
	to be changed in order to match your application path.

	MODIFY:
	1) instance.AppMapping : To point to your application relative from the root
	                         or via CF Mappings.
	2) instance.ConfigMapping : The expanded path location of your coldbox configuration file.

	OPTIONAL:
	3) Execute the on App start handler. You will need to fill out the name
	   of the Application Start Handler to be executed.

---------------------------------------------------------------------->
<cfcomponent name="baseTest" extends="org.cfcunit.framework.TestCase" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
	variables.instance = structnew();
	instance.AppMapping = "";
	instance.ConfigMapping = "";
	instance.controller = "";
	</cfscript>

	<cffunction name="setUp" returntype="void" access="private">
		<cfscript>
		//Initialize ColdBox
		instance.controller = CreateObject("component", "coldbox.system.testcontroller").init( expandPath(instance.AppMapping) );
		instance.controller.getService("loader").setupCalls(instance.ConfigMapping,instance.AppMapping);

		//Create Initial Event Context
		setupRequest();
		//Clean up Initial Event Context due to MACH-II vars of the unit test framework.
		getRequestContext().clearCollection();
		</cfscript>
	</cffunction>

<!------------------------------------------- HELPERS ------------------------------------------->

	<!--- getter for AppMapping --->
	<cffunction name="getAppMapping" access="public" returntype="string" output="false" hint="Get the AppMapping">
		<cfreturn instance.AppMapping>
	</cffunction>
	
	<!--- setter for AppMapping --->
	<cffunction name="setAppMapping" access="public" output="false" returntype="void" hint="Set the AppMapping">
		<cfargument name="AppMapping" type="string" required="true"/>
		<cfset instance.AppMapping = arguments.AppMapping/>
	</cffunction>

	<!--- getter for ConfigMapping --->
	<cffunction name="getConfigMapping" access="public" returntype="string" output="false" hint="Get the ConfigMapping">
		<cfreturn instance.ConfigMapping>
	</cffunction>
	
	<!--- setter for ConfigMapping --->
	<cffunction name="setConfigMapping" access="public" output="false" returntype="void" hint="Set the ConfigMapping">
		<cfargument name="ConfigMapping" type="string" required="true"/>
		<cfset instance.ConfigMapping = arguments.ConfigMapping/>
	</cffunction>

	<!--- getter for controller --->
	<cffunction name="getcontroller" access="public" returntype="any" output="false" hint="Get a reference to the ColdBox controller">
		<cfreturn instance.controller>
	</cffunction>

	<!--- Get current request context --->
	<cffunction name="getRequestContext" access="public" output="false" returntype="any" hint="Get the event object">
		<cfreturn getController().getRequestService().getContext() >
	</cffunction>

	<!--- Setup a request context --->
	<cffunction name="setupRequest" access="public" output="false" returntype="void" hint="Setup a request with FORM/URL data">
		<cfset getController().getRequestService().requestCapture() >
	</cffunction>

	<!--- prepare request, execute request and retrieve request --->
	<cffunction name="execute" access="public" output="false" returntype="any" hint="Executes a framework lifecycle">
		<cfargument name="eventhandler" required="true" type="string" hint="">
		<cfscript>
			var handlerResults = "";
			var requestContext = "";
			
			//Setup the request Context with setup FORM/URL variables set in the unit test.
			setupRequest();
			
			//TEST EVENT EXECUTION
			handlerResults = getController().runEvent(eventhandler);
			
			//Return the correct event context.
			requestContext = getRequestContext();
			
			//If we have results save
			if ( isDefined("handlerResults") ){
				requestContext.setValue("cbox_handler_results", handlerResults);
			}
			
			return requestContext;
		</cfscript>
	</cffunction>
	
	<!--- Announce Interception --->
	<cffunction name="announceInterception" access="public" returntype="void" hint="Announce an interception to the system." output="false" >
		<cfargument name="state" 			required="true"  type="string" hint="The interception state to execute">
		<cfargument name="interceptData" 	required="false" type="struct" default="#structNew()#" hint="A data structure used to pass intercepted information.">
		<cfset getController().getInterceptorService().processState(argumentCollection=arguments)>
	</cffunction>


<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="dump" access="private" hint="Facade for cfmx dump" returntype="void">
		<cfargument name="var" required="yes" type="any">
		<cfdump var="#var#">
	</cffunction>
	<cffunction name="abort" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>

</cfcomponent>