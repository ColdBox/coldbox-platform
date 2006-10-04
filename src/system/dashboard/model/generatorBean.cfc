<cfcomponent output="false" displayname="generatorBean" hint="I model the generation of an application.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- Constructor --->
	<cfset variables.instance = structnew()>
	<cfset variables.instance.basic_step = structnew()>
	<cfset variables.instance.basic_step = structnew()>
	<cfset variables.instance.basic_step = structnew()>
	<cfset variables.instance.basic_step = structnew()>
	
	<!--- ************************************************************* --->
	
	<cffunction name="init" access="public" returntype="generatorBean" output="false">
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
		
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	

</cfcomponent>