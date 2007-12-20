<!---
FileReader.cfc
Uses the Java FileOutputStream, OutputStreamWriter, and BufferedWriter to provide a way to GREATLY increase
performance of file output. Must faster and less resource intensive than trying to build large strings and
perform fewer CFFILE append actions. Also less memory intensive than putting strings into an array and then
performing a listToArray() call.

Supports writting files in US-ASCII, ISO-8859-1, UTF-8, UTF-16BE, UTF-16LE,  UTF-16.
UTF-8 and UTF-16 unicode files will automatically have a byte order mark (BOM) written to them.

To use:
<cfscript>
	variables.joFileWriter = createObject('component', 'FileWriter').init(variables.fileName, variables.encoding, 32768);

	variables.joFileWriter.writeLine(variables.someDataVar);

	variables.joFileWriter.close();
</cfscript>


greg.lively@gmail.com
Use this program however you want.
--->
<cfcomponent displayname="FileWriter">

	<cfscript>
		variables.joFileOutputStream = '';
		variables.joOutputStreamWriter = '';
		variables.joBufferedWriter = '';
	</cfscript>

	<cffunction name="init" access="public" returntype="FileWriter" output="No" hint="initializes the FileWriter CF/java object">
		<cfargument name="fileName" type="string" required="Yes" hint="the path and name of the file to write" />
		<cfargument name="fileEncoding" type="string" required="yes" hint="the file encoding" />
		<cfargument name="bufferSize" type="numeric" required="no" default="8192" hint="the buffer size for the bufferedWriter" />
		
		<cfscript>
			arguments.fileName = trim(arguments.fileName);
			arguments.fileEncoding = uCase(trim(arguments.fileEncoding));
			arguments.bufferSize = bufferSizeLimit(arguments.bufferSize);

			variables.joFileOutputStream = CreateObject('java','java.io.FileOutputStream').init(javaCast('string', arguments.fileName));
			getFileEncoding(arguments.fileEncoding);
			variables.joOutputStreamWriter = CreateObject('java','java.io.OutputStreamWriter').init(variables.joFileOutputStream, javaCast('string', arguments.fileEncoding));
			variables.joBufferedWriter = CreateObject('java','java.io.BufferedWriter').init(variables.joOutputStreamWriter, javaCast('int', arguments.bufferSize));
		</cfscript>

		<cfreturn this />
	</cffunction>

	<cffunction name="bufferSizeLimit" access="private" returntype="numeric" output="No" hint="limit the buffer between 8k and 128k. Come on, let's be reasonable.">
		<cfargument name="bufferSize" type="numeric" required="no" default="8192" hint="the buffer size for the bufferedWriter" />

		<cfscript>
			/* limit the buffer between 8k and 128k. Come on, let's be reasonable. */
			if (arguments.bufferSize LT 8192) {
				arguments.bufferSize = 8192;
			} else if (arguments.bufferSize GT 131072) {
				arguments.bufferSize = 131072;
			}
		</cfscript>

		<cfreturn arguments.bufferSize />
	</cffunction>

	<cffunction name="getFileEncoding" access="private" returntype="void" output="No" hint="checks for a valid file encoding">
		<cfargument name="fileEncoding" type="string" required="yes" hint="the file encoding" />

		<cfset var joCharSet = CreateObject("java","java.nio.charset.Charset") />

		<cfif (joCharSet.isSupported(javaCast("string", arguments.fileEncoding)))>
			<cfscript>
				/*
				Every implementation of the Java platform is required to support the following standard charsets.
		
				US-ASCII 		Seven-bit ASCII, a.k.a. ISO646-US, a.k.a. the Basic Latin block of the Unicode character set
				ISO-8859-1 		ISO Latin Alphabet No. 1, a.k.a. ISO-LATIN-1
				UTF-8 			Eight-bit UCS Transformation Format
				UTF-16BE 		Sixteen-bit UCS Transformation Format, big-endian byte order
				UTF-16LE 		Sixteen-bit UCS Transformation Format, little-endian byte order
				UTF-16 			Sixteen-bit UCS Transformation Format, byte order identified by an optional byte-order mark
				*/

				/* write out file BOM, only if unicode format */
				switch (arguments.fileEncoding) {
					case 'UTF-8' : /* EF BB BF */
						variables.joFileOutputStream.write(239); // 0xEF
						variables.joFileOutputStream.write(187); // 0xBB
						variables.joFileOutputStream.write(191); // 0xBF
						break;
					case 'UTF-16LE' : /* FF FE */
						variables.joFileOutputStream.write(255); // 0xFF
						variables.joFileOutputStream.write(254); // 0xFE
						break;
					case 'UTF-16BE' : /* FE FF */
						variables.joFileOutputStream.write(254); // 0xFE
						variables.joFileOutputStream.write(255); // 0xFF
						break;
					default :
						/* no BOM */			
				}
			</cfscript>
		<cfelse>
			<cfset variables.joFileOutputStream.close() />
			<cfabort showerror="Invalid file encoding" />
		</cfif>
	</cffunction>

	<cffunction name="write" access="public" returntype="void" output="No" hint="writes a string to a file">
		<cfargument name="strIn" type="string" required="No" default="" hint="a string to write to the file" />

		<cfset variables.joBufferedWriter.write(javaCast("string", arguments.strIn)) />
	</cffunction>

	<cffunction name="writeLine" access="public" returntype="void" output="No" hint="writes a string to a file, and places and EOL character at the end">
		<cfargument name="strIn" type="string" required="No" default="" hint="a string to write to the file" />

		<cfset variables.joBufferedWriter.write(javaCast("string", arguments.strIn)) />
		<cfset variables.joBufferedWriter.newLine() />
	</cffunction>

	<cffunction name="newLine" access="public" returntype="void" output="No" hint="Uses the platform's own notion of line separator. Not all platforms use the newline character ('\n') to terminate lines.">
		<cfset variables.joBufferedWriter.newLine() />
	</cffunction>

	<cffunction name="close" access="public" returntype="void" output="No" hint="flushes and closes stream, buffer, and file">
		<cfscript>
			variables.joBufferedWriter.flush();
			variables.joOutputStreamWriter.flush();
			variables.joBufferedWriter.close();
			variables.joOutputStreamWriter.close();
			variables.joFileOutputStream.close();
		</cfscript>
	</cffunction>

</cfcomponent>