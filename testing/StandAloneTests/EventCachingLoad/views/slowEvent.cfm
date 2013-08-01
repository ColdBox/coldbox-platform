<cfoutput>
	#rc.cacheTest#
	<!--- random sleep time to simulate an event taking a bit to run --->
	<cfset sleeptime = randRange(50,750)>

	<cfset sleep(#sleeptime#)>
</cfoutput>
