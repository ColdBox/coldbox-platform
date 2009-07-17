<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Sana Ullah
Date        :	March 05 2008
Description :
	This proxy is an inherited coldbox remote proxy used for enabling
	coldbox as a model framework.
----------------------------------------------------------------------->
<!---  CF8 cfgrid using ajax cfform is mendatory for using ajax stuff --->
<h1>cfselect bind to remote cfc:</h1>
<cfoutput>
<cfform name="mycfform">
    <!--- The States selector.  The bindonload attribute is required to fill the selector. --->
    <cfselect name="ArtistID" bind="cfc:#rc.locColdBoxProxy#.getNames()" bindonload="true">
        <option name="0">--select--</option>
    </cfselect>
	
    <!--- <cfselect name="city" bind="cfc:bindFcns.getcities({state})">
        <option name="0">--city--</option>
    </cfselect> --->
</cfform>
</cfoutput>
