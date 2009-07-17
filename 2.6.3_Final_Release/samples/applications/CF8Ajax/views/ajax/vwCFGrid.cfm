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
<!--- 
CF8 cfgrid using ajax 
cfform is mendatory for using ajax stuff
--->
<cfform>
    <cfgrid name = "FirstGrid" 
			format="html"
	        font="Tahoma" 
			fontsize="12"
			pageSize="10"
			width="100%"	
    		preservePageOnSort="yes"		
	        bind="cfc:#rc.locColdBoxProxy#.getAllArtist({cfgridpage},{cfgridpagesize},{cfgridsortcolumn},{cfgridsortdirection})" >
		    <cfgridcolumn name="ARTISTID"	display="true" header="ARTIST ID"/>
			<cfgridcolumn name="ARTNAME"	display="true" header="Name"/>
			<cfgridcolumn name="FIRSTNAME"	display="true" header="First Name"/>
			<cfgridcolumn name="LASTNAME"	display="true" header="Last Name"/>
			<cfgridcolumn name="EMAIL"		display="true" header="Email"/>
    </cfgrid>
</cfform>
