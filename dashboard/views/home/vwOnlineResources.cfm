<cfoutput>
<!--- HELPBOX --->
<div id="helpbox" class="helpbox" style="display: none">

	<div class="helpbox_header">
	  <div class="helpbox_header_title"><img src="images/icons/icon_guide_help.gif" align="absmiddle"> Help Tip</div>
	</div>
	
	<div class="helpbox_message" >
	  <ul>
	  	<li>From this screen you can link to the various online resources that I have compiled.  These are only official links here, 
		  	if however you want to contribute with links of your own, please email them to <br><br>
		  	<a href="mailto:info@coldboxframework.com">info@coldboxframework.com</a>
	    </li>
	  </ul>
	</div>
	<div align="right" style="margin-right:5px;">
	<input type="button" value="Close" onClick="helpoff()" style="font-size:9px">
	</div>
</div>

<!--- Placed under content div --->

<div class="maincontentbox">
	
	<div class="contentboxes_header">
		<div class="contentboxes_title"><img src="images/icons/online_resources.gif" align="absbottom" />&nbsp; Online Resources</div>
	</div>
	
	<div class="contentboxes">
	
	<p>The links below are resources for the ColdBox Framework.  Please note that you need an internet connection
	to get to these links.</p>
	
		<div style="margin: 5px">
	    <table width="100%" border="0" cellspacing="0" cellpadding="5" class="tablelisting">
		  <tr>
				<th>Resource</th>
				<th>Open</th>
		  </tr>
          
		  <tr>
            <td width="40%" align="right" valign="top"><strong>Official Wiki, Guides, etc:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd"><a href="#getSetting("TracSite")#">Click Here To Open</a></td>
          </tr>
          <tr bgcolor="##f5f5f5">
            <td align="right" valign="top"><strong>Official FAQ:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd"><a href="#getSetting("TracSite")#/trac.cgi/wiki/cbFAQ">Click Here To Open</a></td>
          </tr>
          <tr>
            <td align="right" valign="top"><strong>Online Forums:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd"><a href="#getSetting("FrameworkForums",1)#">Click Here To Open</a></td>
          </tr>
          <tr bgcolor="##f5f5f5">
            <td align="right" valign="top"><strong>Blog:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd"><a href="#getSetting("FrameworkBlog",1)#">Click Here To Open</a></td>
          </tr>
          <tr>
            <td align="right" valign="top"><strong>Official Website:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd"><a href="#getSetting("OfficialSite")#">Click Here To Open</a></td>
          </tr>
		   <tr bgcolor="##f5f5f5">
            <td align="right" valign="top"><strong>Author Website:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd"><a href="#getSetting("AuthorWebsite",true)#">Click Here To Open</a></td>
          </tr>
		   <tr>
            <td align="right" valign="top"><strong>Framework Roadmap:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd"><a href="#getSetting("TracSite")#/trac.cgi/roadmap">Click Here To Open</a></td>
          </tr>
		  <tr bgcolor="##f5f5f5">
            <td align="right" valign="top"><strong>Framework Bug Reports:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd"><a href="#getSetting("TracSite")#/trac.cgi/report">Click Here To Open</a></td>
          </tr>
		  <tr>
            <td align="right" valign="top"><strong>Latest CFC API Docs:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd"><a href="#getSetting("FrameworkAPI",1)#">Click Here To Open</a></td>
          </tr>		
		  <tr bgcolor="##f5f5f5">
            <td align="right" valign="top"><strong>Latest Config Schema Docs:</strong></td>
            <td valign="top" style="border-left:1px solid ##ddd"><a href="#getSetting("SchemaDocs")#">Click Here To Open</a></td>
          </tr>		
		  
        </table>
		</div>
	</div>
	
</div>
</cfoutput>