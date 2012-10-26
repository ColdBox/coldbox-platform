<h3>An Unhandled Exception Occurred</h3>

<cfoutput>
<table>
	<tr>
		<td colspan="2">An unhandled exception has occurred. Please look at the diagnostic information below:</td>
	</tr>
	<tr>
		<td valign="top"><strong>Type</strong></td>
		<td valign="top">#exception.type#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Message</strong></td>
		<td valign="top">#exception.message#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Detail</strong></td>
		<td valign="top">#exception.detail#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Extended Info</strong></td>
		<td valign="top">#exception.extendedInfo#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Message</strong></td>
		<td valign="top">#exception.message#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Tag Context</strong></td>
		<td valign="top">
	       <cfset variables.tagCtxArr = exception.tagContext	 />
	       <cfloop index="i" from="1" to="#ArrayLen(variables.tagCtxArr)#">
	               <cfset variables.tagCtx = variables.tagCtxArr[i] />
	               #variables.tagCtx['template']# (#variables.tagCtx['line']#)<br>
	       </cfloop>
		</td>
	</tr>
	<tr>
		<td valign="top"><strong>Stack Trace</strong></td>
		<td valign="top">#exception.stacktrace#</td>
	</tr>
</table>
</cfoutput>
