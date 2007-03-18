<cfoutput>
<!--- HELPBOX --->
<div id="helpbox" class="helpbox" style="display: none">

	<div class="helpbox_header">
	  <div class="helpbox_header_title"><img src="images/icons/icon_guide_help.gif" align="absmiddle"> Help Tip</div>
	</div>
	
	<div class="helpbox_message" >
	  The Coldbox caching is an in memory cache that can fluctuate according to the set parameters.<br><br />
	  
	  <h3>Object Default Timeout</h3>
	  <p>This is the default timeout in minutes an object will live in cache if no pre-determined timeout is
		used at the time of setting in cache.
	  </p>
	  
	  <h3>Last Access Timeout</h3>
	  <p>This is the timeout in minutes that the cache will use in order to determine when was the last time the
		  object was accessed. For example, if this setting is 10 minutes, and Object A has not been accessed in
		  the last 10 minutes, then Object A will be purged.
	  </p>
	  
	  <h3>Cache Reaping Frequency</h3>
	  <p>This setting is the frequency in which the cache will try to reap items from the cache. Set this too high and
		  your objects will never be purged, set it to low and you will be hitting the cache to frequently. Use it 
		  wisely my young padawan.
	  </p>
	  
	</div>
	<div align="right" style="margin-right:5px;">
	<input type="button" value="Close" onClick="helpToggle()" style="font-size:9px">
	</div>
</div>

<form name="updateform" id="udpateform" action="javascript:doFormEvent('#Event.getValue("xehDoSave")#','content',document.updateform)" onSubmit="return confirmit()" method="post">
<div class="maincontentbox">
	
	<div class="contentboxes_header">
		<div class="contentboxes_title"><img src="images/icons/settings_27.gif" align="absmiddle" />&nbsp; Caching Settings</div>
	</div>
	
	<!--- Messagebox --->
	#getPlugin("messagebox").renderit()#
	<div class="contentboxes">
	
	<p>Below are the configuration settings for the ColdBox Cache Manager. Please note that all entries are in minutes.
	</p>
	<br>
		<div style="margin: 5px">
	    <table width="100%" border="0" cellspacing="0" cellpadding="5" class="tablelisting">
	    	<tr>
			<th>Setting</th>
			<th>Value</th>
		  </tr>
		  
	     <tr>
	     	<td align="right" width="40%" style="border-right:1px solid ##ddd">
	     	<strong>Object Default Timeout</strong>
	     	</td>
	     	<td>
	     	<input type="text" name="CacheObjectDefaultTimeout" value="#Event.getValue("CacheObjectDefaultTimeout")#" size="6" maxlength="3">
	     	(In Minutes)
	     	</td>
	     </tr>	
	     
	     <tr bgcolor="##f5f5f5">
	     	<td align="right" width="40%" style="border-right:1px solid ##ddd">
	     	<strong>Object Last Access Timeout</strong>
	     	</td>
	     	<td>
	     	<input type="text" name="CacheObjectDefaultLastAccessTimeout" value="#Event.getValue("CacheObjectDefaultLastAccessTimeout")#" size="6" maxlength="3">
	     	(In Minutes)
			</td>
	     </tr>	
	     
	     <tr>
	     	<td align="right" width="40%" style="border-right:1px solid ##ddd">
	     	<strong>Cache Reaping Frequency</strong>
	     	</td>
	     	<td>
	     	<input type="text" name="CacheReapFrequency" value="#Event.getValue("CacheReapFrequency")#" size="6" maxlength="2">
	     	(In Minutes)
			</td>
	     </tr>	
	      
        </table>
		</div>
	</div>
	
	<div align="right" style="margin-right:5px;margin-bottom: 10px">
		<input type="submit" value="Submit Changes" >
	</div>
</div>
</form>
</cfoutput>