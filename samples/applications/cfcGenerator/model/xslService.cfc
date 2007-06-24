<cfcomponent name="xslService">
	<cffunction name="init" access="public" output="false" returntype="xslService">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="configure" access="public" output="false" returntype="void">
		<cfargument name="dsn" required="true" type="string" />
		
		<cfset var separator = getOSFileSeparator() />
		<cfset variables.basePath = expandPath("./xsl/") />
		<cfset variables.dsn = arguments.dsn />
		<cfset variables.projectPath = variables.basePath & 'projects' & separator & variables.dsn & separator />
		<cfset readConfig() />
	</cffunction>
	
	<cffunction name="getComponents" access="public" output="false" returntype="array">
		<cfargument name="xmlTable" required="true" type="xml" />
		
		<cfset var i = 0 />
		<cfset var thisXSL = "" />
		<cfset var arrComponents = arrayNew(1) />
		<cfset var stComponent = "" />
		<!--- loop through cfc types --->
		<cfloop from="1" to="#arrayLen(variables.config.generator.xmlChildren)#" index="i">
			<cfset thisXSL = buildXSL(variables.config.generator.xmlChildren[i]) />
			<cfset stComponents = structNew() />
			<cfset stComponents['name'] = variables.config.generator.xmlChildren[i].xmlName />
			<cfset stComponents['content'] = xmlTransform(xmlTable,thisXSL) />
			<cfset arrayAppend(arrComponents,stComponents) />
		</cfloop>
		<cfreturn arrComponents />
	</cffunction>
	
	
	<cffunction name="readConfig" access="private" output="false" returntype="void">		
		<cfset var configXML = "" />
		
		<cfif fileExists(variables.projectPath & "yac.xml")>
			<cfset variables.usePath = variables.projectPath />
			<cffile action="read" file="#variables.projectPath & 'yac.xml'#" variable="configXML" charset="utf-8" />
		<cfelse>
			<cfset variables.usePath = variables.basePath />
			<cffile action="read" file="#variables.basePath & 'yac.xml'#" variable="configXML" charset="utf-8" />
		</cfif>
		<cfset variables.config = xmlParse(configXML) />
	</cffunction>
	
	<cffunction name="buildXSL" access="private" output="false" returntype="string">
		<cfargument name="typeXML" required="true" type="xml" />
		
		<cfset var returnXSL = "" />
		<cfset var innerXSL = "" />
		<cfset var tmpXSL = "" />
		<cfset var i = 0 />
		<cfset var separator = getOSFileSeparator() />
		
		<!--- loop through each include and append it to the inner XSL --->
		<cfloop from="1" to="#arrayLen(arguments.typeXML.xmlChildren)#" index="i">
			<cffile action="read" file="#variables.usePath & arguments.typeXML.xmlName & separator & arguments.typeXML.xmlChildren[i].xmlAttributes.file#" variable="tmpXSL" charset="utf-8" />
			<cfset innerXSL = innerXSL & chr(13) & chr(13) & tmpXSL />
		</cfloop>
		<!--- read the base template --->
		<cffile action="read" file="#variables.usePath & arguments.typeXML.xmlName & '.xsl'#" variable="tmpXSL" charset="utf-8" />
		<cfset returnXSL = replaceNoCase(trim(tmpXSL),"<!-- custom code -->",trim(innerXSL)) />
		<cfreturn trim(returnXSL) />
	</cffunction>
	
	<!--- code supplied by Luis Majano --->
	<cffunction name="getOSFileSeparator" access="public" returntype="any" output="false" hint="Get the operating system's file separator character">
        <cfscript>
        var objFile =  createObject("java","java.lang.System");
        return objFile.getProperty("file.separator");
        </cfscript>
    </cffunction>
</cfcomponent>