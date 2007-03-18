<cfoutput>
<!--- HELPBOX --->
#renderView("tags/help")#

<form name="updateform" id="updateform" action="javascript:doFormEvent('#Event.getValue("xehDoSave")#','content',document.updateform)" method="post">
	<div class="maincontentbox">
		<div class="contentboxes_header">
		<div class="contentboxes_title"><img src="images/icons/bugreports_27.gif" align="absmiddle" />&nbsp; Submit A Bug</div>
	</div>

	<!--- Messagebox --->
	#getPlugin("messagebox").renderit()#

	<div class="contentboxes">

	<p>Submit a new bug to the official bug reports email address.
	   You can use this form or just send an email to: <a href="mailto:bugs@coldboxframework.com">bugs@coldboxframework.com</a>
	   &nbsp;This form uses your ColdFusion Server Mail Settings to send the email.
	</p>
	<br>
		<div style="margin: 5px">
		<span class="redtext">* Required Fields</span><br><br>
	    <table width="100%" border="0" cellspacing="0" cellpadding="5" class="tablelisting">

	     <tr bgcolor="##f5f5f5">
	     	<td align="right"  style="border-right:1px solid ##ddd">
	     	<strong>From Email Address: <span class="redtext">*</span></strong><br />
	     	(Used in the FROM for cfmail)
	     	</td>
	     	<td>
	     	<input type="text" name="email" value="" size="30" >
	     	</td>
	     </tr>

	      <tr >
	     	<td align="right"  style="border-right:1px solid ##ddd">
	     	<strong>Your Name: <span class="redtext">*</span></strong>
	     	</td>
	     	<td>
	     	<input type="text" name="name" value="" size="30" >
	     	</td>
	     </tr>

	     <tr bgcolor="##f5f5f5">
	     	<td align="right"  style="border-right:1px solid ##ddd">
	     	<strong>Bug To Report: <span class="redtext">*</span></strong>
	     	</td>
	     	<td>
	     	<textarea name="bugreport" rows="20" cols="45" ></textarea>
	     	</td>
	     </tr>

        </table>
		</div>

		<div align="center">
		<a class="action" href="javascript:document.updateform.submit()" title="Send Bug Report">
			<span>Send Bug Report</span>
		</a>
		</div>
	</div>
</div>
</form>
</cfoutput>