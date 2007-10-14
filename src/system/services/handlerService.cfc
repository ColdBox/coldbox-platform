<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/10/2007
Description :
	This is the main ColdBox handler service.
----------------------------------------------------------------------->
<cfcomponent name="handlerService" extends="baseService" hint="This is the main Coldbox Handler service" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="handlerService" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			/* Setup The Controller. */
			setController(arguments.controller);
			
			/* Return Service */			
			return this;
		</cfscript>
	</cffunction>



<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Handler Registration System --->
	<cffunction name="registerHandlers" access="public" returntype="void" hint="I register your application's event handlers" output="false">
		<cfscript>
		var HandlersPath = controller.getSetting("HandlersPath");
		var HandlerArray = Arraynew(1);

		//Check for Handlers Directory Location
		if ( not directoryExists(HandlersPath) )
			controller.throw("The handlers directory: #handlerspath# does not exist please check your application structure or your Application Mapping.","","Framework.loaderService.HandlersDirectoryNotFoundException");

		//Get recursive Array listing
		HandlerArray = recurseListing(HandlerArray, HandlersPath, HandlersPath);

		//Verify it
		if ( ArrayLen(HandlerArray) eq 0 )
			controller.throw("No handlers were found in: #HandlerPath#. So I have no clue how you are going to run this application.","","Framework.loaderService.NoHandlersFoundException");

		//Sort The Array
		ArraySort(HandlerArray,"text");
		
		//Set registered Handlers
		controller.setSetting("RegisteredHandlers",arrayToList(HandlerArray));
		</cfscript>
	</cffunction>


<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- Recursive Registration of Handler Directories --->
	<cffunction name="recurseListing" access="private" output="false" returntype="array" hint="Recursive creation of handlers in a directory.">
		<!--- ************************************************************* --->
		<cfargument name="fileArray" 	type="array"  required="true">
		<cfargument name="Directory" 	type="string" required="true">
		<cfargument name="HandlersPath" type="string" required="true">
		<!--- ************************************************************* --->
		<cfscript>
		var oDirectory = CreateObject("java","java.io.File").init(arguments.Directory);
		var Files = oDirectory.list();
		var i = 1;
		var tempfile = "";
		var cleanHandler = "";

		//Loop Through listing if any files found.
		for (; i lte arrayLen(Files); i=i+1 ){
			//get first reference as File Object
			tempFile = CreateObject("java","java.io.File").init(oDirectory,Files[i]);
			//Directory Check for recursion
			if ( tempFile.isDirectory() ){
				//recurse, directory found.
				arguments.fileArray = recurseListing(arguments.fileArray,tempFile.getPath(), arguments.HandlersPath);
			}
			else{
				//Filter only cfc's
				if ( listlast(tempFile.getName(),".") neq "cfc" )
					continue;
				//Clean entry by using Handler Path
				cleanHandler = replacenocase(tempFile.getAbsolutePath(),arguments.handlersPath,"","all");
				//Clean OS separators
				if ( controller.getSetting("OSFileSeparator",1) eq "/")
					cleanHandler = removeChars(replacenocase(cleanHandler,"/",".","all"),1,1);
				else
					cleanHandler = removeChars(replacenocase(cleanHandler,"\",".","all"),1,1);
				//Clean Extension
				cleanHandler = controller.getPlugin("Utilities").ripExtension(cleanhandler);
				//Add data to array
				ArrayAppend(arguments.fileArray,cleanHandler);
			}
		}
		return arguments.fileArray;
		</cfscript>
	</cffunction>

</cfcomponent>