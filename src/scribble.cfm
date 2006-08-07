<cfset arrayTagContext = arraynew(1)>

<cfloop from="1" to="10" index="i">
<cfset str = structnew()>
<cfset str.ID = "CFTRYEDD" & randrange(1,92323)>
<cfset str.LINE = randrange(132,1234124332)>
<cfset str.TEMPLATE = "pio.cfm">

<cfset arrayAppend(arrayTagContext,str)>
</cfloop>

<cfset rtnString = "">
<cfloop from="1" to="#arrayLen(arrayTagContext)#" index="i">
  <cfsavecontent variable="entry"><cfoutput>ID: <cfif not structKeyExists(arrayTagContext[i], "ID")>N/A<cfelse>#arrayTagContext[i].ID#</cfif>; LINE: #arrayTagContext[i].LINE#; TEMPLATE: #arrayTagContext[i].Template# #chr(13)#</cfoutput></cfsavecontent>
  <cfset rtnString = rtnString & entry>
</cfloop>

<cfoutput><pre>#rtnString#</pre></cfoutput>