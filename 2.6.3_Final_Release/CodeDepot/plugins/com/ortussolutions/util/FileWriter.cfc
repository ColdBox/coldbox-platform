<!---
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

FileReader.cfc
Uses the Java FileOutputStream, OutputStreamWriter, and BufferedWriter to provide a way to GREATLY increase
performance of file output. Must faster and less resource intensive than trying to build large strings and
perform fewer CFFILE append actions. Also less memory intensive than putting strings into an array and then
performing a listToArray() call.

Supports writting files in US-ASCII, ISO-8859-1, UTF-8, UTF-16BE, UTF-16LE,  UTF-16.
UTF-8 and UTF-16 unicode files will automatically have a byte order mark (BOM) written to them.

greg.lively@gmail.com
Use this program however you want.

************************************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	Converted this cfc into a ColdBox plugin. You can now also, append to a file, if needed.

Modification History:
08/01/2006 - Updated the cfc to work for ColdBox.
--->
<cfcomponent name="FileWriter"
			 hint="Uses the Java FileOutputStream, OutputStreamWriter, and BufferedWriter to provide a way to GREATLY increase performance of file output."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="FileWriter" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfset setpluginName("File Writer")>
		<cfset setpluginVersion("1.0")>
		<cfset setpluginDescription("Uses the java native classes to perform buffered file writing.")>
		<!--- This instance constructor --->
		<cfset instance.joFileOutputStream = ''>
		<cfset instance.joOutputStreamWriter = ''>
		<cfset instance.joBufferedWriter = ''>
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="setup" access="public" returntype="any" output="false" hint="initializes the FileWriter CF/java object">
		<!--- ************************************************************* --->
		<cfargument name="fileName" 	type="string" 	required="Yes" 	hint="the path and name of the file to write" />
		<cfargument name="fileEncoding" type="string" 	required="yes" 	hint="the file encoding: US-ASCII, ISO-8859-1, UTF-8, UTF-16BE, UTF-16LE,  UTF-16." />
		<cfargument name="bufferSize" 	type="numeric" 	required="no" 	default="8192" hint="the buffer size for the bufferedWriter" />
		<cfargument name="appendFlag"   type="boolean"  required="no"   default="false" hint="This flag determines whether you are creating a file to write to or to append to. The default is FALSE.">
		<!--- ************************************************************* --->
		<cfscript>
			//Clean the arguments.
			arguments.fileName = trim(arguments.fileName);
			arguments.fileEncoding = uCase(trim(arguments.fileEncoding));
			//Test bufferSize Limits.
			arguments.bufferSize = bufferSizeLimit(arguments.bufferSize);
			//prepare Streams.
			instance.joFileOutputStream = CreateObject('java','java.io.FileOutputStream').init(javaCast('string', arguments.fileName),javaCast("boolean",arguments.appendFlag));
			//Verify Encoding
			getFileEncoding(arguments.fileEncoding);
			//Prepare OUtput stream Writer with Encoding
			instance.joOutputStreamWriter = CreateObject('java','java.io.OutputStreamWriter').init(instance.joFileOutputStream, javaCast('string', arguments.fileEncoding));
			//Create BufferedWriter with Buffer Size
			instance.joBufferedWriter = CreateObject('java','java.io.BufferedWriter').init(instance.joOutputStreamWriter, javaCast('int', arguments.bufferSize));
			//Return reference
			return this;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="write" access="public" returntype="void" output="No" hint="writes a string to a file">
		<!--- ************************************************************* --->
		<cfargument name="strIn" type="string" required="No" default="" hint="a string to write to the file" />
		<!--- ************************************************************* --->
		<cfset instance.joBufferedWriter.write(javaCast("string", arguments.strIn)) />
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="writeLine" access="public" returntype="void" output="No" hint="writes a string to a file, and places and EOL character at the end">
		<!--- ************************************************************* --->
		<cfargument name="strIn" type="string" required="No" default="" hint="a string to write to the file" />
		<!--- ************************************************************* --->
		<cfset instance.joBufferedWriter.write(javaCast("string", arguments.strIn)) />
		<cfset instance.joBufferedWriter.newLine() />
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="newLine" access="public" returntype="void" output="No" hint="Uses the platform's own notion of line separator. Not all platforms use the newline character ('\n') to terminate lines.">
		<cfset instance.joBufferedWriter.newLine() />
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="close" access="public" returntype="void" output="No" hint="flushes and closes stream, buffer, and file">
		<cfscript>
			instance.joBufferedWriter.flush();
			instance.joOutputStreamWriter.flush();
			instance.joBufferedWriter.close();
			instance.joOutputStreamWriter.close();
			instance.joFileOutputStream.close();
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="bufferSizeLimit" access="private" returntype="numeric" output="No" hint="limit the buffer between 8k and 128k. Come on, let's be reasonable.">
		<!--- ************************************************************* --->
		<cfargument name="bufferSize" type="numeric" required="no" default="8192" hint="the buffer size for the bufferedWriter" />
		<!--- ************************************************************* --->
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

	<!--- ************************************************************* --->

	<cffunction name="getFileEncoding" access="private" returntype="void" output="No" hint="checks for a valid file encoding">
		<!--- ************************************************************* --->
		<cfargument name="fileEncoding" type="string" required="yes" hint="the file encoding" />
		<!--- ************************************************************* --->
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
						instance.joFileOutputStream.write(239); // 0xEF
						instance.joFileOutputStream.write(187); // 0xBB
						instance.joFileOutputStream.write(191); // 0xBF
						break;
					case 'UTF-16LE' : /* FF FE */
						instance.joFileOutputStream.write(255); // 0xFF
						instance.joFileOutputStream.write(254); // 0xFE
						break;
					case 'UTF-16BE' : /* FE FF */
						instance.joFileOutputStream.write(254); // 0xFE
						instance.joFileOutputStream.write(255); // 0xFF
						break;
					default :
						/* no BOM */
				}
			</cfscript>
		<cfelse>
			<cfset instance.joFileOutputStream.close() />
			<cfthrow type="Framework.plugins.FileWriter.InvalidEncodingException" message="The encoding: #arguments.fileEncoding# is not a valid encoding.">
		</cfif>
	</cffunction>

	<!--- ************************************************************* --->

</cfcomponent>