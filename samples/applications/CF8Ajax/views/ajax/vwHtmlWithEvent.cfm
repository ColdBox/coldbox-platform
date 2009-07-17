<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Sana Ullah
Date        :	Dec 03 2008
Description :
	This proxy is an inherited coldbox remote proxy used for enabling
	coldbox as a model framework.
----------------------------------------------------------------------->
<cfajaxproxy cfc="#rc.locColdBoxProxy#" jsclassname="cbProxy" />

<script type="text/javascript">
    function doHtmlEvent() {
	   // create an instance of the proxy. 
	   var e = new cbProxy();
	   // Setting a callback handler for the proxy automatically makes
	   // the proxy's calls asynchronous.
	   e.setCallbackHandler(HtmlData);
	   e.setErrorHandler(myErrorHandler);
	   e.setHTTPMethod('post');
	   e.setReturnFormat('plain');
	// Call process method of ColdBoxProxy.cfc.
	  e.process2({'event':'ehAjax.doHtmlEvent'});
    }
    var HtmlData = function(sData)
  	{
      document.getElementById('ShowHtmlReponse').innerHTML = sData; 
  	}     
	var myErrorHandler = function(statusCode, statusMsg)
	{
	    alert('Status: ' + statusCode + ', ' + statusMsg);
	}
</script>
<input type="button" name="login" value="Get Html Data!" onclick="doHtmlEvent();" />

<div id="ShowHtmlReponse">Above button will bring back new html data here</div>

