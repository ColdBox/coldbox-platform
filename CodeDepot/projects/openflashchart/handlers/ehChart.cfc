<cfcomponent name="ehChart" extends="coldbox.system.eventhandler" output="false">
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" type="any">
		<cfset super.init(arguments.controller)>
		<cfreturn this>
	</cffunction>

	<cffunction name="getBarChartData" access="public" returntype="struct" output="false">
		<cfargument name="Event" type="any">
		<cfscript>
			var chartData = StructNew();

			title = structNew();
			title.text = "Custom ToolTip";

			x_axis = StructNew();
			x_axis.max = 6;

			elements = ArrayNew(1);
			element = StructNew();
			element.type = "line";
			element.text = "moo";
			element['font-size'] = 10;
			element.values = ArrayNew(1);
			ArrayAppend(element.values,5);
			ArrayAppend(element.values,8);
			ArrayAppend(element.values,9);
			ArrayAppend(element.values,4);
			ArrayAppend(element.values,7);
			ArrayAppend(element.values,8);
			
			ArrayAppend(elements,element);
			
			
			chartData.title = title;
			chartData.x_axis = x_axis;
			chartData.elements = elements;
			
			/*
			chartData.title.style = "font-size: 20px; font-family: Verdana; text-align: center;";
			*/
		</cfscript>

<!--- <cfset jsonData = '{"title":{"text":"remote request"}, "x_axis":{"max":6},"elements":[{"type":"line","text":"moo","font-size":10,"values":[5,8,9,4,7,8]}]}'> --->

		<cfreturn chartData>
	</cffunction>
</cfcomponent>