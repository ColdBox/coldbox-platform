<cfcomponent output="false">

	<!--- configure --->
    <cffunction name="configure" output="false" access="public">
    	<cfargument name="wireBox" 		type="any"/>
		<cfargument name="properties" 	type="struct"/>
		<cfscript>
			variables.wireBox = arguments.wireBox;
			variables.properties = arguments.properties;
			
			variables.log = variables.wireBox.getLogBox().getLogger(this);
		</cfscript>
    </cffunction>

	<!--- afterInjectorConfiguration --->
    <cffunction name="afterInjectorConfiguration" output="false" access="public" returntype="any" hint="">
    	<cfargument name="interceptData" type="struct"/>		
		<cfset log.info("#properties.name# -> afterInjectorConfiguration called", arguments.interceptData.toString())>
    </cffunction>

	<!--- beforeObjectCreation --->
    <cffunction name="beforeInstanceCreation" output="false" access="public" returntype="any" hint="">
    	<cfargument name="interceptData" type="struct"/>
		<cfset log.info("#properties.name# -> beforeInstanceCreation called", arguments.interceptData.toString())>
    </cffunction>
	
	<!--- afterObjectCreation --->
    <cffunction name="afterInstanceCreation" output="false" access="public" returntype="any" hint="">
    	<cfargument name="interceptData" type="struct"/>
		<cfset log.info("#properties.name# -> afterInstanceCreation called", arguments.interceptData.toString())>
    </cffunction>
	

</cfcomponent>