<cfform>
<h2>CFINPUT Auto-Suggest:</h2>
<p>Type <strong>fn</strong> or <strong>q1</strong> </p>
<cfinput type="text"
      name="employeename"
	  autosuggestminlength="2"
      autosuggest="cfc:#rc.locColdBoxProxy#.lookupName({cfautosuggestvalue})">
</cfform>
<p><br><br><br><br><br></p>