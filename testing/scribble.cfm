<cfscript>
	validationData = "1..3";
	min = listFirst( validationData,'..');
	max = listLast( validationData,'..');
		
	writeDump(variables);
</cfscript>