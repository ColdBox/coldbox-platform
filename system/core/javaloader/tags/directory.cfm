<!--- Document Information -----------------------------------------------------

Title:      directory.cfm

Author:     Mark Mandel
Email:      mark@compoundtheory.com

Website:    http://www.compoundtheory.com

Purpose:    Tag proxy for cf7 compilation

Usage:

Modification Log:

Name			Date			Description
================================================================================
Mark Mandel		18/01/2010		Created

------------------------------------------------------------------------------->

<cfif structKeyExists(attributes, "name")>
	<cfset attributes.name = "caller." & attributes.name>
</cfif>
<cfdirectory attributecollection="#attributes#" />
