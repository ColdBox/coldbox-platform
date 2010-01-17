********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
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

<Interceptor class="coldbox.system.interceptors.Deploy">
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
		<cfargument name="controller" required="true" type="coldbox.system.web.Controller" hint="The coldbox controller">
		<cfset instance = structnew()>
		<cfset instance.controller = arguments.controller>
	</cffunction>
	
	<cffunction name="execute" access="public" returntype="void" hint="Execute Command" output="false" >
		<!--- Do your cleanup code or whatever you want here. --->
	</cffunction>
</cfcomponent>