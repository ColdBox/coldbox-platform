<cfcomponent name="ehProxy" output="false">

	<!--- ************************************************************* --->

	<cffunction name="getIntroArrays" access="public" output="false" returntype="Array">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext">
		<cfscript>
		//Just return an array
		var myArray = ArrayNew(1);
		
		myArray[1] = "Hola";
		myArray[2] = "Hello";
		myArray[3] = "Bom Dia";
		myArray[4] = "Ciao";
		
		//Log my call
		getPlugin("Logger").logEntry("information","My intro arrays called from flex.");
		
		return myArray;
		</cfscript>
	</cffunction>
	
	<cffunction name="getIntroArraysCollection" access="public" output="false" returntype="void">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext">
		<cfscript>
		//Just return an array
		var myArray = ArrayNew(1);
		var rc = event.getCollection();
				
		myArray[1] = "Hola";
		myArray[2] = "Hello";
		myArray[3] = "Bom Dia";
		myArray[4] = "Ciao";
		
		//Log my call
		getPlugin("Logger").logEntry("information","My intro arrays called from flex.");

		//Place in collection to return
		rc.myArray = myArray;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->

	<cffunction name="getIntroStructure" access="public" output="false" returntype="any">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext">
		<cfscript>
		var introStruct = structnew();
		
		introStruct.english = "Hello";
		introStruct.spanish = "Hola";
		introStruct.italian = "Ciao";
		
		getPlugin("Logger").logEntry("information","My intro structures called from flex.");
		
		return introStruct;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->
	
	<!--- jsondata --->
	<cffunction name="jsondata" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext" required="yes">
	    <cfset var test = structnew()>
	    
	    <cfset test.name = "Luis Majano">
	    <cfset test.id = createUUID()>
	    <cfset test.date = now()>
	    
	    <cfset event.renderData(type="JSON",data=test)> 
	</cffunction>
	
	<!--- jsondata --->
	<cffunction name="plaindata" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext" required="yes">

	    <cfset event.renderData(type="plain",data='<h2>Hello Luis</h2>')> 
	</cffunction>
	
	<cffunction name="xmldata" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext" required="yes">
		 <cfset var test = structnew()>
	    
	    <cfset test.name = "Luis Majano">
	    <cfset test.id = createUUID()>
	    <cfset test.date = now()>
	    
	    <cfset event.renderData(type="wddx",data=test)> 
	</cffunction>
		
</cfcomponent>