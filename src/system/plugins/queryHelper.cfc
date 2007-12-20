<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	August 21, 2006
Description :
	This is a query helper plugin.

Modification History:
01/30/2007 - Created

qry1, qry2 joined on column name ('fname')
var InnerJoined = getPlugin("queryHelper","false").doInnerJoin(qry1,qry2,"fname","fname");
----------------------------------------------------------------------->
<cfcomponent name="queryHelper"
			 hint="A query helper plugin."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

	<cffunction name="init" access="public" returntype="queryHelper" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("Query Helper")>
		<cfset setpluginVersion("1.5")>
		<cfset setpluginDescription("This is a query helper plugin.")>
		<cfreturn this>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="filterQuery" access="public" returntype="query" hint="Filters a query by the given value" output="false">
		<!--- ************************************************************* --->
		<cfargument name="qry" 			type="query" 	required="yes" hint="Query to filter">
		<cfargument name="field" 		type="string" 	required="yes" hint="Field to filter on">
		<cfargument name="value" 		type="string" 	required="yes" hint="Value to filter on">
		<cfargument name="cfsqltype" 	type="string" 	required="no" default="cf_sql_varchar" hint="The cf sql type of the value.">
		<!--- ************************************************************* --->
		<cfset var qryNew = QueryNew("")>
		<cfquery name="qryNew" dbtype="query">
			SELECT *
				FROM arguments.qry
				WHERE #trim(arguments.field)# = <cfqueryparam cfsqltype="#trim(arguments.cfsqltype)#" value="#trim(arguments.value)#">
		</cfquery>
		<cfreturn qryNew>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="sortQuery" access="public" returntype="query" hint="Sorts a query by the given field" output="false">
		<!--- ************************************************************* --->
		<cfargument name="qry" 			type="query" 	required="yes" hint="Query to sort">
		<cfargument name="sortBy" 		type="string" 	required="yes" hint="Sort by column(s)">
		<cfargument name="sortOrder" 	type="string" 	required="no" default="ASC" hint="ASC/DESC">
		<!--- ************************************************************* --->
		<cfset var qryNew = QueryNew("")>
		<!--- Validate sortOrder --->
		<cfif not reFindnocase("(asc|desc)", arguments.sortOrder)>
			<cfthrow type="Framework.plugin.queryHelper.InvalidSortOrderException" message="The sortOrder you sent in: #arguments.sortOrder# is not valid. Valid sort orders are ASC|DESC">
		</cfif>
		<cfquery name="qryNew" dbtype="query">
			SELECT *
				FROM arguments.qry
				ORDER BY #trim(Arguments.SortBy)# #Arguments.SortOrder#
		</cfquery>
		<cfreturn qryNew>
	</cffunction>

	<!--- ************************************************************* --->
	
	<!--- ************************************************************* ---> 
    <!--- Returns an array of the values in the given column            --->
	<!--- QoQ is case sensitive so use same columns name as in query    --->
	<!--- don't use local word ... this is reserved word in QoQ         --->
    <!---------------------------------------------------------------------> 
    <cffunction name="getColumnArray" access="public" returntype="array" output="false" hint="Returns an array of the values">
        <cfargument name="qry"			type="query"	required="true" hint="cf query" /> 
        <cfargument name="ColumnName"	type="string"	required="true" hint="column name" />
        <cfscript>
            var stPrivate = structNew();
            var i = 0;
             
            stPrivate.arValues = arrayNew(1);
            if( arguments.qry.recordcount ){
                arrayResize( stPrivate.arValues, arguments.qry.recordcount );
                
                for( i = 1; i LTE arguments.qry.recordcount; i =i + 1 ){
                    stPrivate.arValues[i] = arguments.qry[arguments.ColumnName][i];
                }
            }            
            return stPrivate.arValues ;
        </cfscript>
    </cffunction>
	<!--- ************************************************************* --->
	
	<!--- ************************************************************* ---> 
    <!--- Pass Column/s Name to get total/count of distinct values      --->
	<!--- QoQ is case sensitive so use same columns name as in query    --->
    <!--------------------------------------------------------------------->
    <cffunction name="getCountDistinct" access="public" returntype="numeric" output="false" hint="Returns total/count disninct values"> 
        <cfargument name="qry"			type="query"	required="true"  hint="cf query" />
        <cfargument name="ColumnName"	type="string"	required="true"  hint="column/s name" /> 
        <cfset var stPrivate = structNew() />
		
        <cfquery name="stPrivate.qryCount" dbtype="query">
            SELECT DISTINCT #arguments.ColumnName# 
            FROM    arguments.qry
        </cfquery>
		<cfreturn stPrivate.qryCount.RecordCount />
    </cffunction>
	<!--- ************************************************************* --->
	
    <!--- ********************************************************************* --->
    <!--- Returns the row number of the first match, or 0 if no match or exists --->
	<!--- QoQ is case sensitive so use same columns name as in query            ---> 
    <!----------------------------------------------------------------------------->
    <cffunction name="getRowNumber" access="public" returntype="numeric" output="false" hint="Returns the row number of the first match">
        <cfargument name="qry"			type="query"	required="true" hint="cf query" />
		<cfargument name="ColumnValue"	type="string"	required="true" hint="column value" />
        <cfargument name="ColumnName"	type="string"	required="true" hint="column name" />
        <cfscript>
            var stPrivate = structNew();
            var i = 0;
            
            stPrivate.sTestVal = trim(arguments.ColumnValue);
             
            for( i = 1; i LTE arguments.qry.RecordCount; i = i + 1 ){
                stPrivate.sThisVal = trim(arguments.qry[arguments.ColumnName][i]);
               
                if( stPrivate.sThisVal EQ stPrivate.sTestVal ){
                    return i;
                }
            }

            return 0;
        </cfscript>
    </cffunction> 	
	<!--- ********************************************************************* --->
	
	<!--- ********************************************************************* --->
	<!--------------------------------------------->
    <!---  similar to inner join for QofQ's     --->
    <!--------------------------------------------->
    <cffunction name="doInnerJoin" access="public" returntype="query" output="false" hint="Return inner-joined Query"> 
        <cfargument name="qryLeft"		type="query" required="true" />
        <cfargument name="qryRight"		type="query" required="true" />
        <cfargument name="LeftJoinColumn"	type="string" required="true" /> 
        <cfargument name="RightJoinColumn"	type="string" required="true" />
        <cfargument name="OrderByElement"	type="string" required="false" default="" /> 
		<cfscript>
			var qry1 = arguments.qryLeft;
		    var qry2 = arguments.qryRight;
		    var lstRightColumns	= "";
		    var lstLeftColumns	= "";
		    var lstCols			= "";
		    var QryReturn		= "";
		    var qryTmpJoin		= "";
		    var i = 0;	
		try{	
		    // get all the fields in qry_right that are not in qry_left
		    lstRightColumns	= getUnMatchedElements( FirstList=qry1.ColumnList , secondList=qry2.ColumnList );
		    lstLeftColumns	= qry1.ColumnList;
		             
		    // full column list
		    lstCols = listAppend( lstLeftColumns, lstRightColumns );
		            
		    QryReturn = queryNew( lstCols );

		    for( i = 1; i LTE qry1.recordcount; i = i + 1 ){
		        // if the columns match
		        if( qry1[arguments.LeftJoinColumn ][i] EQ qry2[arguments.RightJoinColumn][i] ){
		            // add a row in query
		            QueryAddRow( QryReturn );
		            //get value into return-query
		            QryReturn = QrySetCell(	qryFrom = qry1, 
		                                    qryTo = QryReturn,
		                                    ArrayCols = ListToArray(lstLeftColumns),
		                                    FromRowNumber = i,
		                                    ToRowNumber = QryReturn.RecordCount 
		                                    );
		            //get value into return-query                        
		            QryReturn = QrySetCell(  qryFrom = qry2, 
		                                     qryTo = QryReturn,
		                                     ArrayCols = ListToArray(lstRightColumns),
		                                     FromRowNumber = i,
		                                     ToRowNumber = QryReturn.RecordCount 
		                                 );
		        }
		    }
		    if(len(arguments.OrderByElement)){
		    	return sortQuery(qry = QryReturn, sortBy = arguments.OrderByElement );
		    }
		    else{
		    	return QryReturn;
		    }
		    
		 }Catch(Any e){
			throw("Error in doInnerJoin():","#e.Detail#<br>#e.message#","Framework.plugins.queryHelper.InvalidInnerJoinException");
		 }
		</cfscript>
		
    </cffunction>
	<!--- ********************************************************************* --->

	<!--- ********************************************************************* --->
	<!--------------------------------------------->
    <!--- Append From Query1 To Query2          --->
    <!--------------------------------------------->
    <cffunction name="doQueryAppend" access="public" returntype="query" output="false" hint="Append Query1 into Query2"> 
        <cfargument name="qryFrom"	type="query" required="true" hint="Append Query1 into Query2" />
        <cfargument name="qryTo"	type="query" required="true" hint="Query2 will have all record from Query1" />
        
        <cfscript>
            var i = 0;
            var ArrayCols = ListToArray(arguments.qryFrom.ColumnList);
            var QryReturn = Duplicate(arguments.qryTo);
            
        try{
            for( i = 1; i LTE arguments.qryFrom.RecordCount; i = i + 1 ){
                QueryAddRow( QryReturn );
	            //get value into return-query
	            QryReturn = QrySetCell(	qryFrom = arguments.qryFrom, 
	                                    qryTo = QryReturn,
	                                    ArrayCols = ArrayCols,
	                                    FromRowNumber = i,
	                                    ToRowNumber = QryReturn.RecordCount 
	                                    );
            }
        }Catch(An e){
        	throw("Error in doQueryAppend():","#e.Detail#<br>#e.message#","Framework.plugins.queryHelper.InvalidQueryAppendException");
        }    
           return QryReturn;
        </cfscript>
    </cffunction>
	<!--- ********************************************************************* --->
	
	
	<!--- ********************************************************************* --->
	<!--------------------------------------------------------->
	<!---Returns element which are only present in second-list--->
	<!--------------------------------------------------------->
	<cffunction name="getUnMatchedElements" access="private" returntype="string" output="false" hint="Returns element which are only present in second-list">
		<cfargument name="FirstList"  type="string" required="true" hint="first list which be compared to second list" />
		<cfargument name="secondList" type="string" required="true" hint="second list which be compared from first list" />
		<cfscript>
            var i = 0;
            var sReturn	= "";
            var ArrayCols = "";
        try{ 
        	ArrayCols = ListToArray(arguments.secondList);
            // loop over each column and insert value into query
            for( i = 1; i LTE ArrayLen(ArrayCols); i = i + 1 ){
                // get the value of column
                if(listFindNoCase( arguments.FirstList, ArrayCols[i] ) EQ 0){
                	sReturn = listAppend( sReturn, ArrayCols[i] );
                }
            }
            // return copy of the query with the new row appended
            return sReturn;
            
         }Catch(Any e){
			throw("Error in QrySetCell():","#e.Detail#<br>#e.message#","Framework.plugins.queryHelper.InvalidElementLoopException");
		 }
        </cfscript>
		
	</cffunction>
	<!--- ********************************************************************* --->
	
	<!--- ********************************************************************* --->
	<!--------------------------------------------------------->
    <!---copy value in a row from qryFrom to qryTo without adding additional row--->
    <!---------------------------------------------------------> 
    <cffunction name="QrySetCell" access="private" returntype="query" output="false" hint="Insert value into query">
        <cfargument name="qryFrom" type="query" required="true" /> 
        <cfargument name="qryTo" type="query" required="true" />
        <cfargument name="ArrayCols" type="array" required="true" />
		<cfargument name="FromRowNumber" type="numeric" required="true" />
        <cfargument name="ToRowNumber" type="numeric" required="true" />
		
        <cfscript>
            var i = 0;
            var QryReturn	= Duplicate(arguments.qryTo);
            var ColumName	= "";
            var ColumValue	= "";
        try{ 
            // loop over each column and insert value into query
            for( i = 1; i LTE arrayLen(arguments.ArrayCols); i = i + 1 ){
                // get the value of column
                ColumName	= arguments.ArrayCols[i];
                ColumValue	= arguments.qryFrom[ColumName][arguments.FromRowNumber ];
                // set it in the new row
                if( structkeyExists( QryReturn, arguments.ArrayCols[i] ) ){
                    QuerySetCell( QryReturn, ColumName, ColumValue , arguments.ToRowNumber );
                }
            }
            // return updated query
            return QryReturn;
            
          }Catch(Any e){
			throw("Error in QrySetCell():","#e.Detail#<br>#e.message#","Framework.plugins.queryHelper.InvalidQrySetCellException");
		 }
        </cfscript>
		 
    </cffunction>
	<!--- ********************************************************************* --->
	
</cfcomponent>

