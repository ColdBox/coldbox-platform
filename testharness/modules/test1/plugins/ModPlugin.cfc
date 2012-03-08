<!-----------------------------------------------------------------------
Author 	 :	
Date     :	1/19/2010
Description : 			
 
		
----------------------------------------------------------------------->
<cfcomponent cache="false" extends="coldbox.system.Plugin">
  
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->	
   
    <cffunction name="init" access="public" returntype="ModPlugin" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
  		super.Init(arguments.controller);
  		setpluginName("");
  		setpluginVersion("");
  		setpluginDescription("");
  		setPluginAuthor("");
  		setPluginAuthorURL("");
  		//My own Constructor code here
  		
  		//Return instance
  		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->	

	<!--- printToday --->
	<cffunction name="printToday" output="false" access="public" returntype="any" hint="">
		<cfreturn dateformat(now(),"full") & "" & timeFormat(now(), "full")>
	</cffunction>
	    
<!------------------------------------------- PRIVATE ------------------------------------------->	

	
</cfcomponent>