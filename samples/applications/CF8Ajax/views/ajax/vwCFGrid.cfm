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
	        bind="cfc:#rc.locColdBoxProxy#.getData({cfgridpage},{cfgridpagesize},{cfgridsortcolumn},{cfgridsortdirection})" >
		    <cfgridcolumn name="idt" display=true header="Employee ID"/>
			<cfgridcolumn name="fname" display=true header="First Name"/>
			<cfgridcolumn name="lname" display=true header="Last Name"/>
    </cfgrid>
</cfform>
