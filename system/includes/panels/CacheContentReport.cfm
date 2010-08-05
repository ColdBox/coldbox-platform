<cfoutput>
<table border="0" cellpadding="0" cellspacing="1" class="fw_debugTables">
  <tr >
  	<th >Object</th>
	<th align="center" width="10%" >Hits</th>
	<th align="center" width="10%" >Timeout <br/>(Min)</th>
	<th align="center" width="10%" >Created</th>
	<th align="center" width="10%" >Last Accessed</th>
	<th align="center" width="10%" >Expires</th>
	<th align="center" width="10%" >Status</th>
	<th align="center" width="5%" >CMDS</th>
  </tr>
  <cfloop from="1" to="#cacheKeysLen#" index="x">
  	<cfset thisKey = cacheKeys[x]>
  	<cfset expDate = dateadd("n",cacheMetaData[ thisKey ].timeout, cacheMetaData[ thisKey ].created)>
	<tr <cfif x mod 2 eq 0>class="even"</cfif>>
	  	<!--- Link --->
		<td align="left">
		  	<a href="javascript:fw_openwindow('#URLBase#?debugpanel=cacheviewer&key=#urlEncodedFormat( thisKey )#','CacheViewer',650,375,'resizable,scrollbars,status')" title="Dump contents">#listLast(thisKey,"_")#</a></td>
		<!--- Hits --->
		<td align="center" >#cacheMetadata[thisKey].hits#</td>
		<!--- Timeout --->
		<td align="center" >#cacheMetadata[thisKey].Timeout#</td>
		<!--- Created --->
		<td align="center" >#dateformat(cacheMetadata[thisKey].Created,"mmm-dd")# <Br/> #timeformat(cacheMetadata[thisKey].Created,"hh:mm:ss tt")#</td>
		<!--- Last Accessed --->
		<td align="center">#dateformat(cacheMetadata[thisKey].lastaccesed,"mmm-dd")# <br/> #timeformat(cacheMetadata[thisKey].lastaccesed,"hh:mm:ss tt")#</td>
	 	<!--- Timeouts --->
		<td align="center" class="fw_redText" ><cfif cacheMetadata[thisKey].timeout eq 0>---<cfelse>#dateFormat(expDate,"mmm-dd")# <br /> #timeformat(expDate,"hh:mm:ss tt")#</cfif></td>
	 	<!--- isExpired --->
		<td align="center">
			<cfif cacheMetadata[thisKey].isExpired>
				<span class="fw_redText">Expired</span>
			<cfelse>
				<span class="fw_blueText">Alive</span>
			</cfif>
		</td>
		<!--- Commands --->
	 	<td align="center">
			<input type="button" value="DEL" 
				   name="cboxbutton_removeentry"
			  	   style="font-size:10px" 
				   title="Remove this entry from the cache." 
			   	   onClick="location.href='#URLBase#?cbox_command=delcacheentry&cbox_cacheentry=#urlEncodedFormat(thisKey)#&debugpanel=#event.getValue('debugPanel','')#'">
		</td>
	  </tr>
	
  </cfloop>			  
</table>
</cfoutput>