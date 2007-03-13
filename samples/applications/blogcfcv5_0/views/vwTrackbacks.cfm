<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : c:\projects\blog\client\trackbacks.cfm
	Author       : Dave Lobb 
	Created      : 09/22/05
	Last Updated : 9/22/05
	History      : Ray modified it for 4.0
--->

<cfset article = Event.getValue("article")>

<cfoutput>
<div class="date">Add TrackBack</div>
<div class="body">
#getPlugin("messagebox").renderit()#
<!---<form action="#cgi.script_name#?id=#url.id#" method="post" enctype="application/x-www-form-urlencoded">
<table width="100%">
<tr>
	<td>Your Blog Name:</td>
	<td><input type="text" name="blog_name" value="#form.blog_name#" maxlength="255" style="width:100%"></td>
</tr>
<tr>
	<td>Your Blog Entry Title:</td>
	<td><input type="text" name="title" value="#form.title#" maxlength="255" style="width:100%"></td>
</tr>
<tr>
	<td colspan=2>
	Excerpt from your Blog Entry:<br>
	<textarea name="excerpt" cols=50 rows=10 style="width:100%">#form.excerpt#</textarea>
	</td>
</tr>
<tr>
	<td>Your Blog Entry URL:</td>
	<td><input type="text" name="url" value="#form.url#" maxlength="255" style="width:100%"></td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><input type="submit" name="addtrackback" value="#getResource("post")#"></td>
</tr>
</table>

</form> --->
<form action="#cgi.script_name#?id=#Event.getValue("id")#" method="post" enctype="application/x-www-form-urlencoded" id="tbForm">
	<input type="hidden" name="event" value="#Event.getValue("xehAddTrackback")#">
	<fieldset class="sideBySide">
	<label for="blogName">Your Blog Name:</label>
	<input type="text" id="blogName" name="blog_name" value="#Event.getValue("blog_name","")#" maxlength="255" />
	</fieldset>
	<fieldset class="sideBySide">
	<label for="title">Your Blog Entry Title:</label>
	<input type="text" id="title" name="title" value="#Event.getValue("title","")#" maxlength="255" />
	</fieldset>
	<fieldset>
	<label for="excerpt">Excerpt from your Blog:</label><br/>
	<textarea id="excerpt" name="excerpt" cols=50 rows=10>#Event.getValue("excerpt","")#</textarea>
	</fieldset>
	<fieldset class="sideBySide">
	<label for="url">Your Blog Entry URL:</label>
	<input type="text" id="url" name="url" value="#Event.getValue("url","")#" maxlength="255" />
	</fieldset>
	<fieldset style="text-align:center">
	<input id="submit" type="button" name="cancelbutton" value="Cancel" onClick="window.close()">
	<input id="submit" type="submit" name="addtrackback" value="#getResource("post","")#" />
	</fieldset>
</form> 
</div>

<cfif isUserInRole("admin")>
	<div class="date">Send TrackBack</div>
	<div class="body">
	<script language="javascript">
		function setAction() {
			if (document.sendtb.trackbackURL.value == "") {
				alert('Please provide the trackback url');
				return false;
			}
			else {
				document.sendtb.action = document.sendtb.trackbackURL.value;
				document.sendtb.submit();
				return true;
			}
			
		}
	</script>
	<form action="" name="sendtb" method="post" enctype="application/x-www-form-urlencoded" onSubmit="return setAction();">
	<fieldset class="sideBySide">
	<label for="blogName">Your Blog Name:</label>
	<input type="text" id="blogName" name="blog_name" value="#form.blog_name#" maxlength="255" />
	</fieldset>
	<fieldset class="sideBySide">
	<label for="title">Your Blog Entry Title:</label>
	<input type="text" id="title" name="title" value="#form.title#" maxlength="255" />
	</fieldset>
	<fieldset>
	<label for="excerpt">Excerpt from your Blog:</label><br/>
	<textarea id="excerpt" name="excerpt" cols=50 rows=10>#form.excerpt#</textarea>
	</fieldset>
	<fieldset class="sideBySide">
	<label for="url">Your Blog Entry URL:</label>
	<input type="text" id="url" name="url" value="#form.url#" maxlength="255" />
	</fieldset>
	<fieldset style="text-align:center">
	<input id="submit" type="submit" name="addtrackback" value="#getResource("post")#" />
	</fieldset>
	
	</form> 
	
	</div>
</cfif>

</cfoutput>

<cfsetting enablecfoutputonly=false>