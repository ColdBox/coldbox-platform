<cfcomponent name="LightWire" extends="coldbox.system.extras.lightwire.BaseConfigObject" hint="A LightWire configuration bean.">

  <cffunction name="init" output="false" returntype="any" hint="I initialize the config bean.">
    <cfscript>
		var cfcModelRoot = getController().getSetting('cfc.model.root');
		// Call the base init() method to set sensible defaults. Do NOT remove this.
		super.init();
		// OPTIONAL: Set lazy loading: true or false. If true, Singletons will only be created when requested. If false, they will all be created when LightWire is first initialized. Default if you don't set: LazyLoad = true.
		setLazyLoad("false");
		
		// Transfer
		addSingleton("transfer.TransferFactory","transferFactory");
		addConstructorProperty("TransferFactory","datasourcePath",getController().getSetting('transferSettings.datasourcePath') );
		addConstructorProperty("TransferFactory","configPath",getController().getSetting('transferSettings.configPath') );
		addConstructorProperty("TransferFactory","definitionPath",getController().getSetting('transferSettings.definitionPath') );
		addSingletonFromFactory("TransferFactory","getTransfer","transfer");
		
		// Security Manager
		addSingleton("#cfcModelRoot#.model.managers.Security","securityManager");
		addConstructorDependency("securityManager","transfer","transfer");
		addConstructorProperty("securityManager","coldbox",getController() );

		// User Manager
		addSingleton("#cfcModelRoot#.model.managers.User","UserManager");
		addConstructorDependency("UserManager","transfer","transfer");
		addConstructorProperty("UserManager","coldbox",getController() );

      return this;
    </cfscript>
  </cffunction>

</cfcomponent>
