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

<cfform>
<h2>CFINPUT Auto-Suggest:</h2>
<p>Type <strong>fn</strong> or <strong>q1</strong> </p>
<cfinput type="text"
      name="employeename"
	  autosuggestminlength="2"
      autosuggest="cfc:#rc.locColdBoxProxy#.lookupName({cfautosuggestvalue})">
</cfform>
<p><br><br><br><br><br></p>