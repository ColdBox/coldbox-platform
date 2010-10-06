<cfscript>

cachePut("Test",createUUID());
writeDump(cacheGet("Test"));
writeDump(cacheGet("Test2"));
writeDump(cacheCount());
writeDump(cacheGetAllIds());

writeDump(cacheGetProperties("object") );

</cfscript>