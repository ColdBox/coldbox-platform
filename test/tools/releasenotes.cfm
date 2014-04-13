<cfsavecontent variable="ticket">
1180
 
cf store does not use createTimeSpan to create minute timespans for puts
New
 
1181
 
railo store does not use createTimeSpan to create minute timespans for puts
New
#	Summary	Status
 
1179
 
new cachebox store: BlackholeStore used for optimization and testing
Fixed
 
1182
 
updates to make it coldbox 3.0 compatible
Fixed
 
Release FilesEdit release notes and files

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

