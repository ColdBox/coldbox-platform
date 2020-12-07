<cfcomponent
	displayName             ="class3"
	scope                   ="request"
	annotationClass3Only    ="Class3Value"
	annotationClass1and2and3="class3Value"
>
	<cfproperty name="propClass3Only" default="class3Value">
	<cfproperty name="propClass1and2and3" default="class3Value">

	<cffunction name="funcClass3Only" hint="Function defined in Class3"></cffunction>

	<cffunction name="funcClass1and2and3" hint="Function defined in Class3"></cffunction>
</cfcomponent>
