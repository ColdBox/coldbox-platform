<!---
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

StringBuffer.cfc
This CFC greatly increases the speed of string concatenation. CF strings are immutable. When you append a string
to another string, a whole new string is created. This is fine for a small number of iterations but painfully
slow and memory intensive for a large number of concatenation operations.

greg.lively@gmail.com
Use this program however you want.

To use:
<cfscript>
	variables.joStringBuffer = createObject('component', 'StringBuffer');
	variables.joStringBuffer.append(variables.someDataVar);
	writeOutput(variables.joStringBuffer.getString());
</cfscript>

from Java 1.5 API:
StringBuffer
A thread-safe, mutable sequence of characters. A string buffer is like a String, but can be modified. At any point in
time it contains some particular sequence of characters, but the length and content of the sequence can be changed
through certain method calls.

String buffers are safe for use by multiple threads. The methods are synchronized where necessary so that all the
operations on any particular instance behave as if they occur in some serial order that is consistent with the
order of the method calls made by each of the individual threads involved.

When a StringBuffer object is created it has a capacity, which is the number of characters that the StringBuffer will contain if full. If the default constructor is called with no parameters this capacity is set to 16, otherwise an int may be passed as a parameter to specify the capacity. Another constructor allows an initial set of characters to be passed as a parameter, in this case the capacity of the StringBuffer will be the number of characters in the initial string plus a further 16. The following example shows the possible ways of building StringBuffer objects.

StringBuffer = strbuf new StringBuffer (); // capacity = 16
StringBuffer = strbuf2 new StringBuffer (25); // capacity = 25
StringBuffer = strbuf3 new StringBuffer ("Java"); // capacity = 4 + 16 = 20

************************************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	Converted this cfc into a ColdBox plugin. You can now also, append to a file, if needed.

Modification History:
08/01/2006 - Updated the cfc to work for ColdBox.

--->
<cfcomponent hint="This CFC greatly increases the speed of string concatenation. CF strings are immutable. When you append a string to another string, a whole new string is created. This is fine for a small number of iterations but painfully slow and memory intensive for a large number of concatenation operations. This plugin switches between StringBuilder and StringBuffer if running under cf8"
			 extends="coldbox.system.core.java.StringBuffer"
			 output="false"
			 cache="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="StringBuffer" output="false">
		<cfscript>
			
			super.init();
			
			setpluginName("StringBuffer");
			setpluginVersion("1.0");
			setpluginDescription("This is a facade to the java StringBuffer class.");
			setpluginAuthor("Luis Majano");
			setpluginAuthorURL("http://www.coldbox.org");
			
			return this;
		</cfscript>		
	</cffunction>

</cfcomponent>