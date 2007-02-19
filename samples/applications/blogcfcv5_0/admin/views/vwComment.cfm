<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         :
	Author       : Raymond Camden
	Created      : 04/07/06
	Last Updated :
	History      :
--->

<cfset comment = requestContext.getValue("comment")>

	<cfif requestContext.valueExists("errors") and arrayLen(requestContext.getValue("errors"))>
		<cfset errors = requestContext.getValue("errors")>
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
	<form action="?event=#requestContext.getValue("xehAddComment")#&id=#comment.id#" method="post">
	<table>
		<tr>
			<td align="right">posted:</td>
			<td>#getPlugin("i18n").dateLocaleFormat(comment.posted)# #getPlugin("i18n").timeLocaleFormat(comment.posted)#</td>
		</tr>
		<tr>
			<td align="right">name:</td>
			<td><input type="text" name="name" value="#requestContext.getValue("name",comment.name)#" class="txtField" maxlength="50"></td>
		</tr>
		<tr>
			<td align="right">email:</td>
			<td><input type="text" name="email" value="#requestContext.getValue("email",comment.email)#" class="txtField" maxlength="50"></td>
		</tr>
		<tr>
			<td align="right">website:</td>
			<td><input type="text" name="website" value="#requestContext.getValue("website",comment.website)#" class="txtField"></td>
		</tr>
		<tr valign="top">
			<td align="right">comment:</td>
			<td><textarea name="newcomment" class="txtArea">#requestContext.getValue("newcomment",comment.comment)#</textarea></td>
		</tr>
		<tr>
			<td align="right">subscribed:</td>
			<td>
			<select name="subscribe">
			<option value="yes" <cfif requestContext.getValue("subscribe",comment.subscribe)>selected</cfif>>Yes</option>
			<option value="no" <cfif not requestContext.getValue("subscribe",comment.subscribe)>selected</cfif>>No</option>
			</select>
			</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><input type="submit" name="cancel" value="Cancel"> <input type="submit" name="save" value="Save"></td>
		</tr>
	</table>
	</form>
	</cfoutput>

<cfsetting enablecfoutputonly=false>
