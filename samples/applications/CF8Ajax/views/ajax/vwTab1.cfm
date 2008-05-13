<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Sana Ullah
Date        :	March 05 2008
Description :
----------------------------------------------------------------------->

<h1>This is the first tab.</h1>
<h2>
	content are display using event model. <br />
	Dynamic content by calling url directly.
	<cfoutput>#HtmlEditFormat('source="index.cfm?event=ehAjax.dspTab1"')#</cfoutput>
</h2>
<pre>
	<h2>index.cfm?event=ehGeneral.dspTab1</h2>
</pre>
<p>
<strong>Lorem Ipsum</strong> is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
</p>


