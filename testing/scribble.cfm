<cfquery name="q" datasource="cacheTest">
SELECT * 
  FROM cacheBox
 WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="234">
</cfquery>

<cfdump var="#q#">