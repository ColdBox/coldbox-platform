<!-----------------------------------------------------------------------Author 	 :	Henrik JoretegDate     :	October, 2008Description : 				This is a ColdBox event handler for general methods.Please note that the extends needs to point to the eventhandler.cfcin the ColdBox system directory.extends = coldbox.system.eventhandler	-----------------------------------------------------------------------><cfcomponent name="general" extends="coldbox.system.eventhandler" output="false" autowire="true"><!----------------------------------- CONSTRUCTOR --------------------------------------->			<cfproperty name="EntryService" type="ocm" scope="instance" />	<cfproperty name="CommentService" type="ocm" scope="instance" />		<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">		<cfargument name="controller" type="any">		<cfset super.init(arguments.controller)>		<!--- Any constructor code here --->				<cfreturn this>	</cffunction>	<!----------------------------------- PUBLIC EVENTS --------------------------------------->		<cffunction name="index" access="public" returntype="void" output="false">		<cfargument name="Event" type="any">		<cfset var rc = event.getCollection()>				<!--- Do Your Logic Here to prepare a view --->			<cfscript>			Event.setValue("welcomeMessage","Hello, Coldbox!");		</cfscript>				<!--- Set the View To Display, after Logic --->		<cfset Event.setView("home")>		</cffunction>		<!--- about --->
	<cffunction name="about" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="coldbox.system.beans.requestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	        			<!--- Set the View To Display, after Logic --->		<cfset Event.setView("about")>		
	</cffunction>		<!--- blog --->
	<cffunction name="blog" access="public" returntype="void" output="false" hint="Displays the blog page" cache="true" cachetimeout="30" >
		<cfargument name="Event" type="coldbox.system.beans.requestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	    	    <cfscript>	    	rc.posts = instance.EntryService.getLatestEntries();	    	Event.setView("blog");	    </cfscript>
	     
	</cffunction>		<!--- newPost --->
	<cffunction name="newPost" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="coldbox.system.beans.requestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	        	    <cfset Event.setView("newPost")>
	     
	</cffunction>		<!--- doNewPost --->
	<cffunction name="doNewPost" access="public" returntype="void" output="false" hint="Action to handle new post operation">
		<cfargument name="Event" type="coldbox.system.beans.requestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	    <cfset var newPost = "">	    	    <cfscript>	    	newPost = instance.EntryService.getEntry("posts.entry");	    	/*newPost.settitle(rc.title);	    	newPost.setpost(rc.post);	    	newPost.setauthor(rc.author);	    	*/	    	getPlugin("beanFactory").populateBean(newPost);	    	instance.EntryService.saveEntry(newPost);	    	    	getColdboxOcm().clearEvent("general.blog");	    	    	setNextRoute("general/blog");	    		    </cfscript>    
	     
	</cffunction>		<!--- viewPost --->
	<cffunction name="viewPost" access="public" returntype="void" output="false" hint="Shows one particular post and related comments">
		<cfargument name="Event" type="coldbox.system.beans.requestContext" required="yes">
	    	    <cfscript>	    	var rc = event.getCollection();	    	rc.oPost = instance.EntryService.getEntry(rc.id);	    	rc.comments = instance.CommentService.getComments(rc.id);	    	Event.setView('viewPost');	    </cfscript>    	       
	</cffunction>	<!--- doAddComment --->
	<cffunction name="doAddComment" access="public" returntype="void" output="false" hint="action that adds comment">
		<cfargument name="Event" type="coldbox.system.beans.requestContext" required="yes">	    		<cfscript>			var rc = event.getCollection();			newComment = instance.CommentService.getComment("posts.comment");			newComment.setComment(rc.commentField);		    newComment.setParentEntry(instance.EntryService.getEntry(rc.id));			instance.CommentService.saveComment(newComment);						setNextRoute("general/viewPost/" & rc.ID);		</cfscript>    `
	</cffunction></cfcomponent>