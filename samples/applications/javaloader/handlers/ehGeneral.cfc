<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	September 25, 2005
Description : 			
		
Modification History:
Sep/25/2005 - Luis Majano
	-Created the template.
----------------------------------------------------------------------->
<cfcomponent name="ehGeneral" extends="coldbox.system.eventhandler" output="false">

	<!--- ************************************************************* --->
	<cffunction name="onAppStart" access="public" returntype="void" output="false">
		<cfscript>
		//Create the JavaLoader with the helloworld.jar file. You can send one path or a comma delimited list.
		var stime = getTickcount();
		application.myLoader = getPlugin("JavaLoader").setup("includes/helloworld.jar");
		getPlugin("logger").tracer("My Java Loader has been Loaded into the application scope. It took #stime-gettickcount()# ms");
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspHello" access="public" returntype="void" output="false">
		<cfscript>
		//Load the hello world class
		setvalue("HelloWorldObj", application.myLoader.create("HelloWorld").init());
		getPlugin("logger").tracer("MyLoader just finished loading the HelloWorld Class object.");
		setView("vwHello");
	</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>