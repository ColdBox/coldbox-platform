<cfcomponent output="false" displayname="settings" hint="I am the Dashboard settings model.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- Constructor --->
	<cfset variables.instance = structnew()>
	<cfset variables.instance.hashAlg = "SHA-384">
	<cfset variables.instance.settingsFilePath = ExpandPath("config/settings.xml.cfm")>
	<cfset variables.instance.rolloversFilePath = ExpandPath("config/rollovers.xml")>
	<cfset variables.instance.qSettings = queryNew("")>
	<cfset variables.instance.qRollovers = queryNew("pagesection,rolloverid, text","varchar,varchar,varchar")>
	<cfset variables.instance.xmlObj = "">
	
	<!--- ************************************************************* --->
	
	<cffunction name="init" access="public" returntype="settings" output="false">
		<cfset parseSettings()>
		<cfset parseRollovers()>
		<cfreturn this>
	</cffunction>
	
	<!--- ************************************************************* --->
		
<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->
	
	<cffunction name="changeProxySettings" access="public" returntype="void" output="false">
		<cfargument name="proxyflag" 		required="true" type="boolean">
		<cfargument name="proxyserver" 		required="false" type="string" default="">
		<cfargument name="proxyuser" 		required="false" type="string" default="">
		<cfargument name="proxypassword" 	required="false" type="string" default="">
		<cfargument name="proxyport" 		required="false" type="string" default="">		
		<!--- Save Proxy Settings --->	
		<cfset instance.xmlObj.xmlRoot.proxyflag.xmlText = arguments.proxyflag>
		<cfset instance.xmlObj.xmlRoot.proxyserver.xmlText = arguments.proxyserver>
		<cfset instance.xmlObj.xmlRoot.proxyuser.xmlText = arguments.proxyuser>
		<cfset instance.xmlObj.xmlRoot.proxypassword.xmlText = arguments.proxypassword>
		<cfset instance.xmlObj.xmlRoot.proxyport.xmlText = arguments.proxyport>
		<!--- Savce XML --->
		<cfset saveSettings()>
		<!--- Parse Settings Again --->
		<cfset instance.qSettings = queryNew("")>
		<cfset parseSettings()>
		<!--- Save XML --->
		<cfset saveSettings()>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="changePassword" access="public" returntype="struct" output="false">
		<!--- ************************************************************* --->
		<cfargument name="oldpassword"  type="string" required="true">
		<cfargument name="newpassword"  type="string" required="true">
		<cfargument name="newpassword2" type="string" required="true">
		<!--- ************************************************************* --->
		<cfset var rtnStruct = structnew()>
		<cfset var x = 1>
		<cfset rtnStruct.results = false>
		<cfset rtnStruct.message = "">
		<cfif not validatePassword(arguments.oldpassword)>
			<cfset rtnStruct.message = "Old password is invalid.">
		<cfelseif compare(arguments.newpassword, arguments.newpassword2) neq 0>
			<cfset rtnStruct.message = "New password and confirmation password are not the same.">
		<cfelse>
			<!--- Save Password --->	
			<cfset instance.xmlObj.xmlRoot.password.xmlText = hash(arguments.newpassword, instance.hashAlg)>
			<!--- Savce XML --->
			<cfset saveSettings()>
			<!--- Parse Settings Again --->
			<cfset instance.qSettings = queryNew("")>
			<cfset parseSettings()>
			<!--- Set Results --->
			<cfset rtnStruct.results = true>
		</cfif>
		<cfreturn rtnStruct>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="validatePassword" access="public" returntype="boolean" output="false">
		<!--- ************************************************************* --->
		<cfargument name="password" required="true" type="string">
		<!--- ************************************************************* --->
		<cfset var qry = "">
		<cfquery name="qry" dbtype="query">
		select password
		from   instance.qSettings
		where  password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(arguments.password,instance.hashAlg)#">
		</cfquery>
		<cfif qry.recordcount>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
	<!--- ************************************************************* --->

	<!--- ************************************************************* --->
	
	<cffunction name="getRollovers" access="public" returntype="query" output="false">
		<cfreturn instance.qRollovers>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="getSettings" access="public" returntype="query" output="false">
		<cfreturn instance.qSettings>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- ************************************************************* --->
		
	<cffunction name="parseSettings" access="private" returntype="void" output="false">
		<cfset var xmlString = "">
		<cfset var xmlChildren = ArrayNew(1)>
		<cfset var x = 1>
		<!--- Read File --->
		<cffile action="read" file="#instance.settingsFilePath#" variable="xmlString">
		<!--- Parse File --->
		<cfset instance.xmlObj = XMLParse(trim(xmlString))>
		<cfset xmlChildren = instance.xmlObj.xmlRoot.XMLChildren>
		<!--- Create Query --->
		<cfscript>
			QueryAddRow(instance.qSettings,1);
			for (x=1; x lte ArrayLen(xmlChildren); x=x+1){
				QueryAddColumn(instance.qSettings, trim(xmlChildren[x].xmlName), trim(xmlChildren[x].xmlAttributes["type"]) , ArrayNew(1));				
				QuerySetCell(instance.qSettings, trim(xmlChildren[x].xmlName), trim(xmlChildren[x].xmlText),1);
			}
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
		
	<cffunction name="saveSettings" access="private" returntype="void" output="false">
		<!--- Save the File --->
		<cffile action="write" file="#instance.settingsFilePath#" output="#toString(instance.xmlObj)#">
	</cffunction>
	
	<!--- ************************************************************* --->

	<cffunction name="parseRollovers" access="private" returntype="void" output="false">
		<cfset var xmlString = "">
		<cfset var xmlChildren = ArrayNew(1)>
		<cfset var xmlObj = "">
		<cfset var x = 1>
		<cfset var j = 1>
		<!--- Read File --->
		<cffile action="read" file="#instance.rolloversFilePath#" variable="xmlString">
		<!--- Parse File --->
		<cfset xmlObj = XMLParse(trim(xmlString))>
		<!--- Create Query --->
		<cfscript>
			for (x=1; x lte ArrayLen(xmlObj.rollovers.section); x=x+1){
				//Loop Through Rollovers
				for(j=1; j lte ArrayLen(xmlObj.rollovers.section[x].XMLChildren) ; j=j+1){
					QueryAddRow(instance.qRollovers,1);
					QuerySetCell(instance.qRollovers, "pagesection", trim(xmlObj.rollovers.section[x].XMLAttributes.id) );
					QuerySetCell(instance.qRollovers, "rolloverid", trim(xmlObj.rollovers.section[x].xmlChildren[j].xmlAttributes.id) );
					QuerySetCell(instance.qRollovers, "text", trim(xmlObj.rollovers.section[x].xmlChildren[j].xmlText) );
				}				
			}
		</cfscript>
	</cffunction>
		
	<!--- ************************************************************* --->

</cfcomponent>