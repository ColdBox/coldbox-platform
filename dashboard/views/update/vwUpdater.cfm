<cfoutput>
<cfset qURLS = Event.getValue("qURLS")>
<!--- HELPBOX --->
#renderView("tags/help")#

<!--- CONTENT BOX --->
<div class="maincontentbox">

	<div class="contentboxes_header">
		<div class="contentboxes_title"><img src="images/icons/update_27.gif" align="absmiddle" />&nbsp; ColdBox Update Center</div>
	</div>

	<div class="contentboxes">
	<p>Welcome to the online update section of the ColdBox Framework. You can connect to the distribution site and verify that you are
	running the latest version of the framework and dashboard.  You can then decide to download the update.
	</p>
	<br /><br />
	#getPlugin("messagebox").renderit()#
	<form id="updateform" name="updateform" method="post" action="javascript:doFormEvent('#Event.getValue("xehCheck")#','content',document.updateform)" onSubmit="doUpdater()">
	  <div align="center">
		<table width="100%" border="0" cellspacing="0" cellpadding="5" class="tablelisting">
          <tr>
            <th>Distribution Sites</th>
          </tr>

		  <cfloop query="qURLS">
            <tr <cfif currentrow mod 2 eq 0>bgcolor="##f5f5f5"</cfif>>
              <td valign="top">
				<label><input name="distribution_site" type="radio" value="#url#" <cfif currentrow eq 1>checked="true"</cfif> />
	    #url#</label></td>
            </tr>
		   </cfloop>
        </table>
		<br /><br />
		<a class="action" href="javascript:document.updateform.submit()">
			<span>Update Check</span>
		</a>
		<div id="checkloader" style="display:none;"><img src="images/ajax-loader.gif" width="220" height="19" align="absmiddle" title="Loading..." /></div>
	  </div>
	</form>
	</div>

</div>
</cfoutput>