$(document).ready(function() {
	// Div Filter
	$("#entryFilter").keyup(function(){
		$.uiDivFilter( $(".forgeBox-entrybox"), this.value );
	})
});

function toggle(id){
	$("#"+id).modal({
		overlayClose:true,
		minWidth: 900,
		maxWidth: 900,
		maxHeight: 500,
		minHeight: 400
	});
}

function loadProfile(username){
	var src = "http://www.coldbox.org/profiles/show/" + username;
	$.modal('<iframe src="' + src + '" height="500" width="900" style="border:0">', {
		overlayClose:true
	});
}

function installEntry(downloadURL,slug){
	$("#installDiv").modal({
		minWidth: 400,
		overlayClose:true
	});
	$("#installURL").val(downloadURL);
	$("#installText").text(slug);
	$("#entrySlug").val(slug);
}
function startInstall(){
	$("#loader").slideDown();
	$("#installButton").attr("disabled",true);	
}
