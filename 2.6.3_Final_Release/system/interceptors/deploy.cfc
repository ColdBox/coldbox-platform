<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	01/15/2008
Description :
	This interceptor reads and stores a _deploy.tag file to check
	for new deployments. If the tag has been udpated, the interceptor
	tells the framework to reinitialize itself.  This is done via date comparison.
	Once the framework starts up, it reads the datetimestamp on the tag
	and saves it on memory.
	
	You can use the included ANT script to touch the file with a new
	timestamp. Then just make sure you include the file in your deploy
	
Instructions:

- Place the _deploy.tag and deploy.xml ANT task in your /config directory of your application.
- Add the Deploy interceptor declaration

<Interceptor class="coldbox.system.interceptors.deploy">
	<Property name="tagFile">config/_deploy.tag</Property>
	<Property name="deployCommandObject">model.deployCommand</Property>
</Interceptor>

Interceptor Properties:

- tagFile : config/_deploy.tag [required] The location of the tag.
- deployCommandObject : The class path of the deploy command object to use [optional]. 

This object is a cfc that must implement an init(controller) method and an execute() method.  
This command object will be executed before the framework reinit bit is set so you can do
any kind of cleanup code or anything you like:

<cfcomponent name="DeployCommand" output="false">
	<cffunction name="init" access="public" returntype="any" hint="Constructor" output="false" >
		<cfargument name="controller" required="true" type="coldbox.system.controller" hint="The coldbox controller">
		<cfset instance = structnew()>
		<cfset instance.controller = arguments.controller>
	</cffunction>
	
	<cffunction name="execute" access="public" returntype="void" hint="Execute Command" output="false" >
		<cfscript>
			Do your cleanup code or whatever you want here.
		</cfscript>
	</cffunction>
</cfcomponent>
	
----------------------------------------------------------------------->
<cfcomponent hint="Deployment Control Interceptor"
			 extends="coldbox.system.interceptor"
			 output="false">
	

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="configure" access="public" returntype="void" output="false" hint="My configuration method">
		<cfscript>
			/* Private Properties */
			instance.tagFilepath = "";
			instance.deployCommandObject = "";
			
			/* Verify the properties */
			if( not propertyExists('tagFile') ){
				$throw('The tagFile property has not been defined. Please define it.','','Deploy.tagFilePropertyNotDefined');
			}
			
			/* Try to locate the path */
			instance.tagFilepath = locateFilePath(reReplace(getProperty('tagFile'),"^/",""));
			
			/* Validate it */
			if( len(instance.tagFilepath) eq 0 ){
				$throw('Tag file not found: #getProperty('tagFile')#. Please check again.','','interceptors.deploy.tagFileNotFound');
			}
			
			/* Save TimeStamp */
			setSetting("_deploytagTimestamp", FileLastModified(instance.tagFilepath) );
			
			/* Check for a cleanupCommandObject */
			if( propertyExists('deployCommandObject') ){
				try{
					/* Create it */
					instance.deployCommandObject = createObject("component",getProperty('deployCommandObject')).init(controller);
				}
				catch(Any e){
					rethrowit(e);
				}
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="afterAspectsLoad" output="false" access="public" returntype="void">
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfscript>
			getPlugin("logger").logEntry("information","Deploy tag registered successfully");
		</cfscript>	
	</cffunction>

	<cffunction name="preProcess" output="false" access="public" returntype="void" hint="Check if a deploy has been made">
		<!--- ************************************************************* --->
		<cfargument name="event" 		 required="true" type="any" hint="The event object.">
		<cfargument name="interceptData" required="true" type="struct" hint="interceptData of intercepted info.">
		<!--- ************************************************************* --->
		<cfset var applicationTimestamp = "">
		<cfset var fileTimestamp = FileLastModified(instance.tagFilepath)>
		
		<!--- Check if setting exists --->
		<cfif settingExists("_deploytagTimestamp")>
			<!--- Get setting --->
			<cfset applicationTimestamp = getSetting("_deploytagTimestamp")>
			<!--- Validate Timestamp --->
			<cfif dateCompare(fileTimestamp, applicationTimestamp) eq 1>
				<cflock scope="application" type="exclusive" timeout="15" throwontimeout="true">
				<cfscript>
					//Extra if statement for concurrency
					if ( dateCompare(fileTimestamp, applicationTimestamp) eq 1 ){
						try{
							
							/* cleanup command */
							if( propertyExists('deployCommandObject') ){
								instance.deployCommandObject.execute();
							}
							
							/* Reload ColdBox */
							getController().setColdboxInitiated(false);
							getController().setAspectsInitiated(false);
							
							/* Log Reloading */
							getPlugin("logger").logEntry("information","Deploy tag reloaded successfully at #now()#");
							
						}
						catch(Any e){
							//Log Error
							getPlugin("logger").logError("error","Error in deploy tag: #e.message# #e.detail#");
						}
					}
				</cfscript>
				</cflock>
			</cfif>
		<cfelse>
			<cfset configure()>
		</cfif>
	</cffunction>

		 
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<cffunction name="FileLastModified" access="private" returntype="string" output="false" hint="Get the last modified date of a file">
		<!--- ************************************************************* --->
		<cfargument name="filename" type="string" required="yes">
		<!--- ************************************************************* --->
		<cfscript>
		var objFile =  createObject("java","java.io.File").init(JavaCast("string",arguments.filename));
		// Calculate adjustments fot timezone and daylightsavindtime
		var Offset = ((GetTimeZoneInfo().utcHourOffset)+1)*-3600;
		// Date is returned as number of seconds since 1-1-1970
		return DateAdd('s', (Round(objFile.lastModified()/1000))+Offset, CreateDateTime(1970, 1, 1, 0, 0, 0));
		</cfscript>
	</cffunction>
	
	<cffunction name="rethrowit" access="private" returntype="void" hint="Rethrow an exception" output="false" >
		<cfargument name="throwObject" required="true" type="any" hint="The exception object">
		<cfthrow object="#arguments.throwObject#">
	</cffunction>
	
</cfcomponent>