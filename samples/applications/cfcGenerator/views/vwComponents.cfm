<cfset dbType = Event.getValue("dbType") />
<cfset tables = Event.getValue("tables") />
<cfset dsn = Event.getValue("dsn")>

<cfoutput>
<cfform action="index.cfm?event=#Event.getValue("xehGenerate")#" method="post" format="xml" skin="lightgray">
	
	<cfinput type="hidden" name="dbtype" value="#dbtype#" />
	<cfinput type="hidden" name="dsn" value="#dsn#" />
	
	<cfformitem type="html">DSN: #dsn# (<a href="index.cfm">click to change</a>)</cfformitem>
	
	<cfinput type="text" name="componentPath" label="Component Path:" size="50" required="true" value="#Event.getValue("componentPath")#" />
	
	<cfselect name="table" label="Choose a table" selected="#Event.getValue("table")#">
		<cfloop query="tables">
			<option value="#tables.table_name#">#tables.table_name#</option>
		</cfloop>
	</cfselect>
	
	<!--- <cfinput type="checkbox" name="generateService" value="1" label="Generate Service" checked="#yesNoFormat(form.generateService)#" />
	<cfinput type="checkbox" name="generateTO" value="1" label="Generate Transfer Object" checked="#yesNoFormat(form.generateTO)#" />
	<cfinput type="checkbox" name="generateColdspringXML" value="1" label="Generate ColdSpring XML Snippet" checked="#yesNoFormat(form.generateColdspringXML)#" /> --->
	<cfinput type="submit" name="submitted" value="continue" />
</cfform>
</cfoutput>