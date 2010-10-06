<cfscript>
cacheClear();

cachePut("Test",createUUID());

writeDump(cacheGet("Test"));
writeDump(cacheCount());

writeDump(cacheGetAllIds());

writeDump( cacheGetMetadata("Test") );

</cfscript>