<cftimer type="inline">
<cffile action="read" file="#expandPath("../src/handlers/ehGeneral.cfc")#" variable="content">
<textarea rows="20" cols="80"><cfoutput>#HTMLEditFormat(content)#</cfoutput></textarea>

<cfscript>
joStringBuffer = createObject("java","java.lang.StringBuffer").init();
str = reFindnocase("<cffunction[^>/]*>",content,1,true);
joStringBuffer.append("<component>");
while ( str.len[1] neq 0 ) {
	string = Mid(content,str.pos[1],str.len[1]) & "</cffunction>";
	joStringBuffer.append(javaCast("string", string & chr(13)));
	str = reFindnocase("<cffunction[^>/]*>",content,str.pos[1]+str.len[1],true);
}
joStringBuffer.append("</component>");
test = xmlparse(joStringBuffer.tostring());
functions = xmlsearch(test,"//component/cffunction");
registeredHandlers = ArrayNew(1);
if ( arrayLen(functions) eq 0 ){
	writeoutput("null");
}
for (x=1; x lt arrayLen(functions) ; x=x+1){
	if ( structKeyExists(functions[x].XMLAttributes,"access") and (functions[x].XMLAttributes["access"] eq "public" and functions[x].XMLAttributes["name"] neq "init") ){
		arrayAppend(registeredHandlers,functions[x].XMLAttributes["name"]);
	}
}
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
<cfdump var="#registeredHandlers#">