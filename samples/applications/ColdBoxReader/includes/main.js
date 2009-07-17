// JavaScript Document

//********************************************************************************
/* DreamWeaver Rollout Code */
//********************************************************************************
function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}

//********************************************************************************
//********************************************************************************


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
	$("loadingImage").className = "showlayer";
}

function h_callError(request) {
	alert('Sorry. An error ocurred while calling a server side component.');
}

function doEventComplete (obj) {
	$("loadingImage").className = "hidelayer";
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

function logout(){
	return confirm("Do you wish to logout of your ColdBox reader session?")
}

function toggleFooter(){
	if ( FOOTER_DRAWER ){
		$("footer").className = "hidelayer";
		$("footer_small").className = "footer_small";
		FOOTER_DRAWER = false;
	}	
	else{
		$("footer").className = "footer";
		$("footer_small").className = "hidelayer";
		FOOTER_DRAWER = true;
	}
}



//GLOVAL VARIABLES
var FOOTER_DRAWER = true;