<cfscript>
 f = createObject("java","java.lang.ThreadLocal").init();
 f.set("test");

 writeDump( f.get() );
</cfscript>