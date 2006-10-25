<cfoutput>
 <!--- ************************************************************* --->
       <!--- STEP 3: DEVELOPMENT SET --->
       <!--- ************************************************************* --->
       <div id="development_set"  style="display: none">
       <fieldset >
       <Br>
    <legend><strong>Development & Debugging Settings</strong></legend>
    <table width="100%" border="0" cellspacing="0" cellpadding="5" class="tablelisting">

	  <tr bgcolor="##ffffff" onMouseOver="getHint('appdevmapping')" onMouseOut="resetHint()">
     	<td align="right" width="40%"  style="border-right:1px solid ##ddd">
     	<strong>Application Dev Mapping </strong><br />(Relative from web root or CF mapping, leave blank if same as App Mapping)
     	</td>
     	<td>
     	<input type="text" name="appdevmapping" id="appdevmapping" value="" size="40"> <a href="javascript:openBrowser('#getValue("xehFileBrowser")#','appdevmapping')" title="Select from web root"><img id="appdevmapping_img" src="images/icons/folder.png" border="0" align="absmiddle"></a>
     	</td>
     </tr>

     <tr onMouseOver="getHint('configautoreload')" onMouseOut="resetHint()">
     	<td align="right"  style="border-right:1px solid ##ddd">
     	<strong>Config Auto Reload<span class="redtext">*</span></strong><br />(Use only for development)
     	</td>
     	<td>
     	<select name="configautoreload" id="configautoreload" onChange="toggleLogsLocation()">
     		<option value="true" selected >Enabled</option>
     		<option value="false" >Disabled</option>
     	</select>
     	</td>
     </tr>

	     <tr bgcolor="##ffffff" onMouseOver="getHint('handlersindexautoreload')" onMouseOut="resetHint()">
     	<td align="right"  style="border-right:1px solid ##ddd">
     	<strong>Handlers Index Auto Reload<span class="redtext">*</span></strong><br />(Use only for development)
     	</td>
     	<td>
     	<select name="handlersindexautoreload" id="handlersindexautoreload" onChange="toggleLogsLocation()">
     		<option value="true" selected >Enabled</option>
     		<option value="false" >Disabled</option>
     	</select>
     	</td>
     </tr>

     <tr onMouseOver="getHint('enablebugreports')" onMouseOut="resetHint()">
     	<td align="right"  style="border-right:1px solid ##ddd">
     	<strong>Enable Mailing Bug Reports<span class="redtext">*</span></strong>
     	</td>
     	<td>
     	<select name="enablebugreports" id="enablebugreports" onChange="toggleBugReportEmails()">
     		<option value="true"  selected>Enabled</option>
     		<option value="false"  >Disabled</option>
     	</select>
     	</td>
     </tr>

     <tr bgcolor="##ffffff" onMouseOver="getHint('bugreports')" onMouseOut="resetHint()" id="tr_bugreportEmails">
     	<td align="right"  style="border-right:1px solid ##ddd">
     	<strong>Emails Receiving Bug Reports</strong>
     	</td>
     	<td>
     	  <input name="bugemailadd" id="bugemailadd" type="text" size="20" />
		  <input type="button" name="addemail_btn" value="Add" onclick="addemail()"/>
		  <input type="button" name="addemail_btn" value="Remove" onclick="removeemail()" />
		  <br />
		  <select name="bugemails" size="5" id="bugemails" style="width: 250px">
		  </select>
     	</td>
     </tr>

     <tr onMouseOver="getHint('devenvironments')" onMouseOut="resetHint()">
     	<td align="right"  style="border-right:1px solid ##ddd">
     	<strong>Development Environments</strong><br />Add all the partial url's that will be considered as a Development Environment.
     	</td>
     	<td>
    	  <input name="devurladd" id="devurladd" type="text" size="20" />
		  <input type="button" name="adddev_btn" value="Add" onclick="addDevURL()"/>
		  <input type="button" name="removedev_btn" value="Remove" onclick="removeDevURL()" />
		  <br />
		  <select name="devurls" size="5" id="devurls" style="width: 250px">
		  <option value="dev">dev</option>
		  </select>
     	</td>
     </tr>

       </table>
        <!--- Required Fields --->
       <div class="redtext">* Required Fields</div>
       <!--- Navigation --->
       <div align="right">
       <input type="button" name="next_btn" value="<< Previous" onClick="stepper('development_set','applicationloggin_set','backward')"> &nbsp;
       <input type="button" name="next_btn" value="Next >>" onClick="stepper('development_set','webservices_set','forward')">
       </div>
       </fieldset>
       </div>
       <!--- ************************************************************* --->

</cfoutput>