<cftimer type="inline">
<cffile action="read" file="#expandPath("../src/handlers/ehGeneral.cfc")#" variable="content">
<cfscript>
joStringBuffer = createObject("java","java.lang.StringBuffer").init();
str = reFindnocase("<cffunction[^>/]*>",content,1,true);
joStringBuffer.append("<cfcomponent>");
while ( str.len[1] neq 0 ) {
	string = Mid(content,str.pos[1],str.len[1]) & "</cffunction>";
	joStringBuffer.append(javaCast("string", string & chr(13)));
	str = reFindnocase("<cffunction[^>/]*>",content,str.pos[1]+str.len[1],true);
}
joStringBuffer.append("</cfcomponent>");
test = xmlparse(joStringBuffer.tostring());
</cfscript>
</cftimer>
<br>
<textarea rows="20" cols="80">
<cfoutput>#content#</cfoutput>
</textarea>
<br>Parsed<br>
<textarea rows="20" cols="80">
<cfoutput>#joStringBuffer.tostring()#</cfoutput>
</textarea>
<cfdump var="#test#">