<script language="javascript" src="jquery-latest.pack.js"></script>
<script language="javascript" src="jquery.block.js"></script>
<link href="style.css" rel="stylesheet" type="text/css">

<script type="text/javascript"> 
    $(function() { 
        // cache the question element 
        var question = $('#helpbox')[0]; 
        
        $.extend($.blockUI.defaults.overlayCSS, { backgroundColor: '#333333', opacity: '0.5' });
 
        $('#OpenHelp').click(function() { 
            $.blockUI(question,{backgroundColor:'black',width:'350',border:'none',top:'25%'});
        }); 
  
        $('#CloseHelp').click($.unblockUI); 
    }); 
</script> 
 
<input id="OpenHelp" type="submit" value="Test Dialog" /> 


<div id="helpbox" class="helpbox" style="display:none" align="left">

	<div class="helpbox_header">
	  <div class="helpbox_header_title"><img src="images/icons/icon_guide_help.gif" align="absmiddle"> Help Tip</div>
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
	<div align="right" style="margin-right:5px;">
	<input type="button" id="CloseHelp" name="CloseHelp" value="Close" style="font-size:9px">
	</div>
</div>
