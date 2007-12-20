<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Untitled Document</title>
<script language="javascript" src="jquery-latest.pack.js"></script>
<script language="javascript">
function doFormEvent (e, targetID, frm) {
	var params = {};
	var frm = $(frm);
	for(i=0;i<frm.length;i++) {
		if(!(frm[i].type=="radio" && !frm[i].checked) && frm[i].value != undefined)  {
			params[frm[i].name] = frm[i].value;
		}
	}
	doEvent(e, targetID, params, "POST");
}
function doEvent (e, targetID, params, methodType ) {
	var pars = "event=" + e + "&";
	//Check for Method.
	var methodType = (methodType == null) ? "GET" : methodType;
	//parse params
	for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";
	//do Ajax Updater
	$.ajax( {type: methodType, 
		     url:"test.cfm",
		     dataType:"html",
		     data: pars,
		     error: h_callError,
		     complete: h_onComplete,
		     success: function(req){
		     	$("#"+targetID).html(req)}
	});
	
}
function h_onComplete(){
	alert("Call Completed");	
}
function h_callError(request, errorString) {
	alert('Sorry. An error ocurred while calling a server side component. Please try again. ' + errorString);
}
function placeContent(targetID){
	$("#"+targetID).html("This is a tests");
}
</script>

</head>
This is an ajax test
<input type="button" value="Put Content" onClick="placeContent('testdiv')">
<input type="button" value="Test" onClick="doEvent('','testdiv')">
<br><br>
<div id="testdiv" style="background-color:#f6ff5d;padding:10px;">NOTHING</div>
<body>
</body>
</html>