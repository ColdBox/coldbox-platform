<cfsetting showdebugoutput="false">
var catsErrorArray = new Array(<cfoutput>#listQualify(URL.c, "'")#</cfoutput>);
var postErrorArray = new Array(<cfoutput>#listQualify(URL.p, "'")#</cfoutput>);

for (var i=0; i<catsErrorArray.length; i++) {
	for (var j=0; j<field1.options.length; j++) {
		if (field1.options[j].value == catsErrorArray[i]) {
			field1.options[j].selected = true;
			break;
		}
	}
}
doPopulateEntries(0);

for (var i=0; i<postErrorArray.length; i++) {
	for (var j=0; j<field2.options.length; j++) {
		if (field2.options[j].value == postErrorArray[i]) {
			field2.options[j].selected = true;
			break;
		}
	}
}