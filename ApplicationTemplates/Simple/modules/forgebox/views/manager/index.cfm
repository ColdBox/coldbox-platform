<cfoutput>
<!--- Install Location --->
<div id="installDiv">
	<form name="installForm" id="installForm" method="post" action="#event.buildlink('forgebox.install')#" onsubmit="startInstall()">
	<!--- Title --->
	<h3>Installing: <span id="installText"></span></h3>
	<br /><br />
	<h4>Choose Installation Directory:</h4>
	<p>
	<!--- Parent Listing --->
	<select name="installLocation" id="installLocation">
	<cfloop query="rc.qParentListing">
		<option value="#rc.qParentListing.name#">#rc.qParentListing.name#</option>
	</cfloop>
	</select>
	
	<!--- DownloadURL --->
	<input type="hidden" name="installURL"    id="installURL"    value="" />
	<input type="hidden" name="entrySlug"     id="entrySlug"     value="" />
	<input type="submit" name="installButton" id="installButton" value="Install Code Entry">
	</p>
	
	<div id="loader">
		<img src="#event.getModuleRoot()#/includes/images/ajax-loader.gif" alt="loader" /><br />
		Installing, Please Wait...
	</div>
	</form>
</div>

<!--- Left Panel --->
<div id="left">

	<h2>
		#rc.entriesTitle# (#rc.entries.recordcount# entries)
	</h2>
	
	<!--- Filter Bar --->
	<div id="entryFilterBar">
		<div>
			<label for="entryFilter" class="inline">Quick Entry Filter: </label>
			<input size="40" type="text" name="entryFilter" id="entryFilter" />
		</div>
	</div>
	
	<cfloop query="rc.entries">
	<div class="forgeBox-entrybox">
		
		<div class="forgebox-rating">
			<input name="star_#rc.entries.entryID#" type="radio" class="star" <cfif rc.entries.entryRating gte 1>checked="checked"</cfif> value="1" disabled="disabled"/>
			<input name="star_#rc.entries.entryID#" type="radio" class="star" <cfif rc.entries.entryRating gte 2>checked="checked"</cfif> value="2" disabled="disabled"/>
			<input name="star_#rc.entries.entryID#" type="radio" class="star" <cfif rc.entries.entryRating gte 3>checked="checked"</cfif> value="3" disabled="disabled"/>
			<input name="star_#rc.entries.entryID#" type="radio" class="star" <cfif rc.entries.entryRating gte 4>checked="checked"</cfif> value="4" disabled="disabled"/>
			<input name="star_#rc.entries.entryID#" type="radio" class="star" <cfif rc.entries.entryRating gte 5>checked="checked"</cfif> value="5" disabled="disabled"/>
		</div>
	
		<h3>#rc.entries.title# v#rc.entries.version# (#rc.entries.typeName#)</h3>
		<p><label>ColdBox Version: </label> #rc.entries.coldboxversion#<br /></p>
		<p>#rc.entries.summary#</p>
		<cfif len(rc.entries.description)>
			<a href="javascript:toggle('entry_description_#rc.entries.entryID#')">> Read Description</a>
			<div id="entry_description_#rc.entries.entryID#" class="hidden forgebox-infobox">
				<h2>Description</h2>
				#rc.entries.description#
			</div><br />
		</cfif>
		
		<cfif len(rc.entries.installinstructions)>
			<a href="javascript:toggle('entry_ii_#rc.entries.entryID#')">> Read Installation Instructions</a>
			<div id="entry_ii_#rc.entries.entryID#" class="hidden forgebox-infobox">
				<h2>Installation Instructions</h2>
				#rc.entries.installinstructions#
			</div><br />
		</cfif>
		
		<cfif len(rc.entries.changelog)>
			<a href="javascript:toggle('entry_cl_#rc.entries.entryID#')">> Read Changelog</a>
			<div id="entry_cl_#rc.entries.entryID#" class="hidden forgebox-infobox">
				<h2>Changelog</h2>
				#rc.entries.changelog#
			</div><br />
		</cfif>
		
		<div class="forgebox-download">
			<a href="javascript:installEntry('#JSStringFormat(rc.entries.downloadURL)#','#jsstringFormat(rc.entries.slug)#')" 
			   title="Install Entry"><img src="#event.getModuleRoot()#/includes/images/entry-link.png" alt="Download" border="0" /></a>
		</div>
		
		<p>
			<label>Author: </label> <a href="javascript:loadProfile('#jsStringFormat(rc.entries.username)#')">#rc.entries.username#</a> |
			<label>Updated: </label> #dateFormat(rc.entries.updatedate)# |
			<label>Downloads: </label> #rc.entries.downloads# |
			<label>Views: </label> #rc.entries.hits#<br />
		</p>
	</div>
	</cfloop>
	<cfif NOT rc.entries.recordcount>
		#getPlugin("MessageBox").renderMessage("warning","No Entries Found!")#
	</cfif>
	
</div>

<div id="right">
	<h3>Code Entry Types</h3>
	<p>You can filter the entries by type using our list below:</p>
	<ul>
		<cfloop query="rc.types">
		<li <cfif rc.typeSlug eq rc.types.typeSlug> class="choosen"</cfif>>
			<a href="#event.buildLink('forgebox.manager.' & lcase(rc.orderby) & '.' & rc.types.typeSlug)#">> #rc.types.typeName# (#rc.types.typeTotal#)</a> 
		</li>
		</cfloop>
	</ul>
	<br /><br />
	<h3>ForgeBox Links</h3>
	<ul>
		<li><a href="http://www.coldbox.com/forgebox">Live ForgeBox Site!</a></li>
		<li><a href="http://wiki.coldbox.org/wiki/ForgeBox:API-Documentation.cfm">ForgeBox API Docs</a></li>
	</ul>
</div>
</cfoutput>