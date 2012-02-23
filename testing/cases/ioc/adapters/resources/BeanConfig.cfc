<cfcomponent name="BeanConfig" extends="lightwire.BaseConfigObject" hint="A LightWire configuration bean.">

<cffunction name="init" output="false" returntype="any" hint="I initialize the config bean.">
	<cfscript>
		// Call the base init() method to set sensible defaults. Do NOT remove this.
		super.init();
		// OPTIONAL: Set lazy loading: true or false. If true, Singletons will only be created when requested. If false, they will all be created when LightWire is first initialized. Default if you don't set: LazyLoad = true.
		setLazyLoad("false");

		// BEAN DEFINITIONS (see top of bean for instructions)
		addSingleton("coldbox.testing.testmodel.TestService");

		return this;		
	</cfscript>
</cffunction>

</cfcomponent>