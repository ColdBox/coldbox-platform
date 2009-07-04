<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	04/12/2009
Description :
	An appender that sends out emails
	
Properties:
- subject - Get's pre-pended with the category field.
- from - required
- to - required can be a ; list of emails
- cc
- bcc
- mailserver (optional)
- mailpassword (optional)
- mailusername (optional)
- mailport (optional - 25)

----------------------------------------------------------------------->
<cfcomponent name="EmailAppender" 
			 extends="coldbox.system.logging.AbstractAppender" 
			 output="false"
			 hint="An appender that sends out emails">
	
	<!--- Init --->
	<cffunction name="init" access="public" returntype="CFLogger" hint="Constructor called by a Concrete Logger" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="name" 		type="string"  required="true" hint="The unique name for this logger."/>
		<cfargument name="levelMin" 	type="numeric" required="false" default="0" hint="The default log level for this logger, by default it is 0. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="levelMax" 	type="numeric" required="false" default="5" hint="The default log level for this logger, by default it is 5. Optional. ex: LogBox.logLevels.WARNING"/>
		<cfargument name="properties" 	type="struct"  required="false" default="#structnew()#" hint="A map of configuration properties for the logger"/>
		<!--- ************************************************************* --->
		<cfscript>
			// Init supertype
			super.init(argumentCollection=arguments);
			
			// Property Checks
			if( NOT propertyExists("from") ){
				throw(message="from email is required",type="EmailAppender.PropertyNotFound");
			}
			if( NOT propertyExists("to") ){
				throw(message="to email(s) is required",type="EmailAppender.PropertyNotFound");
			}
			if( NOT propertyExists("subject") ){
				throw(message="subject is required",type="EmailAppender.PropertyNotFound");
			}
			if( NOT propertyExists("cc") ){
				setProperty("cc","");
			}
			if( NOT propertyExists("bcc") ){
				setProperty("bcc","");
			}
			if( NOT propertyExists("mailport") ){
				setProperty("mailport",25);
			}
			if( NOT propertyExists("mailserver") ){
				setProperty("mailserver","");
			}
			if( NOT propertyExists("mailpassword") ){
				setProperty("mailpassword","");
			}
			if( NOT propertyExists("mailusername") ){
				setProperty("mailusername","");
			}
						
			return this;
		</cfscript>
	</cffunction>	
	
	<!--- Log Message --->
	<cffunction name="logMessage" access="public" output="false" returntype="void" hint="Write an entry into the logger.">
		<!--- ************************************************************* --->
		<cfargument name="logEvent" type="coldbox.system.logging.LogEvent" required="true" hint="The logging event"/>
		<!--- ************************************************************* --->
		<cfscript>
			var loge = arguments.logEvent;
			var subject = "#severityToString(loge.getSeverity())#-#loge.getCategory()#-#getProperty("subject")#"
		</cfscript>
		<cftry>
			<!--- Mail the log --->
			<cfmail to="#getProperty("to")#"
					from="#getProperty("from")#"
					cc="#getProperty("cc")#"
					bcc="#getProperty("bcc")#"
					type="text/html"
					server="#getProperty("mailserver")#" username="#getProperty("mailusername")#" password="#getProperty("mailpassword")#" port="#getProperty("mailport")#"
					subject="#subject#" ><p>TimeStamp: #loge.getTimeStamp()#</p><hr/><p>#loge.getMessage()#</p><hr/><p>Extra Info Dump:</p><cfdump var="#loge.getExtraInfo()#"></cfmail>
				
			<cfcatch type="any">
				<cfset $log("ERROR","Error sending email from appender #getName()#. #cfcatch.message# #cfcatch.detail# #cfcatch.stacktrace#")>
			</cfcatch>
		</cftry>			   
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	
</cfcomponent>