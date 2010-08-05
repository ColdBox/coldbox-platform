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
//Cache Panel JS
function fw_cacheClearItem(cacheKey,cacheName){
	// Button
	var button = document.getElementById('button_ccr_del_'+cacheKey);
	button.disabled = true;
	button.value = "Wait";
	// Execute Command
	fw_cboxCommand( URLBase + "?cbox_command=delcacheentry&cbox_cacheentry=" + cacheKey + "&cbox_cacheName="+cacheName);
	// Remove Entry
	var element = document.getElementById('tr_ccr_'+cacheKey);
	element.parentNode.removeChild(element);
}
function fw_cacheCommand(URLBase, command, cacheName, refreshContent){
	// Execute Command
	fw_cboxCommand( URLBase + "?cbox_command=" + command + "&cbox_cacheName="+cacheName);
	// refresh defaults
	if( refreshContent == null ){ refreshContent = true; }
	// ReFill the content report
	if( refreshContent ){
		fw_cacheContentReport(URLBase,cacheName);
	}
}
function fw_cacheReport(URLBase,cacheName){
	var reportHTML = fw_cboxCommand(URLBase+"?debugPanel=cacheReport&cbox_cacheName="+cacheName);
	document.getElementById('fw_cacheReport').innerHTML(reportHTML);
}
function fw_cacheContentReport(URLBase,cacheName){
	var reportHTML = fw_cboxCommand(URLBase+"?debugPanel=cacheContentReport&cbox_cacheName="+cacheName);
	document.getElementById('fw_cacheContentReport').innerHTML(reportHTML);
}
function fw_toggleDiv(targetDiv, displayStyle){
	if( displayStyle == null){ displayStyle = "block"; }
	var target = document.getElementById(targetDiv);
	if( target.style.display == displayStyle ){
		target.style.display = "none";
	}
	else{
		target.style.display = displayStyle;
	}	
}