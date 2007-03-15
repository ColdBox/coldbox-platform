<cfoutput>
<div id="applicationloggin_set"  style="display: none">
       <fieldset >
        <Br>
    <legend><strong>Application Logging</strong></legend>
    <table width="100%" border="0" cellspacing="0" cellpadding="5" class="tablelisting">
	 
	 <tr onMouseOver="getHint('coldboxlogging')" onMouseOut="resetHint()">
     	<td align="right" width="40%" style="border-right:1px solid ##ddd">
     	<strong>ColdBox Logging<span class="redtext">*</span></strong><br />
     	</td>
     	<td>
     	<select name="coldboxlogging" id="coldboxlogging" onChange="toggleLogsLocation()">
     		<option value="true" selected >Enabled</option>
     		<option value="false" >Disabled</option>
     	</select>
     	</td>
     </tr>	
     
	     <tr bgcolor="##ffffff" id="tr_coldboxlogslocation" onMouseOver="getHint('coldboxlogslocations')" onMouseOut="resetHint()">
     	<td align="right"  style="border-right:1px solid ##ddd">
     	<strong>Colbox Log Location<span class="redtext">*</span> </strong><br />(Relative to app root or absolute path)
     	</td>
     	<td>
     	<input type="text" name="coldboxlogslocation" id="coldboxlogslocation" value="logs" size="40"> <a href="JavaScript:openBrowser('#Event.getValue("xehFileBrowser")#','coldboxlogslocation')" title="Select from web root"><img id="coldboxlogslocation_img" src="images/icons/folder.png" border="0" align="absmiddle"></a>
     	</td>
     </tr>
     
     <tr onMouseOver="getHint('coldfusionlogging')" onMouseOut="resetHint()">
     	<td align="right"  style="border-right:1px solid ##ddd">
     	<strong>Coldfusion Logging<span class="redtext">*</span></strong>                                     
     	</td>
     	<td>
     	<select name="coldfusionlogging" id="coldfusionlogging">
     		<option value="true"  >Enabled</option>
     		<option value="false" selected >Disabled</option>
     	</select>
     	</td>
     </tr>	 
     
       </table>
       </fieldset>
       <Br>
       <fieldset >        
    <legend><strong>i18N & Localization</strong></legend>
    <table width="100%" border="0" cellspacing="0" cellpadding="5" class="tablelisting">
	 
	  <tr bgcolor="##ffffff" onMouseOver="getHint('enablelocalization')" onMouseOut="resetHint()">
     	<td align="right" width="40%"  style="border-right:1px solid ##ddd">
     	<strong>Enable Localization: <span class="redtext">*</span></strong><br />(This has to be true in order to use the rest of the options)
     	</td>
     	<td>
     	<select name="i18nFlag" id="i18nFlag" onChange="togglei18n()">
     		<option value="true" selected >Enabled</option>
     		<option value="false" >Disabled</option>
     	</select>
     	</td>
     </tr>
     
	 <tr onMouseOver="getHint('defaultlocale')" onMouseOut="resetHint()" id="tr_locale">
     	<td align="right"  style="border-right:1px solid ##ddd">
     	<strong>Default Locale</strong><br />
     	</td>
     	<td>
     	<select name="defaultlocale" id="defaultlocale" size="1" onChange="toggleResourceBundle()">
		<cfloop index="i" from="1" to="#arrayLen(rc.locales)#">
			<option value="#rc.locales[i].toString()#" <cfif  "en_US" eq rc.locales[i].toString()>selected</cfif>>#rc.locales[i].toString()#</option>
		</cfloop>
		</select>
     	</td>
     </tr>	
     
	     <tr bgcolor="##ffffff" onMouseOver="getHint('localestorage')" onMouseOut="resetHint()" id="tr_localestorage">
     	<td align="right"  style="border-right:1px solid ##ddd">
     	<strong>Locale Storage Scope</strong><br />(Used internally by ColdBox)
     	</td>
     	<td>
     	<select name="defaultlocalestorage" id="defaultlocalestorage">
     		<option value="session" selected >Session</option>
     		<option value="client" >Client</option>
     	</select>
     	</td>
     </tr>
     
     <tr onMouseOver="getHint('resourcebundle')" onMouseOut="resetHint()" id="tr_resourcebundle">
     	<td align="right"  style="border-right:1px solid ##ddd">
     	<strong>Default Resource Bundle:</strong><br />(Relative from app root. Do not include locale or .properties extension.Leave Blank if not used.)                                     
     	</td>
     	<td>
     	<input type="text" name="defaultresourcebundle" id="defaultresourcebundle" value="" size="20"><span id="defaultresourcebundle_locale" style="font-weight:bold">_en_US.properties</span>
     	</td>
     </tr>	 
     
       </table>
       </fieldset>
       <!--- Required Fields --->
       <div class="redtext">* Required Fields</div>
    <!--- Navigation --->
    <div align="right">
       <input type="button" name="next_btn" value="<< Previous" onClick="stepper('applicationloggin_set','basic_set', 'backward')"> &nbsp;
       <input type="button" name="next_btn" value="Next >>" onClick="stepper('applicationloggin_set','development_set','forward')">
    </div>
       
</div>
</cfoutput>