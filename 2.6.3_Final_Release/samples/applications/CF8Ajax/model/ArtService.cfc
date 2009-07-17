<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	March 05 2008
Description :
----------------------------------------------------------------------->
<cfcomponent displayname="ArtService" output="false" extends="BaseService">
	
	<cffunction name="getAllArtist" output="false" access="public" returntype="query">
		<cfargument name="ARTISTID" type="numeric" required="false" default="0">
		
		<cfset var qryAllArtist = "" />
		<cfquery name="qryAllArtist" datasource="#variables.dsn#">		
			SELECT    ART.ARTISTID, ART.ARTNAME, ARTISTS.FIRSTNAME, ARTISTS.LASTNAME, ARTISTS.ADDRESS, ARTISTS.CITY, ARTISTS.STATE, ARTISTS.POSTALCODE, ARTISTS.EMAIL, ARTISTS.PHONE, ARTISTS.FAX, ARTISTS.THEPASSWORD, ART.DESCRIPTION, ART.PRICE, ART.LARGEIMAGE, ART.MEDIAID, ART.ISSOLD
			FROM      APP.ART, APP.ARTISTS 
			WHERE     APP.ART.ARTISTID = APP.ARTISTS.ARTISTID
			<cfif arguments.ARTISTID GT 0>
			AND ART.ARTISTID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ARTISTID#">
			</cfif>
		</cfquery>
		
		<cfreturn qryAllArtist>
	</cffunction>
	
	<cffunction name="getArtist" output="false" access="public" returntype="query">
		<cfargument name="ARTISTID" type="numeric" required="false" default="0">
		
		<cfset var qryAllArtist = "" />
		<cfquery name="qryAllArtist" datasource="#variables.dsn#">		
			SELECT DISTINCT * FROM ARTISTS
			<cfif arguments.ARTISTID GT 0>
			WHERE ARTISTID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ARTISTID#">
			</cfif>
		</cfquery>
		
		<cfreturn qryAllArtist>
	</cffunction>
	
	<cffunction name="getFindByName" output="false" access="public" returntype="query">
		<cfargument name="SearchString" type="string" required="true">
		
		<cfset var qryAllArtist = "" />
		<cfquery name="qryAllArtist" datasource="#variables.dsn#">		
			SELECT    ART.ARTISTID, ART.ARTNAME, ARTISTS.FIRSTNAME, ARTISTS.LASTNAME, ARTISTS.ADDRESS, ARTISTS.CITY, ARTISTS.STATE, ARTISTS.POSTALCODE, ARTISTS.EMAIL, ARTISTS.PHONE, ARTISTS.FAX, ARTISTS.THEPASSWORD, ART.DESCRIPTION, ART.PRICE, ART.LARGEIMAGE, ART.MEDIAID, ART.ISSOLD
			FROM      APP.ART, APP.ARTISTS 
			WHERE     APP.ART.ARTISTID = APP.ARTISTS.ARTISTID
			<!--- Search in first_name of last_name --->
			AND lower(ART.ARTNAME) LIKE  '%#lCase(arguments.SearchString)#%'
		</cfquery>
		
		<cfreturn qryAllArtist>
	</cffunction>
	
</cfcomponent>
