<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	5/12/2009
Description :
	A facade to all CF scopes
----------------------------------------------------------------------->
<cfcomponent name="ScopeStorage" hint="A utility storage to all CF scopes" output="false">

	<cffunction name="init" access="public" returntype="ScopeStorage" hint="Constructor" output="false" >
		<cfscript>
			instance = structnew();
			instance.scopes = "application|client|cookie|session|server|cluster|request";
			
			return this;
		</cfscript>
	</cffunction>
	
	<!----------------------------------------- PUBLIC ------------------------------------->	
	
	<cffunction name="put" access="public" returntype="void" hint="Put into a scope" output="false" >
		<cfargument name="key"    type="string" required="true" hint="The key value">
		<cfargument name="value"  type="any" required="true" hint="The value to put">
		<cfargument name="scope"  type="string" required="true" hint="The CF scope to place it in">
		<cfscript>
			var scopePointer = getScope(arguments.scope);
			scopePointer[arguments.key] = arguments.value;
		</cfscript>
	</cffunction>
	
	<cffunction name="delete" access="public" returntype="boolean" hint="delete from a scope" output="false" >
		<cfargument name="key"    type="string" required="true" hint="The key value">
		<cfargument name="scope"  type="string" required="true" hint="The CF scope to place it in">
		<cfscript>
			return structDelete(getScope(arguments.scope),arguments.key,true);
		</cfscript>
	</cffunction>
	
	<cffunction name="get" access="public" returntype="any" hint="Get something from a scope. Throws exception if not found" output="false" >
		<cfargument name="key"    	type="string" required="true" hint="The key to retrieve">
		<cfargument name="scope"  	type="string" required="true" hint="The CF scope to get an object from">
		<cfargument name="default"  type="any" required="false" hint="The default value if not found">
		<cfscript>
			if( exists(arguments.key,arguments.scope) ){
				return structfind(getscope(arguments.scope),arguments.key);
			}
			else if ( structKeyExists(arguments,"default") ){
				return arguments.default;
			}
		</cfscript>
		<cfthrow type="ScopeStorage.KeyNotFound"
				 message="The key #arguments.key# does not exist in the #arguments.scope# scope.">
	</cffunction>
	
	<cffunction name="exists" access="public" returntype="boolean" hint="Check if a value is in scope" output="false" >
		<cfargument name="key"    	type="string" required="true" hint="The key to retrieve">
		<cfargument name="scope"  	type="string" required="true" hint="The CF scope to get an object from">
		<cfscript>
			return structKeyExists(getScope(arguments.scope),arguments.key);	
		</cfscript>
	</cffunction>
	
	<cffunction name="getScope" access="public" returntype="struct" hint="Get a named scope" output="false" >
		<cfargument name="scope"  	type="string" required="true" hint="The CF scope to get an object from">
		<cfscript>
			scopeCheck(arguments.scope);
			
			switch( arguments.scope ){
				case "session" : { 
					if( isDefined("session") ){
						return session;
					}
					else{
						return structNew();
					}
				}
				case "application" : return application;
				case "server" : return server;
				case "client" : return client;
				case "cookie" : return cookie;
				case "cluster" : return cluster;
				case "request" : return request;
	 		}
		</cfscript>	
	</cffunction>
	
	<cffunction name="getSession" access="public" returntype="struct" hint="Get Session" output="false" >
		<cfreturn getScope("session")>
	</cffunction>
	<cffunction name="getApplication" access="public" returntype="struct" hint="Get application" output="false" >
		<cfreturn getScope("application")>
	</cffunction>
	<cffunction name="getClient" access="public" returntype="struct" hint="Get client" output="false" >
		<cfreturn getScope("client")>
	</cffunction>
	<cffunction name="getServer" access="public" returntype="struct" hint="Get server" output="false" >
		<cfreturn getScope("server")>
	</cffunction>
	<cffunction name="getCookie" access="public" returntype="struct" hint="Get cookie" output="false" >
		<cfreturn getScope("cookie")>
	</cffunction>
	<cffunction name="getCluster" access="public" returntype="struct" hint="Get cluster" output="false" >
		<cfreturn getScope("cluster")>
	</cffunction>
	
	<cffunction name="scopeCheck" access="public" returntype="void" hint="Check if a scope is valid, else throw exception" output="false" >
		<cfargument name="scope"  type="string" required="true" hint="The CF scope to check">
		<cfif NOT reFindNoCase("^(#instance.scopes#)$", arguments.scope)>
			<cfthrow message="Invalid CF Scope"
					 detail="The scope used: #arguments.scope# is invalid."
					 type="ScopeStorage.InvalidScopeException">
		</cfif>
	</cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	

</cfcomponent>