<cfoutput>
<!--- Display Components View --->
#renderView("vwComponents")#
</cfoutput>

<!--- Display the Generated View --->
<cfset arrComponents = getValue("arrComponents") />
<cfoutput>
<cfloop from="1" to="#arrayLen(arrComponents)#" index="i">
	<p><strong>#ucase(arrComponents[i].name)#:</strong><br />
	<textarea rows="20" style="width:100%;" onclick="javascript:this.focus();this.select()">#arrComponents[i].content#</textarea></p>
</cfloop>
</cfoutput>

