<cfscript>
chart = CreateObject('component','ofcplugin.model.openflashchart.ChartData').init();
title = CreateObject('component','ofcplugin.model.openflashchart.element.Title').init('Generated JSON Chart');
title.setStyle('font-size:20px;');
chart.setTitle(title);
// Bar
/*
bar = CreateObject('component','ofcplugin.model.openflashchart.chart.Bar').init();
bar.setValues( ListToArray('2,5,6,4,2,3,5,9') );
bar.setAlpha('10%');
bar.setColor('##343434');
chart.addElement(bar);
*/
// Sketch
/*
sketchBar = CreateObject('component','ofcplugin.model.openflashchart.chart.bar.Sketch').init();
sketchBar.setValues( ListToArray('2,5,6,4,2,3,5,9') );
sketchBar.setOffset(10);
sketchBar.setAlpha('10%');
sketchBar.setColor('##424581');
chart.addElement(sketchBar);
*/
// Glass
/*
glassBar = CreateObject('component','ofcplugin.model.openflashchart.chart.bar.Glass').init();
glassBar.setValues( ListToArray('2,5,6,4,2,3,5,9') );
glassBar.setAlpha(0.2);
glassBar.setTooltip('Some value: ##val## <br>Hello: ##x_label##');
glassBar.setColor('##424581');
chart.addElement(glassBar);
*/
// Filled
/*
filled = CreateObject('component','ofcplugin.model.openflashchart.chart.bar.Filled').init();
filled.setValues( ListToArray('4,2,3,7,8,8,6,1') );
filled.setOutLineColor('##000000');
filled.setColor('##d070ac');
chart.addElement(filled);
*/
// Fade
/*
fadeBar = CreateObject('component','ofcplugin.model.openflashchart.chart.bar.Fade').init();
fadeBar.setValues( ListToArray('9,1,8,5,2,5,9,2') );
fadeBar.setTooltip('Nice huh: ##val## <br>Hello: ##x_label##');
fadeBar.setAlpha(0.3);
fadeBar.setColor('##82BEF4');
chart.addElement(fadeBar);
*/
// 3D
/*
ThreeD = CreateObject('component','ofcplugin.model.openflashchart.chart.bar.ThreeD').init();
ThreeD.setValues( ListToArray('4,2,3,7,8,8,6,1') );
ThreeD.setColor('##424581');
chart.addElement(ThreeD);
*/
//innerBackground = CreateObject('component','ofcplugin.model.openflashchart.element.InnerBackground').init();
//innerBackground.setColor('##82BEF4');
//chart.addElement(innerBackground);
//Line
/*
line = CreateObject('component','ofcplugin.model.openflashchart.chart.Line').init();
line.setValues( ListToArray('9,1,8,5,2,5,9,2') );
line.setWidth(10);
line.setHaloSize(5);
line.setDotSize(15);
line.setColor('##82BEF4');
chart.addElement(line);
*/
// Dotted Line
/*
dottedLine = CreateObject('component','ofcplugin.model.openflashchart.chart.line.dot').init();
dottedLine.setValues( ListToArray('9,1,8,5,2,5,9,2') );
dottedLine.setWidth(2);
dottedLine.setHaloSize(0);
dottedLine.setDotSize(3);
dottedLine.setColor('##82BEF4');
chart.addElement(dottedLine);
*/
// Hollow Line
/*
hollowLine = CreateObject('component','ofcplugin.model.openflashchart.chart.line.Hollow').init();
hollowLine.setValues( ListToArray('9,1,8,5,2,5,9,2') );
hollowLine.setWidth(3);
hollowLine.setHaloSize(3);
hollowLine.setDotSize(7);
hollowLine.setColor('##82BEF4');
hollowLine.setTooltip('Some value: ##val## <br>Hello: ##x_label##');
chart.addElement(hollowLine);
*/
//Pie
pie = CreateObject('component','ofcplugin.model.openflashchart.chart.Pie').init();
pie.setColors( ListToArray('##82BEF4,##8098B2,##0081CE,##323287,##82BEF4,##8098B2,##0081CE,##323287') );
pie.setIsLabels(true);
pie.setStartAngle(90);

// Values
pievalue1 = CreateObject('component','ofcplugin.model.openflashchart.chart.pie.value').init();
pievalue1.setValue(10);
pievalue1.setLabel('sdfsd');
pie.addValue(pievalue1);
pievalue2 = CreateObject('component','ofcplugin.model.openflashchart.chart.pie.value').init();
pievalue2.setValue(100);
pievalue2.setLabel('haha ernesto');
pievalue2.setLabelColor('##82BEF4');
pievalue2.setFontSize(25);
pie.addValue(pievalue2);
pievalue1.getData();
pie.setTooltip('Some value: ##val## <br>Hello: ');
pie.setIsAnimate(false);
chart.addElement(pie);

chartData = chart.getData();
</cfscript>

<cfset jsonData = getPlugin("JSON").encode(data:chartData,structKeyCase:"lower")>

<cfoutput>
<pre>
<strong>JSON</strong>
#jsonData#
</pre>
</cfoutput>
<br />
<script type="text/javascript">

	var isLoaded = false;	
	function open_flash_chart_data()
	{
		if (!isLoaded){
			isLoaded = true;
			return '<cfoutput>#jsonData#</cfoutput>';
			//return '{"title":{"text":"hello1"}, "x_axis":{"max":6},"elements":[{"type":"line","text":"moo","font-size":10,"values":[5,8,9,4,7,8]}]}';
		}	
	}
	
</script>

<script type="text/javascript" src="includes/open-flash-chart/swfobject.js"></script>

<div align="center">
	<div id="my_chart" align="center"></div>
</div>
<script type="text/javascript">
	swfobject.embedSWF(
		"includes/open-flash-chart/open-flash-chart.swf", "my_chart",
		"650", "400", "9.0.0", "includes/open-flash-chart/expressInstall.swf"
	);
</script>


 
