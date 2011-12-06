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
		<td colspan="2"><hr></td>
	</tr>
	
	<tr>
		<td colspan="2"><hr></td>
	</tr>
	
	<tr>
		<td><strong>Datasource:</strong></td>
		<td><cfdump var="#rc.testModel.getDatasource().getMemento()#"></td>
	</tr>
	
	<tr>
		<td colspan="2"><hr></td>
	</tr>
	
	<tr>
		<td><strong>Mail Settings:</strong></td>
		<td><cfdump var="#rc.testModel.getMailSettings().getMemento()#"></td>
	</tr>
	
	<tr>
		<td colspan="2"><hr></td>
	</tr>
	
	<tr>
		<td><strong>String Buffer:</strong></td>
		<td><cfdump var="#rc.testModel.getStringBuffer()#" expand="false"></td>
	</tr>
	
	<tr>
		<td colspan="2"><hr></td>
	</tr>
	
	<tr>
		<td><strong>Update Web Service:</strong></td>
		<td><cfdump var="#rc.testModel.getUpdateWS()#" expand="false"></td>
	</tr>
	
</table>

</cfoutput>