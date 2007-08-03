<script language="javascript" src="jquery-latest.pack.js"></script>
<script language="javascript" src="jqModal.js"></script>
<script language="javascript" src="jqDnR.js"></script>
<link href="style.css" rel="stylesheet" type="text/css">

<style>


.jqmOverlay{ 
	background-color: black;
	opacity: 0.75;
}
</style>

<script language="javascript">
$(document).ready(function() {
	$("#helpbox").jqm({
		modal:false,
		onShow: function(h) {h.w.fadeIn();},
        onHide: function(h) {h.w.fadeOut();h.o.remove();} }).jqDrag('.helpbox_header');
	 
	$('#OpenHelp').click(function(){ 
		 $("#helpbox").jqm().jqmShow();
    }); 
    $('#CloseHelp').click(function(){ 
		 $("#helpbox").jqm().jqmHide();
    }); 
});
</script>

<input type="button" id="OpenHelp" value="Open Help">

<div id="helpbox" class="helpbox" style="display:none" align="left">

	<div class="helpbox_header">
	  <div class="helpbox_header_title"><img src="images/icons/icon_guide_help.gif" align="absmiddle"> Help Tip</div>
	  <div class="helpbox_header_close">
		<input type="button" id="CloseHelp" name="CloseHelp" value="Close" style="font-size:9px">
	  </div>
	</div>
	
	<div class="helpbox_message">
	  <ul>
	  	<li>Welcome to your ColdBox Dashboard application. This intuitive dashboard will help you get familiarized
	  	with ColdBox and all of its features.</li>
	  	<li>You can use the Home section to look at the framework's system information, cfc documentation and online resources.</li>
	  	<li>The Settings section will let you see the read only settings of the framework, logging facility settings, file encoding
	  	settings, change your dashboard password, and change your auto-update proxy settings.</li>
	  	<li>The Tools sections includes an Application Skeleton Generator, Brian Rinaldi's CFC Generator and the ColdBox Log Viewer
	  	application.</li>
	  	<li>The Update section will let you see if there are any updates to your framework and you can either download the bits or auto-update
	  	right from this cool application.</li>
	  	<li>The Submit Bug is just a simple mail form that will let you email a new bug to the official bug registry.</li>
	  </ul>
	</div>
	
</div>

<form name="infoform" id="infoform" action="">
	<fieldset>
		<legend ><strong>Framework Information</strong></legend>
		<div style="margin: 5px">
	    <table width="100%" border="0" cellspacing="0" cellpadding="5" class="tablelisting">
	      
	      <tr>
            <td width="30%" align="right" valign="top"><strong>Framework ID:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd">#getSetting("codename",1)# #getSetting("version",1)# #getSetting("suffix",1)#</td>
          </tr>
          <tr bgcolor="##ffffff">
            <td align="right" valign="top"><strong>Author:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd">#getSetting("author",1)#</td>
          </tr>
          <tr>
            <td align="right" valign="top"><strong>Author Website:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd">#getSetting("authorWebsite",1)#</td>
          </tr>
          <tr bgcolor="##ffffff">
            <td align="right" valign="top"><strong>Official Email:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd">#getSetting("AuthorEmail",1)#</td>
          </tr>
        </table>
		</div>
	</fieldset>
	<br /><br />