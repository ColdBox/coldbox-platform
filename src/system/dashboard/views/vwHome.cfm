<cfoutput>
<div class="sidemenu">
	<!--- Title Bar --->
	<div class="sidemenu_title">
	    <div class="sidemenu_title_img"  ><img src="images/icons/home_27.gif"></div>
		<div class="sidemenu_title_text" >System Information</div>
	</div>
	
	<!--- Sub Menu Links --->
	<ul>
		<li><a href="?event=#getValue("xehHome")#">System Information</a></li>
		
		<li><a href="##">Online Resources</a></li>
		
		<cfif not application.isBD>
		<li><a href="##">CFC Documentation</a></li>
		</cfif>
		
		<li><a href="javascript:doEvent('#getValue("xehSchemaDocs")#', 'content', {})">Config Schema Docs</a></li>
	</ul>
	
	<br>
	<hr style="width:95%;" size="1" />
	
	<div class="sidemenu_help" id="sidemenu_help">
	Help will be shown here, such as rollovers on all the links.
	</div>
	
	<div class="sidemenu_toolbar">
		
		<div class="sidemenu_toolbar_option">
		<img src="images/icons/print_icon.gif" align="absmiddle" id="btn_print" srcoff="images/icons/print_icon.gif"
			 srcon="images/icons/print_icon_on.gif" border="0" alt="Print!">&nbsp;<a href="javascript:window.print()" onMouseOver="rollover(btn_print)" onMouseOut="rollout(btn_print)">Print</a> <br>
		</div>
		
		<div class="sidemenu_toolbar_option">
		<img src="images/icons/help_icon.gif" align="absmiddle" id="btn_help" srcoff="images/icons/help_icon.gif"
			 srcon="images/icons/help_icon_on.gif" border="0" alt="Help Tips!">&nbsp;<a href="##" onMouseOver="rollover(btn_help)" onMouseOut="rollout(btn_help)">Help</a> <br>
		</div>
		
		<div class="sidemenu_toolbar_option">
		 <img src="images/icons/logout.gif" id="btn_logout" srcoff="images/icons/logout.gif" 
	 	  srcon="images/icons/logout_on.gif" align="absmiddle" border="0" alt="Logout of the Dashboard">
			<a href="##" onClick="validateLogout() ? parent.window.location='index.cfm?event=#getValue("xehLogout")#' : null" onMouseOver="rollover(btn_logout)" onMouseOut="rollout(btn_logout)" title="Logout of the Dashboard">Logout</a>
		</div>
	</div>
	
</div>

<div class="content">
	
</div>
</cfoutput>