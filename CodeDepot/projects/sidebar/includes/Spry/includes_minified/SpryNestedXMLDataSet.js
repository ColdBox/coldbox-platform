// SpryNestedXMLDataSet.js - version 0.3 - Spry Pre-Release 1.6
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

Spry.Data.NestedXMLDataSet=function(parentDataSet,xpath,options)
{this.parentDataSet=parentDataSet;this.xpath=xpath;this.nestedDataSets=[];this.nestedDataSetsHash={};this.currentDS=null;this.currentDSAncestor=null;this.options=options;this.ignoreOnDataChanged=false;this.entityEncodeStrings=parentDataSet?parentDataSet.entityEncodeStrings:true;Spry.Data.DataSet.call(this,options);parentDataSet.addObserver(this);};Spry.Data.NestedXMLDataSet.prototype=new Spry.Data.DataSet();Spry.Data.NestedXMLDataSet.prototype.constructor=Spry.Data.NestedXMLDataSet.prototype;Spry.Data.NestedXMLDataSet.prototype.getParentDataSet=function()
{return this.parentDataSet;};Spry.Data.NestedXMLDataSet.prototype.getNestedDataSetForParentRow=function(parentRow)
{var xmlNode=parentRow.ds_XMLNode;if(xmlNode&&this.nestedDataSets)
{if(this.currentDSAncestor&&this.currentDSAncestor==xmlNode)
return this.currentDS;var nDSArr=this.nestedDataSets;var nDSArrLen=nDSArr.length;for(var i=0;i<nDSArrLen;i++)
{var dsObj=nDSArr[i];if(dsObj&&xmlNode==dsObj.ancestor)
return dsObj.dataSet;}}
return null;};Spry.Data.NestedXMLDataSet.prototype.getNestedXMLDataSetsArray=function()
{var resultsArray=[];if(this.nestedDataSets)
{var arrDS=this.nestedDataSets;var numDS=this.nestedDataSets.length;for(var i=0;i<numDS;i++)
resultsArray.push(arrDS[i].dataSet);}
return resultsArray;};Spry.Data.NestedXMLDataSet.prototype.onDataChanged=function(notifier,data)
{if(!this.ignoreOnDataChanged)
this.loadData();};Spry.Data.NestedXMLDataSet.prototype.onCurrentRowChanged=function(notifier,data)
{this.notifyObservers("onPreParentContextChange");this.currentDS=null;this.currentDSAncestor=null;var pCurRow=this.parentDataSet.getCurrentRow();if(pCurRow)
{var nestedDS=this.getNestedDataSetForParentRow(pCurRow);if(nestedDS)
{this.currentDS=nestedDS;this.currentDSAncestor=pCurRow.ds_XMLNode;}}
this.notifyObservers("onDataChanged");this.notifyObservers("onPostParentContextChange");this.ignoreOnDataChanged=false;};Spry.Data.NestedXMLDataSet.prototype.onPostParentContextChange=Spry.Data.NestedXMLDataSet.prototype.onCurrentRowChanged;Spry.Data.NestedXMLDataSet.prototype.onPreParentContextChange=function(notifier,data)
{this.ignoreOnDataChanged=true;};Spry.Data.NestedXMLDataSet.prototype.loadData=function()
{var parentDS=this.parentDataSet;if(!parentDS||parentDS.getLoadDataRequestIsPending()||!this.xpath)
return;if(!parentDS.getDataWasLoaded())
{parentDS.loadData();return;}
this.notifyObservers("onPreLoad");this.nestedDataSets=[];this.currentDS=null;this.currentDSAncestor=null;this.data=[];this.dataHash={};var self=this;var ancestorDS=[parentDS];if(parentDS.getNestedXMLDataSetsArray)
ancestorDS=parentDS.getNestedXMLDataSetsArray();var currentAncestor=null;var currentAncestorRow=parentDS.getCurrentRow();if(currentAncestorRow)
currentAncestor=currentAncestorRow.ds_XMLNode;var numAncestors=ancestorDS.length;for(var i=0;i<numAncestors;i++)
{var aDS=ancestorDS[i];var aData=aDS.getData(true);if(aData)
{var aDataLen=aData.length;for(var j=0;j<aDataLen;j++)
{var row=aData[j];if(row&&row.ds_XMLNode)
{var ds=new Spry.Data.DataSet(this.options);var dataArr=Spry.Data.XMLDataSet.getRecordSetFromXMLDoc(row.ds_XMLNode,this.xpath,false,this.entityEncodeStrings);ds.setDataFromArray(dataArr.data,true);var dsObj=new Object;dsObj.ancestor=row.ds_XMLNode;dsObj.dataSet=ds;this.nestedDataSets.push(dsObj);if(row.ds_XMLNode==currentAncestor)
{this.currentDS=ds;this.currentDSAncestor=this.ds_XMLNode;}
ds.addObserver(function(notificationType,notifier,data){self.notifyObservers(notificationType,data);});}}}}
this.pendingRequest=new Object;this.dataWasLoaded=false;this.pendingRequest.timer=setTimeout(function(){self.pendingRequest=null;self.dataWasLoaded=true;self.notifyObservers("onPostLoad");self.notifyObservers("onDataChanged");},0);};Spry.Data.NestedXMLDataSet.prototype.getData=function(unfiltered)
{if(this.currentDS)
return this.currentDS.getData(unfiltered);return[];};Spry.Data.NestedXMLDataSet.prototype.getRowCount=function(unfiltered)
{if(this.currentDS)
return this.currentDS.getRowCount(unfiltered);return 0;};Spry.Data.NestedXMLDataSet.prototype.getRowByID=function(rowID)
{if(this.currentDS)
return this.currentDS.getRowByID(rowID);return undefined;};Spry.Data.NestedXMLDataSet.prototype.getRowByRowNumber=function(rowNumber,unfiltered)
{if(this.currentDS)
return this.currentDS.getRowByRowNumber(rowNumber,unfiltered);return null;};Spry.Data.NestedXMLDataSet.prototype.getCurrentRow=function()
{if(this.currentDS)
return this.currentDS.getCurrentRow();return null;};Spry.Data.NestedXMLDataSet.prototype.setCurrentRow=function(rowID)
{if(this.currentDS)
return this.currentDS.setCurrentRow(rowID);};Spry.Data.NestedXMLDataSet.prototype.getRowNumber=function(row)
{if(this.currentDS)
return this.currentDS.getRowNumber(row);return 0;};Spry.Data.NestedXMLDataSet.prototype.getCurrentRowNumber=function()
{if(this.currentDS)
return this.currentDS.getCurrentRowNumber();return 0;};Spry.Data.NestedXMLDataSet.prototype.getCurrentRowID=function()
{if(this.currentDS)
return this.currentDS.getCurrentRowID();return 0;};Spry.Data.NestedXMLDataSet.prototype.setCurrentRowNumber=function(rowNumber)
{if(this.currentDS)
return this.currentDS.setCurrentRowNumber(rowNumber);};Spry.Data.NestedXMLDataSet.prototype.findRowsWithColumnValues=function(valueObj,firstMatchOnly,unfiltered)
{if(this.currentDS)
return this.currentDS.findRowsWithColumnValues(valueObj,firstMatchOnly,unfiltered);return firstMatchOnly?null:[];};Spry.Data.NestedXMLDataSet.prototype.setColumnType=function(columnNames,columnType)
{if(columnNames)
{var dsArr=this.nestedDataSets;var dsArrLen=dsArr.length;for(var i=0;i<dsArrLen;i++)
dsArr[i].dataSet.setColumnType(columnNames,columnType);}};Spry.Data.NestedXMLDataSet.prototype.getColumnType=function(columnName)
{if(this.currentDS)
return this.currentDS.getColumnType(columnName);return"string";};Spry.Data.NestedXMLDataSet.prototype.distinct=function(columnNames)
{if(columnNames)
{var dsArr=this.nestedDataSets;var dsArrLen=dsArr.length;for(var i=0;i<dsArrLen;i++)
dsArr[i].dataSet.distinct(columnNames);}};Spry.Data.NestedXMLDataSet.prototype.getSortColumn=function(){if(this.currentDS)
return this.currentDS.getSortColumn();return"";};Spry.Data.NestedXMLDataSet.prototype.getSortOrder=function(){if(this.currentDS)
return this.currentDS.getSortOrder();return"";};Spry.Data.NestedXMLDataSet.prototype.sort=function(columnNames,sortOrder)
{if(columnNames)
{var dsArr=this.nestedDataSets;var dsArrLen=dsArr.length;for(var i=0;i<dsArrLen;i++)
dsArr[i].dataSet.sort(columnNames,sortOrder);}};Spry.Data.NestedXMLDataSet.prototype.filterData=function(filterFunc,filterOnly)
{if(columnNames)
{var dsArr=this.nestedDataSets;var dsArrLen=dsArr.length;for(var i=0;i<dsArrLen;i++)
dsArr[i].dataSet.filterData(filterFunc,filterOnly);}};Spry.Data.NestedXMLDataSet.prototype.filter=function(filterFunc,filterOnly)
{if(columnNames)
{var dsArr=this.nestedDataSets;var dsArrLen=dsArr.length;for(var i=0;i<dsArrLen;i++)
dsArr[i].dataSet.filter(filterFunc,filterOnly);}};