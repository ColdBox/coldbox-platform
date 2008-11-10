// SpryJSONDataSet.js - version 0.4 - Spry Pre-Release 1.6
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

Spry.Data.JSONDataSet=function(dataSetURL,dataSetOptions)
{this.path="";this.pathIsObjectOfArrays=false;this.doc=null;this.subPaths=[];this.useParser=false;this.preparseFunc=null;Spry.Data.HTTPSourceDataSet.call(this,dataSetURL,dataSetOptions);var jwType=typeof this.subPaths;if(jwType=="string"||(jwType=="object"&&this.subPaths.constructor!=Array))
this.subPaths=[this.subPaths];};Spry.Data.JSONDataSet.prototype=new Spry.Data.HTTPSourceDataSet();Spry.Data.JSONDataSet.prototype.constructor=Spry.Data.JSONDataSet;Spry.Data.JSONDataSet.prototype.getDataRefStrings=function()
{var strArr=[];if(this.url)strArr.push(this.url);if(this.path)strArr.push(this.path);if(this.requestInfo&&this.requestInfo.postData)strArr.push(this.requestInfo.postData);return strArr;};Spry.Data.JSONDataSet.prototype.getDocument=function(){return this.doc;};Spry.Data.JSONDataSet.prototype.getPath=function(){return this.path;};Spry.Data.JSONDataSet.prototype.setPath=function(path)
{if(this.path!=path)
{this.path=path;if(this.dataWasLoaded&&this.doc)
{this.notifyObservers("onPreLoad");this.setDataFromDoc(this.doc);}}};Spry.Data.JSONDataSet.getMatchingObjects=function(path,jsonObj)
{var results=[];if(path&&jsonObj)
{var prop="";var leftOverPath="";var offset=path.search(/\./);if(offset!=-1)
{prop=path.substring(0,offset);leftOverPath=path.substring(offset+1);}
else
prop=path;var matches=[];if(prop&&typeof jsonObj=="object")
{var obj=jsonObj[prop];var objType=typeof obj;if(objType!=undefined&&objType!=null)
{if(obj&&objType=="object"&&obj.constructor==Array)
matches=matches.concat(obj);else
matches.push(obj);}}
var numMatches=matches.length;if(leftOverPath)
{for(var i=0;i<numMatches;i++)
results=results.concat(Spry.Data.JSONDataSet.getMatchingObjects(leftOverPath,matches[i]));}
else
results=matches;}
return results;};Spry.Data.JSONDataSet.flattenObject=function(obj,basicColumnName)
{var basicName=basicColumnName?basicColumnName:"column0";var row=new Object;var objType=typeof obj;if(objType=="object")
Spry.Data.JSONDataSet.copyProps(row,obj);else
row[basicName]=obj;row.ds_JSONObject=obj;return row;};Spry.Data.JSONDataSet.copyProps=function(dstObj,srcObj,suppressObjProps)
{if(srcObj&&dstObj)
{for(var prop in srcObj)
{if(suppressObjProps&&typeof srcObj[prop]=="object")
continue;dstObj[prop]=srcObj[prop];}}
return dstObj;};Spry.Data.JSONDataSet.flattenDataIntoRecordSet=function(jsonObj,path,pathIsObjectOfArrays)
{var rs=new Object;rs.data=[];rs.dataHash={};if(!path)
path="";var obj=jsonObj;var objType=typeof obj;var basicColName="";if(objType!="object"||!obj)
{if(obj!=null)
{var row=new Object;row.column0=obj;row.ds_RowID=0;rs.data.push(row);rs.dataHash[row.ds_RowID]=row;}
return rs;}
var matches=[];if(obj.constructor==Array)
{var arrLen=obj.length;if(arrLen<1)
return rs;var eleType=typeof obj[0];if(eleType!="object")
{for(var i=0;i<arrLen;i++)
{var row=new Object;row.column0=obj[i];row.ds_RowID=i;rs.data.push(row);rs.dataHash[row.ds_RowID]=row;}
return rs;}
if(obj[0].constructor==Array)
return rs;if(path)
{for(var i=0;i<arrLen;i++)
matches=matches.concat(Spry.Data.JSONDataSet.getMatchingObjects(path,obj[i]));}
else
{for(var i=0;i<arrLen;i++)
matches.push(obj[i]);}}
else
{if(path)
matches=Spry.Data.JSONDataSet.getMatchingObjects(path,obj);else
matches.push(obj);}
var numMatches=matches.length;if(path&&numMatches>=1&&typeof matches[0]!="object")
basicColName=path.replace(/.*\./,"");if(!pathIsObjectOfArrays)
{for(var i=0;i<numMatches;i++)
{var row=Spry.Data.JSONDataSet.flattenObject(matches[i],basicColName,pathIsObjectOfArrays);row.ds_RowID=i;rs.dataHash[i]=row;rs.data.push(row);}}
else
{var rowID=0;for(var i=0;i<numMatches;i++)
{var obj=matches[i];var colNames=[];var maxNumRows=0;for(var propName in obj)
{var prop=obj[propName];var propyType=typeof prop;if(propyType=='object'&&prop.constructor==Array)
{colNames.push(propName);maxNumRows=Math.max(maxNumRows,obj[propName].length);}}
var numColNames=colNames.length;for(var j=0;j<maxNumRows;j++)
{var row=new Object;for(var k=0;k<numColNames;k++)
{var colName=colNames[k];row[colName]=obj[colName][j];}
row.ds_RowID=rowID++;rs.dataHash[i]=row;rs.data.push(row);}}}
return rs;};Spry.Data.JSONDataSet.prototype.flattenSubPaths=function(rs,subPaths)
{if(!rs||!subPaths)
return;var numSubPaths=subPaths.length;if(numSubPaths<1)
return;var data=rs.data;var dataHash={};var pathArray=[];var cleanedPathArray=[];var isObjectOfArraysArr=[];for(var i=0;i<numSubPaths;i++)
{var subPath=subPaths[i];if(typeof subPath=="object")
{isObjectOfArraysArr[i]=subPath.pathIsObjectOfArrays;subPath=subPath.path;}
if(!subPath)
subPath="";pathArray[i]=Spry.Data.Region.processDataRefString(null,subPath,this.dataSetsForDataRefStrings);cleanedPathArray[i]=pathArray[i].replace(/\[.*\]/g,"");}
var row;var numRows=data.length;var newData=[];for(var i=0;i<numRows;i++)
{row=data[i];var newRows=[row];for(var j=0;j<numSubPaths;j++)
{var newRS=Spry.Data.JSONDataSet.flattenDataIntoRecordSet(row.ds_JSONObject,pathArray[j],isObjectOfArraysArr[j]);if(newRS&&newRS.data&&newRS.data.length)
{if(typeof subPaths[j]=="object"&&subPaths[j].subPaths)
{var sp=subPaths[j].subPaths;spType=typeof sp;if(spType=="string")
sp=[sp];else if(spType=="object"&&spType.constructor==Object)
sp=[sp];this.flattenSubPaths(newRS,sp);}
var newRSData=newRS.data;var numRSRows=newRSData.length;var cleanedPath=cleanedPathArray[j]+".";var numNewRows=newRows.length;var joinedRows=[];for(var k=0;k<numNewRows;k++)
{var newRow=newRows[k];for(var l=0;l<numRSRows;l++)
{var newRowObj=new Object;var newRSRow=newRSData[l];for(var prop in newRSRow)
{var newPropName=cleanedPath+prop;if(cleanedPath==prop||cleanedPath.search(new RegExp("\\."+prop+"\\.$"))!=-1)
newPropName=cleanedPathArray[j];newRowObj[newPropName]=newRSRow[prop];}
Spry.Data.JSONDataSet.copyProps(newRowObj,newRow);joinedRows.push(newRowObj);}}
newRows=joinedRows;}}
newData=newData.concat(newRows);}
data=newData;numRows=data.length;for(i=0;i<numRows;i++)
{row=data[i];row.ds_RowID=i;dataHash[row.ds_RowID]=row;}
rs.data=data;rs.dataHash=dataHash;};Spry.Data.JSONDataSet.prototype.parseJSON=function(str,filter)
{try
{if(/^("(\\.|[^"\\\n\r])*?"|[,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t])+?$/.test(str))
{var j=eval('('+str+')');if(typeof filter==='function')
{function walk(k,v)
{if(v&&typeof v==='object')
{for(var i in v)
{if(v.hasOwnProperty(i))
{v[i]=walk(i,v[i]);}}}
return filter(k,v);}
j=walk('',j);}
return j;}}catch(e){}
throw new Error("Failed to parse JSON string.");};Spry.Data.JSONDataSet.prototype.loadDataIntoDataSet=function(rawDataDoc)
{if(this.preparseFunc)
rawDataDoc=this.preparseFunc(this,rawDataDoc);var jsonObj;try{jsonObj=this.useParser?this.parseJSON(rawDataDoc):eval("("+rawDataDoc+")");}
catch(e)
{Spry.Debug.reportError("Caught exception in JSONDataSet.loadDataIntoDataSet: "+e);jsonObj={};}
if(jsonObj==null)
jsonObj="null";var rs=Spry.Data.JSONDataSet.flattenDataIntoRecordSet(jsonObj,Spry.Data.Region.processDataRefString(null,this.path,this.dataSetsForDataRefStrings),this.pathIsObjectOfArrays);this.flattenSubPaths(rs,this.subPaths);this.doc=rawDataDoc;this.docObj=jsonObj;this.data=rs.data;this.dataHash=rs.dataHash;this.dataWasLoaded=(this.doc!=null);};