<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

ForgeBox API REST Wrapper

Connects to forgebox for operations.  This plugin also uses logbox for debugging
and logging.  You must enable logbox for DEBUG level with the correct class name
if you want to add logging for this category only.

Example:
<Category name="myApp.plugins.ForgeBox" levelMax="DEBUG" />
or just add DEBUG to the root logger
<Root levelMax="DEBUG" />


Settings:

----------------------------------------------------------------------->
<cfcomponent hint="ForgeBox API REST Wrapper" output="false" extends="coldbox.system.Plugin" cache="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	
	<cfscript>
		this.ORDER = {
			POPULAR = "popular",
			NEW = "new",
			RECENT = "recent"
		};
	</cfscript>


	<cffunction name="init" access="public" returnType="ForgeBox" output="false" hint="Constructor">
		<cfargument name="controller" type="any"/>
		<cfscript>
			// Setup Plugin
			super.init(arguments.controller);
			
			setPluginName("ForgeBox API REST Wrapper");
			setPluginVersion("1.0");
			setPluginDescription("A REST wrapper to the ForgeBox API service");
			setPluginAuthor("Luis Majano");
			setPluginAuthorURL("http://www.luismajano.com");
			
			// Setup Properties
			instance.APIURL = "http://www.coldbox.org/index.cfm/api/forgebox";
			
			return this;
		</cfscript>
	</cffunction>
	
	<!--- Get/set API URL --->
	<cffunction name="getAPIURL" access="public" returntype="string" output="false" hint="Get the API URL endpoint">
		<cfreturn instance.APIURL>
	</cffunction>
	<cffunction name="setAPIURL" access="public" returntype="void" output="false" hint="Set the API URL endpoint">
		<cfargument name="APIURL" type="string" required="true">
		<cfset instance.APIURL = arguments.APIURL>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<!--- getTypes --->
	<cffunction name="getTypes" output="false" access="public" returntype="query" hint="Get an array of entry types">
		<cfscript>
		var results = "";
		
		// Invoke call
		results = makeRequest(resource="types");
		
		// error 
		if( results.error ){
			$throw("Error making ForgeBox REST Call",results.message);
		}
		
		return results.response.data;				
		</cfscript>	
	</cffunction>
	
	<!--- getEntries --->
	<cffunction name="getEntries" output="false" access="public" returntype="query" hint="Get entries">
		<cfargument name="orderBy"  type="string"  required="false" default="#this.ORDER.POPULAR#" hint="The type to order by, look at this.ORDERBY"/>
		<cfargument name="maxrows"  type="numeric" required="false" default="0" hint="Max rows to return"/>
		<cfargument name="startRow" type="numeric" required="false" default="1" hint="StartRow"/>
		<cfargument name="typeSlug" type="string" required="false" default="" hint="The tye slug to filter on"/>
		<cfscript>
			var results = "";
			var params = {
				orderBY = arguments.orderby,
				maxrows = arguments.maxrows,
				startrow = arguments.startrow,
				typeSlug = arguments.typeSlug	
			};
			
			// Invoke call
			results = makeRequest(resource="entries",parameters=params);
			
			// error 
			if( results.error ){
				$throw("Error making ForgeBox REST Call",results.message);
			}
			
			return results.response.data;				
		</cfscript>	
	</cffunction>
	
	<!--- getEntry --->
	<cffunction name="getEntry" output="false" access="public" returntype="struct" hint="Get an entry from forgebox by slug">
		<cfargument name="slug" type="string" required="true" default="" hint="The entry slug to retreive"/>
		<cfscript>
			var results = "";
			
			// Invoke call
			results = makeRequest(resource="entry/#arguments.slug#");
			
			// error 
			if( results.error ){
				$throw("Error making ForgeBox REST Call",results.message);
			}
			
			return results.response.data;				
		</cfscript>	
	</cffunction>
	
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- S3Request --->
    <cffunction name="makeRequest" output="false" access="private" returntype="struct" hint="Invoke a ForgeBox REST Call">
    	<cfargument name="method" 			type="string" 	required="false" default="GET" hint="The HTTP method to invoke"/>
		<cfargument name="resource" 		type="string" 	required="false" default="" hint="The resource to hit in the forgebox service."/>
		<cfargument name="body" 			type="any" 		required="false" default="" hint="The body content of the request if passed."/>
		<cfargument name="headers" 			type="struct" 	required="false" default="#structNew()#" hint="An struct of HTTP headers to send"/>
		<cfargument name="parameters"		type="struct" 	required="false" default="#structNew()#" hint="An struct of HTTP URL parameters to send in the request"/>
		<cfargument name="timeout" 			type="numeric" 	required="false" default="20" hint="The default call timeout"/>
		<cfscript>
			var results = {error=false,response={},message="",responseheader={},rawResponse=""};
			var HTTPResults = "";
			var param = "";
			var jsonRegex = "^(\{|\[)(.)*(\}|\])$";
			
			// Default Content Type
			if( NOT structKeyExists(arguments.headers,"content-type") ){
				arguments.headers["content-type"] = "";
			}
		</cfscript>
		
		<!--- REST CAll --->
		<cfhttp method="#arguments.method#" 
				url="#getAPIURL()#/json/#arguments.resource#" 
				charset="utf-8" 
				result="HTTPResults" 
				timeout="#arguments.timeout#">
			
			<!--- Headers --->
			<cfloop collection="#arguments.headers#" item="param">
				<cfhttpparam type="header" name="#param#" value="#arguments.headers[param]#" >
			</cfloop>	
			
			<!--- URL Parameters: encoded automatically by CF --->
			<cfloop collection="#arguments.parameters#" item="param">
				<cfhttpparam type="URL" name="#param#" value="#arguments.parameters[param]#" >
			</cfloop>	
			
			<!--- Body --->
			<cfif len(arguments.body) >
				<cfhttpparam type="body" value="#arguments.body#" >
			</cfif>	
		</cfhttp>
		
		<cfscript>
			// Log
			log.debug("ForgeBox Rest Call ->Arguments: #arguments.toString()#",HTTPResults);
			
			// Set Results
			results.responseHeader 	= HTTPResults.responseHeader;
			results.rawResponse 	= HTTPResults.fileContent.toString();
			
			// Error Details found?
			results.message = HTTPResults.errorDetail;
			if( len(HTTPResults.errorDetail) ){ results.error = true; }
			
			// Try to inflate JSON
			results.response = getPlugin("JSON").decode(results.rawResponse);
			
			return results;
		</cfscript>	
	</cffunction>
	
</cfcomponent>