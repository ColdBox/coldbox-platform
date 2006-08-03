<cfoutput>
<link href="../includes/style.css" rel="stylesheet" type="text/css">
<span class="dashboardTitles">#getresource("changepassword")#</span>
<p>#getresource("changepassword_message")#  </p>

<form name="form_passchange" method="post" action="#cgi.SCRIPT_NAME#">
#getPlugin("messagebox").render()#
  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="2">
    <tr>
      <td width="29%" align="right"><strong>#getresource("current_password")#: </strong></td>
      <td width="71%"><label>
        <input name="current_password" type="password" class="textboxes" id="current_password" size="35">
      </label></td>
    </tr>
    <tr>
      <td align="right"><strong>#getresource("new_password")#: </strong></td>
      <td><input name="new_password" type="password" class="textboxes" id="new_password" size="35"></td>
    </tr>
    <tr>
      <td align="right"><strong>#getresource("confirm_password")#: </strong></td>
      <td><input name="new_password2" type="password" class="textboxes" id="new_password2" size="35" ></td>
    </tr>
    <tr>
      <td colspan="2" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="2" align="center">
        <input name="submit" type="submit" class="buttons" value="#getresource("changepassword")#" onClick="return validatePass()">
        <input name="event" type="hidden" id="event" value="ehColdBox.doChangePassword">
	</td>
    </tr>
  </table>
</form>
</cfoutput>