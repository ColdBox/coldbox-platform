<CFOUTPUT>
<br>
<hr style="width:95%;" size="1" />

<!--- Help Div --->
<div class="sidemenu_help" id="sidemenu_help">
Help tips will be shown here. Just rollover certain areas or links and you will get some quick tips.
</div>

<!--- Toolbar --->
<div class="sidemenu_toolbar">

	<div class="sidemenu_toolbar_option">
	<img src="images/icons/print_icon.gif" align="absmiddle" id="btn_print" srcoff="images/icons/print_icon.gif"
		 srcon="images/icons/print_icon_on.gif" border="0" alt="Print!">&nbsp;<a href="javascript:window.print()" onMouseOver="rollover(btn_print)" onMouseOut="rollout(btn_print)">Print</a> <br>
	</div>

	<div class="sidemenu_toolbar_option">
	<img src="images/icons/help_icon.gif" align="absmiddle" id="btn_help" srcoff="images/icons/help_icon.gif"
		 srcon="images/icons/help_icon_on.gif" border="0" alt="Help Tips!">
		 <a href="javascript:helpToggle()" onMouseOver="rollover(btn_help)" onMouseOut="rollout(btn_help)">Help</a><br>
	</div>

	<div class="sidemenu_toolbar_option">
	 <img src="images/icons/logout.gif" id="btn_logout" srcoff="images/icons/logout.gif"
 	  srcon="images/icons/logout_on.gif" align="absmiddle" border="0" alt="Logout of the Dashboard">
		<a href="##" onClick="validateLogout() ? parent.window.location='index.cfm?event=#Event.getValue("xehLogout")#' : null" onMouseOver="rollover(btn_logout)" onMouseOut="rollout(btn_logout)" title="Logout of the Dashboard">Logout</a>
	</div>
</div>

<div style="margin-top:30px" align="center">
	<form action="https://www.paypal.com/cgi-bin/webscr" method="post" id="paypal_form" name="paypal_form" target="_blank">
	<input type="hidden" name="cmd" value="_s-xclick">
	<a class="action" href="javascript:document.paypal_form.submit()" title="Donate Now!">
		<span>Donate Now</span>
	</a>
	<img width="1" alt src="https://www.paypal.com/en_US/i/scr/pixel.gif" height="1" border="0">
	<input type="hidden" name="encrypted" value="-----BEGIN PKCS7-----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-----END PKCS7-----
	">
	</form>
</div>
</CFOUTPUT>