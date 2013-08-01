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
			 singleton="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="CookieStorage" output="false" hint="Constructor">
		<cfargument name="controller" type="any" required="true" colddoc:generic="coldbox.system.web.Controller">
		<cfscript>
			super.init(arguments.controller);

			// Plugin Properties
			setpluginName("Cookie Storage");
			setpluginVersion("2.0");
			setpluginDescription("A permanent data storage plugin.");
			setpluginAuthor("Sana Ullah & Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");

			// set CFML engine encryption CF, BD, Railo
			setEncryptionAlgorithm("CFMX_COMPAT");
			setEncryptionKey("ColdBoxPlatform");
			setEncryption(false);
			setEncryptionEncoding("HEX");

			// set defautl alogrithm according to CFML engine
			if(controller.getCFMLEngine().getEngine() EQ 'BLUEDRAGON'){
				setEncryptionAlgorithm("BD_DEFAULT");
			}
			// Do we Encrypt.
			if(settingExists('CookieStorage_encryption') and isBoolean(getSetting('CookieStorage_encryption'))){
				setEncryption(getSetting('CookieStorage_encryption'));
			}
			// Override the Seed if sent in.
			if(settingExists('CookieStorage_encryption_seed') and len(getSetting('CookieStorage_encryption_seed'))){
				setEncryptionKey(getSetting('CookieStorage_encryption_seed'));
			}
			// Override the Algorithm if used.
			if(settingExists('CookieStorage_encryption_algorithm') and len(getSetting('CookieStorage_encryption_algorithm'))){
				setEncryptionAlgorithm(getSetting('CookieStorage_encryption_algorithm'));
			}
			// Override the encoding if used.
			if(settingExists('CookieStorage_encryption_encoding') and len(getSetting('CookieStorage_encryption_encoding'))){
				setEncryptionEncoding(getSetting('CookieStorage_encryption_encoding'));
			}

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- setVar --->
	<cffunction name="setVar" access="public" returntype="void" hint="Set a new permanent variable in the storage." output="false">
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

		<!--- JSON storage --->
		<cfset tmpVar = serializeJSON( arguments.value )>

		<!--- Encryption? --->
		<cfif getEncryption()>
			<cfset tmpVar = encryptIt( tmpVar )>
		</cfif>

		<!--- Store cookie with expiration info --->
		<cfset args["name"]		= uCase( arguments.name ) />
		<cfset args["value"]	= tmpVar />
		<cfset args["secure"]	= arguments.secure />
		<cfif arguments.expires GT 0>
			<cfset args["expires"] = arguments.expires />
		</cfif>

		<!--- Store cookie with expiration info --->
		<cfif len( arguments.path ) GT 0 and not len( arguments.domain ) GT 0>
			<cfthrow type="CookieStorage.MissingDomainArgument" message="If you specify path, you must also specify domain.">
		<cfelseif len( arguments.path ) GT 0 and len( arguments.domain ) GT 0>
			<cfset args["path"]		= arguments.path />
			<cfset args["domain"]	= arguments.domain />
		<cfelseif len( arguments.domain )>
			<cfset args["domain"]	= arguments.domain />
		</cfif>

		<cfcookie attributeCollection="#args#" />
	</cffunction>

	<!--- getVar --->
	<cffunction name="getVar" access="public" returntype="any" hint="Get a new permanent variable. If the cookie does not exist. The method returns blank or use the default value argument" output="false">
		<cfargument  name="name" 		required="true" 	hint="The variable name to retrieve.">
		<cfargument  name="default"  	required="false"	default="" hint="The default value to set. If not used, a blank is returned.">
		<cfset var rtnVar = "">

		<cfif exists(arguments.name)>
			<!--- Get value --->
			<cfset rtnVar = cookie[ uCase( arguments.name ) ]>

			<!--- Decrypt? --->
			<cfif getEncryption() and len( rtnVar )>
				<cfset rtnVar = decryptIt( rtnVar )>
			</cfif>

			<!--- JSON Deserialize? --->
			<cfif isJSON( rtnVar )>
				<cfset rtnVar = deserializeJSON( rtnVar )>
			</cfif>
			<!--- Return it --->
			<cfreturn rtnVar>
		<cfelseif structKeyExists(arguments, "default")>
			<!--- Return the default value --->
			<cfreturn arguments.default>
		<cfelse>
			<cfthrow type="CookieStorage.InvalidKey" message="The key you requested: #arguments.name# does not exist">
		</cfif>
	</cffunction>

	<!--- exists --->
	<cffunction name="exists" access="public" returntype="boolean" hint="Checks wether the permanent variable exists in the storage" output="false">
		<cfargument  name="name" type="string" required="true" 	hint="The variable name to retrieve.">
		<cfreturn structKeyExists(cookie, uCase( arguments.name ) )>
	</cffunction>

	<!--- deleteVar --->
	<cffunction name="deleteVar" access="public" returntype="boolean" hint="Tries to delete a permanent cookie variable" output="false">
		<cfargument  name="name" 	type="string" required="true" 	hint="The variable name to retrieve.">
		<cfargument name="domain"	type="string" required="false"	default=""	hint="Domain in which cookie is valid and to which cookie content can be sent from the user's system.">
		<!--- ************************************************************* --->
		<cfset var args		= StructNew() />
		<cfif exists(arguments.name)>
			<cfset args["name"] 	= ucase(arguments.name) />
			<cfset args["expires"]	= "NOW" />
			<cfset args["value"]	= "" />
			<cfif len(arguments.domain)>
				<cfset args["domain"]	= arguments.domain />
			</cfif>
			<cfcookie attributeCollection="#args#">
			<cfset structdelete(cookie, arguments.name)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<!--- Get/Set Encryption Key --->
	<cffunction name="getEncryptionKey" access="public" output="false" returntype="string" hint="Get the EncryptionKey">
		<cfreturn instance.EncryptionKey/>
	</cffunction>
	<cffunction name="setEncryptionKey" access="public" output="false" returntype="void" hint="Set EncryptionKey for this storage">
		<cfargument name="EncryptionKey" type="string" required="true"/>
		<cfset instance.EncryptionKey = arguments.EncryptionKey/>
	</cffunction>

	<!--- Get/Set Encryption Algorithm --->
	<cffunction name="getEncryptionAlgorithm" access="public" output="false" returntype="string" hint="Get the EncryptionAlgorithm">
		<cfreturn instance.EncryptionAlgorithm/>
	</cffunction>
	<cffunction name="setEncryptionAlgorithm" access="public" output="false" returntype="void" hint="Set EncryptionAlgorithm for this storage">
		<cfargument name="EncryptionAlgorithm" type="string" required="true"/>
		<cfset instance.EncryptionAlgorithm = arguments.EncryptionAlgorithm/>
	</cffunction>

	<!--- Get/set Encrypting values or not. --->
	<cffunction name="getEncryption" access="public" output="false" returntype="boolean" hint="Get Encryption flag">
		<cfreturn instance.Encryption/>
	</cffunction>
	<cffunction name="setEncryption" access="public" output="false" returntype="void" hint="Set Encryption flag">
		<cfargument name="Encryption" type="boolean" required="true"/>
		<cfset instance.Encryption = arguments.Encryption/>
	</cffunction>

	<!--- Encryption Encoding --->
	<cffunction name="getEncryptionEncoding" access="public" output="false" returntype="string" hint="Get EncryptionEncoding value">
		<cfreturn instance.EncryptionEncoding/>
	</cffunction>
	<cffunction name="setEncryptionEncoding" access="public" output="false" returntype="void" hint="Set EncryptionEncoding value">
		<cfargument name="EncryptionEncoding" type="string" required="true"/>
		<cfset instance.EncryptionEncoding = arguments.EncryptionEncoding/>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Encrypt Data --->
	<cffunction name="encryptIt" access="private" returntype="any" hint="Return encrypted value" output="false">
		<cfargument name="encValue" hint="string to be encrypted" required="true" type="string" />
		<cfreturn encrypt(arguments.encValue,getEncryptionKey(),getEncryptionAlgorithm(),getEncryptionEncoding()) />
	</cffunction>

	<!--- Decrypt Data --->
	<cffunction name="decryptIt" access="private" returntype="any" hint="Return decrypted value" output="false">
		<cfargument name="decValue" hint="string to be decrypted" required="true" type="string" />
		<cfreturn decrypt(arguments.decValue,getEncryptionKey(),getEncryptionAlgorithm(),getEncryptionEncoding()) />
	</cffunction>

</cfcomponent>