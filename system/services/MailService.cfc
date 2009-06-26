<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	May 8, 2009
Description :
	The ColdBox Mail Service used to send emails in an oo fashion


----------------------------------------------------------------------->
<cfcomponent name="MailService" 
			 output="false" 
			 hint="The ColdBox Mail Service used to send emails in an oo fashion"
			 extends="coldbox.system.services.BaseService">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" output="false" returntype="MailService" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			/* Set Controller */
			setController(arguments.controller);
			
			/* Return instance */
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="newMail" access="public" returntype="coldbox.system.beans.Mail" output="false" hint="Get a new Mail payload object, just use config() on it to prepare it.">
		<cfscript>
			return createObject("component","coldbox.system.beans.Mail").init();
		</cfscript>
	</cffunction>
	
	<cffunction name="send" access="public" returntype="struct" output="false" hint="Send an email payload. Returns a struct: [error:boolean,errorArray:array]">
		<cfargument name="Mail" required="true" type="coldbox.system.beans.Mail" hint="The mail payload to send." />
		<cfscript>
		var rtnStruct = structnew();
		var payload = arguments.mail;
		
		/* The return structure */
		rtnStruct.error = true;
		rtnStruct.errorArray = ArrayNew(1);
			
		/* Validate Basic Mail Fields */
		if( NOT payload.validate() ){
			arrayAppend(rtnStruct.errorArray,"Please check the basic mail fields of To, From and Body as they are empty. To: #payload.getTo()#, From: #payload.getFrom()#, Body Len = #payload.getBody().length()#.");
		}
		
		/* Parse Tokens */
		parseTokens(payload);
				
		//Just mail the darned thing!!
		try{
			mailIt(payload);
			rtnStruct.error = false;
		}
		catch(Any e){
			ArrayAppend(rtnStruct.errorArray,"Error sending mail. #e.message# : #e.detail# : #e.stackTrace#");
			/* log it */
			getLogger().logError("MailService - Error sending mail",e,payload.getMemento());
		}			

		//return
		return rtnStruct;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<cffunction name="mailIt" output="false" access="private" returntype="void" hint="Mail a payload">
		<cfargument name="mail" required="true" type="coldbox.system.beans.Mail" hint="The mail payload" />
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
		<cfargument name="mail" required="true" type="coldbox.system.beans.Mail" hint="The mail payload" />
		<cfset var payload = arguments.mail>
		<cfset var mailParam = 0>
		
		<cfsetting enablecfoutputonly="true">
		
		<!--- I HATE FREAKING CF WHITESPACE, LOOK HOW UGLY THIS IS --->
		<cfmail attributeCollection="#payload.getMemento()#"><cfif ArrayLen(payload.getMailParams())><cfloop array="#payload.getMailParams()#" index="mailparam"><cfif structKeyExists(mailParam,"name")><cfmailparam name="#mailparam.name#" attributeCollection="#mailParam#"><cfelseif structKeyExists(mailparam,"file")><cfmailparam file="#mailparam.file#" attributeCollection="#mailParam#"></cfif></cfloop></cfif><cfif ArrayLen(payload.getMailParts())><cfloop array="#payload.getMailParts()#" index="mailPart"><cfmailpart attributeCollection="#mailpart#"><cfoutput>#mailpart.body#</cfoutput></cfmailpart></cfloop></cfif><cfoutput>#payload.getBody()#</cfoutput></cfmail>
		
		<cfsetting enablecfoutputonly="false">
	</cffunction>

	<cffunction name="mailMultiPart" output="false" access="private" returntype="any" hint="Mail a payload using multi part objects">
		<cfargument name="mail" required="true" type="coldbox.system.beans.Mail" hint="The mail payload" />
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
		<cfargument name="Mail" required="true" type="coldbox.system.beans.Mail" hint="The mail payload" />
		<cfscript>
			var tokens = arguments.Mail.getBodyTokens();
			var body = arguments.Mail.getBody();
			var key = 0;
			
			for(key in tokens){
				body = replaceNoCase(body,"@#key#@", tokens[key],"all");
			}
			
			arguments.Mail.setBody(body);
		</cfscript>
	</cffunction>

</cfcomponent>