<cfoutput>
<!--- HELPBOX --->
<div id="helpbox" class="helpbox" style="display: none">

	<div class="helpbox_header">
	  <div class="helpbox_header_title"><img src="images/icons/icon_guide_help.gif" align="absmiddle"> Help Tip</div>
	</div>
	
	<div class="helpbox_message" >
	  <ul>
	  	<li>You can see from ths screen wether an update is available or not. You can then choose to download
			the update or use the Dashboard's auto-update feature to install it.</li>
		<li>When you perform an auto-update for the framework, the updater will have to delete all the old
		files and make backups. If you have running applications, the installation might be corrupted or
		not possible. So please make sure all your applications are offline.</li>
	  </ul>
	</div>
	<div align="right" style="margin-right:5px;">
	<input type="button" value="Close" onClick="helpoff()" style="font-size:9px">
	</div>
</div>

<!--- CONTENT BOX --->
<div class="maincontentbox">
	
	<div class="contentboxes_header">
		<div class="contentboxes_title"><img src="images/icons/update_27.gif" align="absmiddle" />&nbsp; ColdBox Update Center</div>
	</div>
	
	<div class="contentboxes">
	<p>Below you can see the results of the distribution checks.
	</p>
	<br>
	<p align="center" class="redtext">When you do an auto-update, make sure there are no running applications.</p>
	<br /><br />
	<form id="updateform" name="updateform" method="post" action="javascript:doFormEvent('#getValue("xehCheck")#','content',document.updateform)" onSubmit="document.updateform.button_check.disabled=true">
	  <div align="center">
		<table width="100%" border="0" cellspacing="0" cellpadding="5" class="tablelisting">
          <tr>
            <th>Distribution Sites</th>
          </tr>
          
		  <cfloop query="qURLS">
            <tr <cfif currentrow mod 2 eq 0>bgcolor="##f5f5f5"</cfif>>
              <td valign="top"><input name="distribution_sites" type="radio" value="#url#" <cfif currentrow eq 1>checked="true"</cfif> />
	    #url#</label></td>
            </tr>
		   </cfloop>
        </table>
		<br /><br />
		<input type="submit" name="button_check" id="button_check" value="Check For Updates" class="buttons" />
	  </div>
	</form>
	</div>
	
</div>
</cfoutput>