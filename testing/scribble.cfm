<cfscript>
test = createObject("java","java.lang.ref.SoftReference");
</cfscript>

<cfdump var="#isInstanceOf( "", "java.lang.ref.SoftReference")#">