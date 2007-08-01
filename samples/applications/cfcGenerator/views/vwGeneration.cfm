
<cfoutput>
<script language="JavaScript">
function showit( vdiv ){
	document.getElementById("code_" + vhistorydiv).style.display = 'none';
	document.getElementById("code_" + vdiv).style.display = 'block';
	//Tabs
	document.getElementById("tab_" + vhistorydiv).className = 'navelement';
	document.getElementById("tab_" + vdiv).className = 'navelementON';
	//set history
	vhistorydiv = vdiv;
}
vhistorydiv = "bean"; vhistorytab = "bean";
</script>

<!--- Display Components View --->
#renderView("vwComponents")#


<!--- Display the Generated Tabs --->
<div class="navbar">
	<cfloop from="1" to="#arrayLen(rc.arrComponents)#" index="i">
		<div class="<cfif rc.arrComponents[i].name eq "bean">navelementON<cfelse>navelement</cfif>" id="tab_#rc.arrComponents[i].name#">
		<a href="javascript:showit('#rc.arrComponents[i].name#')">#ucase(rc.arrComponents[i].name)#</a>
		</div>
	</cfloop>
</div>

<!--- Display the Generated Content --->
<div class="generatedtab">
<cfloop from="1" to="#arrayLen(rc.arrComponents)#" index="i">
	<div id="code_#rc.arrComponents[i].name#" style="display:<cfif rc.arrComponents[i].name eq "bean">block;<cfelse>none;</cfif>">
	<textarea rows="20" style="width:100%;" onclick="javascript:this.focus();this.select()">#rc.arrComponents[i].content#</textarea></p>
	</div>
</cfloop>
</div>
</cfoutput>