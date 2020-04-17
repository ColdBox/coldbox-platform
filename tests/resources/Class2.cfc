<cfcomponent
	extends                 ="Class3"
	displayName             ="class2"
	output                  ="false"
	scope                   ="session"
	annotationClass2Only    ="Class2Value"
	annotationClass1and2and3="class2Value"
>
	<cfproperty name="propClass2Only" default="class2Value">
	<cfproperty name="propClass1and2and3" default="class2Value">

	<cffunction name="funcClass2Only" hint="Function defined in Class2"></cffunction>

	<cffunction name="funcClass1and2and3" hint="Function defined in Class2"></cffunction>
</cfcomponent>
