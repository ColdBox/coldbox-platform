<cfsetting enablecfoutputonly=true>
<!---
	Name         : index.cfm
	Author       : Raymond Camden 
	Created      : July 5, 2006
	Last Updated : 
	History      : 
	Purpose		 : Confirms a user.
--->

<cfoutput>
<p>
<table width="500" cellpadding="6" class="tableDisplay" cellspacing="1" border="0">
	<tr class="tableHeader">
		<td class="tableHeader">Registration Confirmation</td>
	</tr>
	<tr class="tableRowMain">
		<td>
		<cfif rc.result>
			<p>
			Thank you for confirming your registration. You will now have to <a href="index.cfm?event=#Event.getValue("xehLogin")#">login</a>
			to finalize the process.
			</p>
		<cfelse>
			<p>
			Sorry, but we were unable to confirm your registration code. Please ensure you copied the complete
			URL from your mail client.
			</p>
		</cfif>
		</td>
	</tr>
</table>
</p>
</cfoutput>

<cfsetting enablecfoutputonly=false>