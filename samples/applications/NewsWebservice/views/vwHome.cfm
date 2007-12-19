<script language="javascript">
function changeEvent( eventName ){
	document.getElementById("form1").event.value = eventName;
}
function disableButtons( clientbutton ){
	document.getElementById("form1").homebutton.disabled = true;
	document.getElementById("form1").getbutton.disabled = true;
	document.getElementById("form1").getclientbutton.disabled = true;
	//Disable clientbutton if sent
	if ( clientbutton != null)
		document.getElementById("clientclearbutton").disabled = true;
	
}
</script>
<style>
.newsbox{
height: 400px;
width:  650px;
overflow: scroll;
background: #f5f5f5;
border: 1px dashed #ddd;
padding: 5px;
}
</style>

<table width="500">
<tr>
	<td><strong><p>Welcome to the ColdBox Webservices NewsLinx.&nbsp; Please click on the button below to retrieve all the coldbox update news via webservices and present them below.</p>
</strong>
<p>When you click on "Get Feed" you will invoke the news webservices, retrieve the news and place into the request collection.  This is temporary, if you click on "Home" and go back, the news are gone.</p>
<p>When you click on "Get Feed (Using Clientstorage Plugin)" the news will be saved using the client storage plugin.  You will need to have a clientstorage setup already in order to use this.  The news now become permanent until you clean them.</p>
</td>
</tr>
<tr>
<td>
	<cfoutput>
	<form id="form1" name="form1" method="post" action="" onSubmit="disableButtons()">
	  <input type="button" name="homebutton" value="Home" onClick="disableButtons();window.location='index.cfm'" />&nbsp;
	  <input type="submit" name="getbutton" value="Get News Feed" />&nbsp;
	  <input type="submit" name="getclientbutton" value="Get News Feed (Using ClientStorage Plugin)" onclick="changeEvent('#Event.getValue("xehGetNewsClient")#')" />
	  <input name="event" type="hidden" id="event" value="#Event.getValue("xehGetNews")#" />
	</form>
	<p >&nbsp;</p>
	<!--- Render a messagebox if set --->
	#getPlugin("messagebox").renderit()#<br>
	</cfoutput>
</td>
</tr>
</table>

<!--- Display the news if found in the request collection --->
<cfif Event.valueExists("newsfeed")>
	<div class="newsbox">
	<cfdump var="#Event.getValue("newsfeed")#">
	</div>
</cfif>

<!--- Display the news if found in the client storage plugin --->
<cfif getPlugin("clientstorage").exists("newsfeed")>
	<div class="newsbox">
	<h4>Client Storage News: <input type="button" name="clientclearbutton" id="clientclearbutton" value="Clear Client Storage News" onClick="disableButtons(true);window.location='index.cfm?event=#Event.getValue("xehDeleteNews")#'" />&nbsp;</h4>
	<cfdump var="#getPlugin("clientstorage").getvar("newsfeed")#">
	</div>
</cfif>