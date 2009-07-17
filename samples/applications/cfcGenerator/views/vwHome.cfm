<cfset DSNs = Event.getValue("DSNs","")>

<cfif isStruct(DSNs)>
	<cfoutput>
	<cfform action="index.cfm?event=#Event.getValue("xehProcessDSN")#" method="post" format="xml" skin="lightgray">
		<cfselect name="dsn" label="Choose a datasource">
			<cfloop collection="#DSNs#" item="ds">
			<!--- only oracle, mssql or mysql for now --->
			<cfif ((DSNs[ds].driver eq "MSSQLServer")  or (DSNs[ds].class contains "MSSQLServer")) 
	       or ((DSNs[ds].driver contains "mySQL") or (DSNs[ds].class contains "mySQL"))
	       or ((DSNs[ds].driver contains "Oracle") or (DSNs[ds].class contains "Oracle"))>
				<option value="#ds#">#DSNs[ds].name#</option>
			</cfif>
			</cfloop>
		</cfselect>
		<cfinput type="submit" name="submitted" value="continue" />
	</cfform>
	</cfoutput>
<cfelse>
	<p>You have no Oracle, MySQL or MSSQL DSNs.</p>
</cfif>