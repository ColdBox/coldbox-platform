<cfset qryData = Event.getValue("qryData")>
<cfset tagValueArray = ListToArray(ValueList(qryData.tagCount))>
<cfset max = ArrayMax(tagValueArray)>
<cfset min = ArrayMin(tagValueArray)>
<cfset diff = max - min>
<cfset distribution = diff / 20>

<p style="line-height:20px;">
	<div class="nicebox">
	<div style="font-weight:bold;margin-bottom:10px;">All Tags:</div>
	<cfoutput query="qryData">
		<cfif qryData.tagCount EQ min>
			<cfset class="smallestTag">
		<cfelseif qryData.tagCount EQ max>
			<cfset class="largestTag">
		<cfelseif qryData.tagCount GT (min + (distribution*2))>
			<cfset class="largeTag">
		<cfelseif qryData.tagCount GT (min + distribution)>
			<cfset class="mediumTag">
		<cfelse>
			<cfset class="smallTag">
		</cfif>
		<a href="javascript:doEvent('#Event.getValue("xehSearchTag")#','centercontent',{tag:'#tag#'});" class="#class#">#qryData.tag#</a>&nbsp;
	</cfoutput>
	<cfif qryData.recordCount eq 0>
		<em>No Tags</em>
	</cfif>
	</div>
</p>
