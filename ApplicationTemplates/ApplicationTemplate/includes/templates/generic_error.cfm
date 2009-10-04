<cfset exceptionBean = event.getValue("ExceptionBean") />

<h3>An Unhandled Exception Occurred</h3>

<cfoutput>
<table>
	<tr>
		<td colspan="2">An unhandled exception has occurred. Please look at the diagnostic information below:</td>
	</tr>
	<tr>
		<td valign="top"><strong>Type</strong></td>
		<td valign="top">#exceptionBean.getType()#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Message</strong></td>
		<td valign="top">#exceptionBean.getMessage()#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Detail</strong></td>
		<td valign="top">#exceptionBean.getDetail()#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Extended Info</strong></td>
		<td valign="top">#exceptionBean.getExtendedInfo()#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Message</strong></td>
		<td valign="top">#exceptionBean.getMessage()#</td>
	</tr>
	<tr>
		<td valign="top"><strong>Tag Context</strong></td>
		<td valign="top">
	       <cfset variables.tagCtxArr = exceptionBean.getTagContext() />
	       <cfloop index="i" from="1" to="#ArrayLen(variables.tagCtxArr)#">
	               <cfset variables.tagCtx = variables.tagCtxArr[i] />
	               #variables.tagCtx['template']# (#variables.tagCtx['line']#)<br>
	       </cfloop>
		</td>
	</tr>
	<tr>
		<td valign="top"><strong>Stack Trace</strong></td>
		<td valign="top">#exceptionBean.getStackTrace()#</td>
	</tr>
</table>
</cfoutput>
