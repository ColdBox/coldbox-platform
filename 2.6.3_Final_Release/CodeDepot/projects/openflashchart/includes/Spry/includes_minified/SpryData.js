// SpryData.js - version 0.41 - Spry Pre-Release 1.6
//
// Copyright (c) 2007. Adobe Systems Incorporated.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//   * Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//   * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//   * Neither the name of Adobe Systems Incorporated nor the names of its
//     contributors may be used to endorse or promote products derived from this
//     software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

var Spry;if(!Spry)Spry={};if(!Spry.Utils)Spry.Utils={};Spry.Utils.msProgIDs=["MSXML2.XMLHTTP.6.0","MSXML2.XMLHTTP.3.0"];Spry.Utils.createXMLHttpRequest=function()
{var req=null;try
{if(window.ActiveXObject)
{while(!req&&Spry.Utils.msProgIDs.length)
{try{req=new ActiveXObject(Spry.Utils.msProgIDs[0]);}catch(e){req=null;}
if(!req)
Spry.Utils.msProgIDs.splice(0,1);}}
if(!req&&window.XMLHttpRequest)
req=new XMLHttpRequest();}
catch(e){req=null;}
if(!req)
Spry.Debug.reportError("Failed to create an XMLHttpRequest object!");return req;};Spry.Utils.loadURL=function(method,url,async,callback,opts)
{var req=new Spry.Utils.loadURL.Request();req.method=method;req.url=url;req.async=async;req.successCallback=callback;Spry.Utils.setOptions(req,opts);try
{req.xhRequest=Spry.Utils.createXMLHttpRequest();if(!req.xhRequest)
return null;if(req.async)
req.xhRequest.onreadystatechange=function(){Spry.Utils.loadURL.callback(req);};req.xhRequest.open(req.method,req.url,req.async,req.username,req.password);if(req.headers)
{for(var name in req.headers)
req.xhRequest.setRequestHeader(name,req.headers[name]);}
req.xhRequest.send(req.postData);if(!req.async)
Spry.Utils.loadURL.callback(req);}
catch(e)
{if(req.errorCallback)
req.errorCallback(req);else
Spry.Debug.reportError("Exception caught while loading "+url+": "+e);req=null;}
return req;};Spry.Utils.loadURL.callback=function(req)
{if(!req||req.xhRequest.readyState!=4)
return;if(req.successCallback&&(req.xhRequest.status==200||req.xhRequest.status==0))
req.successCallback(req);else if(req.errorCallback)
req.errorCallback(req);};Spry.Utils.loadURL.Request=function()
{var props=Spry.Utils.loadURL.Request.props;var numProps=props.length;for(var i=0;i<numProps;i++)
this[props[i]]=null;this.method="GET";this.async=true;this.headers={};};Spry.Utils.loadURL.Request.props=["method","url","async","username","password","postData","successCallback","errorCallback","headers","userData","xhRequest"];Spry.Utils.loadURL.Request.prototype.extractRequestOptions=function(opts,undefineRequestProps)
{if(!opts)
return;var props=Spry.Utils.loadURL.Request.props;var numProps=props.length;for(var i=0;i<numProps;i++)
{var prop=props[i];if(opts[prop]!=undefined)
{this[prop]=opts[prop];if(undefineRequestProps)
opts[prop]=undefined;}}};Spry.Utils.loadURL.Request.prototype.clone=function()
{var props=Spry.Utils.loadURL.Request.props;var numProps=props.length;var req=new Spry.Utils.loadURL.Request;for(var i=0;i<numProps;i++)
req[props[i]]=this[props[i]];if(this.headers)
{req.headers={};Spry.Utils.setOptions(req.headers,this.headers);}
return req;};Spry.Utils.setInnerHTML=function(ele,str,preventScripts)
{if(!ele)
return;ele=Spry.$(ele);var scriptExpr="<script[^>]*>(.|\s|\n|\r)*?</script>";ele.innerHTML=str.replace(new RegExp(scriptExpr,"img"),"");if(preventScripts)
return;var matches=str.match(new RegExp(scriptExpr,"img"));if(matches)
{var numMatches=matches.length;for(var i=0;i<numMatches;i++)
{var s=matches[i].replace(/<script[^>]*>[\s\r\n]*(<\!--)?|(-->)?[\s\r\n]*<\/script>/img,"");Spry.Utils.eval(s);}}};Spry.Utils.updateContent=function(ele,url,finishFunc,opts)
{Spry.Utils.loadURL("GET",url,true,function(req)
{Spry.Utils.setInnerHTML(ele,req.xhRequest.responseText);if(finishFunc)
finishFunc(ele,url);},opts);};if(!Spry.$$)
{Spry.Utils.addEventListener=function(element,eventType,handler,capture)
{try
{element=Spry.$(element);if(element.addEventListener)
element.addEventListener(eventType,handler,capture);else if(element.attachEvent)
element.attachEvent("on"+eventType,handler);}
catch(e){}};Spry.Utils.removeEventListener=function(element,eventType,handler,capture)
{try
{element=Spry.$(element);if(element.removeEventListener)
element.removeEventListener(eventType,handler,capture);else if(element.detachEvent)
element.detachEvent("on"+eventType,handler);}
catch(e){}};Spry.Utils.addLoadListener=function(handler)
{if(typeof window.addEventListener!='undefined')
window.addEventListener('load',handler,false);else if(typeof document.addEventListener!='undefined')
document.addEventListener('load',handler,false);else if(typeof window.attachEvent!='undefined')
window.attachEvent('onload',handler);};Spry.Utils.addClassName=function(ele,className)
{ele=Spry.$(ele);if(!ele||!className||(ele.className&&ele.className.search(new RegExp("\\b"+className+"\\b"))!=-1))
return;ele.className+=(ele.className?" ":"")+className;};Spry.Utils.removeClassName=function(ele,className)
{ele=Spry.$(ele);if(!ele||!className||(ele.className&&ele.className.search(new RegExp("\\b"+className+"\\b"))==-1))
return;ele.className=ele.className.replace(new RegExp("\\s*\\b"+className+"\\b","g"),"");};Spry.$=function(element)
{if(arguments.length>1)
{for(var i=0,elements=[],length=arguments.length;i<length;i++)
elements.push(Spry.$(arguments[i]));return elements;}
if(typeof element=='string')
element=document.getElementById(element);return element;};}
Spry.Utils.eval=function(str)
{return eval(str);};Spry.Utils.escapeQuotesAndLineBreaks=function(str)
{if(str)
{str=str.replace(/\\/g,"\\\\");str=str.replace(/["']/g,"\\$&");str=str.replace(/\n/g,"\\n");str=str.replace(/\r/g,"\\r");}
return str;};Spry.Utils.encodeEntities=function(str)
{if(str&&str.search(/[&<>"]/)!=-1)
{str=str.replace(/&/g,"&amp;");str=str.replace(/</g,"&lt;");str=str.replace(/>/g,"&gt;");str=str.replace(/"/g,"&quot;");}
return str};Spry.Utils.decodeEntities=function(str)
{var d=Spry.Utils.decodeEntities.div;if(!d)
{d=document.createElement('div');Spry.Utils.decodeEntities.div=d;if(!d)return str;}
d.innerHTML=str;if(d.childNodes.length==1&&d.firstChild.nodeType==3&&d.firstChild.nextSibling==null)
str=d.firstChild.data;else
{str=str.replace(/&lt;/gi,"<");str=str.replace(/&gt;/gi,">");str=str.replace(/&quot;/gi,"\"");str=str.replace(/&amp;/gi,"&");}
return str;};Spry.Utils.fixupIETagAttributes=function(inStr)
{var outStr="";var tagStart=inStr.match(/^<[^\s>]+\s*/)[0];var tagEnd=inStr.match(/\s*\/?>$/)[0];var tagAttrs=inStr.replace(/^<[^\s>]+\s*|\s*\/?>/g,"");outStr+=tagStart;if(tagAttrs)
{var startIndex=0;var endIndex=0;while(startIndex<tagAttrs.length)
{while(tagAttrs.charAt(endIndex)!='='&&endIndex<tagAttrs.length)
++endIndex;if(endIndex>=tagAttrs.length)
{outStr+=tagAttrs.substring(startIndex,endIndex);break;}
++endIndex;outStr+=tagAttrs.substring(startIndex,endIndex);startIndex=endIndex;if(tagAttrs.charAt(endIndex)=='"'||tagAttrs.charAt(endIndex)=="'")
{var savedIndex=endIndex++;while(endIndex<tagAttrs.length)
{if(tagAttrs.charAt(endIndex)==tagAttrs.charAt(savedIndex))
{endIndex++;break;}
else if(tagAttrs.charAt(endIndex)=="\\")
endIndex++;endIndex++;}
outStr+=tagAttrs.substring(startIndex,endIndex);startIndex=endIndex;}
else
{outStr+="\"";var sIndex=tagAttrs.slice(endIndex).search(/\s/);endIndex=(sIndex!=-1)?(endIndex+sIndex):tagAttrs.length;outStr+=tagAttrs.slice(startIndex,endIndex);outStr+="\"";startIndex=endIndex;}}}
outStr+=tagEnd;return outStr;};Spry.Utils.fixUpIEInnerHTML=function(inStr)
{var outStr="";var regexp=new RegExp("<\\!--|<\\!\\[CDATA\\[|<\\w+[^<>]*>|-->|\\]\\](>|\&gt;)","g");var searchStartIndex=0;var skipFixUp=0;while(inStr.length)
{var results=regexp.exec(inStr);if(!results||!results[0])
{outStr+=inStr.substr(searchStartIndex,inStr.length-searchStartIndex);break;}
if(results.index!=searchStartIndex)
{outStr+=inStr.substr(searchStartIndex,results.index-searchStartIndex);}
if(results[0]=="<!--"||results[0]=="<![CDATA[")
{++skipFixUp;outStr+=results[0];}
else if(results[0]=="-->"||results[0]=="]]>"||(skipFixUp&&results[0]=="]]&gt;"))
{--skipFixUp;outStr+=results[0];}
else if(!skipFixUp&&results[0].charAt(0)=='<')
outStr+=Spry.Utils.fixupIETagAttributes(results[0]);else
outStr+=results[0];searchStartIndex=regexp.lastIndex;}
return outStr;};Spry.Utils.stringToXMLDoc=function(str)
{var xmlDoc=null;try
{var xmlDOMObj=new ActiveXObject("Microsoft.XMLDOM");xmlDOMObj.async=false;xmlDOMObj.loadXML(str);xmlDoc=xmlDOMObj;}
catch(e)
{try
{var domParser=new DOMParser;xmlDoc=domParser.parseFromString(str,'text/xml');}
catch(e)
{Spry.Debug.reportError("Caught exception in Spry.Utils.stringToXMLDoc(): "+e+"\n");xmlDoc=null;}}
return xmlDoc;};Spry.Utils.serializeObject=function(obj)
{var str="";var firstItem=true;if(obj==null||obj==undefined)
return str+obj;var objType=typeof obj;if(objType=="number"||objType=="boolean")
str+=obj;else if(objType=="string")
str+="\""+Spry.Utils.escapeQuotesAndLineBreaks(obj)+"\"";else if(obj.constructor==Array)
{str+="[";for(var i=0;i<obj.length;i++)
{if(!firstItem)
str+=", ";str+=Spry.Utils.serializeObject(obj[i]);firstItem=false;}
str+="]";}
else if(objType=="object")
{str+="{";for(var p in obj)
{if(!firstItem)
str+=", ";str+="\""+p+"\": "+Spry.Utils.serializeObject(obj[p]);firstItem=false;}
str+="}";}
return str;};Spry.Utils.getNodesByFunc=function(root,func)
{var nodeStack=new Array;var resultArr=new Array;var node=root;while(node)
{if(func(node))
resultArr.push(node);if(node.hasChildNodes())
{nodeStack.push(node);node=node.firstChild;}
else
{if(node==root)
node=null;else
try{node=node.nextSibling;}catch(e){node=null;};}
while(!node&&nodeStack.length>0)
{node=nodeStack.pop();if(node==root)
node=null;else
try{node=node.nextSibling;}catch(e){node=null;}}}
if(nodeStack&&nodeStack.length>0)
Spry.Debug.trace("-- WARNING: Spry.Utils.getNodesByFunc() failed to traverse all nodes!\n");return resultArr;};Spry.Utils.getFirstChildWithNodeName=function(node,nodeName)
{var child=node.firstChild;while(child)
{if(child.nodeName==nodeName)
return child;child=child.nextSibling;}
return null;};Spry.Utils.setOptions=function(obj,optionsObj,ignoreUndefinedProps)
{if(!optionsObj)
return;for(var optionName in optionsObj)
{if(ignoreUndefinedProps&&optionsObj[optionName]==undefined)
continue;obj[optionName]=optionsObj[optionName];}};Spry.Utils.SelectionManager={};Spry.Utils.SelectionManager.selectionGroups=new Object;Spry.Utils.SelectionManager.SelectionGroup=function()
{this.selectedElements=new Array;};Spry.Utils.SelectionManager.SelectionGroup.prototype.select=function(element,className,multiSelect)
{var selObj=null;if(!multiSelect)
{this.clearSelection();}
else
{for(var i=0;i<this.selectedElements.length;i++)
{selObj=this.selectedElements[i].element;if(selObj.element==element)
{if(selObj.className!=className)
{Spry.Utils.removeClassName(element,selObj.className);Spry.Utils.addClassName(element,className);}
return;}}}
selObj=new Object;selObj.element=element;selObj.className=className;this.selectedElements.push(selObj);Spry.Utils.addClassName(element,className);};Spry.Utils.SelectionManager.SelectionGroup.prototype.unSelect=function(element)
{for(var i=0;i<this.selectedElements.length;i++)
{var selObj=this.selectedElements[i].element;if(selObj.element==element)
{Spry.Utils.removeClassName(selObj.element,selObj.className);return;}}};Spry.Utils.SelectionManager.SelectionGroup.prototype.clearSelection=function()
{var selObj=null;do
{selObj=this.selectedElements.shift();if(selObj)
Spry.Utils.removeClassName(selObj.element,selObj.className);}
while(selObj);};Spry.Utils.SelectionManager.getSelectionGroup=function(selectionGroupName)
{if(!selectionGroupName)
return null;var groupObj=Spry.Utils.SelectionManager.selectionGroups[selectionGroupName];if(!groupObj)
{groupObj=new Spry.Utils.SelectionManager.SelectionGroup();Spry.Utils.SelectionManager.selectionGroups[selectionGroupName]=groupObj;}
return groupObj;};Spry.Utils.SelectionManager.select=function(selectionGroupName,element,className,multiSelect)
{var groupObj=Spry.Utils.SelectionManager.getSelectionGroup(selectionGroupName);if(!groupObj)
return;groupObj.select(element,className,multiSelect);};Spry.Utils.SelectionManager.unSelect=function(selectionGroupName,element)
{var groupObj=Spry.Utils.SelectionManager.getSelectionGroup(selectionGroupName);if(!groupObj)
return;groupObj.unSelect(element,className);};Spry.Utils.SelectionManager.clearSelection=function(selectionGroupName)
{var groupObj=Spry.Utils.SelectionManager.getSelectionGroup(selectionGroupName);if(!groupObj)
return;groupObj.clearSelection();};Spry.Utils.Notifier=function()
{this.observers=[];this.suppressNotifications=0;};Spry.Utils.Notifier.prototype.addObserver=function(observer)
{if(!observer)
return;var len=this.observers.length;for(var i=0;i<len;i++)
{if(this.observers[i]==observer)
return;}
this.observers[len]=observer;};Spry.Utils.Notifier.prototype.removeObserver=function(observer)
{if(!observer)
return;for(var i=0;i<this.observers.length;i++)
{if(this.observers[i]==observer)
{this.observers.splice(i,1);break;}}};Spry.Utils.Notifier.prototype.notifyObservers=function(methodName,data)
{if(!methodName)
return;if(!this.suppressNotifications)
{var len=this.observers.length;for(var i=0;i<len;i++)
{var obs=this.observers[i];if(obs)
{if(typeof obs=="function")
obs(methodName,this,data);else if(obs[methodName])
obs[methodName](this,data);}}}};Spry.Utils.Notifier.prototype.enableNotifications=function()
{if(--this.suppressNotifications<0)
{this.suppressNotifications=0;Spry.Debug.reportError("Unbalanced enableNotifications() call!\n");}};Spry.Utils.Notifier.prototype.disableNotifications=function()
{++this.suppressNotifications;};Spry.Debug={};Spry.Debug.enableTrace=true;Spry.Debug.debugWindow=null;Spry.Debug.onloadDidFire=false;Spry.Utils.addLoadListener(function(){Spry.Debug.onloadDidFire=true;Spry.Debug.flushQueuedMessages();});Spry.Debug.flushQueuedMessages=function()
{if(Spry.Debug.flushQueuedMessages.msgs)
{var msgs=Spry.Debug.flushQueuedMessages.msgs;for(var i=0;i<msgs.length;i++)
Spry.Debug.debugOut(msgs[i].msg,msgs[i].color);Spry.Debug.flushQueuedMessages.msgs=null;}};Spry.Debug.createDebugWindow=function()
{if(!Spry.Debug.enableTrace||Spry.Debug.debugWindow||!Spry.Debug.onloadDidFire)
return;try
{Spry.Debug.debugWindow=document.createElement("div");var div=Spry.Debug.debugWindow;div.style.fontSize="12px";div.style.fontFamily="console";div.style.position="absolute";div.style.width="400px";div.style.height="300px";div.style.overflow="auto";div.style.border="solid 1px black";div.style.backgroundColor="white";div.style.color="black";div.style.bottom="0px";div.style.right="0px";div.setAttribute("id","SpryDebugWindow");document.body.appendChild(Spry.Debug.debugWindow);}
catch(e){}};Spry.Debug.debugOut=function(str,bgColor)
{if(!Spry.Debug.debugWindow)
{Spry.Debug.createDebugWindow();if(!Spry.Debug.debugWindow)
{if(!Spry.Debug.flushQueuedMessages.msgs)
Spry.Debug.flushQueuedMessages.msgs=new Array;Spry.Debug.flushQueuedMessages.msgs.push({msg:str,color:bgColor});return;}}
var d=document.createElement("div");if(bgColor)
d.style.backgroundColor=bgColor;d.innerHTML=str;Spry.Debug.debugWindow.appendChild(d);};Spry.Debug.trace=function(str)
{Spry.Debug.debugOut(str);};Spry.Debug.reportError=function(str)
{Spry.Debug.debugOut(str,"red");};Spry.Data={};Spry.Data.regionsArray={};Spry.Data.initRegionsOnLoad=true;Spry.Data.initRegions=function(rootNode)
{rootNode=rootNode?Spry.$(rootNode):document.body;var lastRegionFound=null;var regions=Spry.Utils.getNodesByFunc(rootNode,function(node)
{try
{if(node.nodeType!=1)
return false;var attrName="spry:region";var attr=node.attributes.getNamedItem(attrName);if(!attr)
{attrName="spry:detailregion";attr=node.attributes.getNamedItem(attrName);}
if(attr)
{if(lastRegionFound)
{var parent=node.parentNode;while(parent)
{if(parent==lastRegionFound)
{Spry.Debug.reportError("Found a nested "+attrName+" in the following markup. Nested regions are currently not supported.<br/><pre>"+Spry.Utils.encodeEntities(parent.innerHTML)+"</pre>");return false;}
parent=parent.parentNode;}}
if(attr.value)
{attr=node.attributes.getNamedItem("id");if(!attr||!attr.value)
{node.setAttribute("id","spryregion"+(++Spry.Data.initRegions.nextUniqueRegionID));}
lastRegionFound=node;return true;}
else
Spry.Debug.reportError(attrName+" attributes require one or more data set names as values!");}}
catch(e){}
return false;});var name,dataSets,i;var newRegions=[];for(i=0;i<regions.length;i++)
{var rgn=regions[i];var isDetailRegion=false;name=rgn.attributes.getNamedItem("id").value;attr=rgn.attributes.getNamedItem("spry:region");if(!attr)
{attr=rgn.attributes.getNamedItem("spry:detailregion");isDetailRegion=true;}
if(!attr.value)
{Spry.Debug.reportError("spry:region and spry:detailregion attributes require one or more data set names as values!");continue;}
rgn.attributes.removeNamedItem(attr.nodeName);Spry.Utils.removeClassName(rgn,Spry.Data.Region.hiddenRegionClassName);dataSets=Spry.Data.Region.strToDataSetsArray(attr.value);if(!dataSets.length)
{Spry.Debug.reportError("spry:region or spry:detailregion attribute has no data set!");continue;}
var hasBehaviorAttributes=false;var hasSpryContent=false;var dataStr="";var parent=null;var regionStates={};var regionStateMap={};attr=rgn.attributes.getNamedItem("spry:readystate");if(attr&&attr.value)
regionStateMap["ready"]=attr.value;attr=rgn.attributes.getNamedItem("spry:errorstate");if(attr&&attr.value)
regionStateMap["error"]=attr.value;attr=rgn.attributes.getNamedItem("spry:loadingstate");if(attr&&attr.value)
regionStateMap["loading"]=attr.value;attr=rgn.attributes.getNamedItem("spry:expiredstate");if(attr&&attr.value)
regionStateMap["expired"]=attr.value;var piRegions=Spry.Utils.getNodesByFunc(rgn,function(node)
{try
{if(node.nodeType==1)
{var attributes=node.attributes;var numPI=Spry.Data.Region.PI.orderedInstructions.length;var lastStartComment=null;var lastEndComment=null;for(var i=0;i<numPI;i++)
{var piName=Spry.Data.Region.PI.orderedInstructions[i];var attr=attributes.getNamedItem(piName);if(!attr)
continue;var piDesc=Spry.Data.Region.PI.instructions[piName];var childrenOnly=(node==rgn)?true:piDesc.childrenOnly;var openTag=piDesc.getOpenTag(node,piName);var closeTag=piDesc.getCloseTag(node,piName);if(childrenOnly)
{var oComment=document.createComment(openTag);var cComment=document.createComment(closeTag);if(!lastStartComment)
node.insertBefore(oComment,node.firstChild);else
node.insertBefore(oComment,lastStartComment.nextSibling);lastStartComment=oComment;if(!lastEndComment)
node.appendChild(cComment);else
node.insertBefore(cComment,lastEndComment);lastEndComment=cComment;}
else
{var parent=node.parentNode;parent.insertBefore(document.createComment(openTag),node);parent.insertBefore(document.createComment(closeTag),node.nextSibling);}
if(piName=="spry:state")
regionStates[attr.value]=true;node.removeAttribute(piName);}
if(Spry.Data.Region.enableBehaviorAttributes)
{var bAttrs=Spry.Data.Region.behaviorAttrs;for(var behaviorAttrName in bAttrs)
{var bAttr=attributes.getNamedItem(behaviorAttrName);if(bAttr)
{hasBehaviorAttributes=true;if(bAttrs[behaviorAttrName].setup)
bAttrs[behaviorAttrName].setup(node,bAttr.value);}}}}}
catch(e){}
return false;});dataStr=rgn.innerHTML;if(window.ActiveXObject&&!Spry.Data.Region.disableIEInnerHTMLFixUp&&dataStr.search(/=\{/)!=-1)
{if(Spry.Data.Region.debug)
Spry.Debug.trace("<hr />Performing IE innerHTML fix up of Region: "+name+"<br /><br />"+Spry.Utils.encodeEntities(dataStr));dataStr=Spry.Utils.fixUpIEInnerHTML(dataStr);}
if(Spry.Data.Region.debug)
Spry.Debug.trace("<hr />Region template markup for '"+name+"':<br /><br />"+Spry.Utils.encodeEntities(dataStr));if(!hasSpryContent)
{rgn.innerHTML="";}
var region=new Spry.Data.Region(rgn,name,isDetailRegion,dataStr,dataSets,regionStates,regionStateMap,hasBehaviorAttributes);Spry.Data.regionsArray[region.name]=region;newRegions.push(region);}
for(var i=0;i<newRegions.length;i++)
newRegions[i].updateContent();};Spry.Data.initRegions.nextUniqueRegionID=0;Spry.Data.updateRegion=function(regionName)
{if(!regionName||!Spry.Data.regionsArray||!Spry.Data.regionsArray[regionName])
return;try{Spry.Data.regionsArray[regionName].updateContent();}
catch(e){Spry.Debug.reportError("Spry.Data.updateRegion("+regionName+") caught an exception: "+e+"\n");}};Spry.Data.getRegion=function(regionName)
{return Spry.Data.regionsArray[regionName];};Spry.Data.updateAllRegions=function()
{if(!Spry.Data.regionsArray)
return;for(var regionName in Spry.Data.regionsArray)
Spry.Data.updateRegion(regionName);};Spry.Data.getDataSetByName=function(dataSetName)
{var ds=window[dataSetName];if(typeof ds!="object"||!ds.getData||!ds.filter)
return null;return ds;};Spry.Data.DataSet=function(options)
{Spry.Utils.Notifier.call(this);this.name="";this.internalID=Spry.Data.DataSet.nextDataSetID++;this.curRowID=0;this.data=[];this.unfilteredData=null;this.dataHash={};this.columnTypes={};this.filterFunc=null;this.filterDataFunc=null;this.distinctOnLoad=false;this.distinctFieldsOnLoad=null;this.sortOnLoad=null;this.sortOrderOnLoad="ascending";this.keepSorted=false;this.dataWasLoaded=false;this.pendingRequest=null;this.lastSortColumns=[];this.lastSortOrder="";this.loadIntervalID=0;Spry.Utils.setOptions(this,options);};Spry.Data.DataSet.prototype=new Spry.Utils.Notifier();Spry.Data.DataSet.prototype.constructor=Spry.Data.DataSet;Spry.Data.DataSet.prototype.getData=function(unfiltered)
{return(unfiltered&&this.unfilteredData)?this.unfilteredData:this.data;};Spry.Data.DataSet.prototype.getUnfilteredData=function()
{return this.getData(true);};Spry.Data.DataSet.prototype.getLoadDataRequestIsPending=function()
{return this.pendingRequest!=null;};Spry.Data.DataSet.prototype.getDataWasLoaded=function()
{return this.dataWasLoaded;};Spry.Data.DataSet.prototype.setDataFromArray=function(arr,fireSyncLoad)
{this.notifyObservers("onPreLoad");this.unfilteredData=null;this.filteredData=null;this.data=[];this.dataHash={};var arrLen=arr.length;for(var i=0;i<arrLen;i++)
{var row=arr[i];if(row.ds_RowID==undefined)
row.ds_RowID=i;this.dataHash[row.ds_RowID]=row;this.data.push(row);}
this.loadData(fireSyncLoad);};Spry.Data.DataSet.prototype.loadData=function(syncLoad)
{var self=this;this.pendingRequest=new Object;this.dataWasLoaded=false;var loadCallbackFunc=function()
{self.pendingRequest=null;self.dataWasLoaded=true;self.applyColumnTypes();self.disableNotifications();self.filterAndSortData();self.enableNotifications();self.notifyObservers("onPostLoad");self.notifyObservers("onDataChanged");};if(syncLoad)
loadCallbackFunc();else
this.pendingRequest.timer=setTimeout(loadCallbackFunc,0);};Spry.Data.DataSet.prototype.filterAndSortData=function()
{if(this.filterDataFunc)
this.filterData(this.filterDataFunc,true);if(this.distinctOnLoad)
this.distinct(this.distinctFieldsOnLoad);if(this.keepSorted&&this.getSortColumn())
this.sort(this.lastSortColumns,this.lastSortOrder);else if(this.sortOnLoad)
this.sort(this.sortOnLoad,this.sortOrderOnLoad);if(this.filterFunc)
this.filter(this.filterFunc,true);if(this.data&&this.data.length>0)
this.curRowID=this.data[0]['ds_RowID'];else
this.curRowID=0;};Spry.Data.DataSet.prototype.cancelLoadData=function()
{if(this.pendingRequest&&this.pendingRequest.timer)
clearTimeout(this.pendingRequest.timer);this.pendingRequest=null;};Spry.Data.DataSet.prototype.getRowCount=function(unfiltered)
{var rows=this.getData(unfiltered);return rows?rows.length:0;};Spry.Data.DataSet.prototype.getRowByID=function(rowID)
{if(!this.data)
return null;return this.dataHash[rowID];};Spry.Data.DataSet.prototype.getRowByRowNumber=function(rowNumber,unfiltered)
{var rows=this.getData(unfiltered);if(rows&&rowNumber>=0&&rowNumber<rows.length)
return rows[rowNumber];return null;};Spry.Data.DataSet.prototype.getCurrentRow=function()
{return this.getRowByID(this.curRowID);};Spry.Data.DataSet.prototype.setCurrentRow=function(rowID)
{if(this.curRowID==rowID)
return;var nData={oldRowID:this.curRowID,newRowID:rowID};this.curRowID=rowID;this.notifyObservers("onCurrentRowChanged",nData);};Spry.Data.DataSet.prototype.getRowNumber=function(row,unfiltered)
{if(row)
{var rows=this.getData(unfiltered);if(rows&&rows.length)
{var numRows=rows.length;for(var i=0;i<numRows;i++)
{if(rows[i]==row)
return i;}}}
return-1;};Spry.Data.DataSet.prototype.getCurrentRowNumber=function()
{return this.getRowNumber(this.getCurrentRow());};Spry.Data.DataSet.prototype.getCurrentRowID=function()
{return this.curRowID;};Spry.Data.DataSet.prototype.setCurrentRowNumber=function(rowNumber)
{if(!this.data||rowNumber>=this.data.length)
{Spry.Debug.trace("Invalid row number: "+rowNumber+"\n");return;}
var rowID=this.data[rowNumber]["ds_RowID"];if(rowID==undefined||this.curRowID==rowID)
return;this.setCurrentRow(rowID);};Spry.Data.DataSet.prototype.findRowsWithColumnValues=function(valueObj,firstMatchOnly,unfiltered)
{var results=[];var rows=this.getData(unfiltered);if(rows)
{var numRows=rows.length;for(var i=0;i<numRows;i++)
{var row=rows[i];var matched=true;for(var colName in valueObj)
{if(valueObj[colName]!=row[colName])
{matched=false;break;}}
if(matched)
{if(firstMatchOnly)
return row;results.push(row);}}}
return firstMatchOnly?null:results;};Spry.Data.DataSet.prototype.setColumnType=function(columnNames,columnType)
{if(columnNames)
{if(typeof columnNames=="string")
columnNames=[columnNames];for(var i=0;i<columnNames.length;i++)
this.columnTypes[columnNames[i]]=columnType;}};Spry.Data.DataSet.prototype.getColumnType=function(columnName)
{if(this.columnTypes[columnName])
return this.columnTypes[columnName];return"string";};Spry.Data.DataSet.prototype.applyColumnTypes=function()
{var rows=this.getData(true);var numRows=rows.length;var colNames=[];if(numRows<1)
return;for(var cname in this.columnTypes)
{var ctype=this.columnTypes[cname];if(ctype!="string")
{for(var i=0;i<numRows;i++)
{var row=rows[i];var val=row[cname];if(val!=undefined)
{if(ctype=="number")
row[cname]=new Number(val);else if(ctype=="html")
row[cname]=Spry.Utils.decodeEntities(val);}}}}};Spry.Data.DataSet.prototype.distinct=function(columnNames)
{if(this.data)
{var oldData=this.data;this.data=[];this.dataHash={};var dataChanged=false;var alreadySeenHash={};var i=0;var keys=[];if(typeof columnNames=="string")
keys=[columnNames];else if(columnNames)
keys=columnNames;else
for(var recField in oldData[0])
keys[i++]=recField;for(var i=0;i<oldData.length;i++)
{var rec=oldData[i];var hashStr="";for(var j=0;j<keys.length;j++)
{recField=keys[j];if(recField!="ds_RowID")
{if(hashStr)
hashStr+=",";hashStr+=recField+":"+"\""+rec[recField]+"\"";}}
if(!alreadySeenHash[hashStr])
{this.data.push(rec);this.dataHash[rec['ds_RowID']]=rec;alreadySeenHash[hashStr]=true;}
else
dataChanged=true;}
if(dataChanged)
this.notifyObservers('onDataChanged');}};Spry.Data.DataSet.prototype.getSortColumn=function(){return(this.lastSortColumns&&this.lastSortColumns.length>0)?this.lastSortColumns[0]:"";};Spry.Data.DataSet.prototype.getSortOrder=function(){return this.lastSortOrder?this.lastSortOrder:"";};Spry.Data.DataSet.prototype.sort=function(columnNames,sortOrder)
{if(!columnNames)
return;if(typeof columnNames=="string")
columnNames=[columnNames,"ds_RowID"];else if(columnNames.length<2&&columnNames[0]!="ds_RowID")
columnNames.push("ds_RowID");if(!sortOrder)
sortOrder="toggle";if(sortOrder=="toggle")
{if(this.lastSortColumns.length>0&&this.lastSortColumns[0]==columnNames[0]&&this.lastSortOrder=="ascending")
sortOrder="descending";else
sortOrder="ascending";}
if(sortOrder!="ascending"&&sortOrder!="descending")
{Spry.Debug.reportError("Invalid sort order type specified: "+sortOrder+"\n");return;}
var nData={oldSortColumns:this.lastSortColumns,oldSortOrder:this.lastSortOrder,newSortColumns:columnNames,newSortOrder:sortOrder};this.notifyObservers("onPreSort",nData);var cname=columnNames[columnNames.length-1];var sortfunc=Spry.Data.DataSet.prototype.sort.getSortFunc(cname,this.getColumnType(cname),sortOrder);for(var i=columnNames.length-2;i>=0;i--)
{cname=columnNames[i];sortfunc=Spry.Data.DataSet.prototype.sort.buildSecondarySortFunc(Spry.Data.DataSet.prototype.sort.getSortFunc(cname,this.getColumnType(cname),sortOrder),sortfunc);}
if(this.unfilteredData)
{this.unfilteredData.sort(sortfunc);if(this.filterFunc)
this.filter(this.filterFunc,true);}
else
this.data.sort(sortfunc);this.lastSortColumns=columnNames.slice(0);this.lastSortOrder=sortOrder;this.notifyObservers("onPostSort",nData);};Spry.Data.DataSet.prototype.sort.getSortFunc=function(prop,type,order)
{var sortfunc=null;if(type=="number")
{if(order=="ascending")
sortfunc=function(a,b)
{a=a[prop];b=b[prop];if(a==undefined||b==undefined)
return(a==b)?0:(a?1:-1);return a-b;};else
sortfunc=function(a,b)
{a=a[prop];b=b[prop];if(a==undefined||b==undefined)
return(a==b)?0:(a?-1:1);return b-a;};}
else if(type=="date")
{if(order=="ascending")
sortfunc=function(a,b)
{var dA=a[prop];var dB=b[prop];dA=dA?(new Date(dA)):0;dB=dB?(new Date(dB)):0;return dA-dB;};else
sortfunc=function(a,b)
{var dA=a[prop];var dB=b[prop];dA=dA?(new Date(dA)):0;dB=dB?(new Date(dB)):0;return dB-dA;};}
else
{if(order=="ascending")
sortfunc=function(a,b){a=a[prop];b=b[prop];if(a==undefined||b==undefined)
return(a==b)?0:(a?1:-1);var tA=a.toString();var tB=b.toString();var tA_l=tA.toLowerCase();var tB_l=tB.toLowerCase();var min_len=tA.length>tB.length?tB.length:tA.length;for(var i=0;i<min_len;i++)
{var a_l_c=tA_l.charAt(i);var b_l_c=tB_l.charAt(i);var a_c=tA.charAt(i);var b_c=tB.charAt(i);if(a_l_c>b_l_c)
return 1;else if(a_l_c<b_l_c)
return-1;else if(a_c>b_c)
return 1;else if(a_c<b_c)
return-1;}
if(tA.length==tB.length)
return 0;else if(tA.length>tB.length)
return 1;return-1;};else
sortfunc=function(a,b){a=a[prop];b=b[prop];if(a==undefined||b==undefined)
return(a==b)?0:(a?-1:1);var tA=a.toString();var tB=b.toString();var tA_l=tA.toLowerCase();var tB_l=tB.toLowerCase();var min_len=tA.length>tB.length?tB.length:tA.length;for(var i=0;i<min_len;i++)
{var a_l_c=tA_l.charAt(i);var b_l_c=tB_l.charAt(i);var a_c=tA.charAt(i);var b_c=tB.charAt(i);if(a_l_c>b_l_c)
return-1;else if(a_l_c<b_l_c)
return 1;else if(a_c>b_c)
return-1;else if(a_c<b_c)
return 1;}
if(tA.length==tB.length)
return 0;else if(tA.length>tB.length)
return-1;return 1;};}
return sortfunc;};Spry.Data.DataSet.prototype.sort.buildSecondarySortFunc=function(funcA,funcB)
{return function(a,b)
{var ret=funcA(a,b);if(ret==0)
ret=funcB(a,b);return ret;};};Spry.Data.DataSet.prototype.filterData=function(filterFunc,filterOnly)
{var dataChanged=false;if(!filterFunc)
{this.filterDataFunc=null;dataChanged=true;}
else
{this.filterDataFunc=filterFunc;if(this.dataWasLoaded&&((this.unfilteredData&&this.unfilteredData.length)||(this.data&&this.data.length)))
{if(this.unfilteredData)
{this.data=this.unfilteredData;this.unfilteredData=null;}
var oldData=this.data;this.data=[];this.dataHash={};for(var i=0;i<oldData.length;i++)
{var newRow=filterFunc(this,oldData[i],i);if(newRow)
{this.data.push(newRow);this.dataHash[newRow["ds_RowID"]]=newRow;}}
dataChanged=true;}}
if(dataChanged)
{if(!filterOnly)
{this.disableNotifications();if(this.filterFunc)
this.filter(this.filterFunc,true);this.enableNotifications();}
this.notifyObservers("onDataChanged");}};Spry.Data.DataSet.prototype.filter=function(filterFunc,filterOnly)
{var dataChanged=false;if(!filterFunc)
{if(this.filterFunc&&this.unfilteredData)
{this.data=this.unfilteredData;this.unfilteredData=null;this.filterFunc=null;dataChanged=true;}}
else
{this.filterFunc=filterFunc;if(this.dataWasLoaded&&(this.unfilteredData||(this.data&&this.data.length)))
{if(!this.unfilteredData)
this.unfilteredData=this.data;var udata=this.unfilteredData;this.data=[];for(var i=0;i<udata.length;i++)
{var newRow=filterFunc(this,udata[i],i);if(newRow)
this.data.push(newRow);}
dataChanged=true;}}
if(dataChanged)
this.notifyObservers("onDataChanged");};Spry.Data.DataSet.prototype.startLoadInterval=function(interval)
{this.stopLoadInterval();if(interval>0)
{var self=this;this.loadInterval=interval;this.loadIntervalID=setInterval(function(){self.loadData();},interval);}};Spry.Data.DataSet.prototype.stopLoadInterval=function()
{if(this.loadIntervalID)
clearInterval(this.loadIntervalID);this.loadInterval=0;this.loadIntervalID=null;};Spry.Data.DataSet.nextDataSetID=0;Spry.Data.HTTPSourceDataSet=function(dataSetURL,dataSetOptions)
{Spry.Data.DataSet.call(this);this.url=dataSetURL;this.dataSetsForDataRefStrings=new Array;this.hasDataRefStrings=false;this.useCache=true;this.setRequestInfo(dataSetOptions,true);Spry.Utils.setOptions(this,dataSetOptions,true);this.recalculateDataSetDependencies();if(this.loadInterval>0)
this.startLoadInterval(this.loadInterval);};Spry.Data.HTTPSourceDataSet.prototype=new Spry.Data.DataSet();Spry.Data.HTTPSourceDataSet.prototype.constructor=Spry.Data.HTTPSourceDataSet;Spry.Data.HTTPSourceDataSet.prototype.setRequestInfo=function(requestInfo,undefineRequestProps)
{this.requestInfo=new Spry.Utils.loadURL.Request();this.requestInfo.extractRequestOptions(requestInfo,undefineRequestProps);if(this.requestInfo.method=="POST")
{if(!this.requestInfo.headers)
this.requestInfo.headers={};if(!this.requestInfo.headers['Content-Type'])
this.requestInfo.headers['Content-Type']="application/x-www-form-urlencoded; charset=UTF-8";}};Spry.Data.HTTPSourceDataSet.prototype.recalculateDataSetDependencies=function()
{this.hasDataRefStrings=false;var i=0;for(i=0;i<this.dataSetsForDataRefStrings.length;i++)
{var ds=this.dataSetsForDataRefStrings[i];if(ds)
ds.removeObserver(this);}
this.dataSetsForDataRefStrings=new Array();var regionStrs=this.getDataRefStrings();var dsCount=0;for(var n=0;n<regionStrs.length;n++)
{var tokens=Spry.Data.Region.getTokensFromStr(regionStrs[n]);for(i=0;tokens&&i<tokens.length;i++)
{if(tokens[i].search(/{[^}:]+::[^}]+}/)!=-1)
{var dsName=tokens[i].replace(/^\{|::.*\}/g,"");var ds=null;if(!this.dataSetsForDataRefStrings[dsName])
{ds=Spry.Data.getDataSetByName(dsName);if(dsName&&ds)
{this.dataSetsForDataRefStrings[dsName]=ds;this.dataSetsForDataRefStrings[dsCount++]=ds;this.hasDataRefStrings=true;}}}}}
for(i=0;i<this.dataSetsForDataRefStrings.length;i++)
{var ds=this.dataSetsForDataRefStrings[i];ds.addObserver(this);}};Spry.Data.HTTPSourceDataSet.prototype.getDataRefStrings=function()
{var strArr=[];if(this.url)strArr.push(this.url);if(this.requestInfo&&this.requestInfo.postData)strArr.push(this.requestInfo.postData);return strArr;};Spry.Data.HTTPSourceDataSet.prototype.attemptLoadData=function()
{for(var i=0;i<this.dataSetsForDataRefStrings.length;i++)
{var ds=this.dataSetsForDataRefStrings[i];if(ds.getLoadDataRequestIsPending()||!ds.getDataWasLoaded())
return;}
this.loadData();};Spry.Data.HTTPSourceDataSet.prototype.onCurrentRowChanged=function(ds,data)
{this.attemptLoadData();};Spry.Data.HTTPSourceDataSet.prototype.onPostSort=function(ds,data)
{this.attemptLoadData();};Spry.Data.HTTPSourceDataSet.prototype.onDataChanged=function(ds,data)
{this.attemptLoadData();};Spry.Data.HTTPSourceDataSet.prototype.loadData=function()
{if(!this.url)
return;this.cancelLoadData();var url=this.url;var postData=this.requestInfo.postData;if(this.hasDataRefStrings)
{var allDataSetsReady=true;for(var i=0;i<this.dataSetsForDataRefStrings.length;i++)
{var ds=this.dataSetsForDataRefStrings[i];if(ds.getLoadDataRequestIsPending())
allDataSetsReady=false;else if(!ds.getDataWasLoaded())
{ds.loadData();allDataSetsReady=false;}}
if(!allDataSetsReady)
return;url=Spry.Data.Region.processDataRefString(null,this.url,this.dataSetsForDataRefStrings);if(!url)
return;if(postData&&(typeof postData)=="string")
postData=Spry.Data.Region.processDataRefString(null,postData,this.dataSetsForDataRefStrings);}
this.notifyObservers("onPreLoad");this.data=null;this.dataWasLoaded=false;this.unfilteredData=null;this.dataHash=null;this.curRowID=0;var req=this.requestInfo.clone();req.url=url;req.postData=postData;this.pendingRequest=new Object;this.pendingRequest.data=Spry.Data.HTTPSourceDataSet.LoadManager.loadData(req,this,this.useCache);};Spry.Data.HTTPSourceDataSet.prototype.cancelLoadData=function()
{if(this.pendingRequest)
{Spry.Data.HTTPSourceDataSet.LoadManager.cancelLoadData(this.pendingRequest.data,this);this.pendingRequest=null;}};Spry.Data.HTTPSourceDataSet.prototype.getURL=function(){return this.url;};Spry.Data.HTTPSourceDataSet.prototype.setURL=function(url,requestOptions)
{if(this.url==url)
{if(!requestOptions||(this.requestInfo.method==requestOptions.method&&(requestOptions.method!="POST"||this.requestInfo.postData==requestOptions.postData)))
return;}
this.url=url;this.setRequestInfo(requestOptions);this.cancelLoadData();this.recalculateDataSetDependencies();this.dataWasLoaded=false;};Spry.Data.HTTPSourceDataSet.prototype.setDataFromDoc=function(rawDataDoc)
{this.pendingRequest=null;this.loadDataIntoDataSet(rawDataDoc);this.applyColumnTypes();this.disableNotifications();this.filterAndSortData();this.enableNotifications();this.notifyObservers("onPostLoad");this.notifyObservers("onDataChanged");};Spry.Data.HTTPSourceDataSet.prototype.loadDataIntoDataSet=function(rawDataDoc)
{this.dataHash=new Object;this.data=new Array;this.dataWasLoaded=true;};Spry.Data.HTTPSourceDataSet.prototype.xhRequestProcessor=function(xhRequest)
{var resp=xhRequest.responseText;if(xhRequest.status==200||xhRequest.status==0)
return resp;return null;};Spry.Data.HTTPSourceDataSet.prototype.sessionExpiredChecker=function(req)
{if(req.xhRequest.responseText=='session expired')
return true;return false;};Spry.Data.HTTPSourceDataSet.prototype.setSessionExpiredChecker=function(checker)
{this.sessionExpiredChecker=checker;};Spry.Data.HTTPSourceDataSet.prototype.onRequestResponse=function(cachedRequest,req)
{this.setDataFromDoc(cachedRequest.rawData);};Spry.Data.HTTPSourceDataSet.prototype.onRequestError=function(cachedRequest,req)
{this.notifyObservers("onLoadError",req);};Spry.Data.HTTPSourceDataSet.prototype.onRequestSessionExpired=function(cachedRequest,req)
{this.notifyObservers("onSessionExpired",req);};Spry.Data.HTTPSourceDataSet.LoadManager={};Spry.Data.HTTPSourceDataSet.LoadManager.cache=[];Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest=function(reqInfo,xhRequestProcessor,sessionExpiredChecker)
{Spry.Utils.Notifier.call(this);this.reqInfo=reqInfo;this.rawData=null;this.timer=null;this.state=Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.NOT_LOADED;this.xhRequestProcessor=xhRequestProcessor;this.sessionExpiredChecker=sessionExpiredChecker;};Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.prototype=new Spry.Utils.Notifier();Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.prototype.constructor=Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest;Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.NOT_LOADED=1;Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.LOAD_REQUESTED=2;Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.LOAD_FAILED=3;Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.LOAD_SUCCESSFUL=4;Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.prototype.loadDataCallback=function(req)
{if(req.xhRequest.readyState!=4)
return;var rawData=null;if(this.xhRequestProcessor)rawData=this.xhRequestProcessor(req.xhRequest);if(this.sessionExpiredChecker)
{Spry.Utils.setOptions(req,{'rawData':rawData},false);if(this.sessionExpiredChecker(req))
{this.state=Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.LOAD_FAILED;this.notifyObservers("onRequestSessionExpired",req);this.observers.length=0;return;}}
if(!rawData)
{this.state=Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.LOAD_FAILED;this.notifyObservers("onRequestError",req);this.observers.length=0;return;}
this.rawData=rawData;this.state=Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.LOAD_SUCCESSFUL;this.notifyObservers("onRequestResponse",req);this.observers.length=0;};Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.prototype.loadData=function()
{var self=this;this.cancelLoadData();this.rawData=null;this.state=Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.LOAD_REQUESTED;var reqInfo=this.reqInfo.clone();reqInfo.successCallback=function(req){self.loadDataCallback(req);};reqInfo.errorCallback=reqInfo.successCallback;this.timer=setTimeout(function()
{self.timer=null;Spry.Utils.loadURL(reqInfo.method,reqInfo.url,reqInfo.async,reqInfo.successCallback,reqInfo);},0);};Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.prototype.cancelLoadData=function()
{if(this.state==Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.LOAD_REQUESTED)
{if(this.timer)
{this.timer.clearTimeout();this.timer=null;}
this.rawData=null;this.state=Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.NOT_LOADED;}};Spry.Data.HTTPSourceDataSet.LoadManager.getCacheKey=function(reqInfo)
{return reqInfo.method+"::"+reqInfo.url+"::"+reqInfo.postData+"::"+reqInfo.username;};Spry.Data.HTTPSourceDataSet.LoadManager.loadData=function(reqInfo,ds,useCache)
{if(!reqInfo)
return null;var cacheObj=null;var cacheKey=null;if(useCache)
{cacheKey=Spry.Data.HTTPSourceDataSet.LoadManager.getCacheKey(reqInfo);cacheObj=Spry.Data.HTTPSourceDataSet.LoadManager.cache[cacheKey];}
if(cacheObj)
{if(cacheObj.state==Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.LOAD_REQUESTED)
{if(ds)
cacheObj.addObserver(ds);return cacheObj;}
else if(cacheObj.state==Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest.LOAD_SUCCESSFUL)
{if(ds)
setTimeout(function(){ds.setDataFromDoc(cacheObj.rawData);},0);return cacheObj;}}
if(!cacheObj)
{cacheObj=new Spry.Data.HTTPSourceDataSet.LoadManager.CachedRequest(reqInfo,(ds?ds.xhRequestProcessor:null),(ds?ds.sessionExpiredChecker:null));if(useCache)
{Spry.Data.HTTPSourceDataSet.LoadManager.cache[cacheKey]=cacheObj;cacheObj.addObserver({onRequestError:function(){Spry.Data.HTTPSourceDataSet.LoadManager.cache[cacheKey]=undefined;}});}}
if(ds)
cacheObj.addObserver(ds);cacheObj.loadData();return cacheObj;};Spry.Data.HTTPSourceDataSet.LoadManager.cancelLoadData=function(cacheObj,ds)
{if(cacheObj)
{if(ds)
cacheObj.removeObserver(ds);else
cacheObj.cancelLoadData();}};Spry.Data.XMLDataSet=function(dataSetURL,dataSetPath,dataSetOptions)
{this.xpath=dataSetPath;this.doc=null;this.subPaths=[];this.entityEncodeStrings=true;Spry.Data.HTTPSourceDataSet.call(this,dataSetURL,dataSetOptions);var jwType=typeof this.subPaths;if(jwType=="string"||(jwType=="object"&&this.subPaths.constructor!=Array))
this.subPaths=[this.subPaths];};Spry.Data.XMLDataSet.prototype=new Spry.Data.HTTPSourceDataSet();Spry.Data.XMLDataSet.prototype.constructor=Spry.Data.XMLDataSet;Spry.Data.XMLDataSet.prototype.getDataRefStrings=function()
{var strArr=[];if(this.url)strArr.push(this.url);if(this.xpath)strArr.push(this.xpath);if(this.requestInfo&&this.requestInfo.postData)strArr.push(this.requestInfo.postData);return strArr;};Spry.Data.XMLDataSet.prototype.getDocument=function(){return this.doc;};Spry.Data.XMLDataSet.prototype.getXPath=function(){return this.xpath;};Spry.Data.XMLDataSet.prototype.setXPath=function(path)
{if(this.xpath!=path)
{this.xpath=path;if(this.dataWasLoaded&&this.doc)
{this.notifyObservers("onPreLoad");this.setDataFromDoc(this.doc);}}};Spry.Data.XMLDataSet.nodeContainsElementNode=function(node)
{if(node)
{node=node.firstChild;while(node)
{if(node.nodeType==1)
return true;node=node.nextSibling;}}
return false;};Spry.Data.XMLDataSet.getNodeText=function(node,encodeText,encodeCData)
{var txt="";if(!node)
return;try
{var child=node.firstChild;while(child)
{try
{if(child.nodeType==3)
txt+=encodeText?Spry.Utils.encodeEntities(child.data):child.data;else if(child.nodeType==4)
txt+=encodeCData?Spry.Utils.encodeEntities(child.data):child.data;}catch(e){Spry.Debug.reportError("Spry.Data.XMLDataSet.getNodeText() exception caught: "+e+"\n");}
child=child.nextSibling;}}
catch(e){Spry.Debug.reportError("Spry.Data.XMLDataSet.getNodeText() exception caught: "+e+"\n");}
return txt;};Spry.Data.XMLDataSet.createObjectForNode=function(node,encodeText,encodeCData)
{if(!node)
return null;var obj=new Object();var i=0;var attr=null;try
{for(i=0;i<node.attributes.length;i++)
{attr=node.attributes[i];if(attr&&attr.nodeType==2)
obj["@"+attr.name]=attr.value;}}
catch(e)
{Spry.Debug.reportError("Spry.Data.XMLDataSet.createObjectForNode() caught exception while accessing attributes: "+e+"\n");}
var child=node.firstChild;if(child&&!child.nextSibling&&child.nodeType!=1)
{obj[node.nodeName]=Spry.Data.XMLDataSet.getNodeText(node,encodeText,encodeCData);}
while(child)
{if(child.nodeType==1)
{if(!Spry.Data.XMLDataSet.nodeContainsElementNode(child))
{obj[child.nodeName]=Spry.Data.XMLDataSet.getNodeText(child,encodeText,encodeCData);try
{var namePrefix=child.nodeName+"/@";for(i=0;i<child.attributes.length;i++)
{attr=child.attributes[i];if(attr&&attr.nodeType==2)
obj[namePrefix+attr.name]=attr.value;}}
catch(e)
{Spry.Debug.reportError("Spry.Data.XMLDataSet.createObjectForNode() caught exception while accessing attributes: "+e+"\n");}}}
child=child.nextSibling;}
return obj;};Spry.Data.XMLDataSet.getRecordSetFromXMLDoc=function(xmlDoc,path,suppressColumns,entityEncodeStrings)
{if(!xmlDoc||!path)
return null;var recordSet=new Object();recordSet.xmlDoc=xmlDoc;recordSet.xmlPath=path;recordSet.dataHash=new Object;recordSet.data=new Array;recordSet.getData=function(){return this.data;};var ctx=new ExprContext(xmlDoc);var pathExpr=xpathParse(path);var e=pathExpr.evaluate(ctx);var nodeArray=e.nodeSetValue();var isDOMNodeArray=true;if(nodeArray&&nodeArray.length>0)
isDOMNodeArray=nodeArray[0].nodeType!=2;var nextID=0;var encodeText=true;var encodeCData=false;if(typeof entityEncodeStrings=="boolean")
encodeText=encodeCData=entityEncodeStrings;for(var i=0;i<nodeArray.length;i++)
{var rowObj=null;if(suppressColumns)
rowObj=new Object;else
{if(isDOMNodeArray)
rowObj=Spry.Data.XMLDataSet.createObjectForNode(nodeArray[i],encodeText,encodeCData);else
{rowObj=new Object;rowObj["@"+nodeArray[i].name]=nodeArray[i].value;}}
if(rowObj)
{rowObj['ds_RowID']=nextID++;rowObj['ds_XMLNode']=nodeArray[i];recordSet.dataHash[rowObj['ds_RowID']]=rowObj;recordSet.data.push(rowObj);}}
return recordSet;};Spry.Data.XMLDataSet.PathNode=function(path)
{this.path=path;this.subPaths=[];this.xpath="";};Spry.Data.XMLDataSet.PathNode.prototype.addSubPath=function(path)
{var node=this.findSubPath(path);if(!node)
{node=new Spry.Data.XMLDataSet.PathNode(path);this.subPaths.push(node);}
return node;};Spry.Data.XMLDataSet.PathNode.prototype.findSubPath=function(path)
{var numSubPaths=this.subPaths.length;for(var i=0;i<numSubPaths;i++)
{var subPath=this.subPaths[i];if(path==subPath.path)
return subPath;}
return null;};Spry.Data.XMLDataSet.PathNode.prototype.consolidate=function()
{var numSubPaths=this.subPaths.length;if(!this.xpath&&numSubPaths==1)
{var subPath=this.subPaths[0];this.path+=((subPath[0]!="/")?"/":"")+subPath.path;this.xpath=subPath.xpath;this.subPaths=subPath.subPaths;this.consolidate();return;}
for(var i=0;i<numSubPaths;i++)
this.subPaths[i].consolidate();};Spry.Data.XMLDataSet.prototype.convertXPathsToPathTree=function(xpathArray)
{var xpaLen=xpathArray.length;var root=new Spry.Data.XMLDataSet.PathNode("");for(var i=0;i<xpaLen;i++)
{var xpath=xpathArray[i];var cleanXPath=xpath.replace(/\/\//g,"/__SPRYDS__");cleanXPath=cleanXPath.replace(/^\//,"");var pathItems=cleanXPath.split(/\//);var pathItemsLen=pathItems.length;var node=root;for(var j=0;j<pathItemsLen;j++)
{var path=pathItems[j].replace(/__SPRYDS__/,"//");node=node.addSubPath(path);}
node.xpath=xpath;}
root.consolidate();return root;};Spry.Data.XMLDataSet.prototype.flattenSubPaths=function(rs,subPaths)
{if(!rs||!subPaths)
return;var numSubPaths=subPaths.length;if(numSubPaths<1)
return;var data=rs.data;var dataHash={};var xpathArray=[];var cleanedXPathArray=[];for(var i=0;i<numSubPaths;i++)
{var subPath=subPaths[i];if(typeof subPath=="object")
subPath=subPath.path;if(!subPath)
subPath="";xpathArray[i]=Spry.Data.Region.processDataRefString(null,subPath,this.dataSetsForDataRefStrings);cleanedXPathArray[i]=xpathArray[i].replace(/\[.*\]/g,"");}
var row;var numRows=data.length;var newData=[];for(var i=0;i<numRows;i++)
{row=data[i];var newRows=[row];for(var j=0;j<numSubPaths;j++)
{var newRS=Spry.Data.XMLDataSet.getRecordSetFromXMLDoc(row.ds_XMLNode,xpathArray[j],(subPaths[j].xpath?false:true),this.entityEncodeStrings);if(newRS&&newRS.data&&newRS.data.length)
{if(typeof subPaths[j]=="object"&&subPaths[j].subPaths)
{var sp=subPaths[j].subPaths;spType=typeof sp;if(spType=="string")
sp=[sp];else if(spType=="object"&&spType.constructor==Object)
sp=[sp];this.flattenSubPaths(newRS,sp);}
var newRSData=newRS.data;var numRSRows=newRSData.length;var cleanedXPath=cleanedXPathArray[j]+"/";var numNewRows=newRows.length;var joinedRows=[];for(var k=0;k<numNewRows;k++)
{var newRow=newRows[k];for(var l=0;l<numRSRows;l++)
{var newRowObj=new Object;var newRSRow=newRSData[l];for(prop in newRow)
newRowObj[prop]=newRow[prop];for(var prop in newRSRow)
{var newPropName=cleanedXPath+prop;if(cleanedXPath==(prop+"/")||cleanedXPath.search(new RegExp("\\/"+prop+"\\/$"))!=-1)
newPropName=cleanedXPathArray[j];newRowObj[newPropName]=newRSRow[prop];}
joinedRows.push(newRowObj);}}
newRows=joinedRows;}}
newData=newData.concat(newRows);}
data=newData;numRows=data.length;for(i=0;i<numRows;i++)
{row=data[i];row.ds_RowID=i;dataHash[row.ds_RowID]=row;}
rs.data=data;rs.dataHash=dataHash;};Spry.Data.XMLDataSet.prototype.loadDataIntoDataSet=function(rawDataDoc)
{var rs=null;var mainXPath=Spry.Data.Region.processDataRefString(null,this.xpath,this.dataSetsForDataRefStrings);var subPaths=this.subPaths;var suppressColumns=false;if(this.subPaths&&this.subPaths.length>0)
{var processedSubPaths=[];var numSubPaths=subPaths.length;for(var i=0;i<numSubPaths;i++)
{var subPathStr=Spry.Data.Region.processDataRefString(null,subPaths[i],this.dataSetsForDataRefStrings);if(subPathStr.charAt(0)!='/')
subPathStr=mainXPath+"/"+subPathStr;processedSubPaths.push(subPathStr);}
processedSubPaths.unshift(mainXPath);var commonParent=this.convertXPathsToPathTree(processedSubPaths);mainXPath=commonParent.path;subPaths=commonParent.subPaths;suppressColumns=commonParent.xpath?false:true;}
rs=Spry.Data.XMLDataSet.getRecordSetFromXMLDoc(rawDataDoc,mainXPath,suppressColumns,this.entityEncodeStrings);if(!rs)
{Spry.Debug.reportError("Spry.Data.XMLDataSet.loadDataIntoDataSet() failed to create dataSet '"+this.name+"'for '"+this.xpath+"' - "+this.url+"\n");return;}
this.flattenSubPaths(rs,subPaths);this.doc=rs.xmlDoc;this.data=rs.data;this.dataHash=rs.dataHash;this.dataWasLoaded=(this.doc!=null);};Spry.Data.XMLDataSet.prototype.xhRequestProcessor=function(xhRequest)
{var resp=xhRequest.responseXML;var manualParseRequired=false;if(xhRequest.status!=200)
{if(xhRequest.status==0)
{if(xhRequest.responseText&&(!resp||!resp.firstChild))
manualParseRequired=true;}}
else if(!resp)
{manualParseRequired=true;}
if(manualParseRequired)
resp=Spry.Utils.stringToXMLDoc(xhRequest.responseText);if(!resp||!resp.firstChild||resp.firstChild.nodeName=="parsererror")
return null;return resp;};Spry.Data.XMLDataSet.prototype.sessionExpiredChecker=function(req)
{if(req.xhRequest.responseText=='session expired')
return true;else
{if(req.rawData)
{var firstChild=req.rawData.documentElement.firstChild;if(firstChild&&firstChild.nodeValue=="session expired")
return true;}}
return false;};Spry.Data.Region=function(regionNode,name,isDetailRegion,data,dataSets,regionStates,regionStateMap,hasBehaviorAttributes)
{this.regionNode=regionNode;this.name=name;this.isDetailRegion=isDetailRegion;this.data=data;this.dataSets=dataSets;this.hasBehaviorAttributes=hasBehaviorAttributes;this.tokens=null;this.currentState=null;this.states={ready:true};this.stateMap={};Spry.Utils.setOptions(this.states,regionStates);Spry.Utils.setOptions(this.stateMap,regionStateMap);for(var i=0;i<this.dataSets.length;i++)
{var ds=this.dataSets[i];try
{if(ds)
ds.addObserver(this);}
catch(e){Spry.Debug.reportError("Failed to add '"+this.name+"' as a dataSet observer!\n");}}};Spry.Data.Region.hiddenRegionClassName="SpryHiddenRegion";Spry.Data.Region.evenRowClassName="even";Spry.Data.Region.oddRowClassName="odd";Spry.Data.Region.notifiers={};Spry.Data.Region.evalScripts=true;Spry.Data.Region.addObserver=function(regionID,observer)
{var n=Spry.Data.Region.notifiers[regionID];if(!n)
{n=new Spry.Utils.Notifier();Spry.Data.Region.notifiers[regionID]=n;}
n.addObserver(observer);};Spry.Data.Region.removeObserver=function(regionID,observer)
{var n=Spry.Data.Region.notifiers[regionID];if(n)
n.removeObserver(observer);};Spry.Data.Region.notifyObservers=function(methodName,region,data)
{var n=Spry.Data.Region.notifiers[region.name];if(n)
{var dataObj={};if(data&&typeof data=="object")
dataObj=data;else
dataObj.data=data;dataObj.region=region;dataObj.regionID=region.name;dataObj.regionNode=region.regionNode;n.notifyObservers(methodName,dataObj);}};Spry.Data.Region.RS_Error=0x01;Spry.Data.Region.RS_LoadingData=0x02;Spry.Data.Region.RS_PreUpdate=0x04;Spry.Data.Region.RS_PostUpdate=0x08;Spry.Data.Region.prototype.getState=function()
{return this.currentState;};Spry.Data.Region.prototype.mapState=function(stateName,newStateName)
{this.stateMap[stateName]=newStateName;};Spry.Data.Region.prototype.getMappedState=function(stateName)
{var mappedState=this.stateMap[stateName];return mappedState?mappedState:stateName;};Spry.Data.Region.prototype.setState=function(stateName,suppressNotfications)
{var stateObj={state:stateName,mappedState:this.getMappedState(stateName)};if(!suppressNotfications)
Spry.Data.Region.notifyObservers("onPreStateChange",this,stateObj);this.currentState=stateObj.mappedState?stateObj.mappedState:stateName;if(this.states[stateName])
{var notificationData={state:this.currentState};if(!suppressNotfications)
Spry.Data.Region.notifyObservers("onPreUpdate",this,notificationData);var str=this.transform();if(Spry.Data.Region.debug)
Spry.Debug.trace("<hr />Generated region markup for '"+this.name+"':<br /><br />"+Spry.Utils.encodeEntities(str));Spry.Utils.setInnerHTML(this.regionNode,str,!Spry.Data.Region.evalScripts);if(this.hasBehaviorAttributes)
this.attachBehaviors();if(!suppressNotfications)
Spry.Data.Region.notifyObservers("onPostUpdate",this,notificationData);}
if(!suppressNotfications)
Spry.Data.Region.notifyObservers("onPostStateChange",this,stateObj);};Spry.Data.Region.prototype.getDataSets=function()
{return this.dataSets;};Spry.Data.Region.prototype.addDataSet=function(aDataSet)
{if(!aDataSet)
return;if(!this.dataSets)
this.dataSets=new Array;for(var i=0;i<this.dataSets.length;i++)
{if(this.dataSets[i]==aDataSet)
return;}
this.dataSets.push(aDataSet);aDataSet.addObserver(this);};Spry.Data.Region.prototype.removeDataSet=function(aDataSet)
{if(!aDataSet||this.dataSets)
return;for(var i=0;i<this.dataSets.length;i++)
{if(this.dataSets[i]==aDataSet)
{this.dataSets.splice(i,1);aDataSet.removeObserver(this);return;}}};Spry.Data.Region.prototype.onPreLoad=function(dataSet)
{if(this.currentState!="loading")
this.setState("loading");};Spry.Data.Region.prototype.onLoadError=function(dataSet)
{if(this.currentState!="error")
this.setState("error");Spry.Data.Region.notifyObservers("onError",this);};Spry.Data.Region.prototype.onSessionExpired=function(dataSet)
{if(this.currentState!="expired")
this.setState("expired");Spry.Data.Region.notifyObservers("onExpired",this);};Spry.Data.Region.prototype.onCurrentRowChanged=function(dataSet,data)
{if(this.isDetailRegion)
this.updateContent();};Spry.Data.Region.prototype.onPostSort=function(dataSet,data)
{this.updateContent();};Spry.Data.Region.prototype.onDataChanged=function(dataSet,data)
{this.updateContent();};Spry.Data.Region.enableBehaviorAttributes=true;Spry.Data.Region.behaviorAttrs={};Spry.Data.Region.behaviorAttrs["spry:select"]={attach:function(rgn,node,value)
{var selectGroupName=null;try{selectGroupName=node.attributes.getNamedItem("spry:selectgroup").value;}catch(e){}
if(!selectGroupName)
selectGroupName="default";Spry.Utils.addEventListener(node,"click",function(event){Spry.Utils.SelectionManager.select(selectGroupName,node,value);},false);if(node.attributes.getNamedItem("spry:selected"))
Spry.Utils.SelectionManager.select(selectGroupName,node,value);}};Spry.Data.Region.behaviorAttrs["spry:hover"]={attach:function(rgn,node,value)
{Spry.Utils.addEventListener(node,"mouseover",function(event){Spry.Utils.addClassName(node,value);},false);Spry.Utils.addEventListener(node,"mouseout",function(event){Spry.Utils.removeClassName(node,value);},false);}};Spry.Data.Region.setUpRowNumberForEvenOddAttr=function(node,attr,value,rowNumAttrName)
{if(!value)
{Spry.Debug.showError("The "+attr+" attribute requires a CSS class name as its value!");node.attributes.removeNamedItem(attr);return;}
var dsName="";var valArr=value.split(/\s/);if(valArr.length>1)
{dsName=valArr[0];node.setAttribute(attr,valArr[1]);}
node.setAttribute(rowNumAttrName,"{"+(dsName?(dsName+"::"):"")+"ds_RowNumber}");};Spry.Data.Region.behaviorAttrs["spry:even"]={setup:function(node,value)
{Spry.Data.Region.setUpRowNumberForEvenOddAttr(node,"spry:even",value,"spryevenrownumber");},attach:function(rgn,node,value)
{if(value)
{rowNumAttr=node.attributes.getNamedItem("spryevenrownumber");if(rowNumAttr&&rowNumAttr.value)
{var rowNum=parseInt(rowNumAttr.value);if(rowNum%2)
Spry.Utils.addClassName(node,value);}}
node.removeAttribute("spry:even");node.removeAttribute("spryevenrownumber");}};Spry.Data.Region.behaviorAttrs["spry:odd"]={setup:function(node,value)
{Spry.Data.Region.setUpRowNumberForEvenOddAttr(node,"spry:odd",value,"spryoddrownumber");},attach:function(rgn,node,value)
{if(value)
{rowNumAttr=node.attributes.getNamedItem("spryoddrownumber");if(rowNumAttr&&rowNumAttr.value)
{var rowNum=parseInt(rowNumAttr.value);if(rowNum%2==0)
Spry.Utils.addClassName(node,value);}}
node.removeAttribute("spry:odd");node.removeAttribute("spryoddrownumber");}};Spry.Data.Region.setRowAttrClickHandler=function(node,dsName,rowAttr,funcName)
{if(dsName)
{var ds=Spry.Data.getDataSetByName(dsName);if(ds)
{rowIDAttr=node.attributes.getNamedItem(rowAttr);if(rowIDAttr)
{var rowAttrVal=rowIDAttr.value;if(rowAttrVal)
Spry.Utils.addEventListener(node,"click",function(event){ds[funcName](rowAttrVal);},false);}}}};Spry.Data.Region.behaviorAttrs["spry:setrow"]={setup:function(node,value)
{if(!value)
{Spry.Debug.reportError("The spry:setrow attribute requires a data set name as its value!");node.removeAttribute("spry:setrow");return;}
node.setAttribute("spryrowid","{"+value+"::ds_RowID}");},attach:function(rgn,node,value)
{Spry.Data.Region.setRowAttrClickHandler(node,value,"spryrowid","setCurrentRow");node.removeAttribute("spry:setrow");node.removeAttribute("spryrowid");}};Spry.Data.Region.behaviorAttrs["spry:setrownumber"]={setup:function(node,value)
{if(!value)
{Spry.Debug.reportError("The spry:setrownumber attribute requires a data set name as its value!");node.removeAttribute("spry:setrownumber");return;}
node.setAttribute("spryrownumber","{"+value+"::ds_RowID}");},attach:function(rgn,node,value)
{Spry.Data.Region.setRowAttrClickHandler(node,value,"spryrownumber","setCurrentRowNumber");node.removeAttribute("spry:setrownumber");node.removeAttribute("spryrownumber");}};Spry.Data.Region.behaviorAttrs["spry:sort"]={attach:function(rgn,node,value)
{if(!value)
return;var ds=rgn.getDataSets()[0];var sortOrder="toggle";var colArray=value.split(/\s/);if(colArray.length>1)
{var specifiedDS=Spry.Data.getDataSetByName(colArray[0]);if(specifiedDS)
{ds=specifiedDS;colArray.shift();}
if(colArray.length>1)
{var str=colArray[colArray.length-1];if(str=="ascending"||str=="descending"||str=="toggle")
{sortOrder=str;colArray.pop();}}}
if(ds&&colArray.length>0)
Spry.Utils.addEventListener(node,"click",function(event){ds.sort(colArray,sortOrder);},false);node.removeAttribute("spry:sort");}};Spry.Data.Region.prototype.attachBehaviors=function()
{var rgn=this;Spry.Utils.getNodesByFunc(this.regionNode,function(node)
{if(!node||node.nodeType!=1)
return false;try
{var bAttrs=Spry.Data.Region.behaviorAttrs;for(var bAttrName in bAttrs)
{var attr=node.attributes.getNamedItem(bAttrName);if(attr)
{var behavior=bAttrs[bAttrName];if(behavior&&behavior.attach)
behavior.attach(rgn,node,attr.value);}}}catch(e){}
return false;});};Spry.Data.Region.prototype.updateContent=function()
{var allDataSetsReady=true;var dsArray=this.getDataSets();if(!dsArray||dsArray.length<1)
{Spry.Debug.reportError("updateContent(): Region '"+this.name+"' has no data set!\n");return;}
for(var i=0;i<dsArray.length;i++)
{var ds=dsArray[i];if(ds)
{if(ds.getLoadDataRequestIsPending())
allDataSetsReady=false;else if(!ds.getDataWasLoaded())
{ds.loadData();allDataSetsReady=false;}}}
if(!allDataSetsReady)
{Spry.Data.Region.notifyObservers("onLoadingData",this);return;}
this.setState("ready");};Spry.Data.Region.prototype.clearContent=function()
{this.regionNode.innerHTML="";};Spry.Data.Region.processContentPI=function(inStr)
{var outStr="";var regexp=/<!--\s*<\/?spry:content\s*[^>]*>\s*-->/mg;var searchStartIndex=0;var processingContentTag=0;while(inStr.length)
{var results=regexp.exec(inStr);if(!results||!results[0])
{outStr+=inStr.substr(searchStartIndex,inStr.length-searchStartIndex);break;}
if(!processingContentTag&&results.index!=searchStartIndex)
{outStr+=inStr.substr(searchStartIndex,results.index-searchStartIndex);}
if(results[0].search(/<\//)!=-1)
{--processingContentTag;if(processingContentTag)
Spry.Debug.reportError("Nested spry:content regions are not allowed!\n");}
else
{++processingContentTag;var dataRefStr=results[0].replace(/.*\bdataref="/,"");outStr+=dataRefStr.replace(/".*$/,"");}
searchStartIndex=regexp.lastIndex;}
return outStr;};Spry.Data.Region.prototype.tokenizeData=function(dataStr)
{if(!dataStr)
return null;var rootToken=new Spry.Data.Region.Token(Spry.Data.Region.Token.LIST_TOKEN,null,null,null);var tokenStack=new Array;var parseStr=Spry.Data.Region.processContentPI(dataStr);tokenStack.push(rootToken);var regexp=/((<!--\s*){0,1}<\/{0,1}spry:[^>]+>(\s*-->){0,1})|((\{|%7[bB])[^\}\s%]+(\}|%7[dD]))/mg;var searchStartIndex=0;while(parseStr.length)
{var results=regexp.exec(parseStr);var token=null;if(!results||!results[0])
{var str=parseStr.substr(searchStartIndex,parseStr.length-searchStartIndex);token=new Spry.Data.Region.Token(Spry.Data.Region.Token.STRING_TOKEN,null,str,str);tokenStack[tokenStack.length-1].addChild(token);break;}
if(results.index!=searchStartIndex)
{var str=parseStr.substr(searchStartIndex,results.index-searchStartIndex);token=new Spry.Data.Region.Token(Spry.Data.Region.Token.STRING_TOKEN,null,str,str);tokenStack[tokenStack.length-1].addChild(token);}
if(results[0].search(/^({|%7[bB])/)!=-1)
{var valueName=results[0];var regionStr=results[0];valueName=valueName.replace(/^({|%7[bB])/,"");valueName=valueName.replace(/(}|%7[dD])$/,"");var dataSetName=null;var splitArray=valueName.split(/::/);if(splitArray.length>1)
{dataSetName=splitArray[0];valueName=splitArray[1];}
regionStr=regionStr.replace(/^%7[bB]/,"{");regionStr=regionStr.replace(/%7[dD]$/,"}");token=new Spry.Data.Region.Token(Spry.Data.Region.Token.VALUE_TOKEN,dataSetName,valueName,new String(regionStr));tokenStack[tokenStack.length-1].addChild(token);}
else if(results[0].charAt(0)=='<')
{var piName=results[0].replace(/^(<!--\s*){0,1}<\/?/,"");piName=piName.replace(/>(\s*-->){0,1}|\s.*$/,"");if(results[0].search(/<\//)!=-1)
{if(tokenStack[tokenStack.length-1].tokenType!=Spry.Data.Region.Token.PROCESSING_INSTRUCTION_TOKEN)
{Spry.Debug.reportError("Invalid processing instruction close tag: "+piName+" -- "+results[0]+"\n");return null;}
tokenStack.pop();}
else
{var piDesc=Spry.Data.Region.PI.instructions[piName];if(piDesc)
{var dataSet=null;var selectedDataSetName="";if(results[0].search(/^.*\bselect=\"/)!=-1)
{selectedDataSetName=results[0].replace(/^.*\bselect=\"/,"");selectedDataSetName=selectedDataSetName.replace(/".*$/,"");if(selectedDataSetName)
{dataSet=Spry.Data.getDataSetByName(selectedDataSetName);if(!dataSet)
{Spry.Debug.reportError("Failed to retrieve data set ("+selectedDataSetName+") for "+piName+"\n");selectedDataSetName="";}}}
var jsExpr=null;if(results[0].search(/^.*\btest=\"/)!=-1)
{jsExpr=results[0].replace(/^.*\btest=\"/,"");jsExpr=jsExpr.replace(/".*$/,"");jsExpr=Spry.Utils.decodeEntities(jsExpr);}
var regionState=null;if(results[0].search(/^.*\bname=\"/)!=-1)
{regionState=results[0].replace(/^.*\bname=\"/,"");regionState=regionState.replace(/".*$/,"");regionState=Spry.Utils.decodeEntities(regionState);}
var piData=new Spry.Data.Region.Token.PIData(piName,selectedDataSetName,jsExpr,regionState);token=new Spry.Data.Region.Token(Spry.Data.Region.Token.PROCESSING_INSTRUCTION_TOKEN,dataSet,piData,new String(results[0]));tokenStack[tokenStack.length-1].addChild(token);tokenStack.push(token);}
else
{Spry.Debug.reportError("Unsupported region processing instruction: "+results[0]+"\n");return null;}}}
else
{Spry.Debug.reportError("Invalid region token: "+results[0]+"\n");return null;}
searchStartIndex=regexp.lastIndex;}
return rootToken;};Spry.Data.Region.prototype.processTokenChildren=function(outputArr,token,processContext)
{var children=token.children;var len=children.length;for(var i=0;i<len;i++)
this.processTokens(outputArr,children[i],processContext);};Spry.Data.Region.prototype.processTokens=function(outputArr,token,processContext)
{var i=0;switch(token.tokenType)
{case Spry.Data.Region.Token.LIST_TOKEN:this.processTokenChildren(outputArr,token,processContext);break;case Spry.Data.Region.Token.STRING_TOKEN:outputArr.push(token.data);break;case Spry.Data.Region.Token.PROCESSING_INSTRUCTION_TOKEN:if(token.data.name=="spry:repeat")
{var dataSet=null;if(token.dataSet)
dataSet=token.dataSet;else
dataSet=this.dataSets[0];if(dataSet)
{var dsContext=processContext.getDataSetContext(dataSet);if(!dsContext)
{Spry.Debug.reportError("processTokens() failed to get a data set context!\n");break;}
dsContext.pushState();var dataSetRows=dsContext.getData();var numRows=dataSetRows.length;for(i=0;i<numRows;i++)
{dsContext.setRowIndex(i);var testVal=true;if(token.data.jsExpr)
{var jsExpr=Spry.Data.Region.processDataRefString(processContext,token.data.jsExpr,null,true);try{testVal=Spry.Utils.eval(jsExpr);}
catch(e)
{Spry.Debug.trace("Caught exception in Spry.Data.Region.prototype.processTokens while evaluating: "+jsExpr+"\n    Exception:"+e+"\n");testVal=true;}}
if(testVal)
this.processTokenChildren(outputArr,token,processContext);}
dsContext.popState();}}
else if(token.data.name=="spry:if")
{var testVal=true;if(token.data.jsExpr)
{var jsExpr=Spry.Data.Region.processDataRefString(processContext,token.data.jsExpr,null,true);try{testVal=Spry.Utils.eval(jsExpr);}
catch(e)
{Spry.Debug.trace("Caught exception in Spry.Data.Region.prototype.processTokens while evaluating: "+jsExpr+"\n    Exception:"+e+"\n");testVal=true;}}
if(testVal)
this.processTokenChildren(outputArr,token,processContext);}
else if(token.data.name=="spry:choose")
{var defaultChild=null;var childToProcess=null;var testVal=false;var j=0;for(j=0;j<token.children.length;j++)
{var child=token.children[j];if(child.tokenType==Spry.Data.Region.Token.PROCESSING_INSTRUCTION_TOKEN)
{if(child.data.name=="spry:when")
{if(child.data.jsExpr)
{var jsExpr=Spry.Data.Region.processDataRefString(processContext,child.data.jsExpr,null,true);try{testVal=Spry.Utils.eval(jsExpr);}
catch(e)
{Spry.Debug.trace("Caught exception in Spry.Data.Region.prototype.processTokens while evaluating: "+jsExpr+"\n    Exception:"+e+"\n");testVal=false;}
if(testVal)
{childToProcess=child;break;}}}
else if(child.data.name=="spry:default")
defaultChild=child;}}
if(!childToProcess&&defaultChild)
childToProcess=defaultChild;if(childToProcess)
this.processTokenChildren(outputArr,childToProcess,processContext);}
else if(token.data.name=="spry:state")
{var testVal=true;if(!token.data.regionState||token.data.regionState==this.currentState)
this.processTokenChildren(outputArr,token,processContext);}
else
{Spry.Debug.reportError("processTokens(): Unknown processing instruction: "+token.data.name+"\n");return"";}
break;case Spry.Data.Region.Token.VALUE_TOKEN:var dataSet=token.dataSet;if(!dataSet&&this.dataSets&&this.dataSets.length>0&&this.dataSets[0])
{dataSet=this.dataSets[0];}
if(!dataSet)
{Spry.Debug.reportError("processTokens(): Value reference has no data set specified: "+token.regionStr+"\n");return"";}
var dsContext=processContext.getDataSetContext(dataSet);if(!dsContext)
{Spry.Debug.reportError("processTokens: Failed to get a data set context!\n");return"";}
var ds=dsContext.getDataSet();if(token.data=="ds_RowNumber")
outputArr.push(dsContext.getRowIndex());else if(token.data=="ds_RowNumberPlus1")
outputArr.push(dsContext.getRowIndex()+1);else if(token.data=="ds_RowCount")
outputArr.push(dsContext.getNumRows());else if(token.data=="ds_UnfilteredRowCount")
outputArr.push(dsContext.getNumRows(true));else if(token.data=="ds_CurrentRowNumber")
outputArr.push(ds.getRowNumber(ds.getCurrentRow()));else if(token.data=="ds_CurrentRowID")
outputArr.push(ds.getCurrentRowID());else if(token.data=="ds_EvenOddRow")
outputArr.push((dsContext.getRowIndex()%2)?Spry.Data.Region.evenRowClassName:Spry.Data.Region.oddRowClassName);else if(token.data=="ds_SortOrder")
outputArr.push(ds.getSortOrder());else if(token.data=="ds_SortColumn")
outputArr.push(ds.getSortColumn());else
{var curDataSetRow=dsContext.getCurrentRow();if(curDataSetRow)
outputArr.push(curDataSetRow[token.data]);}
break;default:Spry.Debug.reportError("processTokens(): Invalid token type: "+token.regionStr+"\n");break;}};Spry.Data.Region.prototype.transform=function()
{if(this.data&&!this.tokens)
this.tokens=this.tokenizeData(this.data);if(!this.tokens)
return"";processContext=new Spry.Data.Region.ProcessingContext(this);if(!processContext)
return"";var outputArr=[""];this.processTokens(outputArr,this.tokens,processContext);return outputArr.join("");};Spry.Data.Region.PI={};Spry.Data.Region.PI.instructions={};Spry.Data.Region.PI.buildOpenTagForValueAttr=function(ele,piName,attrName)
{if(!ele||!piName)
return"";var jsExpr="";try
{var testAttr=ele.attributes.getNamedItem(piName);if(testAttr&&testAttr.value)
jsExpr=Spry.Utils.encodeEntities(testAttr.value);}
catch(e){jsExpr="";}
if(!jsExpr)
{Spry.Debug.reportError(piName+" attribute requires a JavaScript expression that returns true or false!\n");return"";}
return"<"+Spry.Data.Region.PI.instructions[piName].tagName+" "+attrName+"=\""+jsExpr+"\">";};Spry.Data.Region.PI.buildOpenTagForTest=function(ele,piName)
{return Spry.Data.Region.PI.buildOpenTagForValueAttr(ele,piName,"test");};Spry.Data.Region.PI.buildOpenTagForState=function(ele,piName)
{return Spry.Data.Region.PI.buildOpenTagForValueAttr(ele,piName,"name");};Spry.Data.Region.PI.buildOpenTagForRepeat=function(ele,piName)
{if(!ele||!piName)
return"";var selectAttrStr="";try
{var selectAttr=ele.attributes.getNamedItem(piName);if(selectAttr&&selectAttr.value)
{selectAttrStr=selectAttr.value;selectAttrStr=selectAttrStr.replace(/\s/g,"");}}
catch(e){selectAttrStr="";}
if(!selectAttrStr)
{Spry.Debug.reportError(piName+" attribute requires a data set name!\n");return"";}
var testAttrStr="";try
{var testAttr=ele.attributes.getNamedItem("spry:test");if(testAttr)
{if(testAttr.value)
testAttrStr=" test=\""+Spry.Utils.encodeEntities(testAttr.value)+"\"";ele.attributes.removeNamedItem(testAttr.nodeName);}}
catch(e){testAttrStr="";}
return"<"+Spry.Data.Region.PI.instructions[piName].tagName+" select=\""+selectAttrStr+"\""+testAttrStr+">";};Spry.Data.Region.PI.buildOpenTagForContent=function(ele,piName)
{if(!ele||!piName)
return"";var dataRefStr="";try
{var contentAttr=ele.attributes.getNamedItem(piName);if(contentAttr&&contentAttr.value)
dataRefStr=Spry.Utils.encodeEntities(contentAttr.value);}
catch(e){dataRefStr="";}
if(!dataRefStr)
{Spry.Debug.reportError(piName+" attribute requires a data reference!\n");return"";}
return"<"+Spry.Data.Region.PI.instructions[piName].tagName+" dataref=\""+dataRefStr+"\">";};Spry.Data.Region.PI.buildOpenTag=function(ele,piName)
{return"<"+Spry.Data.Region.PI.instructions[piName].tagName+">";};Spry.Data.Region.PI.buildCloseTag=function(ele,piName)
{return"</"+Spry.Data.Region.PI.instructions[piName].tagName+">";};Spry.Data.Region.PI.instructions["spry:state"]={tagName:"spry:state",childrenOnly:false,getOpenTag:Spry.Data.Region.PI.buildOpenTagForState,getCloseTag:Spry.Data.Region.PI.buildCloseTag};Spry.Data.Region.PI.instructions["spry:if"]={tagName:"spry:if",childrenOnly:false,getOpenTag:Spry.Data.Region.PI.buildOpenTagForTest,getCloseTag:Spry.Data.Region.PI.buildCloseTag};Spry.Data.Region.PI.instructions["spry:repeat"]={tagName:"spry:repeat",childrenOnly:false,getOpenTag:Spry.Data.Region.PI.buildOpenTagForRepeat,getCloseTag:Spry.Data.Region.PI.buildCloseTag};Spry.Data.Region.PI.instructions["spry:repeatchildren"]={tagName:"spry:repeat",childrenOnly:true,getOpenTag:Spry.Data.Region.PI.buildOpenTagForRepeat,getCloseTag:Spry.Data.Region.PI.buildCloseTag};Spry.Data.Region.PI.instructions["spry:choose"]={tagName:"spry:choose",childrenOnly:true,getOpenTag:Spry.Data.Region.PI.buildOpenTag,getCloseTag:Spry.Data.Region.PI.buildCloseTag};Spry.Data.Region.PI.instructions["spry:when"]={tagName:"spry:when",childrenOnly:false,getOpenTag:Spry.Data.Region.PI.buildOpenTagForTest,getCloseTag:Spry.Data.Region.PI.buildCloseTag};Spry.Data.Region.PI.instructions["spry:default"]={tagName:"spry:default",childrenOnly:false,getOpenTag:Spry.Data.Region.PI.buildOpenTag,getCloseTag:Spry.Data.Region.PI.buildCloseTag};Spry.Data.Region.PI.instructions["spry:content"]={tagName:"spry:content",childrenOnly:true,getOpenTag:Spry.Data.Region.PI.buildOpenTagForContent,getCloseTag:Spry.Data.Region.PI.buildCloseTag};Spry.Data.Region.PI.orderedInstructions=["spry:state","spry:if","spry:repeat","spry:repeatchildren","spry:choose","spry:when","spry:default","spry:content"];Spry.Data.Region.getTokensFromStr=function(str)
{if(!str)
return null;return str.match(/{[^}]+}/g);};Spry.Data.Region.processDataRefString=function(processingContext,regionStr,dataSetsToUse,isJSExpr)
{if(!regionStr)
return"";if(!processingContext&&!dataSetsToUse)
return regionStr;var resultStr="";var re=new RegExp("\\{([^\\}:]+::)?[^\\}]+\\}","g");var startSearchIndex=0;while(startSearchIndex<regionStr.length)
{var reArray=re.exec(regionStr);if(!reArray||!reArray[0])
{resultStr+=regionStr.substr(startSearchIndex,regionStr.length-startSearchIndex);return resultStr;}
if(reArray.index!=startSearchIndex)
resultStr+=regionStr.substr(startSearchIndex,reArray.index-startSearchIndex);var dsName="";if(reArray[0].search(/^\{[^}:]+::/)!=-1)
dsName=reArray[0].replace(/^\{|::.*/g,"");var fieldName=reArray[0].replace(/^\{|.*::|\}/g,"");var row=null;if(processingContext)
{var dsContext=processingContext.getDataSetContext(dsName);if(fieldName=="ds_RowNumber")
{resultStr+=dsContext.getRowIndex();row=null;}
else if(fieldName=="ds_RowNumberPlus1")
{resultStr+=(dsContext.getRowIndex()+1);row=null;}
else if(fieldName=="ds_RowCount")
{resultStr+=dsContext.getNumRows();row=null;}
else if(fieldName=="ds_UnfilteredRowCount")
{resultStr+=dsContext.getNumRows(true);row=null;}
else if(fieldName=="ds_CurrentRowNumber")
{var ds=dsContext.getDataSet();resultStr+=ds.getRowNumber(ds.getCurrentRow());row=null;}
else if(fieldName=="ds_CurrentRowID")
{var ds=dsContext.getDataSet();resultStr+=""+ds.getCurrentRowID();row=null;}
else if(fieldName=="ds_EvenOddRow")
{resultStr+=(dsContext.getRowIndex()%2)?Spry.Data.Region.evenRowClassName:Spry.Data.Region.oddRowClassName;row=null;}
else if(fieldName=="ds_SortOrder")
{resultStr+=dsContext.getDataSet().getSortOrder();row=null;}
else if(fieldName=="ds_SortColumn")
{resultStr+=dsContext.getDataSet().getSortColumn();row=null;}
else
row=processingContext.getCurrentRowForDataSet(dsName);}
else
{var ds=dsName?dataSetsToUse[dsName]:dataSetsToUse[0];if(ds)
row=ds.getCurrentRow();}
if(row)
resultStr+=isJSExpr?Spry.Utils.escapeQuotesAndLineBreaks(""+row[fieldName]):row[fieldName];if(startSearchIndex==re.lastIndex)
{var leftOverIndex=reArray.index+reArray[0].length;if(leftOverIndex<regionStr.length)
resultStr+=regionStr.substr(leftOverIndex);break;}
startSearchIndex=re.lastIndex;}
return resultStr;};Spry.Data.Region.strToDataSetsArray=function(str,returnRegionNames)
{var dataSetsArr=new Array;var foundHash={};if(!str)
return dataSetsArr;str=str.replace(/\s+/g," ");str=str.replace(/^\s|\s$/g,"");var arr=str.split(/ /);for(var i=0;i<arr.length;i++)
{if(arr[i]&&!Spry.Data.Region.PI.instructions[arr[i]])
{try{var dataSet=Spry.Data.getDataSetByName(arr[i]);if(!foundHash[arr[i]])
{if(returnRegionNames)
dataSetsArr.push(arr[i]);else
dataSetsArr.push(dataSet);foundHash[arr[i]]=true;}}
catch(e){}}}
return dataSetsArr;};Spry.Data.Region.DSContext=function(dataSet,processingContext)
{var m_dataSet=dataSet;var m_processingContext=processingContext;var m_curRowIndexArray=[{rowIndex:-1}];var m_parent=null;var m_children=[];var getInternalRowIndex=function(){return m_curRowIndexArray[m_curRowIndexArray.length-1].rowIndex;};this.resetAll=function(){m_curRowIndexArray=[{rowIndex:m_dataSet.getCurrentRow()}]};this.getDataSet=function(){return m_dataSet;};this.getNumRows=function(unfiltered)
{var data=this.getCurrentState().data;return data?data.length:m_dataSet.getRowCount(unfiltered);};this.getData=function()
{var data=this.getCurrentState().data;return data?data:m_dataSet.getData();};this.setData=function(data)
{this.getCurrentState().data=data;};this.getCurrentRow=function()
{if(m_curRowIndexArray.length<2||getInternalRowIndex()<0)
return m_dataSet.getCurrentRow();var data=this.getData();var curRowIndex=getInternalRowIndex();if(curRowIndex<0||curRowIndex>data.length)
{Spry.Debug.reportError("Invalid index used in Spry.Data.Region.DSContext.getCurrentRow()!\n");return null;}
return data[curRowIndex];};this.getRowIndex=function()
{var curRowIndex=getInternalRowIndex();if(curRowIndex>=0)
return curRowIndex;return m_dataSet.getRowNumber(m_dataSet.getCurrentRow());};this.setRowIndex=function(rowIndex)
{this.getCurrentState().rowIndex=rowIndex;var data=this.getData();var numChildren=m_children.length;for(var i=0;i<numChildren;i++)
m_children[i].syncDataWithParentRow(this,rowIndex,data);};this.syncDataWithParentRow=function(parentDSContext,rowIndex,parentData)
{var row=parentData[rowIndex];if(row)
{nestedDS=m_dataSet.getNestedDataSetForParentRow(row);if(nestedDS)
{var currentState=this.getCurrentState();currentState.data=nestedDS.getData();currentState.rowIndex=nestedDS.getCurrentRowNumber();var numChildren=m_children.length;for(var i=0;i<numChildren;i++)
m_children[i].syncDataWithParentRow(this,currentState.rowIndex,currentState.data);}}};this.pushState=function()
{var curState=this.getCurrentState();var newState=new Object;newState.rowIndex=curState.rowIndex;newState.data=curState.data;m_curRowIndexArray.push(newState);var numChildren=m_children.length;for(var i=0;i<numChildren;i++)
m_children[i].pushState();};this.popState=function()
{if(m_curRowIndexArray.length<2)
{Spry.Debug.reportError("Stack underflow in Spry.Data.Region.DSContext.popState()!\n");return;}
var numChildren=m_children.length;for(var i=0;i<numChildren;i++)
m_children[i].popState();m_curRowIndexArray.pop();};this.getCurrentState=function()
{return m_curRowIndexArray[m_curRowIndexArray.length-1];};this.addChild=function(childDSContext)
{var numChildren=m_children.length;for(var i=0;i<numChildren;i++)
{if(m_children[i]==childDSContext)
return;}
m_children.push(childDSContext);};};Spry.Data.Region.ProcessingContext=function(region)
{this.region=region;this.dataSetContexts=[];if(region&&region.dataSets)
{var dsArray=region.dataSets.slice(0);var dsArrayLen=dsArray.length;for(var i=0;i<dsArrayLen;i++)
{var ds=region.dataSets[i];while(ds&&ds.getParentDataSet)
{var doesExist=false;ds=ds.getParentDataSet();if(ds&&this.indexOf(dsArray,ds)==-1)
dsArray.push(ds);}}
for(i=0;i<dsArray.length;i++)
this.dataSetContexts.push(new Spry.Data.Region.DSContext(dsArray[i],this));var dsContexts=this.dataSetContexts;var numDSContexts=dsContexts.length;for(i=0;i<numDSContexts;i++)
{var dsc=dsContexts[i];var ds=dsc.getDataSet();if(ds.getParentDataSet)
{var parentDS=ds.getParentDataSet();if(parentDS)
{var pdsc=this.getDataSetContext(parentDS);if(pdsc)pdsc.addChild(dsc);}}}}};Spry.Data.Region.ProcessingContext.prototype.indexOf=function(arr,item)
{if(arr)
{var arrLen=arr.length;for(var i=0;i<arrLen;i++)
if(arr[i]==item)
return i;}
return-1;};Spry.Data.Region.ProcessingContext.prototype.getDataSetContext=function(dataSet)
{if(!dataSet)
{if(this.dataSetContexts.length>0)
return this.dataSetContexts[0];return null;}
if(typeof dataSet=='string')
{dataSet=Spry.Data.getDataSetByName(dataSet);if(!dataSet)
return null;}
for(var i=0;i<this.dataSetContexts.length;i++)
{var dsc=this.dataSetContexts[i];if(dsc.getDataSet()==dataSet)
return dsc;}
return null;};Spry.Data.Region.ProcessingContext.prototype.getCurrentRowForDataSet=function(dataSet)
{var dsc=this.getDataSetContext(dataSet);if(dsc)
return dsc.getCurrentRow();return null;};Spry.Data.Region.Token=function(tokenType,dataSet,data,regionStr)
{var self=this;this.tokenType=tokenType;this.dataSet=dataSet;this.data=data;this.regionStr=regionStr;this.parent=null;this.children=null;};Spry.Data.Region.Token.prototype.addChild=function(child)
{if(!child)
return;if(!this.children)
this.children=new Array;this.children.push(child);child.parent=this;};Spry.Data.Region.Token.LIST_TOKEN=0;Spry.Data.Region.Token.STRING_TOKEN=1;Spry.Data.Region.Token.PROCESSING_INSTRUCTION_TOKEN=2;Spry.Data.Region.Token.VALUE_TOKEN=3;Spry.Data.Region.Token.PIData=function(piName,data,jsExpr,regionState)
{var self=this;this.name=piName;this.data=data;this.jsExpr=jsExpr;this.regionState=regionState;};Spry.Utils.addLoadListener(function(){setTimeout(function(){if(Spry.Data.initRegionsOnLoad)Spry.Data.initRegions();},0);});