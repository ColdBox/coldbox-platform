<cfsetting showdebugoutput="false">
<cfdirectory name="qTests" action="list" directory="#expandPath("./")#" filter="*.cfm">
<h4>ColdBox Unit Folder Tests</h4>

<strong>MXUnit Tests</strong>
<table style="font-size:13px;float:left;margin-right:5px" cellpadding="5" cellspacing="1" border="1">
<cfoutput query="qTests">
	<cfif name neq "index.cfm">
	<tr>
		<td>#name#</td>
		<td>[<a href="#name#" target="testframe">Run</a>]</td>
	</tr>
	</cfif>
</cfoutput>
</table>

<strong>LightWire Tests</strong>
<table style="font-size:13px;float:left;margin-right:5px" cellpadding="5" cellspacing="1" border="1">
	<tr>
		<td>LightWire Test</td>
		<td>[<a href="LightWireTest/index.cfm" target="testframe">Run</a>]</td>
	</tr>
	<tr>
		<td>LightWire XML Test</td>
		<td>[<a href="LightWireTest/xmltest.cfm" target="testframe">Run</a>]</td>
	</tr>
</table>

<iframe src="/coldbox/testing/tests/instructions.cfm" name="testframe" id="testframe" width="98%" height="550px" 
		style="border:2px solid #ccc;padding:5px;"></iframe>