<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Sana Ullah
Date        :	March 05 2008
Description : demo for using ajax tabs with event-model and proxy-model.
----------------------------------------------------------------------->
<cflayout type="tab" tabheight="600">
	<cflayoutarea title="Tab 0" selected="true" name="tab0">
		<h1>This is the tab zero.</h1>
		<h2>Some contents.....</h2>
	</cflayoutarea>
	
	<cflayoutarea title="Tab 1" source="index.cfm?event=ehAjax.dspTab1" name="tab1">
	
	</cflayoutarea>
	<!--- This binding is via local scope. --->
	<cflayoutarea title="Tab 2" source="coldboxproxy.cfc?method=dspTab2&cfdebug" name="tab2">
	
	</cflayoutarea>

</cflayout>
