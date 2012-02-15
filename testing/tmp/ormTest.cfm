<cfscript>

test = entityLoad("Category","402881882814615e01282bb047fd001e",true);
user = entityLoad("User","88B73A03-FEFA-935D-AD8036E1B7954B76",true);
writeDump(test);
writeDump(user);


orm = ormGetSession();
ormFactory = ormgetSessionFactory();
stats = orm.getStatistics();
results = {
	collectionCount = stats.getCollectionCount(),
	collectionKeys  = stats.getCollectionKeys().toString(),
	entityCount	    = stats.getEntityCount(),
	entityKeys		= stats.getEntityKeys().toString()
};

//writeDump( ormFactory.getStatistics() );

//writeDump("Cache Region Names: #ormFactory.getStatistics().getSecondLevelCacheRegionNames()#");
writeDump("Category Cache: #ormFactory.getStatistics().getSecondLevelCacheStatistics('Category')#");

writeDump("Session Stats:");
writeDump(results);
</cfscript>