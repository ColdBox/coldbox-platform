<cfoutput>
<link href="../includes/style.css" rel="stylesheet" type="text/css" />
<span class="dashboardTitles">
<a href="#cgi.script_name#?event=ehColdbox.dspConfigEditor&cfdoc=true&cfdoctype=pdf" target="_blank"><img src="images/i_pdf.gif" alt="Print Config.xsd" border="0" align="absbottom"/></a>
<a href="#cgi.script_name#?event=ehColdbox.dspConfigEditor&cfdoc=true&cfdoctype=flashpaper" target="_blank"><img src="images/flashpaper.gif" alt="Print Config.xsd" border="0" align="absbottom"/></a>
#getresource("configeditor_title")#</span><br /><br>
#getresource("configeditor_text")# <br />
<br />
#getPlugin("messagebox").render()#
<form id="form_xmleditor" name="form1" method="post" action="#cgi.SCRIPT_NAME#">
  <div align="center">
    <textarea name="xmlcontent" cols="40" rows="10" wrap="physical" class="filecontents"
			  id="xmlcontent" disabled="true"
			  onKeyDown="allowtab(this, event)" onkeyup="this.focus()">#getValue("configXML")#</textarea>
    <br />
    <input name="button_edit" type="button" class="buttons" id="button_edit" onclick="enableEditor()" value="#getresource("edit_button")#" />
    <input name="button_save" type="submit" class="buttons" id="button_save" value="#getresource("save_button")#" disabled="true" onclick="return saveEditor()"/>
    <input name="event" type="hidden" id="event" value="ehColdbox.doSaveConfig" />
  </div>
</form>
</cfoutput>
