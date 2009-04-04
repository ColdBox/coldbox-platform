<cfcomponent name="xmlBeanConfig" extends="coldbox.system.extras.lightwire.BaseConfigObject" hint="A LightWire configuration bean.">
<!--- 
BEAN DEFINITION SYNTAX
SINGLETONS:
addSingleton(FullClassPath, NameList)
Adds the definition for a given Singleton to the config file.
- FullClassPath:string:required - The full class path to the bean including its name. E.g. for com.UserService.cfc it would be com.UserService. 
- BeanName:string:optional - An optional name to be able to use to refer to this bean. If you don't provide this, the name of the bean will be used as a default. E.g. for com.UserService, it'll be named UserService unless you put something else here. If you put UserS, it'd be available as UserS, but NOT as UserService.

addSingletonFromFactory(FactoryBean, FactoryMethod, BeanName)
Adds the definition for a given Singleton that is created by a factory to the config file.
- FactoryBean:string:required - The name of the factory to use to create this bean (the factory must also have been defined as a Singleton in the LightWire config file).
- FactoryMethod:string:required - The name of the method to call on the factory bean to create this bean.
- BeanName:string:required - The required name to use to refer to this bean. 

TRANSIENTS:
addTransient(FullClassPath, NameList)
Adds the definition for a given Transient to the config file.
- FullClassPath:string:required - The full class path to the bean including its name. E.g. for com.UserBean.cfc it would be com.UserBean.
- BeanName:string:optional - An optional name to be able to use to refer to this bean. If you don't provide this, the name of the bean will be used as a default. E.g. for com.UserBean, it'll be named UserService unless you put something else here. If you put User, it'd be available as User, but NOT as UserBean.

addTransientFromFactory(FactoryBean, FactoryMethod, BeanName)
Adds the definition for a given Transient that is created by a factory to the config file.
- FactoryBean:string:required - The name of the factory to use to create this bean (the factory must also have been defined as a Singleton in the LightWire config file).
- FactoryMethod:string:required - The name of the method to call on the factory bean to create this bean.
- BeanName:string:required - The required name to use to refer to this bean. 

BEAN DEPENDENCIES and PROPERTIES
Once you have defined a given bean, you also want to describe its dependencies and properties. Any bean can have 0..n constructor, setter and/or mixin dependencies and properties. Dependencies handle LightWire initialized objects that need to be injected into your beans. Properties handle all other elements (strings, bits, structs, etc.). Please note: constructor dependencies are passed to the init() method, so you need a correspondingly named argument in your init file. Setter dependencies are injected using set#BeanName#() after calling the init() method but before returning the bean, so you need to have the appropriate setter. Mixin injections are auto injected into variables scope for you after calling the init() method but before returning the bean, but you don't need to have a setter() method - it used a generic setter injected automatically into all of your beans (lightwireMixin()).

addConstructorDependencies(BeanName, DependencyNameList)
Adds one or more constructor dependencies to a bean. If you call this more than once on the same bean, the additional dependencies will just be added to the list so it is valid to call this multiple times to build up a dependency list if required.
- BeanName:string:required - The name of the bean (Singleton or Transient) to add the dependencies to. You MUST have defined the bean using addSingleton() AddTransient(), addSingletonFromFactory() or addTransientFromFactory() before you add dependencies to the bean.
- DependencyNameList:string:required - A comma delimited list of one or more bean names to be added to the list of dependencies. 

addSetterDependencies(BeanName, DependencyNameList)
Adds one or more setter dependencies to a bean. If you call this more than once on the same bean, the additional dependencies will just be added to the list so it is valid to call this multiple times to build up a dependency list if required.
- BeanName:string:required - The name of the bean (Singleton or Transient) to add the dependencies to. You MUST have defined the bean using addSingleton() AddTransient(), addSingletonFromFactory() or addTransientFromFactory() before you add dependencies to the bean.
- DependencyNameList:string:required - A comma delimited list of one or more bean names to be added to the list of dependencies. 

addMixinDependencies(BeanName, DependencyNameList)
Adds one or more mixin dependencies to a bean. If you call this more than once on the same bean, the additional dependencies will just be added to the list so it is valid to call this multiple times to build up a dependency list if required.
- BeanName:string:required - The name of the bean (Singleton or Transient) to add the dependencies to. You MUST have defined the bean using addSingleton() AddTransient(), addSingletonFromFactory() or addTransientFromFactory() before you add dependencies to the bean.
- DependencyNameList:string:required - A comma delimited list of one or more bean names to be added to the list of dependencies. 

addConstructorProperty(PropertyName, PropertyValue)
Adds a constructor property to a bean. 
- BeanName:string:required - The name of the bean (Singleton or Transient) to add the property to. You MUST have defined the bean using addSingleton() AddTransient(), addSingletonFromFactory() or addTransientFromFactory() before you add properties to the bean.
- PropertyName:string:required - The name of the property to add.
- PropertyValue:any:required - The value of the property to add. Can be of any simple or complex type (anything from a string or a boolean to a struct or even an object that isn't being managed by LightWire).

addSetterProperty(PropertyName, PropertyValue)
Adds a setter property to a bean. 
- BeanName:string:required - The name of the bean (Singleton or Transient) to add the property to. You MUST have defined the bean using addSingleton() AddTransient(), addSingletonFromFactory() or addTransientFromFactory() before you add properties to the bean.
- PropertyName:string:required - The name of the property to add.
- PropertyValue:any:required - The value of the property to add. Can be of any simple or complex type (anything from a string or a boolean to a struct or even an object that isn't being managed by LightWire).

addMixinProperty(PropertyName, PropertyValue)
Adds a constructor property to a bean. 
- BeanName:string:required - The name of the bean (Singleton or Transient) to add the property to. You MUST have defined the bean using addSingleton() AddTransient(), addSingletonFromFactory() or addTransientFromFactory() before you add properties to the bean.
- PropertyName:string:required - The name of the property to add.
- PropertyValue:any:required - The value of the property to add. Can be of any simple or complex type (anything from a string or a boolean to a struct or even an object that isn't being managed by LightWire).
--->

<cffunction name="init" output="false" returntype="any" hint="I initialize the config bean.">
	<cfargument name="filePath" required="true" type="string" hint="the file path">
	<cfargument name="settings" required="false" type="struct" default="#structnew()#" hint="">
	<cfscript>
		
		// Call the base init() method to set sensible defaults. Do NOT remove this.
		Super.init();
		
		settings.dsn = "mytest";
		
		/* Parse XML Config FIle */
		parseXMLConfigFile(arguments.filePath,settings);
		
		/* Parse again using XML Raw */
		ConfigFile = FileRead(ExpandPath('/coldbox/testing/tests/cases/extras/lightwire/beandefs.xml'));
		parseXMLRaw(ConfigFile,settings);
		
		return this;
	</cfscript>
</cffunction>

</cfcomponent>