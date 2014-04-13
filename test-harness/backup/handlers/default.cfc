<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	4/8/2008
Description : 			
 default handler
		
Modification History:

----------------------------------------------------------------------->
<cfcomponent hint="a default handler" output="false">

			 
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->	 	

	<cffunction name="init" access="public" returntype="default" output="false" hint="Optional Constructor">
		<cfargument name="controller" type="coldbox.system.web.Controller">
		
		<!--- Mandatory Super call --->
		<cfset super.init(arguments.controller)>
		<!--- Any custom constructor code here --->
		
		<cfreturn this>
	</cffunction>
			 
<!------------------------------------------- PUBLIC ------------------------------------------->	 	

	<!--- do something --->
	<cffunction name="index" access="public" returntype="Void" output="false">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext" required="yes">
		<cfset var rc = event.getCollection()>
		 
		<cfset event.setView('vwQuote')>
	</cffunction>
	
	<!--- Pre Handler --->
	<cffunction name="preHandler" access="public" returntype="any" hint="" output="false" >
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext" required="yes">
	    <cfset event.overrideEvent('default.override')>
	</cffunction>
	<!--- protect --->
	<cffunction name="protect" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	    
	    <cfset getPlugin("MessageBox").setMessage(type="error", message="Override did not work")>    
	    <cfset event.setView('default/protect')>
	</cffunction>
	<!--- override --->
	<cffunction name="override" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	    
	    <cfset getPlugin("MessageBox").setMessage(type="info", message="Override Worked")>
	    <cfset event.setView('default/protect')>
	</cffunction>
	
	<!--- implicit --->
	<cffunction name="implicit" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	    
	    <cfset rc.ImplicitView = "The implicit view has to be done for event: #event.getCurrentEvent()#">    
	     
	</cffunction>
	
	<!--- RSS --->
	<cffunction name="rss" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	    <cfscript>
			//get rss feed
			rc.feed = getPlugin("FeedReader").readFeed(feedURL="http://news.google.com/nwshp?hl=en&tab=wn&output=rss");
		</cfscript>	     
	</cffunction>
	
	<!--- onMissingAction --->
	<cffunction name="onMissingAction" access="public" returntype="void" output="false" hint="on missing action">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext" required="yes">
	    <cfargument name="missingAction" required="true" type="string" hint="">
	    <cfset var rc = event.getCollection()>
	   	<cfscript>
			rc.missingAction = arguments.missingAction;
			event.setView('missingAction');
		</cfscript> 
	</cffunction>
	
	<!--- testRoute --->
	<cffunction name="testRoute" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="coldbox.system.web.context.RequestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	    
	    <cfset getPlugin("MessageBox").setMessage("warning","I am relocating from <strong>default.testRoute</strong>")>
	    
	    <cfset setNextEvent('default.index',"page=2&issues=1")>
	</cffunction>
	
	
	
<!------------------------------------------- PRIVATE ------------------------------------------->	 	

	
	
</cfcomponent>