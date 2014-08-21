<cfparam name="rootPath" default="">
<cfoutput>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<link rel ="stylesheet" type="text/css" href="#attributes.rootPath#bootstrap/css/bootstrap.min.css">
<link rel ="stylesheet" type="text/css" href="#attributes.rootPath#stylesheet.css">
	
<link href='https://fonts.googleapis.com/css?family=Ubuntu:400,300,300italic,400italic,700,700italic|Ubuntu+Mono' rel='stylesheet' type='text/css' />
	
<script src="#attributes.rootPath#bootstrap/js/jquery-2.1.0.min.js" type="text/javascript"></script>
<script src="#attributes.rootPath#bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
</cfoutput>
<script>
$(document).ready(function() {
	// Global Tool Tip Settings
	$( '[title]' ).tooltip({
		 animation: 'slide',
		 delay: { show: 250, hide: 250 }
	});
});
</script>