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
		<cfset setpluginVersion("1.0")>
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
    <cffunction name="getRowNumber" access="public" returntype="numeric" output="false" hint="Returns the row number of the first match" >
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
	
</cfcomponent>
