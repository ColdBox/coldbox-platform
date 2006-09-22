<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title>ColdBox Dashboard Header</title>
<link href="includes/style.css" rel="stylesheet" type="text/css" />
<script language="javascript" src="includes/lib/prototype.js"></script>
<script language="javascript" src="includes/dashboard.js"></script>
<script language="javascript" src="includes/toolkit/scriptaculous.js?load=effects"></script>
<script>
	
<!--- DHTML Methods --->
function doFormEvent (e, targetID, frm, callback, methodType) {
	if ( methodType == null || methodType == undefined )
		methodType = "get";
	var params = {};
	var frm = $(frm);
	for(i=0;i<frm.length;i++) {
		if(!(frm[i].type=="radio" && !frm[i].checked) && frm[i].value != undefined)  {
			params[frm[i].name] = frm[i].value;
		}
	}
	doEvent(e, targetID, params, callback, methodType);
}

function doEvent (e, targetID, params, callback, methodType ) {
	if ( methodType == null || methodType == undefined )
		methodType = "get";
	var pars = "";
	for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";
	pars = pars + "event=" + e;
	var myAjax = new Ajax.Updater(targetID,
									"index.cfm",
									{method:methodType, parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:callback});
}

function doCall(targetID, targetURL, params, callback, methodType ){
	if ( methodType == null || methodType == undefined )
		methodType = "get";
	var pars = "";
	for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";
	var myAjax = new Ajax.Updater(targetID,
								   targetURL,
								   {method:methodType, parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:callback});
}

function h_callError(request) {
	alert('Sorry. An error ocurred while calling a server side component. Please try again.');
}

function clearDiv(id) {
	$(id).innerHTML = "";
}

function loading(toggle){
	if ( toggle )
		$("myloader").className = "showlayer";
	else
		$("myloader").className = "hidelayer";
}
function loadit(){
	parent.mainframe.location.href="http://trac.luismajano.com/coldbox";
}

function showAdvancedBar(){
	if ( $("advancedSearchBar").className == "hidelayer" ){
		$("advancedSearchBar").className = "showlayer";
		$("advancedSearchBarTriggerOpen").className = "hidelayer";
		$("advancedSearchBarTriggerClose").className = "showlayer";
	}
	else{
		$("advancedSearchBar").className = "hidelayer";
		$("advancedSearchBarTriggerClose").className = "hidelayer";
		$("advancedSearchBarTriggerOpen").className = "showlayer";
	}
}
</script>
</head>
<body>
<cfoutput>
<div class="headerbar"></div>	

<div class="statusbar">
	<form id="searchdocs" action="#getSetting("tracsite")#/search" method="get" target="mainframe">
	
	<div style="float:left; margin-left:10px;margin-top: 3px">
		<a href="javascript:parent.mainframe.history.back()"><img ></a>
		<a href="javascript:parent.mainframe.history.forward()">Forward</a>
		<input type="text" name="q" size="20" accesskey="f" value="Search Documentation" style="font-size:9px" onclick="this.value='';" />
		<input type="Submit" name="Search" value="Search" style="font-size:9px" />
	</div>
	
	<div style="float:left;margin-left:10px;margin-top: 5px">
		<div id="advancedSearchBarTriggerOpen" class="showlayer"><a href="javascript:showAdvancedBar()" title="Show Advanced Search Bar">Options</a></div>
		<div id="advancedSearchBarTriggerClose" class="hidelayer"><a href="javascript:showAdvancedBar()" title="Close Advanced Search Bar">Close</a></div>
	</div>
	
	<div style="height: 25px;float:left;margin-left: 10px;padding-left: 10px;padding-right:10px; height:inherit; border-left:1px solid #cccccc;border-right:1px solid #cccccc" id="advancedSearchBar" class="hidelayer">
	   <strong>Search:</strong>
	   <input type="checkbox" id="ticket" 
			  name="ticket" checked="checked" />
	   <label for="ticket" style="margin-">Tickets</label>
	   <input type="checkbox" id="changeset" 
			  name="changeset" checked="checked" />
	   <label for="changeset">Changesets</label>
	   <input type="checkbox" id="wiki" 
			  name="wiki" checked="checked" />
	   <label for="wiki">Wiki</label>
	</div>
	
	<div class="hidelayer" id="myloader"><div class="myloader"><img src="images/ajax-loader.gif" width="220" height="19" align="absmiddle" title="Loading..." /></div>
	</div>
	</form>
</div>
</cfoutput>	
</body>
</html>