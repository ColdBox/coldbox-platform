<cfoutput>
<div id="basic_set"  style="display: block">
<fieldset>
   <legend><strong>Basic Configuration</strong></legend>
   <table width="100%" border="0" cellspacing="0" cellpadding="5" class="tablelisting">
 
 <tr onMouseOver="getHint('appname')" onMouseOut="resetHint()">
    	<td align="right" width="40%" style="border-right:1px solid ##ddd">
    	<strong>Application Name <span class="redtext">*</span></strong>
    	<br />(Try not to use strange characters)
    	</td>
    	<td>
    	<input type="text" name="appname" id="appname" value="" size="25" maxlength="30"> <em>Keep it simple!!</em>
    	</td>
    </tr>	
    
    <tr bgcolor="##ffffff" onMouseOver="getHint('appmapping')" onMouseOut="resetHint()">
    	<td align="right"  style="border-right:1px solid ##ddd">
    	<strong>Application Mapping <span class="redtext">*</span></strong>
    	<br />(Relative from web root or CF mapping)
    	</td>
    	<td>
    	<input type="text" name="appmapping" id="appmapping" value="" size="40"> <a href="javascript:openBrowser('#Context.getValue("xehFileBrowser")#','appmapping')" title="Select from web root"><img id="appmapping_img" src="images/icons/folder.png" border="0" align="absmiddle" title="Select from web root"></a>
    	</td>
    </tr>
    
    <tr onMouseOver="getHint('debugmode')" onMouseOut="resetHint()">
    	<td align="right"  style="border-right:1px solid ##ddd">
    	<strong>Debug Mode<span class="redtext">*</span></strong>                                     
    	</td>
    	<td>
    	<select name="debugmode" id="debugmode">
    		<option value="true" selected >Enabled</option>
    		<option value="false" >Disabled</option>
    	</select>
    	</td>
    </tr>	 
    
    <tr bgcolor="##ffffff" onMouseOver="getHint('debugpassword')" onMouseOut="resetHint()">
    	<td align="right"  style="border-right:1px solid ##ddd">
    	<strong>Debug Password<span class="redtext">*</span></strong><br />(Please do not leave blank)
    	</td>
    	<td>
    	<input type="text" name="debugpassword" id="debugpassword" value="coldbox_#gettickcount()#" size="25">
    	</td>
    </tr>
    
    <tr onMouseOver="getHint('enabledumpvar')" onMouseOut="resetHint()">
    	<td align="right"  style="border-right:1px solid ##ddd">
    	<strong>Enable Dump Var URL Action<span class="redtext">*</span></strong>
    	</td>
    	<td>
    	<select name="enabledumpvar" id="enabledumpvar">
    		<option value="true" selected  >Enabled</option>
    		<option value="false" >Disabled</option>
    	</select>
    	</td>
    </tr>	
    
    <tr bgcolor="##ffffff" onMouseOver="getHint('udflibraryfile')" onMouseOut="resetHint()">
    	<td align="right"  style="border-right:1px solid ##ddd">
    	<strong>UDF Library File</strong><br />(Relative from app root or use CF Mappings)
    	</td>
    	<td>
    	<input type="text" name="udflibraryfile" id="udflibraryfile" value="" size="25"><br />(Leave blank if not used)
    	</td>
    </tr>
    
     <tr onMouseOver="getHint('messageboxstyleclass')" onMouseOut="resetHint()">
    	<td align="right"  style="border-right:1px solid ##ddd">
    	<strong>Messagebox Style Class</strong>
    	</td>
    	<td>
    	<input type="text" name="messageboxstyleclass" id="messageboxstyleclass" value="" size="25"><br />(Leave blank if not used)
    	</td>
    </tr>	
    
     <tr bgcolor="##ffffff" onMouseOver="getHint('defaultlayout')" onMouseOut="resetHint()">
    	<td align="right"  style="border-right:1px solid ##ddd">
    	<strong>Default Application Layout<span class="redtext">*</span></strong><br />
    	</td>
    	<td>
    	<input type="text" name="defaultlayout" id="defaultlayout" value="Layout.Main.cfm" size="25">
    	</td>
    </tr>
    
    <tr onMouseOver="getHint('customerrortemplate')" onMouseOut="resetHint()">
    	<td align="right"  style="border-right:1px solid ##ddd" >
    	<strong>Custom Error Template</strong><br />(Relative from app root or CF Mappings)                            
    	</td>
    	<td>
    	<input type="text" name="customerrortemplate" id="customerrortemplate" value="" size="25"><br />(Leave blank if not used)
    	</td>
    </tr>	
    
      </table>
      <!--- Required Fields --->
      <div class="redtext">* Required Fields</div>
      
      <!--- Navigation --->
      <div align="right">
      <input type="button" name="next_btn" value="Next >>" onClick="validate_basic()">
      </div>
      
      </fieldset>
</div>
</cfoutput>