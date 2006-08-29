<!---
	Name         : ping
	Author       : Raymond Camden (mostly others wrote the methods)
	Created      : December 16, 2005
	Last Updated : December 20, 2005
	History      : wrap xmlparse in icerocket with try/catch (rkc 12/20/05)
	Purpose		 : Ping, baby, ping!
--->
<cfcomponent displayName="Ping" output="false">

	<!--- Code modified from Rey Bango's Blog --->
	<cffunction name="pingAggregators" access="public" returnType="void" output="false" 
				hint="Pings blog aggregators.">
		<cfargument name="pingurls" type="string" required="true">
		<cfargument name="blogtitle" type="string" required="true">
		<cfargument name="blogurl" type="string" required="true">
		
		<cfset var aURL = "">

		<cfloop index="aURL" list="#arguments.pingurls#">

			<cfif aURL is "@technorati">
				<cfset pingTechnorati(arguments.blogTitle, arguments.blogURL)>
			<cfelseif aURL is "@weblogs">
				<cfset pingweblogs(arguments.blogTitle, arguments.blogURL)>
			<cfelseif aURL is "@icerocket">
				<cfset pingIceRocket(arguments.blogTitle, arguments.blogURL)>
			<cfelse>
				<cfhttp url="#aURL#" method="GET" resolveurl="false">
			</cfif>
		</cfloop>
	   
	</cffunction>	

	<!---
		  This function written by Dave Carabetta
	--->
	<cffunction name="pingIceRocket" output="false" returnType="boolean" access="public"
	        		hint="Ping IceRocket.com to add blog to IceRocket high-priority indexing queue">
	    <cfargument name="blogtitle" type="string" required="true">
	    <cfargument name="blogurl" type="string" required="true">
	    
		<cfset var pingData = "" />
		<cfset var pingDataLen = "" />
		<cfset var isOK = false />
		<cfset var iceRocketResponse = "" />
		<cfset var pingResultString = "" />
		
		<cfoutput>
			<cfsavecontent variable="pingData">
			<?xml version="1.0" encoding="utf-8"?>
			<methodCall>
				<methodName>ping</methodName>
				<params>
					<param>
						<value>
							<string>#arguments.blogURL#</string>
						</value>
					</param>
				</params>
			</methodCall>
			</cfsavecontent>
		</cfoutput>
		
		<cfset pingData = trim(pingData) />
		<cfset pingDataLen = len(pingData) />
		
		<cfhttp method="post" url="http://rpc.icerocket.com/" port="10080" timeout="20" throwonerror="false">
		   <cfhttpparam type="HEADER" name="User_Agent" value="BlogCFC" />
		   <cfhttpparam type="HEADER" name="Host" value="#cgi.http_host#" />
		   <cfhttpparam type="HEADER" name="Content-Type" value="text/xml" />
		   <cfhttpparam type="HEADER" name="Content-Length" value="#pingDataLen#" />
		   
		   <cfhttpparam type="XML" value="#pingData#" />
		</cfhttp>
		
		<cftry>
			<!--- Create an XML object using the RPC result string --->
			<cfset iceRocketResponse = xmlParse(cfhttp.fileContent) />
			<!--- Set the response string to a local variable for cleaner access --->
			<cfset pingResultString = iceRocketResponse.methodResponse.params.param.value.string.xmlText />
			
			<!--- Check the status code and the XML packet's method response to make sure things worked --->
			<cfif not compare(cfhttp.statuscode, "200 OK") and not compare(pingResultString, "Thanks for ping")>
			   <cfset isOK = true />
			</cfif>
			<cfcatch>
				<cfset isOk = false>
			</cfcatch>
		</cftry>
			
		<cfreturn isOK />
	</cffunction>

	<!---
		  This function written by Steven Erat, www.talkingtree.com/blog
	--->
	<cffunction name="pingTechnorati" output="false" returnType="boolean" access="public"
         		hint="Ping Technorati.com to add blog to Technorati high-priority indexing queue">
	    <cfargument name="blogtitle" type="string" required="true">
	    <cfargument name="blogurl" type="string" required="true">
		
		<cfset var pingData = "">
		<cfset var pingDataLen = "">
		
		<cfoutput>
		   <cfsavecontent variable="pingData">
		      <?xml version="1.0"?>
		      <methodCall>
		       <methodName>weblogUpdates.ping</methodName>
		       <params>
		       <param>
		       <value>#arguments.blogTitle#</value>
		       </param>
		       <param>
		       <value>#arguments.blogURL#</value>
		       </param>
		       </params>
		      </methodCall>
		   </cfsavecontent>
		</cfoutput>

		<cfset pingData = trim(pingData)>
		<cfset pingDataLen = len(pingData)>
		<cfhttp method="POST" url="http://rpc.technorati.com/rpc/ping" timeout="20" throwonerror="No">
		   <cfhttpparam type="HEADER" name="User-Agent" value="BlogCFC"/>
		   <cfhttpparam type="HEADER" name="Content-length" value="#pingDataLen#"/>
		   <cfhttpparam type="XML" value="#pingData#"/>
		</cfhttp>
		<cfif cfhttp.statuscode contains "200" and cfhttp.filecontent contains "Thanks for the ping">
		   <cfreturn true>
		<cfelse>
		   <cfreturn false>
		</cfif>

	</cffunction>	

	<!---
		This function written by Rob Gonda, www.robgonda.com/blog
	--->
	<cffunction name="pingWeblogs" output="false" returnType="boolean" access="public" 
				hint="Ping weblogs.com to add blog to high-priority indexing queue">
	    <cfargument name="blogtitle" type="string" required="true">
	    <cfargument name="blogurl" type="string" required="true">
				
		<cfset var pingData = "">
		<cfset var pingDataLen = "">

		<cfoutput>
		<cfsavecontent variable="pingData">
			<?xml version="1.0"?>
			<methodCall>
				<methodName>weblogUpdates.ping</methodName>
				<params>
					<param><value>#arguments.blogTitle#</value></param>
					<param><value>#arguments.blogURL#</value></param>
				</params>
			</methodCall>
		</cfsavecontent>
		</cfoutput>

 		<cfset pingData = trim(pingData)>
		<cfset pingDataLen = len(pingData)>

		<cfhttp method="POST" url="http://rpc.weblogs.com/RPC2" timeout="20" throwonerror="No">
			<cfhttpparam type="HEADER" name="User-Agent" value="BlogCFC"/>
			<cfhttpparam type="HEADER" name="Content-length" value="#pingDataLen#"/>
			<cfhttpparam type="XML" value="#pingData#"/>
		</cfhttp>

		<cfif cfhttp.statuscode contains "200" and cfhttp.filecontent contains "<member><name>flerror</name><value><boolean>0</boolean>">
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>

 	</cffunction>   

</cfcomponent>