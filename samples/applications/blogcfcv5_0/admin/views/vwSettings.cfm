<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : /client/admin/index.cfm
	Author       : Raymond Camden
	Created      : 04/12/06
	Last Updated :
	History      :
--->

<!--- quick utility func to change foo,moo to foo<newline>moo and reverse --->
<cfscript>
function toLines(str) { return replace(str, ",", chr(10), "all"); }
</cfscript>


<cfset settings = getvalue("settings")>
<cfset validDBTypes = getvalue("ValidDBTypes")>

	<cfoutput>
	<p>
	Please edit your settings below. <b>Be warned:</b> A mistake here can make both the blog and this
	administrator unreachable. Be careful! ("Here be dragons...")
	</p>
	</cfoutput>

	<cfif valueExists("errors") and arrayLen(getvalue("errors"))>
		<cfset errors = getvalue("errors")>
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
	<form action="index.cfm?event=ehAdmin.doSaveSettings" method="post">
	<table>
		<tr>
			<td align="right">blog title:</td>
			<td><input type="text" name="blogtitle" value="#form.blogtitle#" class="txtField" maxlength="255"></td>
		</tr>
		<tr valign="top">
			<td align="right">blog description:</td>
			<td><textarea name="blogdescription" class="txtAreaShort">#form.blogdescription#</textarea></td>
		</tr>
		<tr valign="top">
			<td align="right">blog keywords:</td>
			<td><input type="text" name="blogkeywords" value="#form.blogkeywords#" class="txtField" maxlength="255"></td>
		</tr>
		<tr>
			<td align="right">blog url:</td>
			<td><input type="text" name="blogurl" value="#form.blogurl#" class="txtField" maxlength="255"></td>
		</tr>
		<tr>
			<td align="right">comments sent from:</td>
			<td><input type="text" name="commentsfrom" value="#form.commentsfrom#" class="txtField" maxlength="255"></td>
		</tr>
		<tr>
			<td align="right">max entries:</td>
			<td><input type="text" name="maxentries" value="#form.maxentries#" class="txtField" maxlength="255"></td>
		</tr>
		<tr>
			<td align="right">offset:</td>
			<td><input type="text" name="offset" value="#form.offset#" class="txtField" maxlength="255"></td>
		</tr>
		<tr valign="top">
			<td align="right">ping urls:</td>
			<td><textarea name="pingurls" class="txtAreaShort">#toLines(form.pingurls)#</textarea></td>
		</tr>
		<tr>
			<td align="right">dsn:</td>
			<td><input type="text" name="dsn" value="#form.dsn#" class="txtField" maxlength="50"></td>
		</tr>
		<tr>
			<td align="right">blog database type:</td>
			<td>
			<select name="blogdbtype">
			<cfloop index="dbtype" list="#validDBTypes#">
			<option value="#dbtype#" <cfif form.blogdbtype is dbtype>selected</cfif>>#dbtype#</option>
			</cfloop>
			</select>
			</td>
		</tr>
		<tr>
			<td align="right">locale:</td>
			<td><input type="text" name="locale" value="#form.locale#" class="txtField" maxlength="50"></td>
		</tr>
		<tr valign="top">
			<td align="right">ip block list:</td>
			<td><textarea name="ipblocklist" class="txtAreaShort">#toLines(form.ipblocklist)#</textarea></td>
		</tr>
		<tr>
			<td align="right">use captcha:</td>
			<td>
			<select name="usecaptcha">
			<option value="yes" <cfif form.usecaptcha>selected</cfif>>Yes</option>
			<option value="no" <cfif not form.usecaptcha>selected</cfif>>No</option>
			</select>
			</td>
		</tr>
		<tr>
			<td align="right">allow trackbacks:</td>
			<td>
			<select name="allowtrackbacks">
			<option value="yes" <cfif form.allowtrackbacks>selected</cfif>>Yes</option>
			<option value="no" <cfif not form.allowtrackbacks>selected</cfif>>No</option>
			</select>
			</td>
		</tr>
		<tr valign="top">
			<td align="right">trackback spamlist:</td>
			<td><textarea name="trackbackspamlist" class="txtAreaShort">#toLines(form.trackbackspamlist)#</textarea></td>
		</tr>
		<tr>
			<td align="right">mail server:</td>
			<td><input type="text" name="mailserver" value="#form.mailserver#" class="txtField" maxlength="50"></td>
		</tr>
		<tr>
			<td align="right">mail username:</td>
			<td><input type="text" name="mailusername" value="#form.mailusername#" class="txtField" maxlength="50"></td>
		</tr>
		<tr>
			<td align="right">mail password:</td>
			<td><input type="text" name="mailpassword" value="#form.mailpassword#" class="txtField" maxlength="50"></td>
		</tr>
		<tr>
			<td align="right">users:</td>
			<td><input type="text" name="users" value="#form.users#" class="txtField" maxlength="50"></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><input type="submit" name="cancel" value="Cancel"> <input type="submit" name="save" value="Save"></td>
		</tr>
	</table>
	</form>
	</cfoutput>


<cfsetting enablecfoutputonly=false>