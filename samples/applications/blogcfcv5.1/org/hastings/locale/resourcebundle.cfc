<!---
	This code is a modified version of the resourceBundle.cfc by Paul Hastings.
	You can find the original code + examples here: 
	
	http://www.sustainablegis.com/unicode/resourceBundle/rb.cfm
	
	My modifications were to simply add a few var statements to rbLocale and
	to add a few more methods, as well as adding persistance to the CFC.
--->

<cfcomponent displayname="resourceBundle" hint="Reads and parses resource bundle per locale">
	
	<cffunction name="getResource" access="public" output="false" returnType="string"
				hint="Returns bundle.X, if it exists, and optionally wraps it ** if debug mode.">
		<cfargument name="resource" type="string" required="true">
		<cfset var val = "">
		
		<cfif not isDefined("variables.resourceBundle")>
			<cfthrow message="Fatal error: resource bundle not loaded.">
		</cfif>

		<cfif not structKeyExists(variables.resourceBundle, arguments.resource)>
			<cfset val = "_UNKNOWNTRANSLATION_">
		<cfelse>
			<cfset val = variables.resourceBundle[arguments.resource]>
		</cfif>

		<cfif isDebugMode()>
			<cfset val = "*** #val# ***">
		</cfif>
		
		<cfreturn val>
		
	</cffunction>
	
	<cffunction name="getResourceBundle" access="public" output="No" hint="reads and parses resource bundle per locale" returntype="struct">
		<cfargument name="rbFile" required="Yes" type="string" hint="This must be the path + filename UP to but NOT including the locale. We auto-add .properties to the end.">
		<cfargument name="rbLocale" required="No" type="string" default="en_US">
		<cfset var resourceBundle=structNew()>
		<cfset var thisRBfile="">
		<cfset var fallbackLocale="en_US"> <!--- might change to reflect your locale --->
		<cfset var resourceBundleFile = "">
		<cfset var rbIndx = "">

		<!--- Translate rbFile --->
		<cfset arguments.rbFile = arguments.rbFile & "_#arguments.rbLocale#.properties">		
		<cfif NOT fileExists(arguments.rbFile)> 
			<cfthrow message="Fatal error: resource bundle #arguments.rbFile# not found.">
		</cfif> 
				
		<cffile action="read" file="#arguments.rbFile#" variable="resourceBundleFile" charset="utf-8">
		
		<cfloop index="rbIndx" list="#resourceBundleFile#" delimiters="#chr(10)#">
			<cfif len(trim(rbIndx)) and left(rbIndx,1) NEQ "##">
				<cfset resourceBundle[trim(listFirst(rbIndx,"="))] = trim(listRest(rbIndx,"="))>
			</cfif>
		</cfloop>
		
		<cfreturn resourceBundle>
		
	</cffunction> 

	<cffunction name="loadResourceBundle" access="public" output="false" returnType="void"
				hint="Loads a bundle">
		<cfargument name="rbFile" required="Yes" type="string" hint="This must be the path + filename UP to but NOT including the locale. We auto-add .properties to the end.">
		<cfargument name="rbLocale" required="No" type="string" default="en_US">
		<cfset variables.resourceBundle = getResourceBundle(arguments.rbFile, arguments.rbLocale)>
	</cffunction>
	
</cfcomponent>