<cfoutput>
<h1>#Event.getValue("welcomeMessage")#</h1>
<h5>You are running #getSetting("codename",1)# #getSetting("version",1)# (#getsetting("suffix",1)#)</h5>
</cfoutput>

<cfset spry = getPlugin("Spry",true)>  
<cfset spry.setIsUtils(true)>  
<cfset spry.setIsDataSets(true)>  
<!--- 
<cfset chart = CreateObject('component','ofcplugin.model.openflashchart.Chart')>
 --->

<script type="text/javascript">

	var isLoaded = false;	
	function open_flash_chart_data()
	{
		if (!isLoaded){
			isLoaded = true;
			return '{"title":{"text":"hello1"}, "x_axis":{"max":6},"elements":[{"type":"line","text":"moo","font-size":10,"values":[5,8,9,4,7,8]}]}';
		}	
	}
	
	function findSWF(movieName) {
	  if (navigator.appName.indexOf("Microsoft")!= -1) {
	    return window[movieName];
	  } else {
	    return document[movieName];
	  }
	}

	function ofc_ready()
	{
		//load();
		//alert('loaded');
	}
	
	function loadJSON()
	{
		document.getElementById('chartLoading').style.visibility = 'visible';
		var params = new Object;
		params.chartElementId = "my_chart";
		var request = Spry.Utils.loadURL("GET", "coldboxproxy.cfc?method=process&event=ehChart.getBarChartData&json", true, loadJSONSuccess, { params: params });
	}
	
	function loadJSONSuccess(request)
	{
		document.getElementById('chartLoading').style.visibility = 'hidden';
		tmp = findSWF(request.params.chartElementId);
		//alert(request.xhRequest.responseText);
		x = tmp.load(request.xhRequest.responseText)
	}

</script>

<script type="text/javascript" src="includes/open-flash-chart/swfobject.js"></script>

<div align="center">
	<div id="chartLoading" style="visibility:hidden;"><img src="includes/img/ajax-loader.gif" /></div>
	<div id="my_chart" align="center"></div>
	<br />
	<a href="javascript:loadJSON();">Load Chart Data</a>
</div>
 
<!--- 
swfobject.embedSWF(swfUrl, id, width, height, version, expressInstallSwfurl, flashvars, params, attributes)
 --->
<script type="text/javascript">
	swfobject.embedSWF(
		"includes/open-flash-chart/open-flash-chart.swf", "my_chart",
		"550", "250", "9.0.0", "includes/open-flash-chart/expressInstall.swf"
	);
</script>


 
