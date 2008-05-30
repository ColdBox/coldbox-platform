<cfcomponent name="ehProxy" extends="coldbox.system.eventhandler" output="false">

	<!--- ************************************************************* --->

	<cffunction name="getIntroArrays" access="public" output="false" returntype="Array">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfscript>
		//Just return an array
		var myArray = ArrayNew(1);
		
		myArray[1] = "Hola";
		myArray[2] = "Hello";
		myArray[3] = "Bom Dia";
		myArray[4] = "Ciao";
		
		//Log my call
		getPlugin("logger").logEntry("information","My intro arrays called from flex.");
		
		return myArray;
		</cfscript>
	</cffunction>
	
	<cffunction name="getIntroArraysCollection" access="public" output="false" returntype="void">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfscript>
		//Just return an array
		var myArray = ArrayNew(1);
		var rc = event.getCollection();
				
		myArray[1] = "Hola";
		myArray[2] = "Hello";
		myArray[3] = "Bom Dia";
		myArray[4] = "Ciao";
		
		//Log my call
		getPlugin("logger").logEntry("information","My intro arrays called from flex.");

		//Place in collection to return
		rc.myArray = myArray;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->

	<cffunction name="getIntroStructure" access="public" output="false" returntype="any">
		<cfargument name="Event" type="coldbox.system.beans.requestContext">
		<cfscript>
		var introStruct = structnew();
		
		introStruct.english = "Hello";
		introStruct.spanish = "Hola";
		introStruct.italian = "Ciao";
		
		getPlugin("logger").logEntry("information","My intro structures called from flex.");
		
		return introStruct;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->
		
</cfcomponent>