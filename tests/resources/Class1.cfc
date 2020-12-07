<cfcomponent
	extends                 ="Class2"
	displayName             ="class1"
	output                  ="true"
	scope                   ="server"
	annotationClass1Only    ="Class1Value"
	annotationClass1and2and3="class1Value"
>
	<cfproperty name="propClass1Only" default="class1Value">
	<cfproperty name="propClass1and2and3" default="class1Value">

	<cffunction name="funcClass1Only" hint="Function defined in Class1"></cffunction>

	<cffunction name="funcClass1and2and3" hint="Function defined in Class1"></cffunction>
</cfcomponent>
