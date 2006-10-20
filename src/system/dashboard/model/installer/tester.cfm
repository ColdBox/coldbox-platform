<!--- Tester for the installer --->
<cfscript>
setupStruct = structnew();
setupstruct.BACKUPFILENAME = "Oct.19.06.1421_coldbox_1.1.0.zip";
setupstruct.BACKUPSPATH = "/Users/lmajano/Documents/MyDevelopment/applications/coldbox/src/_tempinstall/system/dashboard/backups";
setupstruct.CURRENTVERSION = "1.1.0";
setupstruct.DOWNLOADEDFILENAME = "coldbox_1.1.1.zip";
setupstruct.INSTALLATIONTYPE = "framework";
setupstruct.INSTALLERDIR = "/Users/lmajano/Documents/MyDevelopment/applications/coldbox/src/system/dashboard/model/installer";
setupstruct.NEWVERSION = "1.1.1";
setupstruct.PROXYFLAG = "0";
setupstruct.PROXYPASSWORD = "";
setupstruct.PROXYPORT = "";
setupstruct.PROXYSERVER = "";
setupstruct.PROXYUSERNAME = "";
setupstruct.TARGETPATH = "/Users/lmajano/Documents/MyDevelopment/applications/coldbox/src/system/";
setupstruct.UPDATEFILESIZE = "81776";
setupstruct.UPDATEFILEURL = "http://jfetmac/applications/coldbox/builds/coldbox_1.1.0.zip";
setupstruct.UPDATETEMPDIR = "/Users/lmajano/Documents/MyDevelopment/applications/coldbox/src/_tempinstall";
</cfscript>
<cfwddx action="cfml2wddx" input="#setupStruct#" output="setupPacket">
<cfdump var="#setupStruct#">
<cfoutput>
<input type="button" name="button" value="Start Installer" onClick="window.location='installer.cfm?setupPacket=#JSStringFormat(setupPacket)#'">
</cfoutput>