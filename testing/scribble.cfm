<cfscript>
stime = getTickCount();

for(x=1; x lte 300; x+=1){
	LoopObjectList = "logger,mydsn,updatews,test,mytest";
	while (ListLen(LoopObjectList))
	{
		// Get the last object name
		LoopObjectName = ListLast(LoopObjectList);
		// Call setterandmixinInject() to inject any setter or mixin dependencies
		// Remove that object name from the list
		LoopObjectList = ListDeleteAt(LoopObjectList,ListLen(LoopObjectList));
	}
}
</cfscript>
<cfoutput>
	Total Time using Lists: #getTickCount()-stime# ms<br />
</cfoutput>


<cfscript>
stime = getTickCount();

for(x=1; x lte 1; x+=1){
	LoopObjectList = "logger,mydsn,updatews,test,mytest";
	Len = listLen(loopObjectList);
	for(y=len; y gt 0; y-=1 )
	{
		// Get the last object name
		LoopObjectName = listGetAt(LoopObjectList,y);
		// Call setterandmixinInject() to inject any setter or mixin dependencies
		writeoutput(loopObjectName & " ");
	}
}
</cfscript>
<cfoutput>
	<br />
	Total Time using Looping: #getTickCount()-stime# ms
</cfoutput>

