//AUTHOR: 		LUIS MAJANO
//DESCRIPTION: 	MAIN JS FILE FOR THE DASHBOARD.
//


//********************************************************************************
//AJAX LOADER JS
//********************************************************************************
function lon(){
	try{
		new Effect.Appear('myloader',{duration: .2});
	}
	catch(err){null;}
}
function loff(){
	try{
		new Effect.Fade('myloader',{duration: .2});	
	}
	catch(err){null;}
}

//********************************************************************************
//DIV EFFECTS
//********************************************************************************
function divon(divid){
	new Effect.Appear(divid,{duration: .2});
}
function divoff(divid){
	new Effect.Fade(divid,{duration: .2});
}
function cleardiv(id) {
	$(id).innerHTML = "";
}
function rollover(img){
	$(img).src = $(img).getAttribute('srcon');
}
function rollout(img){
	$(img).src = $(img).getAttribute('srcoff');
}
function showAdvancedSearchBar( openit ){
	if ( openit ){
		$("advancedSearchBarTriggerOpen").className = "hidelayer";
		$("advancedSearchBarTriggerClose").className = "showlayer";
		divon('advancedSearchBar');
		
	}
	else{
		$("advancedSearchBarTriggerClose").className = "hidelayer";
		$("advancedSearchBarTriggerOpen").className = "showlayer";
		divoff('advancedSearchBar');
	}
}
function helpon(){
	Effect.BlindDown('helpbox',{duration:.5});
}
function helpoff(){
	new Effect.BlindUp('helpbox',{duration:.5});
}
//********************************************************************************
//AJAX INTERACTION
//********************************************************************************
function doFormEvent (e, targetID, frm) {
	var params = {};
	var frm = $(frm);
	for(i=0;i<frm.length;i++) {
		if(!(frm[i].type=="radio" && !frm[i].checked) && frm[i].value != undefined)  {
			params[frm[i].name] = frm[i].value;
		}
	}
	doEvent(e, targetID, params, "POST");
}

function doEvent (e, targetID, params, methodType ) {
	try{parent.topframe.lon();} catch(err){null;}
	var pars = "event=" + e + "&";
	//Check for Method.
	if ( methodType == null )
		methodType = "get";
	//parse params
	for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";
	//do Ajax Updater
	var myAjax = new Ajax.Updater(targetID,
								  "index.cfm",
								  {method:methodType, parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:h_onComplete});
}

function h_onComplete(){
	try{ parent.topframe.loff();}
	catch(err){null;}
}
function h_callError(request) {
	alert('Sorry. An error ocurred while calling a server side component. Please try again.');
}


//********************************************************************************
//INTERACTION
//********************************************************************************
function validateLogout(){
	if ( confirm("Do your really want to exit the ColdBox Dashboard?") ){
		parent.topframe.lon();
		return true;
	}
	return false;
}
function framebuster(){
	if ( top != self )
		top.location=self.location;	
}
function resetHint(){
	$("sidemenu_help").innerHTML = "Help tips will be shown here. Just rollover certain areas or links and you will get some quick tips.";
}
function confirmit(){
	if ( confirm ("Do you want to commit these changes to the framework.") )
		return true;
	else
		return false;
}
function validateappbuilder(){
	
}
function toggleLogsLocation(){
	if ( $("coldboxlogging").value == 'true' )
		$('tr_coldboxlogslocation').style.display = 'table-row';
	else
		$('tr_coldboxlogslocation').style.display = 'none';
}

function addemail(){
	var vemail = $("bugemailadd").value;
	var oldLength = $("bugemails").options.length;
	
	if ( vemail == "") alert("Please enter a valid email");
	else{
		if ( oldLength == 0 )
			newLength = 0;
		$("bugemails").options.length = oldLength + 1;
		$("bugemails").options[oldLength] = new Option(vemail,vemail);
		$("bugemailadd").value = '';
	}
}

function removeemail(){
 var lgth = $("bugemails").options.length - 1;
 var sel = $("bugemails").selectedIndex;
 
 if ( sel < 0 )
 	alert ("Please select a valid email to remove");
 else
 	$("bugemails").options[sel] = null;
}

function addDevURL(){
	var vurl = $("devurladd").value;
	var oldLength = $("devurls").options.length;
	
	if ( vurl == "") alert("Please enter a valid dev url snippet");
	else{
		if ( oldLength == 0 )
			newLength = 0;
		$("devurls").options.length = oldLength + 1;
		$("devurls").options[oldLength] = new Option(vurl,vurl);
		$("devurladd").value = '';
	}
}

