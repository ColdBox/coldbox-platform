<cfoutput>
<cfset qRollovers = getValue("qRollovers")>
<script language="javascript">
function getHint( vid ){
	<cfloop query="qRollovers">
	if ( vid == '#rolloverid#' ){ $("sidemenu_help").innerHTML = '#JSStringFormat(text)#'}
	</cfloop>
}	
</script>
</cfoutput>