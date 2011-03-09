<cfsavecontent variable="ticket">
1169
 
new injector shutdown() method to process graceful injector shutdown
Fixed
 
1170
 
new injector events: beforeInjectorShutdown, afterInjectorShutdown
Fixed
 
1171
 
all injector events now get a reference to the calling injector
Fixed
 
1172
 
builder not checking if constructor exists before executing it.
Fixed
 
1173
 
ioc coldbox dsl builder missing ioc factory reference
Fixed
 
1174
 
locateScopedSelf() added to injector to locate itself on a scoped registration to avoid scope widening issues
Fixed
</cfsavecontent>

<cfset split = ticket.split(chr(13))>
<cfset sb = createObject("java","java.lang.StringBuffer").init('')>

<cfset marker = 1>
<cfloop from="1" to="#arrayLen(split)#" index="i">
	<cfset thisVal = replace(trim(split[i]),chr(10),"")>
	<cfif len(trim(thisVal))>
		<cfif marker eq 1 >
			<cfset sb.append("* ##" & thisVal)>
			<cfset marker++>
		<cfelseif marker eq 2>
			<cfset sb.append(" " & thisVal)>
			<cfset marker++>
		<cfelseif marker eq 3>
			<cfset sb.append(chr(13))>
			<cfset marker =1>
		</cfif>
	</cfif>
</cfloop>

<cfoutput>
<textarea rows="30" cols="120">
#sb.toString()#
</textarea>
</cfoutput>

