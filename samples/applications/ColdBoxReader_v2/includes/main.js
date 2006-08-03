// JavaScript Document


function doFormEvent (e, targetID, frm) {
	var params = {};
	for(i=0;i<frm.length;i++) {
		if(!(frm[i].type=="radio" && !frm[i].checked))  {
			params[frm[i].name] = frm[i].value;
		}
	}
	doEvent(e, targetID, params);
}

function doEvent (e, targetID, params) {
	var pars = "";
	for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";
	pars = pars + "event=" + e;
	var myAjax = new Ajax.Updater(targetID,
									"index.cfm",
									{method:'get', parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:doEventComplete});
	$("loadingImage").style.display = 'block';
}

function h_callError(request) {
	alert('Sorry. An error ocurred while calling a server side component.');
}

function doEventComplete (obj) {
	$("loadingImage").style.display = 'none';
}

function viewContent(id) {
	var i = $(id);
	if(i.style.display=="none")
		i.style.display='block';
	else
		i.style.display='none';

}

function selectFeed(feedID) {
	doEvent("ehFeed.dspViewFeed", "centercontent", {feedID:feedID});
}

function clearDiv(id) {
	$(id).innerHTML = "";
}