function removeDevURL(){
 var lgth = $("devurls").options.length - 1;
 var sel = $("devurls").selectedIndex;
 
 if ( sel < 0 )
 	alert ("Please select a valid dev url to remove");
 else
 	$("devurls").options[sel] = null;
}

function addWebservice(){
	var vname = $("wsname").value;
	var vprourl = $("wsdlpro").value;
	var vdevurl = $("wsdldev").value;
	var valueString = vname + "," + vprourl + "," + vdevurl;
	
	if ( vname == "" || vprourl == ""){
		alert("Please fill out the web service information");
		return;
	}
	
	var oldLength = $("webservices").options.length;
	if ( oldLength == 0 )
		newLength = 0;
	$("webservices").options.length = oldLength + 1;
	$("webservices").options[oldLength] = new Option(vname,valueString);
	//Clean
	$("wsname").value = "";
	$("wsdlpro").value = "";
	$("wsdldev").value = "";
}

function removeWebservice(){
 var lgth = $("webservices").options.length - 1;
 var sel = $("webservices").selectedIndex;
 
 if ( sel < 0 )
 	alert ("Please select a valid Web Service to remove");
 else
 	$("webservices").options[sel] = null;
}

function toggleHandlers( vchecked, vtextboxID, vmethod ){
	if ( vchecked ){
		$(vtextboxID).value = $("maineventhandler").value + "." + vmethod;
	}
	else{
		$(vtextboxID).value = '';
	}
}
function changeallHandlers(){
	if ( $('onapplicationstart_cb').checked ){
		$("onapplicationstart").value = $("maineventhandler").value + ".onApplicationStart";
	}
	if ( $('onrequeststart_cb').checked ){
		$("onrequeststart").value = $("maineventhandler").value + ".onRequestStart";
	}
	if ( $('onrequestend_cb').checked ){
		$("onrequestend").value = $("maineventhandler").value + ".onRequestEnd";
	}
	if ( $('onexception_cb').checked ){
		$("onexception").value = $("maineventhandler").value + ".onException";
	}
	$("defaultevent_handler").innerHTML = $("maineventhandler").value + ".";
}
function toggleBugReportEmails(){
	if ( $("enablebugreports").value == 'true' )
		$('tr_bugreportEmails').style.display = 'table-row';
	else
		$('tr_bugreportEmails').style.display = 'none';
}
function toggleResourceBundle(){
	var locale = $("defaultlocale").options[$("defaultlocale").selectedIndex].value;
	$("defaultresourcebundle_locale").innerHTML = "_" + locale + ".properties";
}
function togglei18n(){
	if ( $("i18nFlag").value == 'true' ){
		$('tr_locale').style.display = 'table-row';
		$('tr_localestorage').style.display = 'table-row';
		$('tr_resourcebundle').style.display = 'table-row';
	}
	else{
		$('tr_locale').style.display = 'none';
		$('tr_localestorage').style.display = 'none';
		$('tr_resourcebundle').style.display = 'none';
	}
}

//FILE BROWSER JS
function openBrowser( vEvent, vCallbackInput ){
	//Open And Place container
	if(window.innerWidth)  clientWidth = window.innerWidth;
	else if (document.body) clientWidth = document.body.clientWidth;

	if(window.innerHeight)  clientHeight = window.innerHeight;
	else if (document.body) clientHeight = document.body.clientHeight;
	
	var Container = $("FileBrowserContainer");
	Container.style.left = ((clientWidth/2)-200) + "px";
	Container.style.top = ((clientHeight/2)-200) + "px";
	
	//Render It
	doEvent(vEvent,'FileBrowserContainer',{callBackItem:vCallbackInput});
	//Show it.
	new Effect.Grow("FileBrowserContainer",{duration: .2});
	
	
}
function closeBrowser( ){
	cleardiv("FileBrowserContainer");
	divoff("FileBrowserContainer");
}

function selectdirectory( vdir , vFullUrl){
	var selectedDir = vdir;
	$("selecteddir").value = vFullUrl;
	$("span_selectedfolder").innerHTML = selectedDir;
	$("selectdir_btn").disabled = false;
	//Color Pattern
	if ( selectDirectoryHistoryID != ""){
		try{$(selectDirectoryHistoryID).style.backgroundColor = '#ffffff';}
		catch(err){null;}
		$(vdir).style.backgroundColor = '#b3cbff';
		selectDirectoryHistoryID = vdir;
	}
	else{
		$(vdir).style.backgroundColor = '#b3cbff';
		selectDirectoryHistoryID = vdir;
	}
}
var selectDirectoryHistoryID = "";

