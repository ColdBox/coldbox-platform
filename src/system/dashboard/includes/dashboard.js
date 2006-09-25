//AUTHOR: 		LUIS MAJANO
//DESCRIPTION: 	MAIN JS FILE FOR THE DASHBOARD.
//

//********************************************************************************
//AJAX LOADER JS
//********************************************************************************
function lon(){
	Effect.Appear('myloader',{duration: .2});
}
function loff(){
	Effect.Fade('myloader',{duration: .2});	
}

//********************************************************************************
//DIV EFFECTS
//********************************************************************************
function divon(divid){
	Effect.Appear(divid,{duration: .1});
}
function divoff(divid){
	Effect.Fade(divid,{duration: .1});
}
function cleariv(id) {
	$(id).innerHTML = "";
}
function rollover(img){
	$(img).src = $(img).getAttribute('srcon');
}
function rollout(img){
	$(img).src = $(img).getAttribute('srcoff');
}
function showAdvancedSearchBar( openit ){
	if ( openit ){
		$("advancedSearchBarTriggerOpen").className = "hidelayer";
		$("advancedSearchBarTriggerClose").className = "showlayer";
		divon('advancedSearchBar');
		
	}
	else{
		$("advancedSearchBarTriggerClose").className = "hidelayer";
		$("advancedSearchBarTriggerOpen").className = "showlayer";
		divoff('advancedSearchBar');
	}
}
//********************************************************************************
//AJAX INTERACTION
//********************************************************************************
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
	parent.topframe.lon();
	var pars = "event=" + e + "&";
	//Check for Method.
	if ( methodType == null )
		methodType = "get";
	//parse params
	for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";
	//do Ajax Updater
	var myAjax = new Ajax.Updater(targetID,
								  "index.cfm",
								  {method:methodType, parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:parent.topframe.loff});
}

function h_callError(request) {
	alert('Sorry. An error ocurred while calling a server side component. Please try again.');
}


//********************************************************************************
//INTERACTION
//********************************************************************************
function validateLogout(){
	if ( confirm("Do your really want to exit the ColdBox Dashboard?") ){
		lon();
		return true;
	}
	return false;
}



//********************************************************************************
//TEST METHODS
//********************************************************************************


function doTest(targetID){
	parent.topframe.lon();
	var pars = "";
	var weburl = "/applications/coldbox/testing/ajax.cfm";
	var	methodType = "GET";
	//do Ajax Updater
	var myAjax = new Ajax.Updater(targetID,
								  weburl,
								  {method:methodType, parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:parent.topframe.loff});
}

