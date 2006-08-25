<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description : 			
		
Modification History:
Sep/25/2005 - Luis Majano
	-Created the template.
----------------------------------------------------------------------->
<cfcomponent name="ehGeneral" extends="coldbox.system.eventhandler">

	<!--- ************************************************************* --->
	<cffunction name="init" access="public" returntype="Any">
		<cfset super.init()>
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