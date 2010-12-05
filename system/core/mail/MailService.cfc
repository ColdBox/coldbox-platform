<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	May 8, 2009
Description :
	The ColdBox Mail Service used to send emails in an oo fashion


----------------------------------------------------------------------->
<cfcomponent output="false" hint="The ColdBox Mail Service used to send emails in an oo fashion">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="MailService" hint="Constructor">
		<cfargument name="mailSettings" type="coldbox.system.core.mail.MailSettingsBean" required="false" hint="A configured mail settings bean with default mail configurations, else ignored and uses payload"/>
		<cfargument name="tokenMarker"  type="string" required="false" default="@" hint="The default token Marker Symbol"/>
		<cfscript>
			// Mail Token Symbol
			setTokenMarker( arguments.tokenMarker );
			
			// Mail Settings
			if( structKeyExists(arguments,"mailSettings") ){
				variables.mailSettings = arguments.mailSettings;
			}
			else{
				variables.mailSettings = createObject("component","coldbox.system.core.mail.MailSettingsBean").init();
			}
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- Get/Set Token Marker --->
	<cffunction name="getTokenMarker" access="public" returntype="string" output="false" hint="Get the token marker">
    	<cfreturn tokenMarker>
    </cffunction>
    <cffunction name="setTokenMarker" access="public" returntype="void" output="false" hint="Set the token marker">
    	<cfargument name="TokenMarker" type="string" required="true">
    	<cfset variables.tokenMarker = arguments.TokenMarker>
    </cffunction>
	
	<!--- Mail Settings --->
	<cffunction name="getMailSettingsBean" output="false" access="public" returntype="coldbox.system.core.mail.MailSettingsBean" hint="Get the mail settings configuration object">
		<cfreturn variables.mailSettings>    	
    </cffunction>

	<!--- newMail --->
	<cffunction name="newMail" access="public" returntype="coldbox.system.core.mail.Mail" output="false" hint="Get a new Mail payload object, just use config() on it to prepare it or pass in all the arguments via this method">
		<cfscript>
			return createObject("component","coldbox.system.core.mail.Mail").init(argumentCollection=arguments);
		</cfscript>
	</cffunction>
	
	<!--- send --->
	<cffunction name="send" access="public" returntype="struct" output="false" hint="Send an email payload. Returns a struct: [error:boolean,errorArray:array]">
		<cfargument name="mail" required="true" type="coldbox.system.core.mail.Mail" hint="The mail payload to send." />
		<cfscript>
			var rtnStruct 	 = structnew();
			var payload 	 = arguments.mail;
			var mailSettings = getMailSettingsBean();
			
			// The return structure
			rtnStruct.error = true;
			rtnStruct.errorArray = ArrayNew(1);
				
			// Validate Basic Mail Fields
			if( NOT payload.validate() ){
				arrayAppend(rtnStruct.errorArray,"Please check the basic mail fields of To, From and Body as they are empty. To: #payload.getTo()#, From: #payload.getFrom()#, Body Len = #payload.getBody().length()#.");
				return rtnStruct;
			}
			
			// If mail payload does not have a server and one is defined in the mail settings, use that
			if( NOT arguments.mail.propertyExists("server") AND len(mailSettings.getServer()) ){
				mail.setServer( mailSettings.getServer() );
			}
			// Same with username, password and port
			if( NOT arguments.mail.propertyExists("username") AND len(mailSettings.getUsername()) ){
				mail.setUsername( mailSettings.getUsername() );
			}
			if( NOT arguments.mail.propertyExists("password") AND len(mailSettings.getPassword()) ){
				mail.setPassword( mailSettings.getPassword() );
			}
			if( NOT arguments.mail.propertyExists("port") AND len(mailSettings.getPort()) ){
				mail.setPort( mailSettings.getPort() );
			}
			
			// Parse Tokens
			parseTokens(payload);
					
			//Just mail the darned thing!!
			try{
				mailIt(payload);
				rtnStruct.error = false;
			}
			catch(Any e){
				ArrayAppend(rtnStruct.errorArray,"Error sending mail. #e.message# : #e.detail# : #e.stackTrace#");
			}			
	
			return rtnStruct;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<cffunction name="mailIt" output="false" access="private" returntype="void" hint="Mail a payload">
		<cfargument name="mail" required="true" type="coldbox.system.core.mail.Mail" hint="The mail payload" />
		<cfscript>
			// Determine Mail Type?
			if( arrayLen(arguments.mail.getMailParts()) ){
				mailMultiPart(arguments.mail);
			}
			else{
				mailNormal(arguments.mail);
			}		
		</cfscript>
	</cffunction>

	<cffunction name="mailNormal" output="false" access="private" returntype="void" hint="Mail a payload">
		<cfargument name="mail" required="true" type="coldbox.system.core.mail.Mail" hint="The mail payload" />
		<cfset var payload = arguments.mail>
		<cfset var mailParam = 0>
		
		<cfsetting enablecfoutputonly="true">
		
		<!--- I HATE FREAKING CF WHITESPACE, LOOK HOW UGLY THIS IS --->
		<cfmail attributeCollection="#payload.getMemento()#"><cfoutput>#payload.getBody()#</cfoutput><cfsilent>
			<cfloop array="#payload.getMailParams()#" index="mailparam">
				<cfif structKeyExists(mailParam,"name")>
					<cfmailparam name="#mailparam.name#" attributeCollection="#mailParam#">
				<cfelseif structKeyExists(mailparam,"file")>
					<cfmailparam file="#mailparam.file#" attributeCollection="#mailParam#">
				</cfif>
			</cfloop></cfsilent></cfmail>
		
		<cfsetting enablecfoutputonly="false">
	</cffunction>

	<cffunction name="mailMultiPart" output="false" access="private" returntype="any" hint="Mail a payload using multi part objects">
		<cfargument name="mail" required="true" type="coldbox.system.core.mail.Mail" hint="The mail payload" />
		<cfset var payload = arguments.mail>
		<cfset var mailParam = 0>
		<cfset var mailPart = 0>
		
		<cfsetting enablecfoutputonly="true">

		<!--- I HATE FREAKING CF WHITESPACE, LOOK HOW UGLY THIS IS --->
		<cfmail attributeCollection="#payload.getMemento()#">
		<!--- Mail Params --->
		<cfloop array="#payload.getMailParams()#" index="mailparam">
			<cfif structKeyExists(mailParam,"name")>
				<cfmailparam name="#mailparam.name#" attributeCollection="#mailParam#">
			<cfelseif structKeyExists(mailparam,"file")>
				<cfmailparam file="#mailparam.file#" attributeCollection="#mailParam#">
			</cfif>
		</cfloop>
		<!--- Mail Parts --->
		<cfloop array="#payload.getMailParts()#" index="mailPart">
			<cfmailpart attributeCollection="#mailpart#"><cfoutput>#mailpart.body#</cfoutput></cfmailpart>
		</cfloop>
		</cfmail>

		<cfsetting enablecfoutputonly="false">	
	</cffunction>
	
	<cffunction name="parseTokens" access="private" returntype="void" output="false" hint="Parse the tokens and do body replacements.">
		<cfargument name="Mail" required="true" type="coldbox.system.core.mail.Mail" hint="The mail payload" />
		<cfscript>
			var tokens 		= arguments.Mail.getBodyTokens();
			var body 		= arguments.Mail.getBody();
			var mailParts	= arguments.Mail.getMailParts();
      		var key 		= 0;
			var tokenMarker = getTokenMarker();
			var mailPart 	= 1;
			
			//Check mail parts for content
			if( arrayLen(mailparts) ){
				// Loop over mail parts
				for(mailPart=1; mailPart lte arrayLen(mailParts); mailPart++){
					body = mailParts[mailPart].body;
					for(key in tokens){
						body = replaceNoCase(body,"#tokenMarker##key##tokenMarker#", tokens[key],"all");
					}
					mailParts[mailPart].body = body;
				}
			}
			
			// Do token replacement on the body text
			for(key in tokens){
				body = replaceNoCase(body,"#tokenMarker##key##tokenMarker#", tokens[key],"all");
			}
			// replace back the body
			arguments.Mail.setBody(body);
		</cfscript>
	</cffunction>

</cfcomponent>