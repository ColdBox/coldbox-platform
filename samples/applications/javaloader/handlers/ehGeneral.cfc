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
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfscript>
		//Create the JavaLoader with the helloworld.jar file. You can send one path or a comma delimited list.
		var stime = getTickcount();
		//Since caching is enabled for plugins, you will need to set it up only.
		getPlugin("JavaLoader").setup("includes/helloworld.jar");
		getPlugin("logger").tracer("My Java Loader has been Loaded into the application scope. It took #stime-gettickcount()# ms");
		</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	<cffunction name="dspHello" access="public" returntype="void" output="false">
		<cfargument name="requestContext" type="coldbox.system.beans.requestContext">
		<cfscript>
		//Load the hello world class
		requestContext.setvalue("HelloWorldObj", getPlugin("javaLoader").create("HelloWorld").init());
		getPlugin("logger").tracer("MyLoader just finished loading the HelloWorld Class object.");
		requestContext.setView("vwHello");
	</cfscript>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>