<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	August 21, 2006
Description :
	This is a query helper plugin.
----------------------------------------------------------------------->
<cfcomponent hint="A query helper plugin."
			 extends="coldbox.system.Plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="QueryHelper" output="false">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			super.init(arguments.controller);
			
			// Plugin Properties
			setpluginName("Query Helper");
			setpluginVersion("1.5");
			setpluginDescription("This is a query helper plugin");
			setpluginAuthor("Sana Ullah");
			setpluginAuthorURL("http://www.coldbox.org");

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- FILTER A QUERY --->
	<cffunction name="filterQuery" access="public" returntype="query" hint="Filters a query by the given value" output="false">
		<!--- ************************************************************* --->
		<cfargument name="qry" 			type="query" 	required="true" hint="Query to filter">
		<cfargument name="field" 		type="string" 	required="true" hint="Field to filter on">
		<cfargument name="value" 		type="string" 	required="true" hint="Value to filter on">
		<cfargument name="cfsqltype" 	type="string" 	required="false" default="cf_sql_varchar" hint="The cf sql type of the value.">
		<cfargument name="list" 		type="boolean"  required="false" default="false" hint="Whether to do a where IN list."/>
		<!--- ************************************************************* --->
		<cfset var qryNew = QueryNew("")>
		<cfquery name="qryNew" dbtype="query">
			SELECT *
				FROM arguments.qry
				<cfif arguments.list>
				WHERE #trim(arguments.field)# IN (<cfqueryparam cfsqltype="#trim(arguments.cfsqltype)#" value="#trim(arguments.value)#" list="true">)
				<cfelse>
				WHERE #trim(arguments.field)# = <cfqueryparam cfsqltype="#trim(arguments.cfsqltype)#" value="#trim(arguments.value)#">
				</cfif>
		</cfquery>
		<cfreturn qryNew>
	</cffunction>
	
	<!--- Sort a query --->
	<cffunction name="sortQuery" access="public" returntype="query" hint="Sorts a query by the given field" output="false">
		<!--- ************************************************************* --->
		<cfargument name="qry" 			type="query" 	required="yes" hint="Query to sort">
		<cfargument name="sortBy" 		type="string" 	required="yes" hint="Sort by column(s)">
		<cfargument name="sortOrder" 	type="string" 	required="no" default="ASC" hint="ASC/DESC">
		<!--- ************************************************************* --->
		<cfset var qryNew = QueryNew("")>
		
		<!--- Validate sortOrder --->
		<cfif not reFindnocase("(asc|desc)", arguments.sortOrder)>
			<cfthrow type="QueryHelper.InvalidSortOrderException" message="The sortOrder you sent in: #arguments.sortOrder# is not valid. Valid sort orders are ASC|DESC">
		</cfif>
		
		<cfquery name="qryNew" dbtype="query">
			SELECT *
				FROM arguments.qry
				ORDER BY #arguments.sortBy# #arguments.sortOrder#
		</cfquery>
		
		<cfreturn qryNew>
	</cffunction>
	
	<!--- Sort a query --->
	<cffunction name="sortQueryNoCase" access="public" returntype="query" hint="Sorts a query by the given field non-case" output="false">
		<!--- ************************************************************* --->
		<cfargument name="qry" 			type="query" 	required="yes" hint="Query to sort">
		<cfargument name="sortBy" 		type="string" 	required="yes" hint="Sort by column">
		<cfargument name="sortOrder" 	type="string" 	required="no" default="ASC" hint="ASC/DESC">
		<!--- ************************************************************* --->
		<cfset var qryNew = QueryNew("")>
		
		<!--- Validate sortOrder --->
		<cfif not reFindnocase("(asc|desc)", arguments.sortOrder)>
			<cfthrow type="QueryHelper.InvalidSortOrderException" message="The sortOrder you sent in: #arguments.sortOrder# is not valid. Valid sort orders are ASC|DESC">
		</cfif>
		
		<cfquery name="qryNew" dbtype="query">
			SELECT *, UPPER(#trim(arguments.sortBy)#) as sortBy
				FROM arguments.qry
				ORDER BY sortBy #arguments.sortOrder#
		</cfquery>
		
		<cfreturn qryNew>
	</cffunction>

	<!--- ********************************************************************* ---> 
    <!--- Returns an array of the values in the given column                    --->
	<!--- QoQ is case sensitive so use same columns name as in query            --->
	<!--- don't use local word ... this is reserved word in QoQ                 --->
    <!-----------------------------------------------------------------------------> 
    <cffunction name="getColumnArray" access="public" returntype="any" output="false" hint="Returns an array of the values">
        <cfargument name="qry"			type="query"	required="true" hint="cf query" /> 
        <cfargument name="ColumnName"	type="string"	required="true" hint="column name" />
        <cfscript>
            var arValues = ArrayNew(1);
            var i = 0;
             
            if( arguments.qry.recordcount ){
                //arrayResize( arValues, arguments.qry.recordcount );
                
                for( i = 1; i LTE arguments.qry.recordcount; i =i + 1 ){
                    ArrayAppend(arValues, arguments.qry[arguments.ColumnName][i]);
                }
            }            
            return arValues;
        </cfscript>
    </cffunction>
	
	<!--- ********************************************************************* ---> 
    <!--- Pass Column/s Name to get total/count of distinct values              --->
	<!--- QoQ is case sensitive so use same columns name as in query            --->
    <!----------------------------------------------------------------------------->
    <cffunction name="getCountDistinct" access="public" returntype="numeric" output="false" hint="Returns total/count disninct values"> 
        <cfargument name="qry"			type="query"	required="true"  hint="cf query" />
        <cfargument name="ColumnName"	type="string"	required="true"  hint="column/s name" /> 
        <cfset var qryCount = "" />
		
        <cfquery name="qryCount" dbtype="query">
            SELECT DISTINCT #arguments.ColumnName# 
            FROM    arguments.qry
        </cfquery>
		<cfreturn qryCount.RecordCount />
    </cffunction>
	
    <!--- ********************************************************************* --->
    <!--- Returns the row number of the first match, or 0 if no match or exists --->
	<!--- QoQ is case sensitive so use same columns name as in query            ---> 
    <!----------------------------------------------------------------------------->
    <cffunction name="getRowNumber" access="public" returntype="numeric" output="false" hint="Returns the row number of the first match">
        <cfargument name="qry"			type="query"	required="true" hint="cf query" />
		<cfargument name="ColumnValue"	type="string"	required="true" hint="column value" />
        <cfargument name="ColumnName"	type="string"	required="true" hint="column name" />
        <cfscript>
            var sTestVal = "";
            var sThisVal = "";
            var i = 0;
            
            sTestVal = trim(arguments.ColumnValue);
             
            for( i = 1; i LTE arguments.qry.RecordCount; i = i + 1 ){
                sThisVal = trim(arguments.qry[arguments.ColumnName][i]);
               
                if( sThisVal EQ sTestVal ){
                    return i;
                }
            }
            return 0;
        </cfscript>
    </cffunction> 	
	
	<!--- ********************************************************************* --->
    <!---  similar to inner join for QofQ's                                     --->
    <!----------------------------------------------------------------------------->
    <cffunction name="doInnerJoin" access="public" returntype="query" output="false" hint="Return inner-joined Query"> 
        <cfargument name="qryLeft"		type="query" required="true" />
        <cfargument name="qryRight"		type="query" required="true" />
        <cfargument name="LeftJoinColumn"	type="string" required="true"  hint="the column name, not the value of column" /> 
        <cfargument name="RightJoinColumn"	type="string" required="true"  hint="the column name, not the value of column" />
        <cfargument name="OrderByElement"	type="string" required="false" default="" />
		<cfargument name="CaseSensitive"	type="boolean" required="false" default="false" />
		<cfscript>
			var qry1 = arguments.qryLeft;
		    var qry2 = arguments.qryRight;
		    var lstRightColumns	= "";
		    var lstLeftColumns	= "";
		    var lstCols			= "";
		    var QryReturn		= "";
		    var valueExists		= "";
		    var bProceed		= false;
		    var i = 0;	
		try{	
		    // get all the fields in qry_right which are not in qry_left
		    lstRightColumns	= getUnMatchedElements( FirstList=qry1.ColumnList , secondList=qry2.ColumnList );
		    lstLeftColumns	= qry1.ColumnList;
		             
		    // full column list
		    lstCols = listAppend( lstLeftColumns, lstRightColumns );
		            
		    QryReturn = queryNew( lstCols );

		    for( i = 1; i LTE qry1.recordcount; i = i + 1 ){
		    	bProceed = false;
		    	
		        if(CaseSensitive){
		        	valueExists = ListFind(ArrayToList(getColumnArray(qry2,arguments.RightJoinColumn)),trim(qry1[arguments.LeftJoinColumn][i]));
		        	if(valueExists GT 0){
		        		bProceed = true;
		        	}
		        }
		        else{
		        	valueExists = ListFindNoCase(ArrayToList(getColumnArray(qry2,arguments.RightJoinColumn)),trim(qry1[arguments.LeftJoinColumn][i]));
		        	if(valueExists GT 0){
		        		bProceed = true;
		        	}
		        }
		    	// if the columns match	        
		        if( bProceed ){
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
		                                     FromRowNumber = valueExists,
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
		    
		 }catch(Any e){
			$throw("Error in doInnerJoin():","#e.Detail#<br>#e.message#","QueryHelper.InvalidInnerJoinException");
		 }
		</cfscript>
		
    </cffunction>
	
	<!--- ********************************************************************* --->
    <!--- similar to left outer join for QofQ's                                 --->
    <!----------------------------------------------------------------------------->
    <cffunction name="doLeftOuterJoin" access="public" returntype="query" output="false" hint="Return left outer-joined Query"> 
        <cfargument name="qryLeft"		type="query" required="true" />
        <cfargument name="qryRight"		type="query" required="true" />
        <cfargument name="LeftJoinColumn"	type="string" required="true" hint="the column name, not the value of column" /> 
        <cfargument name="RightJoinColumn"	type="string" required="true" hint="the column name, not the value of column" />
        <cfargument name="OrderByElement"	type="string" required="false" default="" />
		<cfargument name="CaseSensitive"	type="boolean" required="false" default="false" />
		<cfscript>
			var qry1 = arguments.qryLeft;
		    var qry2 = arguments.qryRight;
		    var lstRightColumns	= "";
		    var lstLeftColumns	= "";
		    var lstCols			= "";
		    var QryReturn		= "";
		    var valueExists		= "";
		    var ToRowNumber		= "";
			var ArrayCols		= ArrayNew(1);
		    var i = 0;
				
		try{	
		    // get all the fields in qry_right which are not in qry_left
		    lstRightColumns	= getUnMatchedElements( FirstList=qry1.ColumnList , secondList=qry2.ColumnList );
		    lstLeftColumns	= qry1.ColumnList;
		             
		    // full column list
		    lstCols = listAppend( lstLeftColumns, lstRightColumns );
		            
		    QryReturn = queryNew( lstCols );
			// add additional columns to qry1, these columns may have null value.
			for( i = 1; i LTE ListLen(lstRightColumns); i = i + 1 ){
				QueryAddColumn(qry1, ListGetAt(lstRightColumns, i), ArrayCols);
			}
					
		    for( i = 1; i LTE qry1.recordcount; i = i + 1 ){
		    	 // add a row in query
		         QueryAddRow( QryReturn );
		    	
		        if(CaseSensitive){
		        	valueExists = ListFind(ArrayToList(getColumnArray(qry2,arguments.RightJoinColumn)),trim(qry1[arguments.LeftJoinColumn][i]));
		        }
		        else{
		        	valueExists = ListFindNoCase(ArrayToList(getColumnArray(qry2,arguments.RightJoinColumn)),trim(qry1[arguments.LeftJoinColumn][i]));
		        }
		        
		    	// if the columns match	        
		        if( valueExists GT 0 ){
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
		                                     FromRowNumber = valueExists,
		                                     ToRowNumber = QryReturn.RecordCount 
		                                 );
		        }
		       else{
		       		//get value into return-query
		       		if(QryReturn.RecordCount EQ 0){
		       			ToRowNumber = 1;
		       		}
		       		else{
		       			ToRowNumber = QryReturn.RecordCount;
		       		}
		       		
		            QryReturn = QrySetCell(	qryFrom = qry1, 
		                                    qryTo = QryReturn,
		                                    ArrayCols = ListToArray(lstCols),
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
		    
		 }catch(Any e){
			$throw("Error in doLeftOuterJoin():","#e.Detail#<br>#e.message#","QueryHelper.InvalidInnerJoinException");
		 }
		</cfscript>
		
    </cffunction>
	
	<!--- ********************************************************************* --->
    <!--- Append From Query1 To Query2                                          --->
    <!----------------------------------------------------------------------------->
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
        }Catch(Any e){
        	$throw("Error in doQueryAppend():","#e.Detail#<br>#e.message#","QueryHelper.InvalidQueryAppendException");
        }    
           return QryReturn;
        </cfscript>
    </cffunction>
	
	<!--- Filter by Null --->
	<cffunction name="filterNull" access="public" returntype="query" hint="Filters a query by NULL" output="false">
		<!--- ************************************************************* --->
		<cfargument name="qry"        type="query"    required="yes" hint="Query to filter">
		<cfargument name="field"      type="string"   required="yes" hint="Field to filter on">
		<cfargument name="null"       type="string"   required="no" default="NULL" hint="NULL by default, also accepts NOT NULL">
		<!--- ************************************************************* --->
		<cfset var qryNew = QueryNew("")>
		<cfquery name="qryNew" dbtype="query">
		   SELECT *
		      FROM arguments.qry
		      WHERE #trim(arguments.field)# IS #arguments.null#
		</cfquery>
		<cfreturn qryNew>	
	</cffunction>
	
	<!--- querySim --->
	<cffunction name="querySim" access="public" returntype="query" output="false" hint="First line are the query columns separated by commas. Then do a consecuent rows separated by line breaks separated by | to denote columns." >
		<cfargument name="queryData"  type="string" required="true" hint="The data to create queries">
		<cfscript>
		/**
		* Accepts a specifically formatted chunk of text, and returns it as a query object.
		* v2 rewrite by Jamie Jackson
		*
		* @param queryData      Specifically format chunk of text to convert to a query. (Required)
		* @return Returns a query object.
		* @author Bert Dawson (bert@redbanner.com)
		* @version 2, December 18, 2007
		* 
		*/
		var fieldsDelimiter="|";
	    var colnamesDelimiter=",";
	    var listOfColumns="";
	    var tmpQuery="";
	    var numLines="";
	    var cellValue="";
	    var cellValues="";
	    var colName="";
	    var lineDelimiter=chr(10) & chr(13);
	    var lineNum=0;
	    var colPosition=0;
	
	    // the first line is the column list, eg "column1,column2,column3"
	    listOfColumns = Trim(ListGetAt(queryData, 1, lineDelimiter));
	    
	    // create a temporary Query
	    tmpQuery = QueryNew(listOfColumns);
	
	    // the number of lines in the queryData
	    numLines = ListLen(queryData, lineDelimiter);
	    
	    // loop though the queryData starting at the second line
	    for(lineNum=2; lineNum LTE numLines; lineNum = lineNum + 1) {
	     cellValues = ListGetAt(queryData, lineNum, lineDelimiter);
	
	        if (ListLen(cellValues, fieldsDelimiter) IS ListLen(listOfColumns,",")) {
	            QueryAddRow(tmpQuery);
	            for (colPosition=1; colPosition LTE ListLen(listOfColumns); colPosition = colPosition + 1){
	                cellValue = Trim(ListGetAt(cellValues, colPosition, fieldsDelimiter));
	                colName = Trim(ListGetAt(listOfColumns,colPosition));
	                QuerySetCell(tmpQuery, colName, cellValue);
	            }
	        }
	    }
	    
	    return( tmpQuery );
		</cfscript>
	</cffunction>
	
	<!--- getCSV --->
	<cffunction name="getCSV" access="public" returntype="string" output="false" hint="returns query in delimited text file format">
		<cfargument name="qry"  	 type="query"  required="true" hint="query to return as a delimited text file" />
		<cfargument name="delimiter" type="string" required="false" default="," hint="delimiter" />
		<cfscript>
        var i = 0;
        var rptQry = arguments.qry;
        var delim = arguments.delimiter;
        var cols = 0;
        var col = 0;
        var csv = 0;
        var c = 0;
		var line = "";
		</cfscript>
		
		<!--- set columns as first row in the csv --->
		<cfset cols = lcase(rptQry.columnList)>
		<cfset csv = cols & chr(13) & chr(10)>
		
		<!--- return data rows in csv format --->
		<cfset i = 0>
		<cfloop query="rptQry">
			<cfset i = i + 1>
			<cfset line = "">
			<cfset c = 0>
			<cfloop list="#cols#" index="col">
				<cfif c gt 0>
					<cfset line = line & ",">
				</cfif>
				<cfif findNoCase("date",col)>
					<cfset line = line & DateFormat(replace(rptQry[col][i],delim,"","all"))>
				<cfelse>
					<cfset line = line & replace(rptQry[col][i],delim,"","all")>
				</cfif>
				<cfset c = c + 1>
			</cfloop>
			<cfset csv = csv & line & chr(13) & chr(10)>	
		</cfloop>
		
		<cfreturn csv>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- ********************************************************************* --->
	<!--- Returns element which are only present in second-list                 --->
	<!----------------------------------------------------------------------------->
	<cffunction name="getUnMatchedElements" access="private" returntype="string" output="false" hint="Returns element which are only present in second-list">
		<cfargument name="FirstList"  type="string" required="true" hint="first list which be compared to second list" />
		<cfargument name="secondList" type="string" required="true" hint="second list which be compared from first list" />
		<cfscript>
            var i = 0;
            var sReturn	= "";
            var ArrayCols = "";
        try{ 
        	ArrayCols = ListToArray(arguments.secondList);
            // loop over each column and append to list.
            for( i = 1; i LTE ArrayLen(ArrayCols); i = i + 1 ){
                // get the value of column
                if(listFindNoCase( arguments.FirstList, ArrayCols[i] ) EQ 0){
                	sReturn = listAppend( sReturn, ArrayCols[i] );
                }
            }
            // Returns element which are only present in second-list
            return sReturn;
            
         }Catch(Any e){
			$throw("Error in getUnMatchedElements():","#e.Detail#<br>#e.message#","QueryHelper.InvalidElementLoopException");
		 }
        </cfscript>
		
	</cffunction>
	<!--- ********************************************************************* --->
	
	<!--- ********************************************************************* --->
	<!--- Returns unique elements from two list                                 --->
	<!----------------------------------------------------------------------------->
	<cffunction name="getUniqueElements" access="private" returntype="any" output="false" hint="Returns unique elements from two list">
		<cfargument name="FirstList"  type="string" required="true" hint="first list which be compared to second list" />
		<cfargument name="secondList" type="string" required="true" hint="second list which be compared from first list" />
		<cfscript>
            var i = 0;
            var sReturn	= "";
            var CombinedList = arguments.FirstList;
        try{ 
        	CombinedList = ListAppend(CombinedList,arguments.secondList);
            // loop over each column and insert value into query
            for( i = 1; i LTE ListLen(CombinedList); i = i + 1 ){
                // get the value of column
                if(listFindNoCase( sReturn, listGetAt(CombinedList, i) ) EQ 0){
                	sReturn = ListAppend( sReturn, listGetAt(CombinedList, i) );
                }
            }
            // return unique list of elements
            return sReturn;
            
         }Catch(Any e){
			$throw("Error in getUniqueElements():","#e.Detail#<br>#e.message#","QueryHelper.InvalidElementLoopException");
		 }
        </cfscript>
		
	</cffunction>
	<!--- ********************************************************************* --->
	
	<!--- ********************************************************************* --->
    <!---copy value in a row from qryFrom to qryTo without adding additional row--->
    <!-----------------------------------------------------------------------------> 
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
                ColumValue	= arguments.qryFrom[ColumName][arguments.FromRowNumber];
                // set it in the new row
                if( structkeyExists( QryReturn, arguments.ArrayCols[i] ) ){
                    QuerySetCell( QryReturn, ColumName, ColumValue , arguments.ToRowNumber );
                }
            }
            // return updated query
            return QryReturn;
            
          }Catch(Any e){
			$throw("Error in QrySetCell():","#e.Detail#<br>#e.message#","QueryHelper.InvalidQrySetCellException");
		 }
        </cfscript>
		 
    </cffunction>
	<!--- ********************************************************************* --->
	
</cfcomponent>

