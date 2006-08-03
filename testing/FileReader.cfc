<!---
FileReader.cfc
Uses the Java FileInputStream, InputStreamReader, and BufferedReader to provide a way to incrementally read large files.

To use:
<cfscript>
	variables.joFileReader = createObject('component', 'FileReader').init('filename.txt', 32768);
	variables.inStr = variables.joFileReader.readLine();
	while ( not variables.joFileReader.isEOF() ) {
	   // writeOutput(variables.inStr & "<br>");
		variables.inStr = variables.joFileReader.readLine();
	}
	variables.joFileReader.close();
</cfscript>

greg.lively@gmail.com
Use this program however you want.
--->
<cfcomponent displayname="FileReader">

	<cfscript>
		variables.EOF = false;
		variables.joFileInputStream = '';
		variables.joInputStreamReader = '';
		variables.joBufferedReader = '';
	</cfscript>

	<cffunction name="init" access="public" returntype="FileReader" output="No" hint="initializes the FileReader CF/java object">
		<cfargument name="fileName" type="string" required="Yes" hint="the path and name of the file to read" />
		<cfargument name="fileEncoding" type="string" required="yes" hint="the file encoding" />
		<cfargument name="bufferSize" type="numeric" required="no" default="8192" hint="the buffer size for the bufferedReader" />

		<cfscript>
			arguments.fileName = trim(arguments.fileName);
			arguments.fileEncoding = uCase(trim(arguments.fileEncoding));

			checkFileEncoding(arguments.fileEncoding);
			variables.EOF = false;
			variables.joFileInputStream = CreateObject("java","java.io.FileInputStream").init(javaCast("string", arguments.fileName));
			variables.joInputStreamReader = CreateObject("java","java.io.InputStreamReader").init(variables.joFileInputStream,  javaCast("string", arguments.fileEncoding));
			variables.joBufferedReader = CreateObject("java","java.io.BufferedReader").init(variables.joInputStreamReader, javaCast("int", arguments.bufferSize));
		</cfscript>

		<cfreturn this />
	</cffunction>

	<cffunction name="checkFileEncoding" access="private" returntype="void" output="No" hint="checks for a valid file encoding">
		<cfargument name="fileEncoding" type="string" required="yes" hint="the file encoding" />

		<cfset var joCharSet = CreateObject("java","java.nio.charset.Charset") />
		<cfif not (joCharSet.isSupported(javaCast("string", arguments.fileEncoding)))>
			<cfabort showerror="Invalid file encoding" />
		</cfif>
	</cffunction>

	<cffunction name="readLine" access="public" returntype="string" output="No" hint="Read a line of text">
		<cfset var returnString = "" />
		<cfset var goodString = "" />

		<cftry>
			<!--- if readLine gets EOF, it will return a null, with is undefined in CF. This will throw an exception. Once
			the returnString gets UNDEFINED assigned to it, we can no longer use it; it's toast. If not EOF, the returnString will
			get assigned to the good string, which gets returned. --->
			<cfset returnString = variables.joBufferedReader.readLine() />
			<cfset goodString = returnString />

			<cfcatch type="coldfusion.runtime.UndefinedVariableException">
				<cfset variables.EOF = true />
			</cfcatch>
		</cftry>

		<cfreturn goodString />
	</cffunction>

	<cffunction name="isEOF" access="public" returntype="boolean" output="No" hint="returns a boolean of whether the EOF has been reached">
		<cfreturn variables.EOF />
	</cffunction>

	<cffunction name="close" returntype="void" access="public" output="No" hint="flushes and closes stream, buffer, and file">
		<cfscript>
			variables.joBufferedReader.close();
			variables.joInputStreamReader.close();
			variables.joFileInputStream.close();
		</cfscript>
	</cffunction>

</cfcomponent>