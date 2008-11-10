// SpryNestedJSONDataSet.js - version 0.2 - Spry Pre-Release 1.6
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

Spry.Data.NestedJSONDataSet=function(parentDataSet,jpath,options)
{this.parentDataSet=parentDataSet;this.jpath=jpath;this.nestedDataSets=[];this.nestedDataSetsHash={};this.currentDS=null;this.currentDSAncestor=null;this.options=options;this.ignoreOnDataChanged=false;Spry.Data.DataSet.call(this,options);parentDataSet.addObserver(this);};Spry.Data.NestedJSONDataSet.prototype=new Spry.Data.DataSet();Spry.Data.NestedJSONDataSet.prototype.constructor=Spry.Data.NestedJSONDataSet.prototype;Spry.Data.NestedJSONDataSet.prototype.getParentDataSet=function()
{return this.parentDataSet;};Spry.Data.NestedJSONDataSet.prototype.getNestedDataSetForParentRow=function(parentRow)
{var jsonNode=parentRow.ds_JSONObject;if(jsonNode&&this.nestedDataSets)
{if(this.currentDSAncestor&&this.currentDSAncestor==jsonNode)
return this.currentDS;var nDSArr=this.nestedDataSets;var nDSArrLen=nDSArr.length;for(var i=0;i<nDSArrLen;i++)
{var dsObj=nDSArr[i];if(dsObj&&jsonNode==dsObj.ancestor)
return dsObj.dataSet;}}
return null;};Spry.Data.NestedJSONDataSet.prototype.getNestedJSONDataSetsArray=function()
{var resultsArray=[];if(this.nestedDataSets)
{var arrDS=this.nestedDataSets;var numDS=this.nestedDataSets.length;for(var i=0;i<numDS;i++)
resultsArray.push(arrDS[i].dataSet);}
return resultsArray;};Spry.Data.NestedJSONDataSet.prototype.onDataChanged=function(notifier,data)
{if(!this.ignoreOnDataChanged)
this.loadData();};Spry.Data.NestedJSONDataSet.prototype.onCurrentRowChanged=function(notifier,data)
{this.notifyObservers("onPreParentContextChange");this.currentDS=null;this.currentDSAncestor=null;var pCurRow=this.parentDataSet.getCurrentRow();if(pCurRow)
{var nestedDS=this.getNestedDataSetForParentRow(pCurRow);if(nestedDS)
{this.currentDS=nestedDS;this.currentDSAncestor=pCurRow.ds_JSONObject;}}
this.notifyObservers("onDataChanged");this.notifyObservers("onPostParentContextChange");this.ignoreOnDataChanged=false;};Spry.Data.NestedJSONDataSet.prototype.onPostParentContextChange=Spry.Data.NestedJSONDataSet.prototype.onCurrentRowChanged;Spry.Data.NestedJSONDataSet.prototype.onPreParentContextChange=function(notifier,data)
{this.ignoreOnDataChanged=true;};Spry.Data.NestedJSONDataSet.prototype.loadData=function()
{var parentDS=this.parentDataSet;if(!parentDS||parentDS.getLoadDataRequestIsPending()||!this.jpath)
return;if(!parentDS.getDataWasLoaded())
{parentDS.loadData();return;}
this.notifyObservers("onPreLoad");this.nestedDataSets=[];this.currentDS=null;this.currentDSAncestor=null;this.data=[];this.dataHash={};var self=this;var ancestorDS=[parentDS];if(parentDS.getNestedJSONDataSetsArray)
ancestorDS=parentDS.getNestedJSONDataSetsArray();var currentAncestor=null;var currentAncestorRow=parentDS.getCurrentRow();if(currentAncestorRow)
currentAncestor=currentAncestorRow.ds_JSONObject;var numAncestors=ancestorDS.length;for(var i=0;i<numAncestors;i++)
{var aDS=ancestorDS[i];var aData=aDS.getData(true);if(aData)
{var aDataLen=aData.length;for(var j=0;j<aDataLen;j++)
{var row=aData[j];if(row&&row.ds_JSONObject)
{var ds=new Spry.Data.DataSet(this.options);var dataArr=Spry.Data.JSONDataSet.flattenDataIntoRecordSet(row.ds_JSONObject,this.jpath);ds.setDataFromArray(dataArr.data,true);var dsObj=new Object;dsObj.ancestor=row.ds_JSONObject;dsObj.dataSet=ds;this.nestedDataSets.push(dsObj);if(row.ds_JSONObject==currentAncestor)
{this.currentDS=ds;this.currentDSAncestor=this.ds_JSONObject;}
ds.addObserver(function(notificationType,notifier,data){self.notifyObservers(notificationType,data);});}}}}
this.pendingRequest=new Object;this.dataWasLoaded=false;this.pendingRequest.timer=setTimeout(function(){self.pendingRequest=null;self.dataWasLoaded=true;self.notifyObservers("onPostLoad");self.notifyObservers("onDataChanged");},0);};Spry.Data.NestedJSONDataSet.prototype.getData=function(unfiltered)
{if(this.currentDS)
return this.currentDS.getData(unfiltered);return[];};Spry.Data.NestedJSONDataSet.prototype.getRowCount=function(unfiltered)
{if(this.currentDS)
return this.currentDS.getRowCount(unfiltered);return 0;};Spry.Data.NestedJSONDataSet.prototype.getRowByID=function(rowID)
{if(this.currentDS)
return this.currentDS.getRowByID(rowID);return undefined;};Spry.Data.NestedJSONDataSet.prototype.getRowByRowNumber=function(rowNumber,unfiltered)
{if(this.currentDS)
return this.currentDS.getRowByRowNumber(rowNumber,unfiltered);return null;};Spry.Data.NestedJSONDataSet.prototype.getCurrentRow=function()
{if(this.currentDS)
return this.currentDS.getCurrentRow();return null;};Spry.Data.NestedJSONDataSet.prototype.setCurrentRow=function(rowID)
{if(this.currentDS)
return this.currentDS.setCurrentRow(rowID);};Spry.Data.NestedJSONDataSet.prototype.getRowNumber=function(row)
{if(this.currentDS)
return this.currentDS.getRowNumber(row);return 0;};Spry.Data.NestedJSONDataSet.prototype.getCurrentRowNumber=function()
{if(this.currentDS)
return this.currentDS.getCurrentRowNumber();return 0;};Spry.Data.NestedJSONDataSet.prototype.getCurrentRowID=function()
{if(this.currentDS)
return this.currentDS.getCurrentRowID();return 0;};Spry.Data.NestedJSONDataSet.prototype.setCurrentRowNumber=function(rowNumber)
{if(this.currentDS)
return this.currentDS.setCurrentRowNumber(rowNumber);};Spry.Data.NestedJSONDataSet.prototype.findRowsWithColumnValues=function(valueObj,firstMatchOnly,unfiltered)
{if(this.currentDS)
return this.currentDS.findRowsWithColumnValues(valueObj,firstMatchOnly,unfiltered);return firstMatchOnly?null:[];};Spry.Data.NestedJSONDataSet.prototype.setColumnType=function(columnNames,columnType)
{if(columnNames)
{var dsArr=this.nestedDataSets;var dsArrLen=dsArr.length;for(var i=0;i<dsArrLen;i++)
dsArr[i].dataSet.setColumnType(columnNames,columnType);}};Spry.Data.NestedJSONDataSet.prototype.getColumnType=function(columnName)
{if(this.currentDS)
return this.currentDS.getColumnType(columnName);return"string";};Spry.Data.NestedJSONDataSet.prototype.distinct=function(columnNames)
{if(columnNames)
{var dsArr=this.nestedDataSets;var dsArrLen=dsArr.length;for(var i=0;i<dsArrLen;i++)
dsArr[i].dataSet.distinct(columnNames);}};Spry.Data.NestedJSONDataSet.prototype.getSortColumn=function(){if(this.currentDS)
return this.currentDS.getSortColumn();return"";};Spry.Data.NestedJSONDataSet.prototype.getSortOrder=function(){if(this.currentDS)
return this.currentDS.getSortOrder();return"";};Spry.Data.NestedJSONDataSet.prototype.sort=function(columnNames,sortOrder)
{if(columnNames)
{var dsArr=this.nestedDataSets;var dsArrLen=dsArr.length;for(var i=0;i<dsArrLen;i++)
dsArr[i].dataSet.sort(columnNames,sortOrder);}};Spry.Data.NestedJSONDataSet.prototype.filterData=function(filterFunc,filterOnly)
{if(columnNames)
{var dsArr=this.nestedDataSets;var dsArrLen=dsArr.length;for(var i=0;i<dsArrLen;i++)
dsArr[i].dataSet.filterData(filterFunc,filterOnly);}};Spry.Data.NestedJSONDataSet.prototype.filter=function(filterFunc,filterOnly)
{if(columnNames)
{var dsArr=this.nestedDataSets;var dsArrLen=dsArr.length;for(var i=0;i<dsArrLen;i++)
dsArr[i].dataSet.filter(filterFunc,filterOnly);}};