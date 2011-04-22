<cfcomponent extends="coldbox.system.core.mail.abstractprotocol">

	<cffunction name="init" access="public" returntype="cfmailProtocol" hint="Constructor" output="false">
		<cfargument name="properties" required="false" default="#structnew()#" hint="A map of configuration properties for the protocol" />

		<cfscript>
			super.init(argumentCollection=arguments);

			return this;
		</cfscript>
		
	</cffunction>
	
	<!--- Public Protocol Methods. --->
	
	<cffunction name="send" access="public" returntype="struct" hint="I send a payload via the cfmail protocol.">
		<cfargument name="Payload" required="true" type="coldbox.system.core.mail.mail" hint="I'm the payload to delivery" />

		<cfscript>
			// The return structure
			var rtnStruct 	 = structnew();
			rtnStruct.error = true;
			rtnStruct.errorArray = ArrayNew(1);		
			
			//Just mail the darned thing!!
			try{
				mailIt(payload);
				rtnStruct.error = false;
			}
			catch(Any e){
				ArrayAppend(rtnStruct.errorArray,"Error sending mail. #e.message# : #e.detail# : #e.stackTrace#");
			}			
			
			// Return the return structure.
			return rtnStruct;
		</cfscript>
	</cffunction>
	
	<!--- Private methods for this protocol. --->
	
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
	
</cfcomponent>