<cfparam name="type" default="all">


<cfswitch expression="#type#">

	<cfcase value="session">
		<cfset structclear(session)>
	</cfcase>
	
	<cfcase value="application">
		<cfset structclear(application)>
	</cfcase>
	
	<cfcase value="all">
		<cfset structclear(session)>
		<cfset structclear(application)>
	</cfcase>

</cfswitch>

<cfoutput>Structures Cleared...</cfoutput>

<a href="index.cfm?fwreinit=1">Index.cfm?fwreinit=1</a>