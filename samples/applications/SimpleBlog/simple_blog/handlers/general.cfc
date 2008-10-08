<!-----------------------------------------------------------------------Author 	 :	Henrik JoretegDate     :	October, 2008Description : 				This is a ColdBox event handler for general methods.Please note that the extends needs to point to the eventhandler.cfcin the ColdBox system directory.extends = coldbox.system.eventhandler	-----------------------------------------------------------------------><cfcomponent name="general" extends="coldbox.system.eventhandler" output="false" autowire="true"><!----------------------------------- CONSTRUCTOR --------------------------------------->			<cfproperty name="Transfer" type="ocm" scope="instance" />		<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">		<cfargument name="controller" type="any">		<cfset super.init(arguments.controller)>		<!--- Any constructor code here --->				<cfreturn this>	</cffunction>	<!----------------------------------- PUBLIC EVENTS --------------------------------------->		<cffunction name="index" access="public" returntype="void" output="false">		<cfargument name="Event" type="any">		<cfset var rc = event.getCollection()>				<!--- Do Your Logic Here to prepare a view --->			<cfscript>			Event.setValue("welcomeMessage","Hello, Coldbox!");		</cfscript>				<!--- Set the View To Display, after Logic --->		<cfset Event.setView("home")>		</cffunction>		<!--- about --->
	<cffunction name="about" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="coldbox.system.beans.requestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	        			<!--- Set the View To Display, after Logic --->		<cfset Event.setView("about")>		
	</cffunction>		<!--- blog --->
	<cffunction name="blog" access="public" returntype="void" output="false" hint="Displays the blog page" >
		<cfargument name="Event" type="coldbox.system.beans.requestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	    	    <cfscript>	    	rc.posts = instance.transfer.list("posts.entry","time", false);	     	    	Event.setView("blog");	    </cfscript>
	     
	</cffunction>		<!--- newPost --->
	<cffunction name="newPost" access="public" returntype="void" output="false" hint="">
		<cfargument name="Event" type="coldbox.system.beans.requestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	        	    <cfset Event.setView("newPost")>
	     
	</cffunction>		<!--- doNewPost --->
	<cffunction name="doNewPost" access="public" returntype="void" output="false" hint="Action to handle new post operation">
		<cfargument name="Event" type="coldbox.system.beans.requestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	    <cfset var newPost = "">	    	    <cfscript>	    	newPost = instance.transfer.new("posts.entry");	    	/*newPost.settitle(rc.title);	    	newPost.setpost(rc.post);	    	newPost.setauthor(rc.author);	    	*/	    	getPlugin("beanFactory").populateBean(newPost);	    	instance.transfer.save(newPost);	    	    	getColdboxOcm().clearEvent("general.blog");	    	    	setNextRoute("general/blog");	    		    </cfscript>    
	     
	</cffunction>		<!--- viewPost --->
	<cffunction name="viewPost" access="public" returntype="void" output="false" hint="Shows one particular post and related comments" >
		<cfargument name="Event" type="coldbox.system.beans.requestContext" required="yes">
	    <cfset var rc = event.getCollection()>
	    	    <cfscript>	    	rc.oPost = instance.transfer.get("posts.entry",rc.id);	    	rc.comments = rc.oPost.getCommentArray();	    </cfscript>    	        
	    <cfset Event.setView('viewPost')>
	</cffunction>	<!--- doAddComment --->
	<cffunction name="doAddComment" access="public" returntype="void" output="false" hint="action that adds comment">
		<cfargument name="Event" type="coldbox.system.beans.requestContext" required="yes">
	    <cfset var rc = event.getCollection()>	    		<cfscript>			newComment = instance.transfer.new("posts.comment");			newComment.setComment(rc.commentField);			newComment.setParentEntry(instance.transfer.get("posts.entry", rc.id));			instance.transfer.save(newComment);						getColdboxOCM().clearEvent("general.viewPost","id=#rc.id#");						setNextRoute("general/viewPost/" & rc.ID);		</cfscript>    `
	</cffunction></cfcomponent>