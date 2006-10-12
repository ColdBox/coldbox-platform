<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link href="includes/style.css" rel="stylesheet" type="text/css" />
<script language="javascript" src="includes/prototype-1.4.js"></script>
<script language="javascript" src="includes/javascript.js"></script>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title>ColdBox Dashboard</title>
</head>
<body class="adminBody">
<div class="page">
	<div class="header"></div>
	  <table border="0" cellpadding="0" cellspacing="0" class="contentTable">
        <tr>
          <td class="menuColumn" id="mainmenu">
			 
			  <div class="menuheader"></div>
			  <cfinclude template="../includes/menubar.cfm">

			  <cfoutput>
			  <div style="padding:10px;" align="center">
			  #getResource("changelanguage")#
				<select name="locale" onChange="window.location='?event=ehColdbox.doChangeLocale&locale=' + this.value" class="textboxes" style="width:100px">
				   	<option value="en_US" <cfif getPlugin("i18n").getfwLocale() eq "en_US">selected</cfif>>English</option>
				   	<option value="es_SV" <cfif getPlugin("i18n").getfwLocale() eq "es_SV">selected</cfif>>Spanish</option>
				</select>
			  </div>
			  </cfoutput>
			  
			  <div style="margin-bottom:30px; margin-top:10px">
		  	  <div class="TablesTitles" align="center">
			   	<cfoutput>#getresource("livelinks")#</cfoutput>
			  </div>
			  <cfoutput>
		  	  <ul>
		  	  	<li><a href="#getSetting("FrameworkAPI",1)#" target="_blank">#getresource("onlineapi")#</a></li><br>
		  	  	<li><a href="#getSetting("FrameworkForums",1)#" target="_blank">#getresource("onlineforums")#</a></li><br>
		  	  	<li><a href="#getSetting("FrameworkBlog",1)#" target="_blank">ColdBox Blog</a></li><br>
		  	  	<li><a href="#getSetting("FrameworkTrac",1)#" target="_blank">Trac Site</a></li>
		  	  </ul>
			  </cfoutput>
		  	  </div>
		  </td>

		  <td class="collapser" onclick="collapse()" onmouseover="changepic('on')"
					  onmouseout="changepic('off')" >
		  <a href="#"
		  			  onmouseover="changepic('on')"
					  onmouseout="changepic('off')"><img src="images/collapser_left.gif" border="0" id="collapser"
		  										alt="Hide/Show Menubar" title="Hide/Show Menubar"/></a>
		  </td>

		  <td valign="top" class="dashboardColumn">
			  <div style="background:#5A4D52"><img src="images/dashboard_header_bar.png" width="512" height="25" /></div>
			  <div class="dashboardContent"><cfoutput>#renderView()#</cfoutput></div>
		  </td>
        </tr>
      </table>
	<div class="adminSmall" align="right">Powered by ColdBox</div>
</div>

</body>

</html>