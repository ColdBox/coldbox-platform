<cfoutput>
<!--- HELPBOX --->
#renderView("tags/help")#

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
            <td valign="top" style="border-left:1px solid ##ddd">
				<a class="action silver" href="#getSetting("TracSite")#">
					<span>Open</span>
				</a>
			</td>
          </tr>
          <tr bgcolor="##f5f5f5">
            <td align="right" valign="top"><strong>Official FAQ:</strong></td>
            <td valign="middle" style="border-left:1px solid ##ddd">
				<a class="action silver" href="#getSetting("TracSite")#/trac.cgi/wiki/cbFAQ">
					<span>Open</span>
				</a>
			</td>
          </tr>
          <tr>
            <td align="right" valign="top"><strong>Online Forums:</strong></td>
            <td valign="middle" style="border-left:1px solid ##ddd">
				<a class="action silver" href="#getSetting("FrameworkForums",1)#">
					<span>Open</span>
				</a>
			</td>
          </tr>
          <tr bgcolor="##f5f5f5">
            <td align="right" valign="top"><strong>Blog:</strong></td>
            <td valign="middle" style="border-left:1px solid ##ddd">
				<a class="action silver" href="#getSetting("FrameworkBlog",1)#">
					<span>Open</span>
				</a>
			</td>
          </tr>
          <tr>
            <td align="right" valign="top"><strong>Official Website:</strong></td>
            <td valign="middle" style="border-left:1px solid ##ddd">
				<a class="action silver" href="#getSetting("OfficialSite")#">
					<span>Open</span>
				</a>
			</td>
          </tr>
		   <tr bgcolor="##f5f5f5">
            <td align="right" valign="top"><strong>Author Website:</strong></td>
            <td valign="middle" style="border-left:1px solid ##ddd">
				<a class="action silver" href="#getSetting("AuthorWebsite",true)#">
					<span>Open</span>
				</a>
			</td>
          </tr>
		   <tr>
            <td align="right" valign="top"><strong>Framework Roadmap:</strong></td>
            <td valign="middle" style="border-left:1px solid ##ddd">
				<a class="action silver" href="#getSetting("TracSite")#/trac.cgi/roadmap">
					<span>Open</span>
				</a>
			</td>
          </tr>
		  <tr bgcolor="##f5f5f5">
            <td align="right" valign="top"><strong>Framework Bug Reports:</strong></td>
            <td valign="middle" style="border-left:1px solid ##ddd">
				<a class="action silver" href="#getSetting("TracSite")#/trac.cgi/report">
					<span>Open</span>
				</a>
			</td>
          </tr>
		  <tr>
            <td align="right" valign="top"><strong>Latest CFC API Docs:</strong></td>
            <td valign="middle" style="border-left:1px solid ##ddd">
				<a class="action silver" href="#getSetting("FrameworkAPI",1)#">
					<span>Open</span>
				</a>
			</td>
          </tr>
		  <tr bgcolor="##f5f5f5">
            <td align="right" valign="top"><strong>Latest Config Schema Docs:</strong>
			</td>
            <td valign="middle" style="border-left:1px solid ##ddd">
				<a class="action silver" href="#getSetting("SchemaDocs")#">
					<span>Open</span>
				</a>
			</td>
          </tr>

        </table>
		</div>
	</div>

</div>
</cfoutput>