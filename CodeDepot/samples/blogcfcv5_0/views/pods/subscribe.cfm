<cfsetting enablecfoutputonly=true>
<cfprocessingdirective pageencoding="utf-8">
<!---
	Name         : subscribe.cfm
	Author       : Raymond Camden 
	Created      : May 12, 2005
	Last Updated : 
	History      : 
	Purpose		 : Allow folks to subscribe.
--->

<cfmodule template="../../tags/podlayout.cfm" title="#getResource("subscribe")#">

	<cfoutput>
	<cfform action="#cgi.script_name#?" 
			method="post">
	<p align="center">
		<cfinput type="text"
				 name="subscriber_email" size="15" 
			     message="Please enter a valid email address"
				 validateat="onsubmit"
				 validate="email" 
				 required="yes"
			     class="textboxes" value="E-Mail Address" onclick="this.value=''">
		<cfinput type="submit" name="Submit" value="Join" class="buttons">
		<input type="hidden" value="#Event.getValue("xehSubscribe")#" name="event" id="event" />
		<input type="hidden" value="#cgi.query_string#" name="query_string" id="query_string"  />
	</p>
	</cfform>
	<img src="../images/spacer.gif" height="1">
	</cfoutput>
			
</cfmodule>
	
<cfsetting enablecfoutputonly=false>