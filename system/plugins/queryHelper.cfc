<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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
<!--- example test cases 
<cfscript>
	variables.q1 = queryNew('idt,fname,lname,phone,location');
	variables.q2 = queryNew('idt,fname,lname,phone,location');
	variables.q3 = queryNew('idt,fname,lname,telephone,city');
</cfscript>

<cfloop from="1" to="10" index="i">
	<cfset queryAddRow(q1,1) />
	<cfset querySetCell(q1, 'idt', '#i#')>
	<cfset querySetCell(q1, 'fname', 'fname-q1-#chr(65 + i)#')>
	<cfset querySetCell(q1, 'lname', 'lname-q1-#chr(65 + i)#')>
	<cfset querySetCell(q1, 'phone', 'phone-q1-954-555-5555-#i#')>
	<cfset querySetCell(q1, 'location', 'location-q1-#chr(65 + i)#')>
</cfloop>

<cfloop from="11" to="20" index="i">
	<cfset queryAddRow(q2,1) />
	<cfset querySetCell(q2, 'idt', '#i#')>
	<cfset querySetCell(q2, 'fname', 'fname-q2-#chr(75 + i)#')>
	<cfset querySetCell(q2, 'lname', 'lname-q2-#chr(75 + i)#')>
	<cfset querySetCell(q2, 'phone', 'phone-q2-954-555-5555-#i#')>
	<cfset querySetCell(q2, 'location', 'location-q2-#chr(75 + i)#')>
</cfloop>

<cfloop from="6" to="15" index="i">
	<cfset queryAddRow(q3,1) />
	<cfset querySetCell(q3, 'idt', '#i#')>
	<cfset querySetCell(q3, 'fname', 'fname-q3-#chr(65 + i)#')>
	<cfset querySetCell(q3, 'lname', 'lname-q3-#chr(65 + i)#')>
	<cfset querySetCell(q3, 'telephone', 'phone-q3-954-555-5555-#i#')>
	<cfset querySetCell(q3, 'city', 'location-q3-#chr(65 + i)#')>
</cfloop>

queryPlugin = getPlugin("queryHelper",false)
queryPlugin.doInnerJoin(q1,q3,"idt","idt")
queryPlugin.doLeftOuterJoin(q1,q3,"idt","idt")
--->

<cfcomponent name="queryHelper"
			 hint="A query helper plugin."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="queryHelper" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("Query Helper")>
		<cfset setpluginVersion("1.5")>
		<cfset setpluginDescription("This is a query helper plugin.")>
		<cfreturn this>
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
			<cfthrow type="Framework.plugin.queryHelper.InvalidSortOrderException" message="The sortOrder you sent in: #arguments.sortOrder# is not valid. Valid sort orders are ASC|DESC">
		</cfif>
		<cfquery name="qryNew" dbtype="query">
			SELECT *
				FROM arguments.qry
				ORDER BY #trim(Arguments.SortBy)# #Arguments.SortOrder#
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
			$throw("Error in doInnerJoin():","#e.Detail#<br>#e.message#","ColdBox.plugins.queryHelper.InvalidInnerJoinException");
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
			$throw("Error in doLeftOuterJoin():","#e.Detail#<br>#e.message#","ColdBox.plugins.queryHelper.InvalidInnerJoinException");
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
        	$throw("Error in doQueryAppend():","#e.Detail#<br>#e.message#","ColdBox.plugins.queryHelper.InvalidQueryAppendException");
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
			$throw("Error in getUnMatchedElements():","#e.Detail#<br>#e.message#","ColdBox.plugins.queryHelper.InvalidElementLoopException");
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
			$throw("Error in getUniqueElements():","#e.Detail#<br>#e.message#","ColdBox.plugins.queryHelper.InvalidElementLoopException");
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
			$throw("Error in QrySetCell():","#e.Detail#<br>#e.message#","ColdBox.plugins.queryHelper.InvalidQrySetCellException");
		 }
        </cfscript>
		 
    </cffunction>
	<!--- ********************************************************************* --->
	
</cfcomponent>

