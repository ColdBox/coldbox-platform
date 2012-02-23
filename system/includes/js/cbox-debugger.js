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
function fw_openwindow(mypage,myname,w,h,features) {
	if(screen.width){
		var winl = (screen.width-w)/2;
		var wint = (screen.height-h)/2;
	}
	else{
		winl = 0;wint =0;
	}
	if (winl < 0) winl = 0;
	if (wint < 0) wint = 0;
	
	var settings = 'height=' + h + ',';
	settings += 'width=' + w + ',';
	settings += 'top=' + wint + ',';
	settings += 'left=' + winl + ',';
	settings += features;
	win = window.open(mypage,myname,settings);
	win.window.focus();
}
function fw_reinitframework(usingPassword){
	var reinitForm = document.getElementById('fw_reinitcoldbox');
	if( usingPassword ){
		reinitForm.fwreinit.value = prompt("Reinit Password?");
		if( reinitForm.fwreinit.value.length ){
			reinitForm.submit();
		}
	}else{
		reinitForm.submit();
	}
}
function fw_pollmonitor(panel, frequency, urlBase){
	window.location=urlBase + '?debugpanel='+panel+'&frequency='+frequency;
}
function fw_cboxCommand( commandURL, verb ){
	if( verb == null ){
		verb = "GET";
	}
	var request = new XMLHttpRequest();
	request.open( verb, commandURL, false);
	request.send();
	return request.responseText;
}
function fw_toggleDiv(targetDiv, displayStyle){
	// toggle a div with styles, man I miss jquery
	if( displayStyle == null){ displayStyle = "block"; }
	var target = document.getElementById(targetDiv);
	if( target.style.display == displayStyle ){
		target.style.display = "none";
	}
	else{
		target.style.display = displayStyle;
	}	
}