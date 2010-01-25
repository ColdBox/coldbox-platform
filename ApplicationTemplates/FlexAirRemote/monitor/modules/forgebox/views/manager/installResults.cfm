<cfoutput>
<!--- Left Panel --->
<div id="installLog">

	<h2>
		#rc.entry.title# Installation Log!
	</h2>
	
	<div>
		<a href="#event.buildLink('forgebox')#"><input type="button" value="Back To Entries" /></a><br /><br />
	</div>
	
	<!--- Install Log --->
	<cfif flash.exists("installResults")>
		<div class="forgeBox-entrybox">
			#flash.get("installResults").logInfo#		
		</div>
		
		<!--- Error or good install --->
		<cfif NOT flash.get("installResults").error>
			<!--- Description --->
			<cfif len(rc.entry.description)>
			<h2>Entry Description</h2>
			<p>#rc.entry.description#</p>
			<br />
			</cfif>
			
			<!--- Install Instructions --->
			<cfif len(rc.entry.installInstructions)>
			<h2>Installation Instructions</h2>
			<p>#rc.entry.installInstructions#</p>
			</cfif>
		</cfif>
	</cfif>
</div>
</cfoutput>