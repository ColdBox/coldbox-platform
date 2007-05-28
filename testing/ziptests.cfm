<cftimer label="zipping">
<cfset obj = createObject("component","coldbox.system.plugins.zip")>
<cfset filename = ExpandPath("./") & "coldbox.#dateformat(now(),"MM.DD.YYYY")#.zip">
<cfset filetoCompress = ExpandPath("./") & "coldbox.log">
<cfoutput>#getDirectoryFromPath(filetoCompress)#</cfoutput>
<cfset obj.AddFiles(filename,filetoCompress,"","","no","9","no" )>
</cftimer>
Done

