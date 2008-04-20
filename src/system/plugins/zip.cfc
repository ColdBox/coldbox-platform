<!---
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

*        Application: newsight Zip Component
*          File Name: Zip.cfc
* CFC Component Name: Zip
*            Support: ColdFusion MX 6.0, ColdFusion MX 6.1, ColdFusion MX 7
*         Created By: Artur Kordowski - info@newsight.de
*            Created: 16.06.2005
*        Description: A collections of functions that supports the Zip and GZip functionality by using the
*                     Java Zip file API.
*
*    Version History: [dd.mm.yyyy]   [Version]   [Author]        [Comments]
*                      16.06.2005     0.1 Beta    A. Kordowski    Beta status reached.
*                      27.06.2005     1.0         A. Kordowski    Component complete.
*                      07.08.2005     1.1         A. Kordowski    Fixed some bugs. Add GZip functionality. New functions
*                                                                 gzipAddFile() and gzipExtract().
*					   02.10.2005     1.2         A.Kordowski     Fixed bug for ColdFusion MX 6.
*
*           Comments: [dd.mm.yyyy]   [Version]   [Author]        [Comments]
*                      27.06.2005     0.1 Beta    A. Kordowski    Thanks a lot to Warren Sung for testing the Component with
*                                                                 ColdFusion MX 6.1 on Linux Debian 3.1.
*                      27.06.2005     0.1 Beta    A. Kordowski    Component tested with ColdFusion MX 7 on Windows XP Professional.
*                      29.06.2005     1.0         A. Kordowski    Created documentation.
*                      01.07.2005     1.0         A. Kordowski    Release component.
*                      08.08.2005     1.1         A. Kordowski    Update documentation.
*
*               Docs: http://livedocs.newsight.de/com/Zip/
*
*             Notice: For comments, bug reports or suggestions to optimise this component, feel free to send
*                     a E-Mail: info@newsight.de
*
*            License: THIS IS A OPEN SOURCE COMPONENT. YOU ARE FREE TO USE THIS COMPONENT IN ANY APPLICATION,
*                     TO COPY IT OR MODIFY THE FUNCTIONS FOR YOUR OWN NEEDS, AS LONG THIS HEADER INFORMATION
*                     REMAINS IN TACT AND YOU DON'T CHARGE ANY MONEY FOR IT. USE THIS COMPONENT AT YOUR OWN
*                     RISK. NO WARRANTY IS EXPRESSED OR IMPLIED, AND NO LIABILITY ASSUMED FOR THE RESULT OF
*                     USING THIS COMPONENT.
*
*                     THIS COMPONENT IS LICENSED UNDER THE CREATIVE COMMONS ATTRIBUTION-SHAREALIKE LICENSE.
*                     FOR THE FULL LICENSE TEXT PLEASE VISIT: http://creativecommons.org/licenses/by-sa/2.5/
*
************************************************************************************************

Author 	 :	Luis Majano
Date     :	September 23, 2005
Description :
	Converted this cfc into a ColdBox plugin.

