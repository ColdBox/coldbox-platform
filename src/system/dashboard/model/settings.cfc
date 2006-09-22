<cfcomponent output="false" displayname="settings" hint="I am the Dashboard settings model.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- Constructor --->
	<cfset variables.instance = structnew()>
	<cfset variables.instance.hashAlg = "SHA-384">
	<cfset variables.instance.settingsFilePath = ExpandPath("config/settings.xml.cfm")>
	<cfset variables.instance.qSettings = queryNew("")>
	<cfset variables.instance.xmlObj = "">
	
	<!--- ************************************************************* --->
	
	<cffunction name="init" access="public" returntype="settings" output="false">
		<cfset parseSettings()>
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
		<cfquery name="qry" dbtype="query">
		update instance.qSettings
		   set proxyflag = <cfqueryparam cfsqltype="cf_sql_bit" value="">,
		       proxyserver = <cfqueryparam cfsqltype="cf_sql_varchar" value="">,
		       proxyuser = <cfqueryparam cfsqltype="cf_sql_varchar" value="">,
		       proxypassword = <cfqueryparam cfsqltype="cf_sql_varchar" value="">,
		       proxyport = <cfqueryparam cfsqltype="cf_sql_varchar" value="">,
		</cfquery>
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
		<cfset rtnStruct.results = false>
		<cfset rtnStruct.message = "">
		<cfif not validatePassword(arguments.oldpassword)>
			<cfset rtnStruct.message = "Old password is invalid.">
		<cfelseif compare(arguments.newpassword, arguments.newpassword2) neq 0>
			<cfset rtnStruct.message = "New password and confirmation password are not the same.">
		<cfelse>
			<!--- Save Password --->	
			<cfquery name="qry" dbtype="query">
			update instance.qSettings
			   set password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#hash(arguments.newpassword,instance.hashAlg)#">
			</cfquery>
			<!--- Savce XML --->
			<cfset saveSettings()>
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
		<cfset var xmlString = "">
		<cfset var setting = "">
		<cfset var i = "">
		<!--- Flatten the query --->
		<cfloop from="1" to="#listLen(instance.qSettings.columnList)#" index="i">
			<cfset setting = lcase(listgetAt(instance.qSettings.columnList,i))>
			<cfset instance.xmlObj.settings[setting].xmlText = instance.qSettings[setting][1]>
		</cfloop>
		<!--- Write File --->
		<cffile action="write" file="#instance.settingsFilePath#" output="#toString(instance.xmlObj)#">
	</cffunction>
	
	<!--- ************************************************************* --->

</cfcomponent>