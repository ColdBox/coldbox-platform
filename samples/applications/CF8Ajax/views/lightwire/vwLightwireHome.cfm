<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	March 05 2008
Description :	Home Page.
----------------------------------------------------------------------->

<cfoutput>
<h1>#Event.getValue("welcomeMessage")#</h1>
<h5>You are running #getSetting("codename",1)# #getSetting("version",1)# (#getsetting("suffix",1)#)</h5>
</cfoutput>

