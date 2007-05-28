<!--- Style --->
<style>
<cfinclude template="style.css">
</style>
<script  language="javascript" type="text/javascript">
function fw_toggle(divid){
	if ( document.getElementById(divid).className == "fw_debugContent"){
		document.getElementById(divid).className = "fw_debugContentView";
	}
	else{
		document.getElementById(divid).className = "fw_debugContent";
	}
}
function fw_poprc(divid){
	var _div = document.getElementById(divid);
	if ( _div.className == 'hideRC' )
		document.getElementById(divid).className = "showRC";
	else
		document.getElementById(divid).className = "hideRC";
}
</script>