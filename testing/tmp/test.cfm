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


Active Factory Annotations on Component Tag
@singleton
@cache
@cacheTimeout
@cacheLastAccessTimeout
@cacheName
@scope
@scopeKey

Active Factory Methods Annotations
@onDIComplete will fire on an object when di completes. 1 or more
@inject

*/

// Wirebox configuraiton settings
settings = {
	// defaults
	defaultConstructor = "[init]",
	scopeLeech = "scope name",
	scopeLeechKey = "keyname, defaults to 'wirebox'",
	
	// Cache Box Config
	cacheBoxConfig = "path or cfc for altering the default cache. Defaults to: coldbox.system.ioc.config.CacheBoxConfig",
	
	// aop config
	aop = {
		// if false, we use onMM
		generateFiles = "[true],false",
		generatePath  = "file path or file ram path"
	}
};

// Paths that you register for convention lookups or package scans
externalPackages = [
	"shared",
	"model.test",
	"transfer"
];

// Register Custom DSL Classes that must implement: coldbox.system.ioc.dsl.INamespace
customDSL = {
	DSLNamespace = "bean ID",
	groovy = "CFGroovy"
};

/* listeners IN ORDER, as they will fire by convention in registered order
	and receive a structure of data of information
	- afterDIComplete()
	- afterBeanInitialization()
	- beforeBeanInitialization()
	- onFactoryStartup()
	- onFactoryShutdown()
	- afterLateralFactoryRegistration()
	- afterLateralFactoryRemoval()
*/
listeners = [
	{name="optional", id="beanPostProcessor"},
	{name="trans", id="transformer"}
];

// The bean mappings, optional, as objects can be retrieved via externalPackages and autowired
beanMappings = {
	beanName = {
	  alias 		= "list,of,aliases", 
	  path			= "shortcut using registered external package paths", 
	  class			= "The full class path of an object",
	  autowire		= "[true] or false",
	  type			= "[cfc],java,feed,webservice", 
	  dsl			= "full DSL used for wiring purposes or retrieval purposes",
	  scope			= "[singleton], transient or prototype, cache, session, server, application, cluster, request",
	  scopeKey 		= "the key to save on some persistent scopes, else defaults to bean name",
	  cache			= {timeout=10, lastAccessTimeout=5,cachename="Region"},
	  constructorName   = "[init]",
	  callConstructor   = "[true],false",
	  parent		= "BeanID",
	  
	  
	  // Constructor Arguments
	  constructor = [
	      {name="ArgumentName",value="Optional",dsl="optional, defaults to id", castTo="",definition=""}
	  ],
	  
	  // Setter method injections, if name is not used, we revert to a model name
	  setters = [
	     {name="setterName",value="optional",dsl="optional, defaults to id",castTo="",definition=""}
	  ],
	  
	  // CFproperty injections: If name is not used, we rever to a model name
	  Injections = [
	     {name="setterName",value="optional",dsl="optional, defaults to id", scope="variables", castTo="",definition=""}
	  ],
	  factoryArguments = [
	  	{name="ArgumentName",value="Optional",dsl="optional, defaults to id", castTo="",definition=""}
	  ]
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
		Injections 	= [
			{name="dsn", dsl="model:CodexDatasource"},
			{dsl="model:BeanInjector"},
			{name="utilList", type="java", class="java.util.LinkedList"}
		]
	},  
	
	UserService = {
		path		 = "UserService",
		cache		 = {timeout=60, lastAccessTimeout=15},
		constructor	= [
			{name="MyArray", value=[1,2,3] },
			{name="MyStruct", value={name="luis",age="32"} }
		],
		injections  = [
			{dsl="model:UserGateway", scope="instance"},
			{name="defaultRole", value=controller.getSetting('Admin'), scope="instance"},
			{name="util", value=createObject("component","my.class.util")}
		]
	},

	// Register Java Class
	MyStringBuffer = {
		class	= "java.lang.StringBuffer",
		type	= "java",
		constructor = [
			{value="Starting Buffer...", castTo="string"}
		],
		setters		= [
			{name="buffer", value="16000", castTo="int"},
			{name="classLoader", castTo="null"}
		]
	},
	
	//Inner Bean Definitions
	TransferFactory = {
        path		 ='TransferFactory',
        scope 		 = "application",
		scopeKey	 = "transferFactory1",
        constructor=[
            {
                name="Configuration",
                definition={
                    class="transfer.com.config.Configuration",
                    constructor=[
                        {name='datasourcePath',value='#controller.getSetting('transfer-config-path')#'},
                        {name='configPath',value='#controller.getSetting('transfer-definition-path')#'},
                        {name='definitionsPath',value='/config/definitions'}
                    ]
                }
            }
        ]
	}
};

aop = {

	aspectName = {
		// The aspect object
		id = "beanID",
		// Optional class, instead of bean
		class = "path.to.class",
		// optional directed bean targets
		target = "beanID,beanID2",
		// optional annotation the aop weaver should look for instead of pointcuts
		annotation = "name[=value]",
		// Optional Pointcuts, as the actual aspect can implement an annotation based approach.
		pointCuts = {
			// method names, via a list of regex
			methods = "",
			// a list of regex of family types
			types = "",
			//aspectJ execution
			execution  = "aspectJ parser"
		}		
	},
	transaction = {
		class = "coldbox.system.aop.aspects.AnnotationTransaction",
		pointCuts = {
			types = ".*\.services"
		}
	}
};



/*
Aspects can have annotations to determine what annotations to weave upon.

@annotation name[=value]
component{

	function before(AOPEvent){}
	function after(AOPEvent){}
	function around(AOPEvent){}
	function afterThrows(AOPEvent){}
	function afterFinally(AOPEvent){}
	
}


*/
</cfscript>