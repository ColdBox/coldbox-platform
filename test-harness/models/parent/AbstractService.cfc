<cfcomponent displayname="AbstractService" hint="AbstractService - Abstract Bean Class" output="false" accessors="true">
	<cfproperty name="someAlphaDAO" type="any">
	<cfproperty name="someBravoDAO" type="any">

	<cfscript>
	function init(){
		return this;
	}
	</cfscript>
</cfcomponent>