Modification History:
08/01/2006 - Updated the cfc to work for ColdBox.
--->
<cfcomponent name="zip"
             hint = "A collections of functions that supports the Zip and GZip functionality by using the Java Zip file API."
             extends="coldbox.system.plugin"
			 output="false"
			 cache="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="zip" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfset super.Init(arguments.controller) />
		<cfscript>
		//Local Plugin Definition
		setpluginName("Zip Plugin");
		setpluginVersion("1.0");
		setpluginDescription("This is a zip utility for the framework.");
		//This plugin's properties
		instance.ioFile      = CreateObject("java","java.io.File");
		instance.ioInput     = CreateObject("java","java.io.FileInputStream");
		instance.ioOutput    = CreateObject("java","java.io.FileOutputStream");
		instance.ioBufOutput = CreateObject("java","java.io.BufferedOutputStream");
		instance.zipFile     = CreateObject("java","java.util.zip.ZipFile");
		instance.zipEntry    = CreateObject("java","java.util.zip.ZipEntry");
		instance.zipInput    = CreateObject("java","java.util.zip.ZipInputStream");
		instance.zipOutput   = CreateObject("java","java.util.zip.ZipOutputStream");
		instance.gzInput     = CreateObject("java","java.util.zip.GZIPInputStream");
		instance.gzOutput    = CreateObject("java","java.util.zip.GZIPOutputStream");
		instance.objDate     = CreateObject("java","java.util.Date");

		/* Set Localized Variables */
		instance.os = Server.OS.Name;
		instance.slash = createObject("java","java.lang.System").getProperty("file.separator");

		//LM. To fix Overflow.
		instance.filename = "";

		//Return instance
		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="AddFiles" access="public" output="no" returntype="boolean" hint="Add files to a new or an existing Zip file archive.">
		<!--- ************************************************************* --->
		<cfargument name="zipFilePath" required="yes" type="string"                hint="Pathname of the Zip file to add files.">
		<cfargument name="files"       required="no"  type="string"  default=""    hint="| (Chr(124)) delimited list of files to add to the Zip file. Required if argument 'directory' is not set.">
		<cfargument name="directory"   required="no"  type="string"  default=""    hint="Absolute pathname of directory to add to the Zip file. Required if argument 'files' is not set.">
		<cfargument name="filter"      required="no"  type="string"  default=""    hint="File extension filter. One filter can be applied. Only if argument 'directory' is set.">
		<cfargument name="recurse"     required="no"  type="boolean" default="no"  hint="Get recursive files of subdirectories. Only if argument 'directory' is set.">
		<cfargument name="compression" required="no"  type="numeric" default="9"   hint="Compression level (0 through 9, 0=minimum, 9=maximum).">
		<cfargument name="savePaths"   required="no"  type="boolean" default="no"  hint="Save full path info.">
		<!--- ************************************************************* --->
		<cfscript>
			/* Default variables */
			var i = 0;
			var l = 0;
			var buffer    = RepeatString(" ",1024).getBytes();
			var entryPath = "";
			var entryFile = "";
			var localfiles = "";
			var path = "";
			var skip = "";

			try{
				/* Initialize Zip file */
				instance.ioOutput.init(PathFormat(arguments.zipFilePath));
				instance.filename = getFileFromPath(arguments.zipFilePath);
				instance.zipOutput.init(instance.ioOutput);
				instance.zipOutput.setLevel(arguments.compression);

				/* Get files list array */
				if( structKeyExists(arguments, "files") and arguments.files neq "")
					localfiles = ListToArray(PathFormat(arguments.files), "|");
				else if( structKeyExists(arguments,"directory") and arguments.directory neq ""){
					localfiles = FilesList(arguments.directory, arguments.filter, arguments.recurse);
					arguments.directory = PathFormat(arguments.directory);
				}

				/* Loop over files array */
				for(i=1; i LTE ArrayLen(localfiles); i=i+1){
					if(FileExists(localfiles[i])){
						path = localfiles[i];

						// Get entry path and file
						entryPath = GetDirectoryFromPath(path);
						entryFile = GetFileFromPath(path);

						// Remove drive letter from path
						if(arguments.savePaths EQ "yes" AND Right(ListFirst(entryPath, instance.slash), 1) EQ ":")
							entryPath = ListDeleteAt(entryPath, 1, instance.slash);
						// Remove directory from path
						else if(arguments.savePaths EQ "no"){
							if( structKeyExists(arguments, "directory") and arguments.directory neq "" )
								entryPath = ReplaceNoCase(entryPath, arguments.directory, "", "ALL");
							else if(structKeyExists(arguments, "files") and arguments.files neq "")
								entryPath = "";
						}

						// Remove slash at first
						if(Len(entryPath) GT 1 AND Left(entryPath, 1) EQ instance.slash)      entryPath = Right(entryPath, Len(entryPath)-1);
						else if(Len(entryPath) EQ 1 AND Left(entryPath, 1) EQ instance.slash) entryPath = "" ;

						//  Skip if entry with the same name already exsits
						try	{
							instance.ioFile.init(path);
							instance.ioInput.init(instance.ioFile.getPath());

							instance.zipEntry.init(entryPath & entryFile);
							instance.zipOutput.putNextEntry(instance.zipEntry);

							l = instance.ioInput.read(buffer);

							while(l GT 0){
								instance.zipOutput.write(buffer, 0, l);
								l = instance.ioInput.read(buffer);
							}

							instance.zipOutput.closeEntry();
							instance.ioInput.close();
						}

						catch(java.util.zip.ZipException ex)
						{ skip = "yes"; }
					}
				}

				/* Close Zip file */
				instance.zipOutput.close();

				/* Return true */
				return true;
			}

			catch(Any expr)
			{
				/* Close Zip file */
				instance.zipOutput.close();

				/* Return false */
				return false;
			}

		</cfscript>

	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="DeleteFiles" access="public" output="no" returntype="boolean" hint="Delete files from an existing Zip file archive.">
		<!--- ************************************************************* --->
		<cfargument name="zipFilePath" required="yes" type="string" hint="Pathname of the Zip file to delete files from.">
		<cfargument name="files"       required="yes" type="string" hint="| (Chr(124)) delimited list of files to delete from Zip file.">
		<!--- ************************************************************* --->
		<cfscript>

			/* NOTICE: There is no function in the Java API to delete entrys from a Zip file.
			           So we have to create a workaround for this function. At first we create
					   a new temporary Zip file and save there all entrys, excluded the delete
					   files. Then we delete the orginal Zip file and rename the temporary Zip
					   file. */

			/* Default variables */
			var l = 0;
			var buffer = RepeatString(" ",1024).getBytes();
			var entries = "";
			var entry = "";
			var inStream = "";
			var zipTemp = "";
			var zipRename = "";
			/* Convert to the right path format */
			arguments.zipFilePath = PathFormat(arguments.zipFilePath);

			try{
				/* Open Zip file and get Zip file entries */
				instance.zipFile.init(arguments.zipFilePath);
				entries = instance.zipFile.entries();

				/* Create a new temporary Zip file */
				instance.ioOutput.init(PathFormat(arguments.zipFilePath & ".temp"));
				instance.zipOutput.init(instance.ioOutput);

				/* Loop over Zip file entries */
				while(entries.hasMoreElements()){
					entry = entries.nextElement();

					if(NOT entry.isDirectory()){
						/* Create a new entry in the temporary Zip file */
						if(NOT ListFindNoCase(arguments.files, entry.getName(), "|")){
							// Set entry compression
							instance.zipOutput.setLevel(entry.getMethod());

							// Create new entry in the temporary Zip file
							instance.zipEntry.init(entry.getName());
							instance.zipOutput.putNextEntry(instance.zipEntry);

							inStream = instance.zipFile.getInputStream(entry);
							l        = inStream.read(buffer);

							while(l GT 0){
								instance.zipOutput.write(buffer, 0, l);
								l = inStream.read(buffer);
							}

							// Close entry
							instance.zipOutput.closeEntry();
						}
					}
				}

				/* Close the orginal Zip and the temporary Zip file */
				instance.zipFile.close();
				instance.zipOutput.close();

				/* Delete the orginal Zip file */
				instance.ioFile.init(arguments.zipFilePath).delete();

				/* Rename the temporary Zip file */
				zipTemp   = instance.ioFile.init(arguments.zipFilePath & ".temp");
				zipRename = instance.ioFile.init(arguments.zipFilePath);
				zipTemp.renameTo(zipRename);

				/* Return true */
				return true;
			}

			catch(Any expr)
			{
				/* Close the orginal Zip and the temporary Zip file */
				instance.zipOutput.close();
				instance.zipFile.close();

				/* Delete the temporary Zip file, if exists */
				if(FileExists(arguments.zipFilePath & ".temp"))
					instance.ioFile.init(arguments.zipFilePath & ".temp").delete();

				/* Return false */
				return false;
			}

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="Extract" access="public" output="no" returntype="boolean" hint="Extracts a specified Zip file into a specified directory.">
		<!--- ************************************************************* --->
		<cfargument name="zipFilePath"    required="yes" type="string"                              hint="Pathname of the Zip file to extract.">
		<cfargument name="extractPath"    required="no"  type="string"  default="#ExpandPath(".")#" hint="Pathname to extract the Zip file to.">
		<cfargument name="extractFiles"   required="no"  type="string"                              hint="| (Chr(124)) delimited list of files to extract.">
		<cfargument name="useFolderNames" required="no"  type="boolean" default="yes"               hint="Create folders using the pathinfo stored in the Zip file.">
		<cfargument name="overwriteFiles" required="no"  type="boolean" default="no"                hint="Overwrite existing files.">
		<!--- ************************************************************* --->
		<cfscript>

			/* Default variables */
			var l = 0;
			var entries  = "";
			var entry    = "";
			var name     = "";
			var path     = "";
			var filePath = "";
			var buffer   = RepeatString(" ",1024).getBytes();
			var lastChr = "";
			var lenPath = "";
			var inStream = "";
			var skip = "";

			/* Convert to the right path format */
			arguments.zipFilePath = PathFormat(arguments.zipFilePath);
			arguments.extractPath = PathFormat(arguments.extractPath);

			/* Check if the 'extractPath' string is closed */
			lastChr = Right(arguments.extractPath, 1);

			/* Set an slash at the end of string */
			if(lastChr NEQ instance.slash)
				arguments.extractPath = arguments.extractPath & instance.slash;

			try{
				/* Open Zip file */
				instance.zipFile.init(arguments.zipFilePath);

				/* Zip file entries */
				entries = instance.zipFile.entries();

				/* Loop over Zip file entries */
				while(entries.hasMoreElements()){
					entry = entries.nextElement();

					if(NOT entry.isDirectory()){
						name = entry.getName();

						/* Create directory only if 'useFolderNames' is 'yes' */
						if(arguments.useFolderNames EQ "yes"){
							lenPath = Len(name) - Len(GetFileFromPath(name));

							if(lenPath) path = extractPath & Left(name, lenPath);
							else        path = extractPath;

							if(NOT DirectoryExists(path)){
								instance.ioFile.init(path);
								instance.ioFile.mkdirs();
							}
						}

						/* Set file path */
						if(arguments.useFolderNames EQ "yes") filePath = arguments.extractPath & name;
						else                                  filePath = arguments.extractPath & GetFileFromPath(name);

						/* Extract files. Files would be extract when following conditions are fulfilled:
						   If the 'extractFiles' list is not defined,
						   or the 'extractFiles' list is defined and the entry filename is found in the list,
						   or the file already exists and 'overwriteFiles' is 'yes'. */
						if((NOT structKeyExists(arguments, "extractFiles")
						    OR (structKeyExists(arguments, "extractFiles") AND ListFindNoCase(arguments.extractFiles, GetFileFromPath(name), "|")))
						   AND (NOT FileExists(filePath) OR (FileExists(filePath) AND arguments.overwriteFiles EQ "yes")))
						{
							// Skip if entry contains special characters
							try{
								instance.ioOutput.init(filePath);
								instance.ioBufOutput.init(instance.ioOutput);

								inStream = instance.zipFile.getInputStream(entry);
								l        = inStream.read(buffer);

								while(l GTE 0){
									instance.ioBufOutput.write(buffer, 0, l);
									l = inStream.read(buffer);
								}

								inStream.close();
								instance.ioBufOutput.close();
								instance.ioOutput.close();
							}

							catch(Any Expr)
							{ skip = "yes"; }
						}
					}
				}

				/* Close the Zip file */
				instance.zipFile.close();

				/* Return true */
				return true;
			}

			catch(Any expr){
				/* Close the Zip file */
				instance.zipFile.close();

				/* Return false */
				return false;
			}

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="List" access="public" output="no" returntype="query" hint="List the content of a specified Zip file.">
		<!--- ************************************************************* --->
		<cfargument name="zipFilePath" required="yes" type="string" hint="Pathname of the Zip file to list the content.">
		<!--- ************************************************************* --->
		<cfscript>
			/* Default variables */
			var i = 0;
			var entries = "";
			var entry   = "";
			var cols    = "entry,date,size,packed,ratio,crc";
			var query   = QueryNew(cols);
			var qEntry = "";
			var qDate = "";
			var qSize = "";
			var qPacked = "";
			var qCrc = "";
			var qRatio = "";

			cols = ListToArray(cols);

			/* Open Zip file */
			instance.zipFile.init(arguments.zipFilePath);

			/* Zip file entries */
			entries = instance.zipFile.entries();

			/* Fill query with data */
			while(entries.hasMoreElements()){
				entry = entries.nextElement();

				if(NOT entry.isDirectory()){
					QueryAddRow(query, 1);

					qEntry     = PathFormat(entry.getName());
					qDate      = instance.objDate.init(entry.getTime());
					qSize      = entry.getSize();
					qPacked    = entry.getCompressedSize();
					qCrc       = entry.getCrc();

					if(qSize GT 0) qRatio = Round(Evaluate(100-((qPacked*100)/qSize))) & "%";
					else           qRatio = "0%";

					for(i=1; i LTE ArrayLen(cols); i=i+1)
						QuerySetCell(query, cols[i], Trim(Evaluate("q#cols[i]#")));
				}
			}

			/* Close the Zip File */
			instance.zipFile.close();

			/* Return query */
			return query;
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="gzipAddFile" access="public" output="no" returntype="boolean" hint="Create a new GZip file archive.">
		<!--- ************************************************************* --->
		<cfargument name="gzipFilePath" required="yes" type="string" hint="Pathname of the GZip file to create.">
		<cfargument name="filePath"     required="yes" type="string" hint="Pathname of a file to add to the GZip file archive.">
		<!--- ************************************************************* --->
		<cfscript>
			/* Default variables */
			var l = 0;
			var buffer     = RepeatString(" ",1024).getBytes();
			var gzFileName = "";
			var outputFile = "";
			var lastChr = "";



			/* Convert to the right path format */
			arguments.gzipFilePath = PathFormat(arguments.gzipFilePath);
			arguments.filePath     = PathFormat(arguments.filePath);

			/* Check if the 'extractPath' string is closed */
			lastChr = Right(arguments.gzipFilePath, 1);

			/* Set an slash at the end of string */
			if(lastChr NEQ instance.slash)
				arguments.gzipFilePath = arguments.gzipFilePath & instance.slash;

			try{
				/* Set output gzip file name */
				gzFileName = getFileFromPath(arguments.filePath) & ".gz";
				outputFile = arguments.gzipFilePath & gzFileName;

				instance.ioInput.init(arguments.filePath);
				instance.ioOutput.init(outputFile);
				instance.gzOutput.init(instance.ioOutput);

				l = instance.ioInput.read(buffer);

				while(l GT 0){
					instance.gzOutput.write(buffer, 0, l);
					l = instance.ioInput.read(buffer);
				}

				/* Close the GZip file */
				instance.gzOutput.close();
				instance.ioOutput.close();
				instance.ioInput.close();

				/* Return true */
				return true;
			}

			catch(Any expr)
			{ return false; }

		</cfscript>

	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="gzipExtract" access="public" output="no" returntype="boolean" hint="Extracts a specified GZip file into a specified directory.">
		<!--- ************************************************************* --->
		<cfargument name="gzipFilePath" required="yes" type="string"                             hint="Pathname of the GZip file to extract.">
		<cfargument name="extractPath"  required="no"  type="string" default="#ExpandPath(".")#" hint="Pathname to extract the GZip file to.">
		<!--- ************************************************************* --->
		<cfscript>
			/* Default variables */
			var l = 0;
			var buffer     = RepeatString(" ",1024).getBytes();
			var gzFileName = "";
			var outputFile = "";
			var lastChr = "";

			/* Convert to the right path format */
			arguments.gzipFilePath = PathFormat(arguments.gzipFilePath);
			arguments.extractPath  = PathFormat(arguments.extractPath);

			/* Check if the 'extractPath' string is closed */
			lastChr = Right(arguments.extractPath, 1);

			/* Set an slash at the end of string */
			if(lastChr NEQ instance.slash)
				arguments.extractPath = arguments.extractPath & instance.slash;

			try{
				/* Set output file name */
				gzFileName = getFileFromPath(arguments.gzipFilePath);
				outputFile = arguments.extractPath & Left(gzFileName, Len(gzFileName)-3);

				/* Initialize gzip file */
				instance.ioOutput.init(outputFile);
				instance.ioInput.init(arguments.gzipFilePath);
				instance.gzInput.init(instance.ioInput);

				while(l GTE 0){
					instance.ioOutput.write(buffer, 0, l);
					l = instance.gzInput.read(buffer);
				}

				/* Close the GZip file */
				instance.gzInput.close();
				instance.ioInput.close();
				instance.ioOutput.close();

				/* Return true */
				return true;
			}
			catch(Any expr)
			{ return false; }

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- ************************************************************* --->

	<cffunction name="FilesList" access="private" output="no" returntype="array" hint="Create an array with the file names of specified directory.">
		<!--- ************************************************************* --->
		<cfargument name="directory" required="yes" type="string"               hint="Absolute pathname of directory to get files list.">
		<cfargument name="filter"    required="no"  type="string"  default=""   hint="File extension filter. One filter can be applied.">
		<cfargument name="recurse"   required="no"  type="boolean" default="no" hint="Get recursive files of subdirectories.">
		<!--- ************************************************************* --->
		<cfset var i = 0>
		<cfset var n = 0>
		<cfset var dir   = "">
		<cfset var array = ArrayNew(1)>
		<cfset var path = "">
		<cfset var subdir = "">

		<cfdirectory action    = "list"
					 name      = "dir"
		             directory = "#PathFormat(arguments.directory)#"
					 filter    = "#arguments.filter#">

		<cfscript>
			/* Loop over directory query */
			for(i=1; i LTE dir.recordcount; i=i+1){
				path = PathFormat(arguments.directory & instance.slash & dir.name[i]);

				/* Add file to array */
				if(dir.type[i] eq "file" and dir.name[i] neq instance.filename)
					ArrayAppend(array, path);

				/* Get files from sub directorys and add them to the array */
				else if(dir.type[i] EQ "dir" AND arguments.recurse EQ "yes"){
					subdir = FilesList(path, arguments.filter, arguments.recurse);

					for(n=1; n LTE ArrayLen(subdir); n=n+1)
						ArrayAppend(array, subdir[n]);
				}
			}

			/* Return array */
			return array;

		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="PathFormat" access="private" output="no" returntype="string" hint="Convert path into Windows or Unix format.">
		<!--- ************************************************************* --->
		<cfargument name="path" required="yes" type="string" hint="The path to convert.">
		<!--- ************************************************************* --->
		<cfif FindNoCase("Windows", instance.os)>
			<cfset arguments.path = Replace(arguments.path, "/", "\", "ALL")>
		<cfelse>
			<cfset arguments.path = Replace(arguments.path, "\", "/", "ALL")>
		</cfif>
		<cfreturn arguments.path>
	</cffunction>
	<!--- ************************************************************* --->

</cfcomponent>