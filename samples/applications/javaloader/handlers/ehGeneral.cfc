<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description : 			
	General handler for my hello application. Please remember to extend 
	your event handler to the system eventhanlder using your colfusion
	mapping.

	example:
		Mapping: coldboxSamples
		
Modification History:
Sep/25/2005 - Luis Majano
	-Created the template.
----------------------------------------------------------------------->
<cfcomponent name="ehGeneral" extends="coldboxSamples.system.eventhandler">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="Any">
		<cfargument name="controller" required="yes" hint="The reference to the framework controller">	
		<cfset super.init(arguments.controller)>
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="onAppStart" access="public">
		<cfscript>
		//Create the JavaLoader with the helloworld.jar file. You can send one path or a comma delimited list.
		var stime = getTickcount();
		application.myLoader = getPlugin("JavaLoader").setup("includes/helloworld.jar");
		getPlugin("logger").tracer("My Loader has been Loaded into the application scope. It took #stime-gettickcount()# ms");
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspHello" access="public" returntype="string">
		<cfscript>
		//Load the hello world class
		setvalue("HelloWorldObj", application.myLoader.create("HelloWorld").init());
		getPlugin("logger").tracer("MyLoader just finished loading the HelloWorld Class object.");
		setView("vwHello");
	</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>