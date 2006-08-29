<cfsetting enablecfoutputonly=true>
<!---
	Name         : datacol.cfm
	Author       : Raymond Camden 
	Created      : September 7, 2004
	Last Updated : September 7, 2004
	History      : 
	Purpose		 : Allows you to specify settings for datatable 
--->

<cfassociate baseTag="cf_datatable">

<cfparam name="attributes.colname" type="string" default="">
<cfparam name="attributes.name" type="string" default="#attributes.colname#">
<cfparam name="attributes.label" type="string" default="#attributes.name#">

<cfif attributes.name is "">
	<cfthrow message="dataCol: Name must not be an empty string.">
</cfif>

<cfsetting enablecfoutputonly=false>

<cfexit method="EXITTAG">
