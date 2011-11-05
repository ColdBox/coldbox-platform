function cachebox_toggle(divid){
	if ( document.getElementById(divid).className == "cachebox_debugContent"){
		document.getElementById(divid).className = "cachebox_debugContentView";
	}
	else{
		document.getElementById(divid).className = "cachebox_debugContent";
	}
}
function cachebox_openwindow(mypage,myname,w,h,features) {
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
function cachebox_getBase(baseURL){
	var idx = baseURL.search(/\?/);
	if( idx > 0 )
		return baseURL + "&";
	return baseURL + "?";
}
function cachebox_pollmonitor(panel, frequency, urlBase,newWindow){
	var newLocation = cachebox_getBase(urlBase) + 'debugpanel=' + panel + '&frequency=' + frequency + '&cbox_cacheMonitor=true';
	if (newWindow == 'undefined') {
		window.location = newLocation;
	}
	else{
		cachebox_openwindow(newLocation,'cachemonitor',850,750,'status=1,toolbar=0,location=0,resizable=1,scrollbars=1');
	}
}
function cachebox_cboxCommand( commandURL, verb ){
	if( verb == null ){
		verb = "GET";
	}
	var request = new XMLHttpRequest();
	request.open( verb, commandURL, false);
	request.send();
	return request.responseText;
}
function cachebox_cacheExpireItem(URLBase, cacheKey, cacheName){
	// Button
	var btn = document.getElementById('cboxbutton_expireentry_'+cacheKey);
	btn.disabled = true;
	btn.value = "Wait";
	// Execute Command
	cachebox_cboxCommand( cachebox_getBase(URLBase) + "cbox_command=expirecacheentry&cbox_cacheentry=" + cacheKey + "&cbox_cacheName="+cacheName);
	// ReFill the content report
	cachebox_cacheContentReport(URLBase,cacheName);
}
function cachebox_cacheClearItem(URLBase, cacheKey, cacheName){
	// Button
	var btn = document.getElementById('cboxbutton_removeentry_'+cacheKey);
	btn.disabled = true;
	btn.value = "Wait";
	// Execute Command
	cachebox_cboxCommand( cachebox_getBase(URLBase) + "cbox_command=delcacheentry&cbox_cacheentry=" + cacheKey + "&cbox_cacheName="+cacheName);
	// Remove Entry
	var element = document.getElementById('cbox_cache_tr_'+cacheKey);
	element.parentNode.removeChild(element);
}
//Execute a command from the cacheBox Toolbar
function cachebox_cacheBoxCommand(URLBase, command, btnID, showAlert){
	if( showAlert == null){ showAlert = true; }
	var btn = document.getElementById(btnID)
	btn.disabled = true
	cachebox_cboxCommand( cachebox_getBase(URLBase) + "cbox_command=" + command)
	btn.disabled = false
	if( showAlert ){ alert("CacheBox Command Completed!"); }
}
// Execute a garbage collection
function cachebox_cacheGC(URLBase,cacheName,btnID){
	// Run GC
	cachebox_cacheBoxCommand(URLBase,"gc",btnID,false)
	// Re-Render Cache Report
	cachebox_cacheReport(URLBase,cacheName)
}
// Render a cache report dynamically based on a cache name
function cachebox_cacheReport(URLBase,cacheName){
	// loader change
	var loader = document.getElementById('cachebox_cachebox_selector_loading');
	loader.style.display='inline';
	var reportDiv = document.getElementById('cachebox_cacheReport');
	reportDiv.innerHTML = "";
	// get report
	var reportHTML = cachebox_cboxCommand(cachebox_getBase(URLBase)+"debugPanel=cacheReport&cbox_cacheName="+cacheName);
	reportDiv.innerHTML = reportHTML;
	// turn off loader
	loader.style.display='none';
}
// Re-Fill Content Report
function cachebox_cacheContentReport(URLBase,cacheName){
	var reportDiv = document.getElementById('cachebox_cacheContentReport')
	reportDiv.innerHTML = ""
	var reportHTML = cachebox_cboxCommand(cachebox_getBase(URLBase)+"debugPanel=cacheContentReport&cbox_cacheName="+cacheName);
	reportDiv.innerHTML = reportHTML;
}
//Execute a CacheContent Command
function cachebox_cacheContentCommand(URLBase, command, cacheName, loaderDiv){
	var loader = document.getElementById('cachebox_cacheContentReport_loader');
	loader.style.display='inline';
	// Execute Command
	cachebox_cboxCommand( cachebox_getBase(URLBase) + "cbox_command=" + command + "&cbox_cacheName="+cacheName);
	// ReFill the content report
	cachebox_cacheContentReport(URLBase,cacheName);
	// turn off loader
	loader.style.display='none';
}
function cachebox_toggleDiv(targetDiv, displayStyle){
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
// Timed Refresh
function cachebox_timedRefresh(timeoutPeriod) {
	setTimeout("location.reload(true);",timeoutPeriod);
}