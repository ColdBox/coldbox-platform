<cfcomponent name="ssl" output="false" extends="coldbox.system.interceptor">

	<cffunction name="preEvent" access="public" returntype="void" output="false" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		
		<!--- SSL check? --->
		<cfif getProperty('isSSLCheck')>
			<cfset sslCheck(arguments.event)>
		</cfif>	
		
	</cffunction>

	<cffunction name="sslCheck" access="public" returntype="void" output="false" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
	  	<!--- http or https? --->
		<cfif not isSSL() and isSSLRequired(arguments.event)>
			<!--- redirect with SSL (any post data is lost) --->
			<cflocation url="https://#cgi.server_name##cgi.script_name#?#cgi.query_string#" addtoken="no">
		<cfelseif isSSL() and not isSSLRequired(arguments.event)>
			<!--- redirect without SSL (any post data is lost) --->
			<cflocation url="http://#cgi.server_name##cgi.script_name#?#cgi.query_string#" addtoken="no">
		</cfif>
	</cffunction>

	<cffunction name="isSSL" access="public" returntype="boolean">
		<cfset var isSSL = false>
		<!--- SSL Connection? --->
		<cfif isBoolean(cgi.server_port_secure) and cgi.server_port_secure>
			<cfset isSSL = true>
		</cfif>
		<cfreturn isSSL>
	</cffunction>
		
	<cffunction name="isSSLRequired" access="public" returntype="boolean" output="false">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		
		<cfset var isSSLRequired = false>
	  	<cfset var currentEvent = LCASE( arguments.event.getCurrentEvent() )>
	  	<cfset var currentHandler = LCASE( arguments.event.getCurrentHandler() )>
		<cfset var sslEventList = LCASE( getProperty('sslEventList') )>
	
		<!--- SSL Required for current event? --->
		<cfif sslEventList eq "*" or ListFind(sslEventList,currentEvent) or ListFind(sslEventList,"#currentHandler#.*")>
			<cfset isSSLRequired = true>
		</cfif>	
		<cfreturn isSSLRequired>
	</cffunction>
			
</cfcomponent>
