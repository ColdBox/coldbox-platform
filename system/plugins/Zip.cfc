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
<cfcomponent name="Zip"
             hint = "A collections of functions that supports the Zip and GZip functionality by using the Java Zip file API."
             extends="coldbox.system.Plugin"
			 output="false"
			 cache="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="Zip" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			super.Init(arguments.controller);
			
			//Local Plugin Definition
			setpluginName("Zip");
			setpluginVersion("1.0");
			setpluginDescription("This is a zip utility for the framework.");
			setpluginAuthor("Luis Majano, Sana Ullah");
			setpluginAuthorURL("http://www.coldbox.org");
			
			instance.oZip = createObject("component","coldbox.system.util.Zip").init();
	
			//Return instance
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="addFiles" access="public" output="no" returntype="boolean" hint="Add files to a new or an existing Zip file archive.">
		<!--- ************************************************************* --->
		<cfargument name="zipFilePath" required="yes" type="string"                hint="Pathname of the Zip file to add files.">
		<cfargument name="files"       required="no"  type="string"  default=""    hint="| (Chr(124)) delimited list of files to add to the Zip file. Required if argument 'directory' is not set.">
		<cfargument name="directory"   required="no"  type="string"  default=""    hint="Absolute pathname of directory to add to the Zip file. Required if argument 'files' is not set.">
		<cfargument name="filter"      required="no"  type="string"  default=""    hint="File extension filter. One filter can be applied. Only if argument 'directory' is set.">
		<cfargument name="recurse"     required="no"  type="boolean" default="no"  hint="Get recursive files of subdirectories. Only if argument 'directory' is set.">
		<cfargument name="compression" required="no"  type="numeric" default="9"   hint="Compression level (0 through 9, 0=minimum, 9=maximum).">
		<cfargument name="savePaths"   required="no"  type="boolean" default="no"  hint="Save full path info.">
		<!--- ************************************************************* --->
		<cfreturn instance.oZip.addFiles(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="deleteFiles" access="public" output="no" returntype="boolean" hint="Delete files from an existing Zip file archive.">
		<!--- ************************************************************* --->
		<cfargument name="zipFilePath" required="yes" type="string" hint="Pathname of the Zip file to delete files from.">
		<cfargument name="files"       required="yes" type="string" hint="| (Chr(124)) delimited list of files to delete from Zip file.">
		<!--- ************************************************************* --->
		<cfreturn instance.oZip.deleteFiles(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="extract" access="public" output="no" returntype="boolean" hint="Extracts a specified Zip file into a specified directory.">
		<!--- ************************************************************* --->
		<cfargument name="zipFilePath"    required="yes" type="string"                              hint="Pathname of the Zip file to extract.">
		<cfargument name="extractPath"    required="no"  type="string"  default="#ExpandPath(".")#" hint="Pathname to extract the Zip file to.">
		<cfargument name="extractFiles"   required="no"  type="string"                              hint="| (Chr(124)) delimited list of files to extract.">
		<cfargument name="useFolderNames" required="no"  type="boolean" default="yes"               hint="Create folders using the pathinfo stored in the Zip file.">
		<cfargument name="overwriteFiles" required="no"  type="boolean" default="no"                hint="Overwrite existing files.">
		<!--- ************************************************************* --->
		<cfreturn instance.oZip.extract(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="list" access="public" output="no" returntype="query" hint="List the content of a specified Zip file.">
		<!--- ************************************************************* --->
		<cfargument name="zipFilePath" required="yes" type="string" hint="Pathname of the Zip file to list the content.">
		<!--- ************************************************************* --->
		<cfreturn instance.oZip.list(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="gzipAddFile" access="public" output="no" returntype="boolean" hint="Create a new GZip file archive.">
		<!--- ************************************************************* --->
		<cfargument name="gzipFilePath" required="yes" type="string" hint="Pathname of the GZip file to create.">
		<cfargument name="filePath"     required="yes" type="string" hint="Pathname of a file to add to the GZip file archive.">
		<!--- ************************************************************* --->
		<cfreturn instance.oZip.gzipAddFile(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="gzipExtract" access="public" output="no" returntype="boolean" hint="Extracts a specified GZip file into a specified directory.">
		<!--- ************************************************************* --->
		<cfargument name="gzipFilePath" required="yes" type="string"                             hint="Pathname of the GZip file to extract.">
		<cfargument name="extractPath"  required="no"  type="string" default="#ExpandPath(".")#" hint="Pathname to extract the GZip file to.">
		<!--- ************************************************************* --->
		<cfreturn instance.oZip.gzipExtract(argumentCollection=arguments)>
	</cffunction>


<!------------------------------------------- PRIVATE ------------------------------------------->

	

</cfcomponent>