<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : category.cfm
	Author       : Raymond Camden
	Created      : 04/07/06
	Last Updated :
	History      :
--->

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
	</cfif>

	<cfoutput>
	<p>
	Use the form below to edit your category. The alias field is used when creating SES (Search Engine Safe) URLs.
	If you leave the field blank, one will be generated for you. If wish to create it yourself, do not use any non-alphanumeric characters
	in the alias. Spaces should be replaced with dashes.
	</p>

	<form action="?event=#Event.getValue("xehSaveCategory")#&id=#url.id#" method="post">
	<table>
		<tr>
			<td align="right">name:</td>
			<td><input type="text" name="name" value="#Event.getValue("name","")#" class="txtField" maxlength="50"></td>
		</tr>
		<tr>
			<td align="right">alias:</td>
			<td><input type="text" name="alias" value="#Event.getValue("alias","")#" class="txtField" maxlength="50"></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><input type="submit" name="cancel" value="Cancel"> <input type="submit" name="save" value="Save"></td>
		</tr>
	</table>
	</form>
	</cfoutput>

<cfsetting enablecfoutputonly=false>
