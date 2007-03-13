<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : C:\projects\blogcfc5\client\admin\entry.cfm
	Author       : Raymond Camden
	Created      : 04/07/06
	Last Updated : 05/17/06
	History      : Remove an extra line (5/17/06)
--->

<cfset message = Event.getValue("message")>
<cfset entry = Event.getValue("entry")>
<cfset allCats = Event.getValue("allCats")>

<cfif not structKeyExists(form, "preview")>

	<cfoutput>
	<script type="text/javascript" src="includes/relatedpostsjs.cfm?id=#Event.getValue("ID")#"></script>
	</cfoutput>

	<cfif Event.valueExists("errors") and arrayLen(Event.getValue("errors"))>
		<cfset errors = Event.getValue("errors")>
		<cfoutput>
			<div class="errors">
			Please correct the following error(s):
			<ul>
			<cfloop index="x" from="1" to="#arrayLen(errors)#">
			<li>#errors[x]#</li>
			</cfloop>
			</ul>
			</div>
		</cfoutput>
	<cfelseif Event.getValue("message","") neq "">
		<cfoutput>
		<div class="message">
		#message#
		</div>
		</cfoutput>
	</cfif>

	<cfoutput>
	<form action="?event=#Event.getValue("xehSave")#&id=#Event.getValue("id")#" method="post" enctype="multipart/form-data" name="editForm">
	<table>
		<tr>
			<td align="right">title:</td>
			<td><input type="text" name="title" value="#htmlEditFormat(Event.getValue("title"))#" class="txtField" maxlength="100"></td>
		</tr>
		<tr valign="top">
			<td align="right">body:</td>
			<td><textarea name="body" class="txtArea">#Event.getValue("body")#</textarea></td>
		</tr>
		<tr>
			<td align="right">posted:</td>
			<td><input type="text" name="posted" value="#Event.getValue("posted")#" class="txtField" maxlength="100"></td>
		</tr>
		<tr valign="top">
			<td align="right">categories:</td>
			<td>
			<cfif allCats.recordCount>
			<select name="categories" multiple size=4 class="txtDropdown">
				<cfloop query="allCats">
				<option value="#categoryID#" <cfif Event.valueExists("categories") and listFind(Event.getValue("categories"),categoryID)>selected</cfif>>#categoryName#</option>
				</cfloop>
			</select><br>
			</cfif>
			<input type="text" name="newcategory" value="#htmlEditFormat(Event.getValue("newcategory"))#" class="txtField" maxlength="50"> New Category</td>
		</tr>

		<tr valign="top">
			<td>
				<b>Related Entries</b>
				<br />
				<a href="javascript:void(resetRelatedEntries());" style="font-weight:normal;">reset</a>
			</td>
			<td>
				<table border="0" width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td width="50%"><strong>Categories</strong></td>
					<td width="50%">
			  			<div style="float:left;"><strong>Entries</strong></div>
						<div style="float:right; padding-right: .5em;">
							Sort By:
							<a href="javascript:void(0);" id="sortLinkDate" onclick="updateRememberEntries(); doPopulateEntries('sortByDate');" style="color:rgb(0, 0, 255);">Date</a> |
							<a href="javascript:void(0);" id="sortLinkTitle" onclick="updateRememberEntries(); doPopulateEntries('sortByTitle');" style="color:rgb(128, 128, 128);">Title</a>
						</div>
					</td>
	        	</tr>
		        <tr>
	    	      <td style="padding-right: 5px;">
		    	      <select name="cboRelatedEntriesCats" multiple="multiple" size="4" onclick="doPopulateEntries(0); checkRememberEntries(); updateRememberEntries();" style="width:100%;"></select></td>
	        	  <td><select name="cboRelatedEntries" multiple="multiple" size="4" style="width:100%;" onclick="updateRememberEntries();"></select></td>
		        </tr>
				</table>

				<script type="text/javascript" src="includes/relatedposts.js"></script>
				<!--- BEGIN : if there was an error, repopulate the related entries categories/entries fields : cjg : 31 december 2005 --->
				<cfif len(trim(Event.getValue("cboRelatedEntries"))) GT 0>
					<script type="text/javascript" src="includes/relatedpostsjs_error.cfm?c=#URLEncodedFormat(Event.getValue("cboRelatedEntriesCats"))#&p=#URLEncodedFormat(Event.getValue("cboRelatedEntries"))#"></script>
				</cfif>
				<!--- END : if there was an error, repopulate the related entries categories/entries fields : cjg : 31 december 2005 --->
			</td>
		</tr>

		<tr>
			<td align="right">alias:</td>
			<td><input type="text" name="alias" value="#Event.getValue("alias")#" class="txtField" maxlength="100"></td>
		</tr>
		<tr>
			<td align="right">allow comments:</td>
			<td>
			<select name="allowcomments">
				<option value="true" <cfif Event.getValue("allowcomments") is "true">selected</cfif>>Yes</option>
				<option value="false" <cfif Event.getValue("allowcomments") is "false">selected</cfif>>No</option>
			</select>
			</td>
		</tr>
		<tr>
			<td align="right">enclosure:</td>
			<td>
			<input type="hidden" name="oldenclosure" value="#Event.getValue("oldenclosure")#">
			<input type="hidden" name="oldfilesize" value="#Event.getValue("oldfilesize")#">
			<input type="hidden" name="oldmimetype" value="#Event.getValue("oldmimetype")#">
			<cfif len(Event.getValue("oldenclosure"))>#listLast(Event.getValue("oldenclosure"),"/\")# <input type="submit" name="delete_enclosure" value="#getResource("deleteenclosure")#"></cfif>
			<input type="file" name="enclosure" style="width:100%">
			</td>
		</tr>
		<tr>
			<td align="right">released:</td>
			<td>
			<select name="released">
			<option value="true" <cfif Event.getValue("released") is "true">selected</cfif>>Yes</option>
			<option value="false" <cfif Event.getValue("released") is "false">selected</cfif>>No</option>
			</select>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><input type="submit" name="cancel" value="Cancel"> 
			    <input type="submit" name="preview" value="Preview">
  				<input type="submit" name="save" value="Save"></td>
		</tr>
	</table>
	</form>
	</cfoutput>

<cfelse>

	<!--- Handles previews. --->
	<cfoutput>
	<div class="previewEntry">
	#application.blog.renderEntry(Event.getValue("body"),false,Event.getValue("oldenclosure"))#
	</div>
	</cfoutput>

	<cfoutput>
	<form action="index.cfm?#cgi.query_string#" method="post">
	<cfset rc = Event.getCollection()>
	<cfloop item="key" collection="#rc#">
		<cfif not listFindNoCase("preview,fieldnames,enclosure,event,fwreinit,allCats", key)>
			<input type="hidden" name="#key#" value="#htmlEditFormat(rc[key])#">
		</cfif>
	</cfloop>
	
	<input type="submit" name="return" value="Return"> <input type="submit" name="save" value="Save">
	</form>
	</cfoutput>

</cfif>

<cfsetting enablecfoutputonly=false>