<!-----------------------------------------------------------------------
Author 	 :	Henrik Joreteg
Date     :	October, 2008
Description : 			
	This is a ColdBox event handler for admin methods.

Please note that the extends needs to point to the eventhandler.cfc
in the ColdBox system directory.
extends = coldbox.system.eventhandler
	
----------------------------------------------------------------------->
<cfcomponent displayname="admin" extends="coldbox.system.eventhandler" output="false" autowire="true">
	
	<!--- Dependencies --->
	<cfproperty name="SecurityService" type="ioc" scope="instance">
	<cfproperty name="EntryService" type="ioc" scope="instance">
	
	
<!----------------------------------- CONSTRUCTOR --------------------------------------->	

	<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">
		<cfargument name="controller" type="any">
		<cfset super.init(arguments.controller)>
		<!--- Any constructor code here --->
		
		<cfreturn this>
	</cffunction>

<!----------------------------------- PUBLIC EVENTS --------------------------------------->

	<!--- index --->
	<cffunction name="index" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var rc = event.getCollection()>
		
		<!--- Do Your Logic Here to prepare a view --->	
		
		<cfset Event.setView("admin/home")>
	
	</cffunction>
	
	<!--- loginForm --->
	<cffunction name="loginForm" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var rc = event.getCollection()>
		
		<!--- Do Your Logic Here to prepare a view --->	
		
		<cfset Event.setView("admin/loginForm")>
	
	</cffunction>
	
	<!--- newPost --->
	<cffunction name="newPost" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="any" required="yes">
	    <cfset var rc = event.getCollection()>
	        
	    <cfset Event.setView("admin/newPost")>
	     
	</cffunction>
	
	<!--- doNewPost --->
	<cffunction name="doNewPost" access="public" returntype="void" output="false" hint="Action to handle new post operation">
		<cfargument name="Event" type="any" required="yes">
	    <cfset var rc = event.getCollection()>
	    <cfset var newPost = "">
	    
	    <cfscript>
	    	newPost = instance.EntryService.getEntry("posts.entry");
	    	getPlugin("beanFactory").populateBean(newPost);
	    	instance.EntryService.saveEntry(newPost);
	    	getColdboxOcm().clearAllEvents(false);
	    	setNextRoute("general/blog");
	    </cfscript>    
	     
	</cffunction>

	<!--- doLogin --->
	<cffunction name="doLogin" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<cfset var rc = event.getCollection()>
			
			<cfif instance.SecurityService.isUserVerified(rc.username, rc.password)>
				<cfset setNextRoute("admin/index")>
			<cfelse>
				<cfset getPlugin("messagebox").setMessage("error","Login Failed: Please try again.")>
				<cfset setNextRoute("admin/loginForm")>
			</cfif>
			
	</cffunction>
	
	<!--- doLogOut --->
	<cffunction name="doLogOut" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		
		<!--- Process logoff --->
		<cfset instance.SecurityService.deleteUserSession()>
		<cfset setNextRoute('general/index')>
	
	</cffunction>


</cfcomponent>