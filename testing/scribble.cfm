<cfif structKeyExists(url,"Test")>
<cfoutput>true</cfoutput><cfsetting showdebugoutput="false">
<cfelse>
<script language="JavaScript" type="text/javascript">


function fw_cboxCommand( commandURL, verb ){
	if( verb == null ){
		verb = "GET";
	}
	var request = xmlhttp=new XMLHttpRequest();
	request.open( verb, commandURL, false);
	request.send();
	var serverResponse = eval(request.responseText);
	alert(serverResponse);
	
}

fw_cboxCommand("scribble.cfm?test");

</script>

</cfif>
