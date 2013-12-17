<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	The ColdBox Mail Service used to send emails in an oo and ColdBoxy fashion


----------------------------------------------------------------------->
<cfcomponent output="false" hint="The ColdBox Mail Service used to send emails in an oo and ColdBoxy fashion">

	<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="MailService" hint="Constructor">
		<cfargument name="mailSettings" type="any" required="false" hint="A configured mail settings bean with default mail configurations, else ignored and uses payload" colddoc:generic="coldbox.system.core.mail.MailSettingsBean"/>
		<cfargument name="tokenMarker"  type="any" required="false" default="@" hint="The default token Marker Symbol"/>
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
	<cffunction name="getTokenMarker" access="public" returntype="string" output="false" hint="Get the token marker to use for body token replacements">
    	<cfreturn tokenMarker>
    </cffunction>
    <cffunction name="setTokenMarker" access="public" returntype="void" output="false" hint="Set the token marker to use for body token replacements">
    	<cfargument name="tokenMarker" type="any" required="true">
    	<cfset variables.tokenMarker = arguments.tokenMarker>
    </cffunction>
	
	<!--- Mail Settings --->
	<cffunction name="getMailSettingsBean" output="false" access="public" returntype="any" hint="Get the mail settings configuration object" colddoc:generic="coldbox.system.core.mail.MailSettingsBean">
		<cfreturn variables.mailSettings>    	
    </cffunction>

	<!--- newMail --->
	<cffunction name="newMail" access="public" returntype="any" output="false" hint="Get a new Mail payload object, just use config() on it to prepare it or pass in all the arguments via this method" colddoc:generic="coldbox.system.core.mail.Mail">
		<cfscript>
			var mail 		 = createObject("component","coldbox.system.core.mail.Mail").init(argumentCollection=arguments);
			var mailSettings = getMailSettingsBean();
			
			// If mail payload does not have a server and one is defined in the mail settings, use that
			if( NOT mail.propertyExists("server") AND len(mailSettings.getServer()) ){
				mail.setServer( mailSettings.getServer() );
			}
			// Same with username, password, port, useSSL and useTLS
			if( NOT mail.propertyExists("username") AND len(mailSettings.getUsername()) ){
				mail.setUsername( mailSettings.getUsername() );
			}
			if( NOT mail.propertyExists("password") AND len(mailSettings.getPassword()) ){
				mail.setPassword( mailSettings.getPassword() );
			}
			if( NOT mail.propertyExists("port") AND len(mailSettings.getPort()) and mailSettings.getPort() NEQ 0 ){
				mail.setPort( mailSettings.getPort() );
			}
			if( NOT mail.propertyExists("useSSL")  AND len(mailSettings.getValue("useSSL","")) ){
				mail.setUseSSL( mailSettings.getValue("useSSL") );
			}
			if( NOT mail.propertyExists("useTLS")  AND len(mailSettings.getValue("useTLS","")) ){
				mail.setUseTLS( mailSettings.getValue("useTLS") );
			}
			// set default mail attributes if the MailSettings bean has values
			if( NOT len(mail.getTo()) AND len(mailSettings.getValue("to","")) ){
				mail.setTo( mailSettings.getValue("to") );
			}
			if( NOT len(mail.getFrom()) AND len(mailSettings.getValue("from","")) ){
				mail.setFrom( mailSettings.getValue("from") );
			}
			if( ( NOT mail.propertyExists("bcc") OR NOT len(mail.getBcc()) ) AND len(mailSettings.getValue("bcc","")) ){
				mail.setBcc( mailSettings.getValue("bcc") );
			}
			if( ( NOT mail.propertyExists("replyto") OR NOT len(mail.getReplyTo()) ) AND len(mailSettings.getValue("replyto","")) ){
				mail.setReplyTo( mailSettings.getValue("replyto") );
			}
			if( ( NOT mail.propertyExists("type") OR NOT len(mail.getType()) ) AND len(mailSettings.getValue("type","")) ){
				mail.setType( mailSettings.getValue("type") );
			}
			
			return mail;
		</cfscript>
	</cffunction>
	
	<!--- send --->
	<cffunction name="send" access="public" returntype="struct" output="false" hint="Send an email payload. Returns a struct: [error:boolean,errorArray:array]">
		<cfargument name="mail" required="true" type="any" hint="The mail payload to send." colddoc:generic="coldbox.system.core.mail.Mail"/>
		<cfscript>
			var rtnStruct 	 = structnew();
			var payload 	 = arguments.mail;
			
			// The return structure
			rtnStruct.error = true;
			rtnStruct.errorArray = ArrayNew(1);
				
			// Validate Basic Mail Fields
			if( NOT payload.validate() ){
				arrayAppend(rtnStruct.errorArray,"Please check the basic mail fields of To, From and Body as they are empty. To: #payload.getTo()#, From: #payload.getFrom()#, Body Len = #payload.getBody().length()#.");
				return rtnStruct;
			}
			
			// Parse Body Tokens
			parseTokens(payload);
					
			//Just mail the darned thing!!
			try{
				// We mail it using the protocol which is defined in the mail settings.
				rtnStruct = variables.mailSettings.getTransit().send(payload);
			}
			catch(Any e){
				ArrayAppend(rtnStruct.errorArray,"Error sending mail. #e.message# : #e.detail# : #e.stackTrace#");
			}
	
			return rtnStruct;
		</cfscript>
	</cffunction>
	
	<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Parse body tokens --->
	<cffunction name="parseTokens" access="private" returntype="void" output="false" hint="Parse the tokens and do body replacements.">
		<cfargument name="mail" required="true" type="any" hint="The mail payload" colddoc:generic="coldbox.system.core.mail.Mail"/>
		<cfscript>
			var tokens 		= arguments.mail.getBodyTokens();
			var body 		= arguments.mail.getBody();
			var mailParts	= arguments.mail.getMailParts();
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
			arguments.mail.setBody(body);
		</cfscript>
	</cffunction>

</cfcomponent>