<cfset exception = event.getPrivateValue( "exception" ) />

<h3><strong>An Unhandled Exception Occurred</strong></h3>

<cfoutput>
<table>
	<tr>
		<td colspan="2">An unhandled exception has occurred. Please look at the diagnostic information below:</td>
	</tr>
	<tr>
		<td valign="top"><strong>Type</strong></td>
		<td valign="top">#exception.getType()#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Message</strong></td>
		<td valign="top">#exception.getMessage()#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Detail</strong></td>
		<td valign="top">#exception.getDetail()#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Extended Info</strong></td>
		<td valign="top">#exception.getExtendedInfo()#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Message</strong></td>
		<td valign="top">#exception.getMessage()#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Tag Context</strong></td>
		<td valign="top">
			<pre>
	       <cfset variables.tagCtxArr = exception.getTagContext() />
	       <cfloop index="i" from="1" to="#ArrayLen(variables.tagCtxArr)#">
	               <cfset variables.tagCtx = variables.tagCtxArr[i] />
	               #variables.tagCtx['template']# (#variables.tagCtx['line']#)<br>
	       </cfloop>
	   		</pre>
		</td>
	</tr>
	<tr>
		<td valign="top"><strong>Stack Trace</strong></td>
		<td valign="top"><pre>#exception.getStackTrace()#</pre></td>
	</tr>
</table>
</cfoutput>
