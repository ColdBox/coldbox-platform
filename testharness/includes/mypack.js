
var isIE=(navigator.appVersion.indexOf("MSIE")!=-1)?true:false;var isWin=(navigator.appVersion.toLowerCase().indexOf("win")!=-1)?true:false;var isOpera=(navigator.userAgent.indexOf("Opera")!=-1)?true:false;function ControlVersion()
{var version;var axo;var e;try{axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");version=axo.GetVariable("$version");}catch(e){}
if(!version)
{try{axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.6");version="WIN 6,0,21,0";axo.AllowScriptAccess="always";version=axo.GetVariable("$version");}catch(e){}}
if(!version)
{try{axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.3");version=axo.GetVariable("$version");}catch(e){}}
if(!version)
{try{axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash.3");version="WIN 3,0,18,0";}catch(e){}}
if(!version)
{try{axo=new ActiveXObject("ShockwaveFlash.ShockwaveFlash");version="WIN 2,0,0,11";}catch(e){version=-1;}}
return version;}
function GetSwfVer(){var flashVer=-1;if(navigator.plugins!=null&&navigator.plugins.length>0){if(navigator.plugins["Shockwave Flash 2.0"]||navigator.plugins["Shockwave Flash"]){var swVer2=navigator.plugins["Shockwave Flash 2.0"]?" 2.0":"";var flashDescription=navigator.plugins["Shockwave Flash"+swVer2].description;var descArray=flashDescription.split(" ");var tempArrayMajor=descArray[2].split(".");var versionMajor=tempArrayMajor[0];var versionMinor=tempArrayMajor[1];var versionRevision=descArray[3];if(versionRevision==""){versionRevision=descArray[4];}
if(versionRevision[0]=="d"){versionRevision=versionRevision.substring(1);}else if(versionRevision[0]=="r"){versionRevision=versionRevision.substring(1);if(versionRevision.indexOf("d")>0){versionRevision=versionRevision.substring(0,versionRevision.indexOf("d"));}}
var flashVer=versionMajor+"."+versionMinor+"."+versionRevision;}}
else if(navigator.userAgent.toLowerCase().indexOf("webtv/2.6")!=-1)flashVer=4;else if(navigator.userAgent.toLowerCase().indexOf("webtv/2.5")!=-1)flashVer=3;else if(navigator.userAgent.toLowerCase().indexOf("webtv")!=-1)flashVer=2;else if(isIE&&isWin&&!isOpera){flashVer=ControlVersion();}
return flashVer;}
function DetectFlashVer(reqMajorVer,reqMinorVer,reqRevision)
{versionStr=GetSwfVer();if(versionStr==-1){return false;}else if(versionStr!=0){if(isIE&&isWin&&!isOpera){tempArray=versionStr.split(" ");tempString=tempArray[1];versionArray=tempString.split(",");}else{versionArray=versionStr.split(".");}
var versionMajor=versionArray[0];var versionMinor=versionArray[1];var versionRevision=versionArray[2];if(versionMajor>parseFloat(reqMajorVer)){return true;}else if(versionMajor==parseFloat(reqMajorVer)){if(versionMinor>parseFloat(reqMinorVer))
return true;else if(versionMinor==parseFloat(reqMinorVer)){if(versionRevision>=parseFloat(reqRevision))
return true;}}
return false;}}
function AC_AddExtension(src,ext)
{if(src.indexOf('?')!=-1)
return src.replace(/\?/,ext+'?');else
return src+ext;}
function AC_Generateobj(objAttrs,params,embedAttrs)
{var str='';if(isIE&&isWin&&!isOpera)
{str+='<object ';for(var i in objAttrs)
str+=i+'="'+objAttrs[i]+'" ';str+='>';for(var i in params)
str+='<param name="'+i+'" value="'+params[i]+'" /> ';str+='</object>';}else{str+='<embed ';for(var i in embedAttrs)
str+=i+'="'+embedAttrs[i]+'" ';str+='> </embed>';}
document.write(str);}
function AC_FL_RunContent(){var ret=AC_GetArgs
(arguments,".swf","movie","clsid:d27cdb6e-ae6d-11cf-96b8-444553540000","application/x-shockwave-flash");AC_Generateobj(ret.objAttrs,ret.params,ret.embedAttrs);}
function AC_GetArgs(args,ext,srcParamName,classid,mimeType){var ret=new Object();ret.embedAttrs=new Object();ret.params=new Object();ret.objAttrs=new Object();for(var i=0;i<args.length;i=i+2){var currArg=args[i].toLowerCase();switch(currArg){case"classid":break;case"pluginspage":ret.embedAttrs[args[i]]=args[i+1];break;case"src":case"movie":args[i+1]=AC_AddExtension(args[i+1],ext);ret.embedAttrs["src"]=args[i+1];ret.params[srcParamName]=args[i+1];break;case"onafterupdate":case"onbeforeupdate":case"onblur":case"oncellchange":case"onclick":case"ondblClick":case"ondrag":case"ondragend":case"ondragenter":case"ondragleave":case"ondragover":case"ondrop":case"onfinish":case"onfocus":case"onhelp":case"onmousedown":case"onmouseup":case"onmouseover":case"onmousemove":case"onmouseout":case"onkeypress":case"onkeydown":case"onkeyup":case"onload":case"onlosecapture":case"onpropertychange":case"onreadystatechange":case"onrowsdelete":case"onrowenter":case"onrowexit":case"onrowsinserted":case"onstart":case"onscroll":case"onbeforeeditfocus":case"onactivate":case"onbeforedeactivate":case"ondeactivate":case"type":case"codebase":ret.objAttrs[args[i]]=args[i+1];break;case"id":case"width":case"height":case"align":case"vspace":case"hspace":case"class":case"title":case"accesskey":case"name":case"tabindex":ret.embedAttrs[args[i]]=ret.objAttrs[args[i]]=args[i+1];break;default:ret.embedAttrs[args[i]]=ret.params[args[i]]=args[i+1];}}
ret.objAttrs["classid"]=classid;if(mimeType)ret.embedAttrs["type"]=mimeType;return ret;}