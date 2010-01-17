<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	 :	Sana Ullah
Date     :	October 15, 2007
Description :
	This is a plugin that enables the setting/getting of permanent variables in	the cookie scope.
	Usage: 
	set		controller.getPlugin("CookieStorage").setVar(name="name1",value="hello1",expires="11")
	get		controller.getPlugin("CookieStorage").getVar(name="name1")
Modification History: March 23,2008 Added new feature to encrypt/decrypt cookie value

----------------------------------------------------------------------->
<cfcomponent name="CookieStorage"
			 hint="Cookie Storage plugin. It provides the user with a mechanism for permanent data storage using the cookie scope."
			 extends="coldbox.system.Plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="CookieStorage" output="false" hint="Constructor.">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.web.Controller">
		<!--- ************************************************************* --->
		<cfscript>	
			super.Init(arguments.controller);
			
			/* Plugin Properties */
			setpluginName("Cookie Storage");
			setpluginVersion("1.0");
			setpluginDescription("A permanent data storage plugin.");
			setpluginAuthor("Sana Ullah");
			setpluginAuthorURL("http://www.coldbox.org");
			
			/* set CFML engine encryption CF, BD, Railo*/
			setEncryptionAlgorithm("CFMX_COMPAT");
			setEncryptionKey("ColdBoxPlatform");
			setEncryption(false);
			setEncryptionEncoding("HEX");
			
			/* set defautl alogrithm according to CFML engine */
			if(controller.getCFMLEngine().getEngine() EQ 'BLUEDRAGON'){
				setEncryptionAlgorithm("BD_DEFAULT");
			}
			
			/* Do we Encrypt. */
			if(settingExists('CookieStorage_encryption') and isBoolean(getSetting('CookieStorage_encryption'))){
				setEncryption(getSetting('CookieStorage_encryption'));
			}
			/* Override the Seed if sent in. */
			if(settingExists('CookieStorage_encryption_seed') and len(getSetting('CookieStorage_encryption_seed'))){
				setEncryptionKey(getSetting('CookieStorage_encryption_seed'));
			}
			/* Override the Algorithm if used. */
			if(settingExists('CookieStorage_encryption_algorithm') and len(getSetting('CookieStorage_encryption_algorithm'))){
				setEncryptionAlgorithm(getSetting('CookieStorage_encryption_algorithm'));
			}
			
			/* Return Instance. */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Set A Cookie --->
	<cffunction name="setVar" access="public" returntype="void" hint="Set a new permanent variable." output="false">
		<!--- ************************************************************* --->
		<cfargument name="name"  	type="string" 	required="true"  hint="The name of the variable.">
		<cfargument name="value" 	type="any"    	required="true"  hint="The value to set in the variable, simple, array, query or structure.">
		<cfargument name="expires"	type="numeric"	required="false"	default="0"	hint="Cookie Expire in number of days. [default cookie is session only = 0 days]">
		<cfargument name="secure"	type="boolean"	required="false"	default="false"	hint="If browser does not support Secure Sockets Layer (SSL) security, the cookie is not sent. To use the cookie, the page must be accessed using the https protocol.">
		<cfargument name="path"		type="string"	required="false"	default=""		hint="URL, within a domain, to which the cookie applies; typically a directory. Only pages in this path can use the cookie. By default, all pages on the server that set the cookie can access the cookie.">
		<cfargument name="domain"	type="string"	required="false"	default=""		hint="Domain in which cookie is valid and to which cookie content can be sent from the user's system.">
		<!--- ************************************************************* --->
		<cfset var tmpVar	= "">
		<cfset var args		= StructNew()>
		
		<!--- Test for simple mode --->
		<cfif isSimpleValue(arguments.value)>
			<cfset tmpVar = arguments.value>
		<cfelse>
			<!--- Wddx variable --->
			<cfwddx action="cfml2wddx" input="#arguments.value#" output="tmpVar">
		</cfif>
		
		<!--- Encryption? --->
		<cfif getEncryption()>
			<cfset tmpVar = EncryptIt(tmpVar)>		
		</cfif>
		
		<!--- Store cookie with expiration info --->
		<cfset args["name"]		= uCase(arguments.name) />
		<cfset args["value"]	= tmpVar />
		<cfset args["secure"]	= arguments.secure />
		
		<cfif arguments.expires GT 0>
			<cfset args["expires"] = arguments.expires />
		</cfif>	
		
		<!--- Store cookie with expiration info --->
		<cfif len(arguments.path) GT 0 and not len(arguments.domain) GT 0>
			<cfthrow type="CookieStorage.MissingDomainArgument" message="If you specify path, you must also specify domain.">
		<cfelseif len(arguments.path) GT 0 and len(arguments.domain) GT 0>
			<cfset args["path"]		= arguments.path />
			<cfset args["domain"]	= arguments.domain />
		<cfelseif len(arguments.domain)>
			<cfset args["domain"]	= arguments.domain />
		</cfif>
		
		<cfcookie attributeCollection="#args#" />
	</cffunction>

	<!--- Get a Cookie Var --->
	<cffunction name="getVar" access="public" returntype="any" hint="Get a new permanent variable. If the cookie does not exist. The method returns blank." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" 		type="string"  required="true" 		hint="The variable name to retrieve.">
		<cfargument  name="default"  	type="any"     required="false"  	hint="The default value to set. If not used, a blank is returned." default="">
		<!--- ************************************************************* --->
		<cfset var wddxVar = "">
		<cfset var rtnVar = "">
		
		<cfif exists(arguments.name)>
			<!--- Get value --->
			<cfset rtnVar = cookie[uCase(arguments.name)]>
			
			<!--- Decrypt? --->
			<cfif getEncryption() and rtnVar.length()>
				<cfset rtnVar = DecryptIt(rtnVar)>
			</cfif>
			
			<cfif isWDDX(rtnVar)>
				<!--- Unwddx packet --->
				<cfwddx action="wddx2cfml" input="#rtnVar#" output="wddxVar">
				<cfset rtnVar = wddxVar>
			</cfif>
		<cfelse>
			<!--- Return the default value --->
			<cfset rtnVar = arguments.default>
		</cfif>
		<!--- Return Var --->
		<cfreturn rtnVar>
	</cffunction>

	<!--- Check if a cookie value exists --->
	<cffunction name="exists" access="public" returntype="boolean" hint="Checks wether the permanent variable exists." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfreturn structKeyExists(cookie,uCase(arguments.name))>
	</cffunction>

	<!--- Delete a Cookie Value --->
	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent cookie var." output="false">
		<!--- ************************************************************* --->
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<!--- ************************************************************* --->
		<cfif exists(arguments.name)>
			<cfcookie name="#arguments.name#" expires="NOW" value='NULL'>
			<cfset structdelete(cookie, arguments.name)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
	<!--- Get/Set Encryption Key --->
	<cffunction name="getEncryptionKey" access="public" output="false" returntype="string" hint="Get EncryptionKey">
		<cfreturn instance.EncryptionKey/>
	</cffunction>
	<cffunction name="setEncryptionKey" access="public" output="false" returntype="void" hint="Set EncryptionKey">
		<cfargument name="EncryptionKey" type="string" required="true"/>
		<cfset instance.EncryptionKey = arguments.EncryptionKey/>
	</cffunction>

	<!--- Get/Set Encryption Algorithm --->
	<cffunction name="getEncryptionAlgorithm" access="public" output="false" returntype="string" hint="Get EncryptionAlgorithm">
		<cfreturn instance.EncryptionAlgorithm/>
	</cffunction>
	<cffunction name="setEncryptionAlgorithm" access="public" output="false" returntype="void" hint="Set EncryptionAlgorithm">
		<cfargument name="EncryptionAlgorithm" type="string" required="true"/>
		<cfset instance.EncryptionAlgorithm = arguments.EncryptionAlgorithm/>
	</cffunction>
	
	<!--- Get/set Encrypting values or not. --->
	<cffunction name="getEncryption" access="public" output="false" returntype="boolean" hint="Get Encryption">
		<cfreturn instance.Encryption/>
	</cffunction>
	<cffunction name="setEncryption" access="public" output="false" returntype="void" hint="Set Encryption">
		<cfargument name="Encryption" type="boolean" required="true"/>
		<cfset instance.Encryption = arguments.Encryption/>
	</cffunction>
	
	<!--- Encryption Encoding --->
	<cffunction name="getEncryptionEncoding" access="public" output="false" returntype="string" hint="Get EncryptionEncoding">
		<cfreturn instance.EncryptionEncoding/>
	</cffunction>	
	<cffunction name="setEncryptionEncoding" access="public" output="false" returntype="void" hint="Set EncryptionEncoding">
		<cfargument name="EncryptionEncoding" type="string" required="true"/>
		<cfset instance.EncryptionEncoding = arguments.EncryptionEncoding/>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Encrypt Data --->
	<cffunction name="EncryptIt" access="private" returntype="Any" hint="Return encypted value" output="false">
		<cfargument name="encValue" hint="string to be encrypted" required="yes" type="string" />
		<cfreturn encrypt(arguments.encValue,getEncryptionKey(),getEncryptionAlgorithm(),getEncryptionEncoding()) />		
	</cffunction>
	
	
	<!--- Decrypt Data --->
	<cffunction name="DecryptIt" access="private" returntype="Any" hint="Return decrypted value" output="false">
		<cfargument name="decValue" hint="string to be decrypted" required="yes" type="string" />
		<cfreturn decrypt(arguments.decValue,getEncryptionKey(),getEncryptionAlgorithm(),getEncryptionEncoding()) />		
	</cffunction>
	
</cfcomponent>
