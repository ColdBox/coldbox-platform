<cfoutput>
<table border="0" cellpadding="0" cellspacing="1" class="cachebox_debugTables">
  <thead>
  	<tr>
	  	<th>Object</th>
		<th align="center" width="10%" >Hits</th>
		<th align="center" width="10%" >Timeout</th>
		<th align="center" width="10%" >Idle Timeout</th>
		<th align="center" width="10%" >Created</th>
		<th align="center" width="10%" >Last Accessed</th>
		<th align="center" width="10%" >Status</th>
		<th align="center" width="5%" >CMDS</th>
 	</tr>
  </thead>
  <tbody>
  	
  <cfloop from="1" to="#cacheKeysLen#" index="x">
  	<cfset thisKey = cacheKeys[x]>
	<cfif structKeyExists( cacheMetadata, thisKey )>
		<tr <cfif x mod 2 eq 0>class="even"</cfif> id="cbox_cache_tr_#urlEncodedFormat(thisKey)#">
	  	<!--- Link --->
		<td align="left">
		  	<a href="javascript:cachebox_openwindow('#URLBase##iif(Find("?", URLBase), DE('&'), DE('?'))#debugpanel=cacheviewer&cbox_cacheName=#arguments.cacheName#&cbox_cacheEntry=#urlEncodedFormat( thisKey )#','CacheViewer',650,375,'resizable,scrollbars,status')" 
			   title="#thisKey#">
		  	#thisKey#
			</a>
		</td>
		<!--- Hits --->
		<td align="center" >#cacheMetadata[thisKey][ cacheMDKeyLookup.hits ]#</td>
		<!--- Timeout --->
		<td align="center" >#cacheMetadata[thisKey][ cacheMDKeyLookup.timeout ]#</td>
		<!--- Last Access Timeout --->
		<td align="center" >#cacheMetadata[thisKey][ cacheMDKeyLookup.lastAccessTimeout ]#</td>
		<!--- Created --->
		<td align="center" >
			<cfif !isNull( cacheMetadata[thisKey][ cacheMDKeyLookup.Created ] )>
			#dateformat( cacheMetadata[thisKey][ cacheMDKeyLookup.Created ], "mmm-dd" )# <br/>
			#timeformat( cacheMetadata[thisKey][ cacheMDKeyLookup.created ], "hh:mm:ss tt" )#
			</cfif>
		</td>
		<!--- Last Accessed --->
		<td align="center">
			<cfif !isNull( cacheMetadata[thisKey][ cacheMDKeyLookup.LastAccessed ] )>
			#dateformat(cacheMetadata[thisKey][ cacheMDKeyLookup.LastAccessed ],"mmm-dd")# <br/> 
			#timeformat(cacheMetadata[thisKey][ cacheMDKeyLookup.LastAccessed ],"hh:mm:ss tt")#
			</cfif>
		</td>
	 	<!--- isExpired --->
		<td align="center">
			<cfif structKeyExists(cacheMDKeyLookup,"isExpired") and cacheMetadata[thisKey][ cacheMDKeyLookup.isExpired ]>
				<span class="cachebox_redText">Expired</span>
			<cfelse>
				<span class="cachebox_blueText">Alive</span>
			</cfif>
		</td>
		<!--- Commands --->
	 	<td align="center">
			<input type="button" value="Expire" 
				   name="cboxbutton_expireentry_#urlEncodedFormat(thisKey)#" id="cboxbutton_expireentry_#urlEncodedFormat(thisKey)#"
			  	   style="font-size:10px" 
				   title="Expire this entry from the cache" 
				   onclick="cachebox_cacheExpireItem('#URLBase#','#urlEncodedFormat(thisKey)#','#arguments.cacheName#')">
			<input type="button" value="Delete" 
				   name="cboxbutton_removeentry_#urlEncodedFormat(thisKey)#" id="cboxbutton_removeentry_#urlEncodedFormat(thisKey)#"
			  	   style="font-size:10px" 
				   title="Remove this entry from the cache." 
				   onclick="cachebox_cacheClearItem('#URLBase#','#urlEncodedFormat(thisKey)#','#arguments.cacheName#')">
		</td>
	  </tr>
	</cfif>
  </cfloop>	
  </tbody>		  
</table>
</cfoutput>