function newFolder( vEvent, vcurrentRoot ){
	var vNewFolder = prompt("Please enter the name of the folder to create:");
	if (vNewFolder == ""){ 
		alert("Please enter a valid name");
	}
	else{
		doEvent(vEvent,'FileBrowser',{dir:vcurrentRoot,newfolder:vNewFolder});
	}
}
function chooseFolder( vcallbackItem ){
	$(vcallbackItem).value = $("selecteddir").value;
	closeBrowser();
}

//Navigation of app Builder 
function stepper( vsource, vtarget, direction ){
	$(vsource).style.display = "none";
	Effect.SlideDown(vtarget, {duration:.5});
	//Change step Color
	$("step_" + vtarget).className = 'menu_appgenerator_step_on';
	//Change Indicator
	if ( direction == "forward" ){
		currentGeneratorStep =  $("step_" + vtarget).innerHTML;
		$("step_" + vtarget).innerHTML = "^" + currentGeneratorStep;
		$("step_" + vsource).innerHTML = "Done";
	}
	else{
		$("step_" + vsource).innerHTML = currentGeneratorStep;
		currentGeneratorStep = $("step_" + vtarget).innerHTML;
		$("step_" + vtarget).innerHTML = "^Done";
	}
}
var currentGeneratorStep = "^Step 1";
//Validation for app Builder
function validate_basic(vRelocate){
	var errors = "";
	if ( vRelocate == null ){
		vRelocate = true;
	}
	
	if ( $("appname").value == ""){
		errors += "- Please enter an application name\n";
	}
	if( $("appmapping").value == ""){
		errors += "- Please enter an application mapping\n";
	}
	if( $("debugpassword").value == ""){
		errors += "- Please enter an debug password\n";
	}
	if( $("defaultlayout").value == ""){
		errors += "- Please enter a default layout.\n";
	}
	if ( errors != ""){
		alert(errors);
		return false;
	}
	else{
		if (vRelocate) 
			stepper('basic_set','applicationloggin_set','forward');
		return true;
	}
}
function validate_applicationlogging(vRelocate){
	if( vRelocate == null ){
		vRelocate = true;
	}
	
	if ($("coldboxlogging").value == "true" && $("coldboxlogslocation").value == ""){
		alert("Please enter the logs location");
		return false;
	}
	else{
		if (vRelocate) 
			stepper('applicationloggin_set','development_set','forward');
		return true;
	}
}
function validate_eventhandlers(vRelocate){
	var errors = "";
	if( vRelocate == null ){
		vRelocate = true;
	}
	if ( $("maineventhandler").value == ""){
		errors += "- Please enter the main event handler's name.\n";
	}
	if( $("defaultevent").value == ""){
		errors += "- Please enter the default event.\n";
	}
	
	if ( errors != ""){
		alert(errors);
		return false;
	}
	else{
		if (vRelocate)
			stepper('eventhandler_set','generation_set','forward');
		return true;
	}
}
function validateGeneration(){
	//Check inputs
	var errors = "";
	if ( $("authorname").value == ""){
		errors += "- Please enter your name.\n";
	}
	if ( $("skeleton_name").value == ""){
		errors += "- Please enter the name of this skeleton that will be generated.\n";
	}
	if ( $("generation_target").value == ""){
		errors += "- Please enter the target directory in the web server where your application will be generated.\n";
	}
	if ( errors != ""){
		alert(errors);
		return false;
	}
	else{
		if ( validate_basic(false) && validate_applicationlogging(false) && validate_eventhandlers(false) )
			return true;
		else
			return false;
	}
}


//Auto Update Methods
function confirmUpdate( vupdateType ){
	$("updatetype").value = vupdateType;
	if ( vupdateType == "dashboard" ){
		if ( confirm ("Do you wish to auto update the Dashboard application?") )
			return true;
		else
			return false;
	}
	else if ( vupdateType == "framework" ){
		if ( confirm ("Do you wish to auto update the ColdBox framework?") )
			return true;
		else
			return false;
	}
	
}
//******************************************************************************
//TEST METHODS
//********************************************************************************


function doTest(targetID){
	parent.topframe.lon();
	var pars = "";
	var weburl = "/applications/coldbox/testing/ajax.cfm";
	var	methodType = "GET";
	//do Ajax Updater
	var myAjax = new Ajax.Updater(targetID,
								  weburl,
								  {method:methodType, parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:parent.topframe.loff});
}

