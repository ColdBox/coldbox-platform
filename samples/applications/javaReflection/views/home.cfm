<cfoutput>
#getPlugin("messagebox").renderit()#

<div style="padding:5px;width:300px;background-color:##ffffF0;font-size:10px">Based on Dough Houghes Java Reflection Tool</div>

<table border="1" cellpadding="10" cellspacing="0">
	<tr>
		<td>
			<p>Enter the name of a class or interface to reflect.  Note that the class name is case sensitive.</p>
			<cfform action="#event.getSelf()##rc.xehDoReflection#" method="post">
				
				<cfinput type="text" name="className" value="#event.getValue('className','')#" size="75" required="true" />
				
				<input type="submit" value="Reflect!">
			</cfform>
		</td>
	</tr>

</table>

</cfoutput>

