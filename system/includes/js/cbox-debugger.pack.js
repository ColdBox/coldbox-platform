function fw_toggle(divid){if(document.getElementById(divid).className=="fw_debugContent"){document.getElementById(divid).className="fw_debugContentView";}
else{document.getElementById(divid).className="fw_debugContent";}}
function fw_poprc(divid){var _div=document.getElementById(divid);if(_div.className=='hideRC')
document.getElementById(divid).className="showRC";else
document.getElementById(divid).className="hideRC";}
function fw_openwindow(mypage,myname,w,h,features){if(screen.width){var winl=(screen.width-w)/2;var wint=(screen.height-h)/2;}
else{winl=0;wint=0;}
if(winl<0)winl=0;if(wint<0)wint=0;var settings='height='+h+',';settings+='width='+w+',';settings+='top='+wint+',';settings+='left='+winl+',';settings+=features;win=window.open(mypage,myname,settings);win.window.focus();}
function fw_reinitframework(usingPassword){var reinitForm=document.getElementById('fw_reinitcoldbox');if(usingPassword){reinitForm.fwreinit.value=prompt("Reinit Password?");if(reinitForm.fwreinit.value.length){reinitForm.submit();}}else{reinitForm.submit();}}
function fw_pollmonitor(panel,frequency,urlBase){window.location=urlBase+'?debugpanel='+panel+'&frequency='+frequency;}
function fw_cboxCommand(commandURL,verb){if(verb==null){verb="GET";}
var request=new XMLHttpRequest();request.open(verb,commandURL,false);request.send();return request.responseText;}
function fw_cacheClearItem(URLBase,cacheKey,cacheName){var btn=document.getElementById('cboxbutton_removeentry_'+cacheKey);btn.disabled=true;btn.value="Wait";fw_cboxCommand(URLBase+"?cbox_command=delcacheentry&cbox_cacheentry="+cacheKey+"&cbox_cacheName="+cacheName);var element=document.getElementById('cbox_cache_tr_'+cacheKey);element.parentNode.removeChild(element);}
function fw_cacheExpireItem(URLBase,cacheKey,cacheName){var btn=document.getElementById('cboxbutton_expireentry_'+cacheKey);btn.disabled=true;btn.value="Wait";fw_cboxCommand(URLBase+"?cbox_command=expirecacheentry&cbox_cacheentry="+cacheKey+"&cbox_cacheName="+cacheName);fw_cacheContentReport(URLBase,cacheName);}
function fw_cacheBoxCommand(URLBase,command,btnID,showAlert){if(showAlert==null){showAlert=true;}
var btn=document.getElementById(btnID)
btn.disabled=true
fw_cboxCommand(URLBase+"?cbox_command="+command)
btn.disabled=false
if(showAlert){alert("CacheBox Command Completed!");}}
function fw_cacheGC(URLBase,cacheName,btnID){fw_cacheBoxCommand(URLBase,"gc",btnID,false)
fw_cacheReport(URLBase,cacheName)}
function fw_cacheReport(URLBase,cacheName){var loader=document.getElementById('fw_cachebox_selector_loading');loader.style.display='inline';var reportDiv=document.getElementById('fw_cacheReport');reportDiv.innerHTML="";var reportHTML=fw_cboxCommand(URLBase+"?debugPanel=cacheReport&cbox_cacheName="+cacheName);reportDiv.innerHTML=reportHTML;loader.style.display='none';}
function fw_cacheContentReport(URLBase,cacheName){var reportDiv=document.getElementById('fw_cacheContentReport')
reportDiv.innerHTML=""
var reportHTML=fw_cboxCommand(URLBase+"?debugPanel=cacheContentReport&cbox_cacheName="+cacheName);reportDiv.innerHTML=reportHTML;}
function fw_cacheContentCommand(URLBase,command,cacheName,loaderDiv){var loader=document.getElementById('fw_cacheContentReport_loader');loader.style.display='inline';fw_cboxCommand(URLBase+"?cbox_command="+command+"&cbox_cacheName="+cacheName);fw_cacheContentReport(URLBase,cacheName);loader.style.display='none';}
function fw_toggleDiv(targetDiv,displayStyle){if(displayStyle==null){displayStyle="block";}
var target=document.getElementById(targetDiv);if(target.style.display==displayStyle){target.style.display="none";}
else{target.style.display=displayStyle;}}