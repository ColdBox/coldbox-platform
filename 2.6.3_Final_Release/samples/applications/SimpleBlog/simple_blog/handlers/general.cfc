<!-----------------------------------------------------------------------Author 	 :	Henrik JoretegDate     :	October, 2008Description : 				This is a ColdBox event handler for general methods.Please note that the extends needs to point to the eventhandler.cfcin the ColdBox system directory.extends = coldbox.system.eventhandler	-----------------------------------------------------------------------><cfcomponent name="general" extends="coldbox.system.eventhandler" output="false" autowire="true">	<!--- Dependencies --->	<cfproperty name="Transfer" type="ocm" scope="instance" />	<!----------------------------------- CONSTRUCTOR --------------------------------------->			<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">		<cfargument name="controller" type="any">		<cfset super.init(arguments.controller)>		<!--- Any constructor code here --->				<cfreturn this>	</cffunction>	<!----------------------------------- PUBLIC EVENTS --------------------------------------->		<cffunction name="index" access="public" returntype="void" output="false">		<cfargument name="Event" type="any">		<cfscript>			/* Welcome message */			Event.setValue("welcomeMessage","Hello, welcome to Simple Blog!");			/* Display View */			Event.setView("home");		</cfscript>	</cffunction>		<!--- about --->
	<cffunction name="about" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="any" required="yes">
	    <cfset var rc = event.getCollection()>
	    <!--- Display View --->    			<cfset Event.setView("about")>	</cffunction>		<!--- blog --->
	<cffunction name="blog" access="public" returntype="void" output="false" hint="Displays the blog page" cache="true" cacheTimeout="10">
		<cfargument name="Event" type="any" required="yes">
	    <cfscript>			var rc = event.getCollection();						/* Get all Posts */			rc.posts = instance.transfer.list("posts.entry","time", false);	     	/* Set View */	    	Event.setView("blog");	    </cfscript>
	</cffunction>		<!--- newPost --->
	<cffunction name="newPost" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="any" required="yes">
	    <cfset var rc = event.getCollection()>
	        	    <cfset Event.setView("newPost")>	     
	</cffunction>		<!--- doNewPost --->
	<cffunction name="doNewPost" access="public" returntype="void" output="false" hint="Action to handle new post operation">
		<cfargument name="Event" type="any" required="yes">
	    <cfset var rc = event.getCollection()>
	    <cfset var newPost = "">	    <cfscript>	    	/* Get a new transfer entry object  */	    	newPost = instance.transfer.new("posts.entry");	    	/* Populate the sucker */	    	getPlugin("beanFactory").populateBean(newPost);	    	/* Save it */	    	instance.transfer.save(newPost);	    	/* Clear event caching */	    	getColdboxOcm().clearEvent("general.blog");	    	/* Re-Route */	    	setNextRoute("general/blog");	    		    </cfscript>    
	     
	</cffunction>		<!--- viewPost --->
	<cffunction name="viewPost" access="public" returntype="void" output="false" hint="Shows one particular post and related comments" cache="true" cacheTimeout="10" >
		<cfargument name="Event" type="any" required="yes">
	    <cfset var rc = event.getCollection()>
	    <cfscript>	    	/* Get Current incoming Post */	    	rc.oPost = instance.transfer.get("posts.entry",rc.id);	    	/* Setup the comments */	    	rc.comments = rc.oPost.getCommentArray();	    	/* Setup the view */	    	Event.setView('viewPost');	    </cfscript>    	</cffunction>	<!--- doAddComment --->
	<cffunction name="doAddComment" access="public" returntype="void" output="false" hint="action that adds comment">
		<cfargument name="Event" type="any" required="yes">
	    <cfset var rc = event.getCollection()>	    <cfset var newComment = "">	    <cfscript>	    	/* get a New Comment */			newComment = instance.transfer.new("posts.comment");			/* Population */			newComment.setComment(rc.commentField);			newComment.setParentEntry(instance.transfer.get("posts.entry", rc.id));			/* Save it */			instance.transfer.save(newComment);			/* Clear Events from cache */			getColdboxOCM().clearEvent("general.viewPost","id=#rc.id#");			/* Re route */			setNextRoute("general/viewPost/" & rc.ID);		</cfscript>    `
	</cffunction></cfcomponent>