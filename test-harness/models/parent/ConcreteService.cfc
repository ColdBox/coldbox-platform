<cfcomponent
	displayname="ConcreteService"
	extends    ="AbstractService"
	hint       ="ConcreteService - Value Object Bean Class"
	output     ="false"
	accessors  ="true"
>
	<cfproperty name="someCharlieDAO" type="any">
	<cfproperty name="someDeltaDAO" type="any">

	<cfscript>
	function init(){
		return this;
	}
	</cfscript>
</cfcomponent>
