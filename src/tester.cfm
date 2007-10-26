<cftry>
<cfset test = CreateObject("component","coldboxproxy")>


	<cfcatch type="any">

	<cfdump var="#cfcatch#">
	</cfcatch>

</cftry>

<cfdump var="#test#">