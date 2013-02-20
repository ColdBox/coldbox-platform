<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano
Date     :	May 8, 2009
Description :
	I model a mail payload object

----------------------------------------------------------------------->
<cfcomponent output="false" hint="I model a cfmail object with extra pizzazz">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- init --->
	<cffunction name="init" access="public" output="false" returntype="Mail" hint="Initialize the Mail object">
		<cfscript>
			instance = structnew();
			// Internal Properties
			instance.bodyTokens = structnew();
			instance.mailParams = ArrayNew(1);
			instance.mailParts = ArrayNew(1);
			instance.body = "";
			instance.from = "";
			instance.to = "";

			return config(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- propertyExists --->
	<cffunction name="propertyExists" output="false" access="public" returntype="boolean" hint="Checks if a mail property exists">
		<cfargument name="property" type="string" required="true" hint="The property to check"/>
		<cfreturn structKeyExists(instance,arguments.property)>
	</cffunction>

	<!--- config --->
	<cffunction name="config" access="public" output="false" returntype="Mail" 	hint="Configure the Mail object">
		<cfargument name="from" 			required="false" type="string" 		hint="Initial value for the from property." />
		<cfargument name="to" 				required="false" type="string" 		hint="Initial value for the to property." />
		<cfargument name="body" 			required="false" type="string" 		hint="Initial value for the email body." />
		<cfargument name="bcc" 				required="false" type="string" 		hint="Initial value for the bcc property." />
		<cfargument name="cc" 				required="false" type="string" 		hint="Initial value for the cc property." />
		<cfargument name="charset" 			required="false" type="string" 		hint="Initial value for the charset property." />
		<cfargument name="debug" 			required="false" type="boolean" 	hint="Initial value for the debug property." />
		<cfargument name="failto" 			required="false" type="string" 		hint="Initial value for the failto property." />
		<cfargument name="group"			required="false" type="string" 		hint="Initial value for the group property." />
		<cfargument name="groupcasesensitive" required="false" type="boolean" 	hint="Initial value for the groupcasesensitive property." />
		<cfargument name="mailerid" 		required="false" type="string" 		hint="Initial value for the mailerid property." />
		<cfargument name="maxrows" 			required="false" type="numeric" 	hint="Initial value for the maxrows property." />
		<cfargument name="mimeattach" 		required="false" type="string" 		hint="Initial value for the mimeattach property." />
		<cfargument name="password" 		required="false" type="string" 		hint="Initial value for the password property." />
		<cfargument name="port" 			required="false" type="numeric" 	hint="Initial value for the port property." />
		<cfargument name="priority" 		required="false" type="string" 		hint="Initial value for the priority property." />
		<cfargument name="query" 			required="false" type="string" 		hint="Initial value for the query property." />
		<cfargument name="replyto" 			required="false" type="string" 		hint="Initial value for the replyto property." />
		<cfargument name="server" 			required="false" type="string" 		hint="Initial value for the server property." />
		<cfargument name="spoolenable" 		required="false" type="boolean" 	hint="Initial value for the spoolenable property." />
		<cfargument name="startrow" 		required="false" type="numeric" 	hint="Initial value for the startrow property." />
		<cfargument name="subject" 			required="false" type="string" 		hint="Initial value for the subject property." />
		<cfargument name="timeout" 			required="false" type="numeric" 	hint="Initial value for the timeout property." />
		<cfargument name="type" 			required="false" type="string" 		hint="Initial value for the type property." />
		<cfargument name="username" 		required="false" type="string" 		hint="Initial value for the username property." />
		<cfargument name="useSSL" 			required="false" type="boolean" 	hint="Initial value for the useSSL property." />
		<cfargument name="useTLS" 			required="false" type="boolean" 	hint="Initial value for the useTLS property." />
		<cfargument name="wraptext" 		required="false" type="numeric" 	hint="Initial value for the wraptext property." />
		<cfscript>
			var key = 0;

			// populate mail keys
			for(key in arguments){
				if( structKeyExists(arguments,key) ){
					instance[key] = arguments[key];
				}
			}

			// server exception
			if( structKeyExists(arguments, "server") AND NOT len( arguments.server ) ){
				structDelete( instance, "server" );
			}

			return this;
		</cfscript>
	</cffunction>


<!------------------------------------------- GETTERS ------------------------------------------->

	<cffunction name="getFrom" access="public" output="false" returntype="any" hint="Gets the from property">
		<cfreturn instance.from />
	</cffunction>

	<cffunction name="getTo" access="public" output="false" returntype="any" hint="Gets the to property">
		<cfreturn instance.to />
	</cffunction>

	<cffunction name="getBcc" access="public" output="false" returntype="any" hint="Gets the bcc property">
		<cfreturn instance.bcc />
	</cffunction>

	<cffunction name="getCc" access="public" output="false" returntype="any" hint="Gets the cc property">
		<cfreturn instance.cc />
	</cffunction>

	<cffunction name="getCharset" access="public" output="false" returntype="any" hint="Gets the charset property">
		<cfreturn instance.charset />
	</cffunction>

	<cffunction name="getDebug" access="public" output="false" returntype="any" hint="Gets the debug property">
		<cfreturn instance.debug />
	</cffunction>

	<cffunction name="getFailto" access="public" output="false" returntype="any" hint="Gets the failto property">
		<cfreturn instance.failto />
	</cffunction>

	<cffunction name="getGroup" access="public" output="false" returntype="any" hint="Gets the group property">
		<cfreturn instance.group />
	</cffunction>

	<cffunction name="getGroupcasesensitive" access="public" output="false" returntype="any" hint="Gets the groupcasesensitive property">
		<cfreturn instance.groupcasesensitive />
	</cffunction>

	<cffunction name="getMailerid" access="public" output="false" returntype="any" hint="Gets the mailerid property">
		<cfreturn instance.mailerid />
	</cffunction>

	<cffunction name="getMaxrows" access="public" output="false" returntype="any" hint="Gets the maxrows property">
		<cfreturn instance.maxrows />
	</cffunction>

	<cffunction name="getMimeattach" access="public" output="false" returntype="any" hint="Gets the mimeattach property">
		<cfreturn instance.mimeattach />
	</cffunction>

	<cffunction name="getPassword" access="public" output="false" returntype="any" hint="Gets the password property">
		<cfreturn instance.password />
	</cffunction>

	<cffunction name="getPort" access="public" output="false" returntype="any" hint="Gets the port property">
		<cfreturn instance.port />
	</cffunction>

	<cffunction name="getPriority" access="public" output="false" returntype="any" hint="Gets the priority property">
		<cfreturn instance.priority />
	</cffunction>

	<cffunction name="getQuery" access="public" output="false" returntype="any" hint="Gets the query property">
		<cfreturn instance.query />
	</cffunction>

	<cffunction name="getReplyto" access="public" output="false" returntype="any" hint="Gets the replyto property">
		<cfreturn instance.replyto />
	</cffunction>

	<cffunction name="getServer" access="public" output="false" returntype="any" hint="Gets the server property">
		<cfreturn instance.server />
	</cffunction>

	<cffunction name="getSpoolenable" access="public" output="false" returntype="any" hint="Gets the spoolenable property">
		<cfreturn instance.spoolenable />
	</cffunction>

	<cffunction name="getStartrow" access="public" output="false" returntype="any" hint="Gets the startrow property">
		<cfreturn instance.startrow />
	</cffunction>

	<cffunction name="getSubject" access="public" output="false" returntype="any" hint="Gets the subject property">
		<cfreturn instance.subject />
	</cffunction>

	<cffunction name="getTimeout" access="public" output="false" returntype="any" hint="Gets the timeout property">
		<cfreturn instance.timeout />
	</cffunction>

	<cffunction name="getType" access="public" output="false" returntype="any" hint="Gets the type property">
		<cfreturn instance.type />
	</cffunction>

	<cffunction name="getUsername" access="public" output="false" returntype="any" hint="Gets the username property">
		<cfreturn instance.username />
	</cffunction>

	<cffunction name="getUseSSL" access="public" output="false" returntype="any" hint="Gets the useSSL property">
		<cfreturn instance.useSSL />
	</cffunction>

	<cffunction name="getUseTLS" access="public" output="false" returntype="any" hint="Gets the useTLS property">
		<cfreturn instance.useTLS />
	</cffunction>

	<cffunction name="getWraptext" access="public" output="false" returntype="any" hint="Gets the wraptext property">
		<cfreturn instance.wraptext />
	</cffunction>

	<cffunction name="getBodyTokens" access="public" output="false" returntype="any" hint="Gets the bodyTokens property">
		<cfreturn instance.bodyTokens />
	</cffunction>

	<cffunction name="getMailParams" access="public" output="false" returntype="Array" hint="Gets the mailParams property">
		<cfreturn instance.mailParams />
	</cffunction>

	<cffunction name="getMailParts" access="public" output="false" returntype="Array" hint="Gets the mailParts defined in this Mail object">
		<cfreturn instance.mailParts />
	</cffunction>

	<cffunction name="getBody" access="public" output="false" returntype="string" hint="Get body">
		<cfreturn instance.body/>
	</cffunction>

<!------------------------------------------- SETTERS ------------------------------------------->

	<cffunction name="setBody" access="public" output="false" returntype="any" hint="Set Body">
		<cfargument name="Body" type="string" required="true"/>
		<cfset instance.Body = arguments.Body/>
		<cfreturn this>
	</cffunction>

	<cffunction name="setFrom" access="public" output="false" returntype="any" hint="Sets a new value for the from property">
		<cfargument name="newFrom" type="string" required="yes" />
		<cfset instance.from = arguments.newFrom />
		<cfreturn this>
	</cffunction>

	<cffunction name="setTo" access="public" output="false" returntype="any" hint="Sets a new value for the to property">
		<cfargument name="newTo" type="string" required="yes" />
		<cfset instance.to = arguments.newTo />
		<cfreturn this>
	</cffunction>

	<cffunction name="setBcc" access="public" output="false" returntype="any" hint="Sets a new value for the bcc property">
		<cfargument name="newBcc" type="string" required="yes" />
		<cfset instance.bcc = arguments.newBcc />
		<cfreturn this>
	</cffunction>

	<cffunction name="setCc" access="public" output="false" returntype="any" hint="Sets a new value for the cc property">
		<cfargument name="newCc" type="string" required="yes" />
		<cfset instance.cc = arguments.newCc />
		<cfreturn this>
	</cffunction>

	<cffunction name="setCharset" access="public" output="false" returntype="any" hint="Sets a new value for the charset property">
		<cfargument name="newCharset" type="string" required="yes" />
		<cfset instance.charset = arguments.newCharset />
		<cfreturn this>
	</cffunction>

	<cffunction name="setDebug" access="public" output="false" returntype="any" hint="Sets a new value for the debug property">
		<cfargument name="newDebug" type="boolean" required="yes" />
		<cfset instance.debug = arguments.newDebug />
		<cfreturn this>
	</cffunction>

	<cffunction name="setFailto" access="public" output="false" returntype="any" hint="Sets a new value for the failto property">
		<cfargument name="newFailto" type="string" required="yes" />
		<cfset instance.failto = arguments.newFailto />
		<cfreturn this>
	</cffunction>

	<cffunction name="setGroup" access="public" output="false" returntype="any" hint="Sets a new value for the group property">
		<cfargument name="newGroup" type="string" required="yes" />
		<cfset instance.group = arguments.newGroup />
		<cfreturn this>
	</cffunction>

	<cffunction name="setGroupcasesensitive" access="public" output="false" returntype="any" hint="Sets a new value for the groupcasesensitive property">
		<cfargument name="newGroupcasesensitive" type="boolean" required="yes" />
		<cfset instance.groupcasesensitive = arguments.newGroupcasesensitive />
		<cfreturn this>
	</cffunction>

	<cffunction name="setMailerid" access="public" output="false" returntype="any" hint="Sets a new value for the mailerid property">
		<cfargument name="newMailerid" type="string" required="yes" />
		<cfset instance.mailerid = arguments.newMailerid />
		<cfreturn this>
	</cffunction>

	<cffunction name="setMaxrows" access="public" output="false" returntype="any" hint="Sets a new value for the maxrows property">
		<cfargument name="newMaxrows" type="numeric" required="yes" />
		<cfset instance.maxrows = arguments.newMaxrows />
		<cfreturn this>
	</cffunction>

	<cffunction name="setMimeattach" access="public" output="false" returntype="any" hint="Sets a new value for the mimeattach property">
		<cfargument name="newMimeattach" type="string" required="yes" />
		<cfset instance.mimeattach = arguments.newMimeattach />
		<cfreturn this>
	</cffunction>

	<cffunction name="setPassword" access="public" output="false" returntype="any" hint="Sets a new value for the password property">
		<cfargument name="newPassword" type="string" required="yes" />
		<cfset instance.password = arguments.newPassword />
		<cfreturn this>
	</cffunction>

	<cffunction name="setPort" access="public" output="false" returntype="any" hint="Sets a new value for the port property">
		<cfargument name="newPort" type="numeric" required="yes" />
		<cfset instance.port = arguments.newPort />
		<cfreturn this>
	</cffunction>

	<cffunction name="setPriority" access="public" output="false" returntype="any" hint="Sets a new value for the priority property">
		<cfargument name="newPriority" type="string" required="yes" />
		<cfset instance.priority = arguments.newPriority />
		<cfreturn this>
	</cffunction>

	<cffunction name="setQuery" access="public" output="false" returntype="any" hint="Sets a new value for the query property">
		<cfargument name="newQuery" type="string" required="yes" />
		<cfset instance.query = arguments.newQuery />
		<cfreturn this>
	</cffunction>

	<cffunction name="setReplyto" access="public" output="false" returntype="any" hint="Sets a new value for the replyto property">
		<cfargument name="newReplyto" type="string" required="yes" />
		<cfset instance.replyto = arguments.newReplyto />
		<cfreturn this>
	</cffunction>

	<cffunction name="setServer" access="public" output="false" returntype="any" hint="Sets a new value for the server property">
		<cfargument name="newServer" type="string" required="yes" />
		<cfset instance.server = arguments.newServer />
		<cfreturn this>
	</cffunction>

	<cffunction name="setSpoolenable" access="public" output="false" returntype="any" hint="Sets a new value for the spoolenable property">
		<cfargument name="newSpoolenable" type="boolean" required="yes" />
		<cfset instance.spoolenable = arguments.newSpoolenable />
		<cfreturn this>
	</cffunction>

	<cffunction name="setStartrow" access="public" output="false" returntype="any" hint="Sets a new value for the startrow property">
		<cfargument name="newStartrow" type="numeric" required="yes" />
		<cfset instance.startrow = arguments.newStartrow />
		<cfreturn this>
	</cffunction>

	<cffunction name="setSubject" access="public" output="false" returntype="any" hint="Sets a new value for the subject property">
		<cfargument name="newSubject" type="string" required="yes" />
		<cfset instance.subject = arguments.newSubject />
		<cfreturn this>
	</cffunction>

	<cffunction name="setTimeout" access="public" output="false" returntype="any" hint="Sets a new value for the timeout property">
		<cfargument name="newTimeout" type="numeric" required="yes" />
		<cfset instance.timeout = arguments.newTimeout />
		<cfreturn this>
	</cffunction>

	<cffunction name="setType" access="public" output="false" returntype="any" hint="Sets a new value for the type property">
		<cfargument name="newType" type="string" required="yes" />
		<cfset instance.type = arguments.newType />
		<cfreturn this>
	</cffunction>

	<cffunction name="setUsername" access="public" output="false" returntype="any" hint="Sets a new value for the username property">
		<cfargument name="newUsername" type="string" required="yes" />
		<cfset instance.username = arguments.newUsername />
		<cfreturn this>
	</cffunction>

	<cffunction name="setUseSSL" access="public" output="false" returntype="any" hint="Sets a new value for the useSSL property">
		<cfargument name="newUseSSL" type="boolean" required="yes" />
		<cfset instance.useSSL = arguments.newUseSSL />
		<cfreturn this>
	</cffunction>

	<cffunction name="setUseTLS" access="public" output="false" returntype="any" hint="Sets a new value for the useTLS property">
		<cfargument name="newUseTLS" type="boolean" required="yes" />
		<cfset instance.useTLS = arguments.newUseTLS />
		<cfreturn this>
	</cffunction>

	<cffunction name="setWraptext" access="public" output="false" returntype="any" hint="Sets a new value for the wraptext property">
		<cfargument name="newWraptext" type="numeric" required="yes" />
		<cfset instance.wraptext = arguments.newWraptext />
		<cfreturn this>
	</cffunction>

	<cffunction name="validate" access="public" returntype="boolean" hint="validates the basic fields of To, From and Body" output="false" >
		<cfscript>
			if( getFrom().length() eq 0 OR
				getTO().length() eq 0 OR
				getSubject().length() eq 0 OR
				( getBody().length() eq 0 AND arrayLen(getMailParts()) EQ 0 )

			){
				return false;
			}
			else{
				return true;
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC HELPER METHODS ------------------------------------------->

	<!--- setReadReceipt --->
    <cffunction name="setReadReceipt" output="false" access="public" returntype="any" hint="Set the email address that will receive read receipts. I just place the appropriate mail headers">
    	<cfargument name="email"/>
    	<cfscript>
    		addMailParam(name="Read-Receipt-To",value=arguments.email);
			addMailParam(name="Disposition-Notification-To",value=arguments.email);
    		return this;
		</cfscript>
    </cffunction>

	<!--- setSendReceipt --->
    <cffunction name="setSendReceipt" output="false" access="public" returntype="any" hint="Sets the email that get's notified once the email is delivered by setting the appropriate mail headers">
    	<cfargument name="email"/>
    	<cfscript>
    		addMailParam(name="Return-Receipt-To",value=arguments.email);
    		return this;
		</cfscript>
    </cffunction>

	<!--- setHTML --->
    <cffunction name="setHTML" output="false" access="public" returntype="any" hint="Sets up a mail part that is HTML using utf8 for you by calling addMailpart()">
    	<cfargument name="body" hint="The HTML content to set in the mail part"/>
		<cfset addMailPart(charset='utf8',type='text/html',body=arguments.body)>
		<cfreturn this>
    </cffunction>

	<!--- setText --->
    <cffunction name="setText" output="false" access="public" returntype="any" hint="Sets up a mail part that is TEXT using utf8 for you by calling addMailpart()">
    	<cfargument name="body" hint="The HTML content to set in the mail part"/>
		<cfset addMailPart(charset='utf8',type='text/plain',body=arguments.body)>
		<cfreturn this>
    </cffunction>

	<!--- addAttachments --->
    <cffunction name="addAttachments" output="false" access="public" returntype="any" hint="Add attachment(s) to this payload using a list or array of file locations">
    	<cfargument name="files"  type="any" 		required="true" hint="A list or array of files to attach to this payload"/>
		<cfargument name="remove" type="boolean" 	required="false" default="false" hint="If true, ColdFusion removes attachment files (if any) after the mail is successfully delivered.">
		<cfscript>
			var x =1;

			if ( isSimpleValue(arguments.files) ){
				arguments.files = listToArray(arguments.files);
			}
			for(x=1; x lte arrayLen(arguments.files); x=x+1){
				addMailParam(file=arguments.files[x], remove=arguments.remove);
			}

			return this;
		</cfscript>
    </cffunction>

	<!--- setBodyTokens --->
	<cffunction name="setBodyTokens" access="public" output="false" returntype="any" hint="Sets a new struct of body tokens that can be used for replacement when the mail is sent. The tokens are replaced in the body content ast @token@ delimmitted.">
		<cfargument name="tokenMap" type="struct" required="yes" />
		<cfset instance.bodyTokens = arguments.tokenMap />
		<cfreturn this>
	</cffunction>

	<!--- addMailPart --->
	<cffunction name="addMailPart" access="public" returntype="any" output="false" hint="Add a new mail part to this mail payload">
		<cfargument name="charset" 		required="false" type="string" 	hint="Initial value for the charset property." />
		<cfargument name="type" 		required="false" type="string" 	hint="Initial value for the type property." />
		<cfargument name="wraptext" 	required="false" type="numeric" hint="Initial value for the wraptext property." />
		<cfargument name="body" 		required="false" type="string" 	hint="Initial value for the body property." />
		<cfscript>
			// Add new mail part
			var mailpart = structnew();
			var key = 0;

			for( key in arguments ){
				if( structKeyExists(arguments, key) ){ mailpart[key] = arguments[key]; }
			}

			arrayAppend(getMailParts(), mailpart);

			return this;
		</cfscript>
	</cffunction>

	<!--- addMailParam --->
	<cffunction name="addMailParam" access="public" returntype="any" output="false" hint="Add mail params to this payload">
		<cfargument name="contentID" 	required="false" type="any" 	hint="Initial value for the contentID property." />
		<cfargument name="disposition" 	required="false" type="any" 	hint="Initial value for the dispositio nproperty." />
		<cfargument name="file" 		required="false" type="any" 	hint="Initial value for the file property." />
		<cfargument name="type" 		required="false" type="any" 	hint="Initial value for the type property." />
		<cfargument name="name" 		required="false" type="any" 	hint="Initial value for the name property." />
		<cfargument name="value" 		required="false" type="any" 	hint="Initial value for the value property." />
		<cfargument name="remove" 		required="false" type="boolean" hint="If true, ColdFusion removes attachment files (if any) after the mail is successfully delivered.">
		<cfargument name="content" 		required="false" type="any" 	hint="Lets you send the contents of a ColdFusion variable as an attachment." />
		<cfscript>
			// Add new mail Param
			var mailparams = structnew();
			var key = 0;

			for( key in arguments ){
				if( structKeyExists(arguments, key) ){ mailparams[key] = arguments[key]; }
			}

			arrayAppend(getMailParams(), mailparams);

			return this;
		</cfscript>
	</cffunction>

	<!--- get/set Memento --->
	<cffunction name="getMemento" access="public" returntype="struct" output="false">
		<cfreturn instance>
	</cffunction>
	<cffunction name="setMemento" access="public" returntype="void" output="false">
		<cfargument name="memento" required="false" type="struct" />
		<cfset instance = arguments.memento>
	</cffunction>

</cfcomponent>