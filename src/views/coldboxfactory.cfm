<cfoutput>
<h2>ColdBox Factory Tests</h2>

<table >
	<tr>
		<td><strong>TestModel:</strong></td>
		<td>#rc.testModel.getController().getApphash()#</td>
	</tr>
	
	<tr>
		<td><strong>Controller:</strong></td>
		<td>#getController().getApphash()#</td>
	</tr>
	
	<tr>
		<td colspan="2"><hr></td>
	</tr>
	
	<tr>
		<td><strong>TestModel:</strong></td>
		<td>#rc.testModel.getConfigBean().getkey('AppName')#</td>
	</tr>
	
	<tr>
		<td><strong>Controller:</strong></td>
		<td>#getSetting('AppName')#</td>
	</tr>
	
	<tr>
		<td colspan="2"><hr></td>
	</tr>
	
	<tr>
		<td><strong>TestModel:</strong></td>
		<td>#rc.testModel.getLogger().getHash()#</td>
	</tr>
	
	<tr>
		<td><strong>Controller:</strong></td>
		<td>#getPlugin("logger").getHash()#</td>
	</tr>
	
	<tr>
		<td colspan="2"><hr></td>
	</tr>
	
	<tr>
		<td><strong>Cache Manager:</strong></td>
		<td><cfdump var="#rc.testModel.getCacheManager().getItemTypes()#"></td>
	</tr>
	
	
</table>

</cfoutput>