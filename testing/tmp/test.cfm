<cfscript>
/* 
New Component annotations


New DSLs: 
factory:modelName:method (This will search in the definitions for a factoryArguments struct, if not found,
it just calls the method)

Also, the model object the modelName represents can be ANY object.  No need to declare an object as a factory,
every object can be a factory.

Every mapping registered in the model mappings structure can be referenced by using model:{name} in the DSL.
This abstracts type, where it comes from, setup, etc.

When you register an object with type of "webservice" you can refer to it by:

- model:name or webservice:name

*/

// Paths that you register for convention lookups
externalLocations = [
	"shared",
	"model.test",
	"transfer"
];

// Register Custom DSL Classes that must implement: coldbox.system.ioc.dsl.IDSL
customDSL = {
	DSLName = {namespace="Custom", classPath="path.to.DSLCFC", dsl="I can use a declare model mapping for it too."}
};

modelMappings = {
	beanName = {
	  alias 		= "list", 
	  path			= "shortcut using registered external locations path", 
	  classPath		= "The full class path of an object",
	  autowire		= "true or false",
	  classpath		= 'full class path', 
	  singleton		= "true or false", 
	  cache			= "true or false", 
	  cacheTimeout  = 0, 
	  cacheLastAccessTimeout=0,
	  type			= "cfc,java,feed,webservice", 
	  dsl			= "full DSL",
	  persistScope	= "session, server, application, cluster",
	  persistKey 	= "the key to save on, else defaults to bean name",
	  // Constructor arguments
	  Constructor = [
	      {name="",value="optional",dsl="", castTo="", def=""}
	  ],
	  // Setter method injections, if name is not used, we revert to a model name
	  Setters = [
	     {name="",value="optional",dsl="",castTo="",def=""}
	  ],
	  // CFproperty injections: If name is not used, we rever to a model name
	  Injections = [
	     {name="",value="optional",dsl="", scope="variables", castTo="",def=""}
	  ],
	  // Used only for factory arguments
	  factoryArguments = {
	  
	  }
	},
	
	// Webservice
	MyWebservice = {
		type	= "webservice",
		path 	= "http://www.coldbox.org/distro.cfc?wsdl"
	},
	
	// Factory Object
	ColdBoxFactory = {
		classPath 	= "coldbox.system.ioc.ColdBoxFactory",
		alias 		= "CBOXFactory,CBOX"
	},
	
	// Factory Bean
	BeanInjector = {
		dsl = "factory:ColdBoxFactory:getPlugin",
		factoryArguments = {
			plugin 		= "BeanFactory",
			newInstance = false
		}
	},
	
	// Datsource
	CodexDatasource = {
		dsl = "coldbox:dsn:codexDSN"
	},
	
	// UserGateway
	userGateway = {
		path 		= "UserGateway", 
		singleton	= true,
		Injections 	= [
			{name="dsn", dsl="model:CodexDatasource"},
			{dsl="model:BeanInjector"}
		]
	},  
	UserService = {
		path		 = "UserService",
		cache		 = true,
		cacheTimeout = 60, // 60 minutes
		cacheLastAccessTimeout = 15, // purge if not used in the next 15 minutes
		constructor	= [
			{name="MyArray", value=[1,2,3] },
			{name="MyStruct", value={name="luis",age="32"} }
		],
		injections  = [
			{dsl="model:UserGateway", scope="instance"},
			{name="defaultRole", value=controller.getSetting('Admin'), scope="instance"}
		]
	},

	// Register Java Class
	MyStringBuffer = {
		classPath	= "java.lang.StringBuffer",
		type		= "java",
		constructor = [
			{value="nada", castTo="string"}
		],
		setters		= [
			{name="buffer", value="16000", castTo="int"},
			{name="classLoader", castTo="null"}
		]
	},
	
	//Inner Bean Definitions
	TransferFactory = {
        path		 ='TransferFactory',
        singleton	 = true,
		persistScope = "application",
		persistKey   = "transferFactory1",
        constructor=[
            {
                name="Configuration",
                def={
                    classPath="transfer.com.config.Configuration",
                    constructor=[
                        {name='datasourcePath',value='#controller.getSetting('transfer-config-path')#'},
                        {name='configPath',value='#controller.getSetting('transfer-definition-path')#'},
                        {name='definitionsPath',value='/config/definitions'}
                    ]
                }
            }
        ]
	},
	// Inner Bean Definitions with References:
	TransferFactory = {
        path='TransferFactory',
        singleton=true,
        constructor=[
            {name="Configuration", bean=refConfig}
        ]
	}
};

var refConfig = {
    classPath="transfer.com.config.Configuration",
    constructor=[
        {name='datasourcePath',value='#controller.getSetting('transfer-config-path')#'},
        {name='configPath',value='#controller.getSetting('transfer-definition-path')#'},
        {name='definitionsPath',value='/config/definitions'}
    ]
};





</cfscript>