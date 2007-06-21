<!-----------------------------------------------------------------------
Template : baseTest.cfc
Author 	 : luis5198
Date     : 5/25/2007 5:59:04 PM
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

Modification History:
5/25/2007 - Created Template
---------------------------------------------------------------------->
<cfcomponent name="baseTest" extends="org.cfcunit.framework.TestCase" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
	variables.instance = structnew();
	variables.instance.AppMapping = "";
	variables.instance.ConfigMapping = "";
	variables.instance.controller = "";
	</cfscript>

	<cffunction name="setUp" returntype="void" access="private">
		<cfscript>
		//Initialize ColdBox
		instance.controller = CreateObject("component", "coldbox.system.testcontroller").init();
		instance.controller.getService("loader").configLoader(instance.ConfigMapping,instance.AppMapping);
		instance.controller.getService("loader").registerHandlers();

		//Create Initial Event Context
		setupRequest();
		//Clean up Initial Event Context due to MACH-II vars of the unit test framework.
		getRequestContext().clearCollection();
		</cfscript>
	</cffunction>

<!------------------------------------------- HELPERS ------------------------------------------->

	<!--- getter for AppMapping --->
	<cffunction name="getAppMapping" access="public" returntype="string" output="false">
		<cfreturn instance.AppMapping>
	</cffunction>
	
	<cffunction name="setAppMapping" access="public" output="false" returntype="void" hint="Set AppMapping">
		<cfargument name="AppMapping" type="string" required="true"/>
		<cfset instance.AppMapping = arguments.AppMapping/>
	</cffunction>

	<!--- getter for ConfigMapping --->
	<cffunction name="getConfigMapping" access="public" returntype="string" output="false">
		<cfreturn instance.ConfigMapping>
	</cffunction>
	
	<cffunction name="setConfigMapping" access="public" output="false" returntype="void" hint="Set ConfigMapping">
		<cfargument name="ConfigMapping" type="string" required="true"/>
		<cfset instance.ConfigMapping = arguments.ConfigMapping/>
	</cffunction>

	<!--- getter for controller --->
	<cffunction name="getcontroller" access="public" returntype="any" output="false">
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
		//Setup the request Context with setup FORM/URL variables set in the unit test.
		setupRequest();
		//TEST EVENT EXECUTION
		getController().runEvent(eventhandler);
		//Return the correct event context.
		return getRequestContext();
		</cfscript>
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