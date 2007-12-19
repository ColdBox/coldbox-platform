<cfif isDefined("form.hashbutton")>
<cfoutput><h3>Hash: #hash(str)#</h3></cfoutput>
</cfif>

<cfoutput>
<form action="#cgi.SCRIPT_NAME#" method="post">

<input type="textbox" name="str">

<input type="submit" name="hashbutton" id="hashbutton">
</form>
</cfoutput>