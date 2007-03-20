<cfoutput>
<!--- HELPBOX --->
#renderView("tags/help")#

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
	     
	     <tr bgcolor="##f5f5f5">
	     	<td align="right" width="40%" style="border-right:1px solid ##ddd">
	     	<strong>Maximum Objects In Cache</strong>
	     	</td>
	     	<td>
	     	<input type="text" name="CacheMaxObjects" value="#Event.getValue("CacheMaxObjects")#" size="6" maxlength="4">
	     	(0 = Unlimited)
			</td>
	     </tr>
	     
	     <tr>
	     	<td align="right" width="40%" style="border-right:1px solid ##ddd">
	     	<strong>JVM Free Memory Percentage Threshold</strong>
	     	</td>
	     	<td>
	     	<input type="text" name="CacheFreeMemoryPercentageThreshold" value="#Event.getValue("CacheFreeMemoryPercentageThreshold")#" size="6" maxlength="2">
	     	(0 = Unlimited)
			</td>
	     </tr>
	     
        </table>
		</div>

		<div align="center" style="margin-top:30px">
			<a class="action" href="javascript:document.updateform.submit()" title="Submit Changes">
				<span>Submit Changes</span>
			</a>
		</div>

	</div>
</div>
</form>
</cfoutput>