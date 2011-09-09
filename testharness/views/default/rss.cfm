<cfoutput>
<h1>#rc.feed.Title# - [<a href="#rc.feed.link#">Open</a>]</h1>
<a href="#rc.feed.image.link#"><img src="#rc.feed.image.url#" title="#rc.feed.image.title#"></a>
<br />
<strong>Author: </strong>#rc.feed.author#<br />
<strong>Date: </strong> #dateFormat(rc.feed.dateupdated,"long")# #timeformat(rc.feed.dateupdated,"long")#<br />
<strong>Description:</strong> #rc.feed.description#

<cfloop query="rc.feed.items">
	
	<h4><strong><a href="#link#">#title#</a></strong></h4>
	<br />
	#description#<br /><br />

</cfloop>

</cfoutput>