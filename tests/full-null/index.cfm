<cfscript>
env        = new coldbox.system.core.delegates.Env();
javaSystem = env.getJavaSystem();
utility    = new coldbox.system.core.util.Util();
mixer      = utility.getMixerUtil();

logBoxConfig = new coldbox.system.logging.config.LogBoxConfig().init().loadDataDSL( { "appenders" : {} } );
cacheBoxConfig = new coldbox.system.cache.config.CacheBoxConfig()
	.init()
	.loadDataDSL( { "defaultCache" : { "coldboxEnabled" : false } } );

if (
	!isInstanceOf( javaSystem, "java.lang.System" ) ||
	!isInstanceOf( mixer, "coldbox.system.core.dynamic.MixerUtil" ) ||
	logBoxConfig.getRoot().appenders != "*" ||
	structIsEmpty( cacheBoxConfig.getMemento().defaultCache )
) {
	throw( type = "RegressionFailure", message = "ColdBox public APIs did not initialize with full null support." );
}

writeOutput( "PASS" );
</cfscript>
