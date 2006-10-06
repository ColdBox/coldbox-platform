<cfoutput>
<!--- HELPBOX --->
<div id="helpbox" class="helpbox" style="display: none">

	<div class="helpbox_header">
	  <div class="helpbox_header_title"><img src="images/icons/icon_guide_help.gif" align="absmiddle"> Help Tip</div>
	</div>
	
	<div class="helpbox_message" >
	  <ul>
	  	<li>Use this screen to submit a new bug to the official email address for bug reports.  As work progresses, this
			screen will be tightly integrated with the bug database.</li>
		<li>You must enter a mail server, username and password in order to send this bug report. If they are not filled out,
		then the settings in the CFMX/BlueDragon Administrator will be used.</li>
	  </ul>
	</div>
	<div align="right" style="margin-right:5px;">
	<input type="button" value="Close" onClick="helpoff()" style="font-size:9px">
	</div>
</div>

<form name="updateform" id="udpateform" action="javascript:doFormEvent('#getValue("xehDoSave")#','content',document.updateform)" method="post">
	<div class="maincontentbox">
		<div class="contentboxes_header">
		<div class="contentboxes_title"><img src="images/icons/bugreports_27.gif" align="absmiddle" />&nbsp; Submit A Bug</div>
	</div>
	
	<!--- Messagebox --->
	<cfif application.isBD>
		#getPlugin("messagebox").renderit()#
	<cfelse>
		#getPlugin("messagebox").render()#
	</cfif>
	
	<div class="contentboxes">
	
	<cfif getPlugin("clientstorage").exists("sentbugreport")>
		This is a copy of the bug report you sent to bugs@coldboxframework.com:<br /><br>
		<div style="border:1px solid ##ddd; background-color: ##fffff0;padding:10px; overflow: auto; width: 550px; height:400px;">
		#htmlCodeFormat(getPlugin("clientstorage").getVar("sentbugreport"))#
		</div>
		<cfset getPlugin("clientstorage").deleteVar("sentbugreport")>
	
	<cfelse>
	
	<p>Submit a new bug to the official bug reports email address. You can use this form or just send an email to: <a href="mailto:bugs@coldboxframework.com">bugs@coldboxframework.com</a></p>
	<br>
		<div style="margin: 5px">
	    <table width="100%" border="0" cellspacing="0" cellpadding="5" class="tablelisting">
		
	     <tr>
	     	<td align="right" width="35%" style="border-right:1px solid ##ddd">
	     	<strong>Mail Server: <br /></strong>(Leave Blank if using CFMX Settings)
	     	</td>
	     	<td>
		     	<input type="text" name="mailserver" value="" size="30">
	     	</td>
	     </tr>	
	     
	     <tr bgcolor="##f5f5f5">
	     	<td align="right"  style="border-right:1px solid ##ddd">
	     	<strong>Mail Username: <br /></strong>(Leave Blank if using CFMX Settings)
	     	</td>
	     	<td>
	     	<input type="text" name="mailusername" value="" size="30">
	     	</td>
	     </tr>
	     
	     <tr>
	     	<td align="right"  style="border-right:1px solid ##ddd">
	     	<strong>Mail Password: <br /></strong>(Leave Blank if using CFMX Settings)
	     	</td>
	     	<td>
	     	<input type="password" name="mailpassword" value="" size="30" >
	     	</td>
	     </tr>	 
	     
	     <tr bgcolor="##f5f5f5">
	     	<td align="right"  style="border-right:1px solid ##ddd">
	     	<strong>From Email Address: <span class="redtext">*</span></strong>
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
		<span class="redtext">* Required Fields</span>
		</div>
	</div>
	
	<div align="right" style="margin-right:5px;margin-bottom: 10px">
		<input type="submit" value="Send Bug Report" >
	</div>
	
	</cfif>
	
	
</div>
</form>
</cfoutput>