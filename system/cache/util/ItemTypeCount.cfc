<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Description :
	A simple data holder CFC for coldbox application caches

----------------------------------------------------------------------->
<cfcomponent output="false" hint="A simple data holder CFC for coldbox application caches, item type counts needed for creating cool reports">

	<cfscript>
		this.plugins  		= 0;
		this.customPlugins	= 0;
		this.handlers 		= 0;
		this.interceptors	= 0;
		this.events			= 0;
		this.views			= 0;
		this.other			= 0;
	</cfscript>

</cfcomponent>