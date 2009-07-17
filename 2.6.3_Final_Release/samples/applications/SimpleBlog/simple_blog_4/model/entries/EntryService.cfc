<!-----------------------------------------------------------------------
Author 	 :	Henrik Joreteg
Date     :	October, 2008
Description : 			
	This is a service for handling blog entries.
	
----------------------------------------------------------------------->
<cfcomponent displayname="EntryService" hint="Service layer for handling blog entries" output="false">

<!----------------------------------- CONSTRUCTOR --------------------------------------->	
	
	<cfscript>
		//instance scope
		instance = structnew();
	</cfscript>
	
	<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">
		<cfargument name="transfer" type="any">
		<cfset instance.transfer = arguments.transfer>
		<!--- Any constructor code here --->
			
		<cfreturn this>
	</cffunction>

<!----------------------------------- PUBLIC METHODS --------------------------------------->

	<!--- getEntry --->
	<cffunction name="getEntry" access="public" returntype="any" output="false" hint="">
		<cfargument name="id" type="any" required="false">
	       
	    <cfscript>
			if (structKeyExists(arguments,"id")){
				return instance.transfer.get("posts.entry",arguments.id);
			}
			else {
				return instance.transfer.new("posts.entry");
			}
		</cfscript>
	     
	</cffunction>
	
	<!--- getLatestEntries --->
	<cffunction name="getLatestEntries" access="public" returntype="any" output="false" hint="">
	    
	    <cfscript>
			return instance.transfer.list("posts.entry","time", false);
		</cfscript>
	     
	</cffunction>
	
	<!--- saveEntry --->
	<cffunction name="saveEntry" access="public" returntype="void" output="false" hint="">
		<cfargument name="newEntry" type="any" required="yes">
	       
	    <cfscript>
			instance.transfer.save(newEntry);
		</cfscript>
	     
	</cffunction>
	
	<!--- deleteEntry --->
	<cffunction name="deleteEntry" access="public" returntype="void" output="false" hint="">
		<cfargument name="Entry" type="any" required="yes">
	       
	    <cfscript>
			instance.transfer.cascadeDelete(Entry);
		</cfscript>
	     
	</cffunction>
	
	<!--- findEntries --->
	<cffunction name="findEntries" access="public" returntype="void" output="false" hint="">
		<cfargument name="id" type="any" required="yes">
	       
	       <!--- TQL goes here (LEARN TQL!) --->
	     
	</cffunction>
	
</cfcomponent>