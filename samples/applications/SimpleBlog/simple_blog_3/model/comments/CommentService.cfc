<cfcomponent displayname="CommentService" hint="Service to handle comment operations." output="false" cache="true" cachetimeout="0">

	<!--- Dependencies --->
	<cfproperty name="Transfer" type="ocm" scope="instance">
	
<!----------------------------------- CONSTRUCTOR --------------------------------------->	
	
	<cfscript>
		//instance scope
		instance = structnew();
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">
    	<cfreturn this>
	</cffunction>

<!----------------------------------- PUBLIC METHODS --------------------------------------->

	<!--- getComment --->
	<cffunction name="getComment" access="public" returntype="any" output="false" hint="">
		<cfargument name="id" type="any" required="false">
	       
	    <cfscript>
			if (structKeyExists(arguments,"id")){
				return instance.transfer.get("posts.comment",id);
			}
			else {
				return instance.transfer.new("posts.comment");
			}
		</cfscript>
	     
	</cffunction>
	
	<!--- getComments --->
	<cffunction name="getComments" access="public" returntype="any" output="false" hint="">
		<cfargument name="entry_id" type="any" required="true">
		<cfset var query = 0>
		
	    <cfscript>
			query = instance.transfer.createQuery("from posts.comment join posts.entry where posts.entry.entry_id = :entry_id");
			query.setParam("entry_id",entry_id,"string");
			return instance.transfer.listByQuery(query);
		</cfscript>
	     
	</cffunction>
	
	<!--- saveComment --->
	<cffunction name="saveComment" access="public" returntype="void" output="false" hint="">
		<cfargument name="comment" type="any" required="yes">
    
	    <cfscript>
			instance.transfer.save(arguments.comment);
		</cfscript>
	     
	</cffunction>
	
	<!--- deleteComment --->
	<cffunction name="deleteComment" access="public" returntype="void" output="false" hint="">
		<cfargument name="Comment" type="any" required="yes">
	       
	    <cfscript>
			instance.transfer.delete(Comment);
		</cfscript>
	     
	</cffunction>
	
	<!--- findComments --->
	<cffunction name="findComments" access="public" returntype="void" output="false" hint="">
		<cfargument name="id" type="any" required="yes">
	       
	       <!--- TQL goes here (LEARN TQL!) --->
	     
	</cffunction>
	

</cfcomponent>