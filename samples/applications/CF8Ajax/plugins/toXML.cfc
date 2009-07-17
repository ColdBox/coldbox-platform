<!---
LICENSE 
Copyright 2006 Raymond Camden

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   
If you find this app worthy, I have a Amazon wish list set up (www.amazon.com/o/registry/2TCL1D08EZEYE ). Gifts are always welcome. ;)
--->

<!---
	Name         : toxml
	Author       : Raymond Camden (ray@camdenfamily.com) 
	Created      : 2006
	Last Updated : 10/12/07
	History      : Switched to stringbuffer (rkc 7/13/06)
				 : xmlFormat doesn't strip out extended MS chars (rkc 11/2/06)
				 : All methods allow for optional arg to determine if the "XML" header is used (rkc 4/30/07)
				 : New xml stripper by Ben Garret (http://www.civbox.com/) (rkc 8/13/07)
				 : New columnList attribute to queryToXML, lets you specify columns (rkc 10/12/07)
--->
<cfcomponent name="toXML"
			 hint="Set of utility functions to generate XML."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

	<!--- ************************************************************* --->

	<cffunction name="init" access="public" returntype="toXML" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
		super.Init(arguments.controller);
		setpluginName("To XML");
		setpluginVersion("1.0");
		setpluginDescription("utility functions to generate JSON");
		return this;
		</cfscript>
	</cffunction>
	
<cffunction name="arrayToXML" returnType="string" access="public" output="false" hint="Converts an array into XML">
	<cfargument name="data" type="array" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">
	<cfargument name="includeheader" type="boolean" required="false" default="true">
	
	<cfset var s = createObject('java','java.lang.StringBuffer').init()>
	<cfset var x = "">
	
	<cfif arguments.includeheader>
		<cfset s.append("<?xml version=""1.0"" encoding=""UTF-8""?>")>
	</cfif>
	
	<cfset s.append("<#arguments.rootelement#>")>

	<cfloop index="x" from="1" to="#arrayLen(arguments.data)#">
		<cfset s.append("<#arguments.itemelement#>#safeText(arguments.data[x])#</#arguments.itemelement#>")>
	</cfloop>

	<cfset s.append("</#arguments.rootelement#>")>
	
	<cfreturn s.toString()>
</cffunction>

<cffunction name="listToXML" returnType="string" access="public" output="false" hint="Converts a list into XML.">
	<cfargument name="data" type="string" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">
	<cfargument name="delimiter" type="string" required="false" default=",">
	<cfargument name="includeheader" type="boolean" required="false" default="true">
	
	<cfreturn arrayToXML( listToArray(arguments.data, arguments.delimiter), arguments.rootelement, arguments.itemelement,arguments.includeheader)>
</cffunction>

<cffunction name="queryToXML" returnType="string" access="public" output="false" hint="Converts a query to XML">
	<cfargument name="data" type="query" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">
	<cfargument name="cDataCols" type="string" required="false" default="">
	<cfargument name="includeheader" type="boolean" required="false" default="true">
	<cfargument name="columnlist" type="string" required="false" default="#arguments.data.columnlist#">
	
	<cfset var s = createObject('java','java.lang.StringBuffer').init()>
	<cfset var col = "">
	<cfset var columns = arguments.columnlist>
	<cfset var txt = "">

	<cfif arguments.includeheader>
		<cfset s.append("<?xml version=""1.0"" encoding=""UTF-8""?>")>
	</cfif>

	<cfset s.append("<#arguments.rootelement#>")>
	
	<cfloop query="arguments.data">
		<cfset s.append("<#arguments.itemelement#>")>

		<cfloop index="col" list="#columns#">
			<cfset txt = arguments.data[col][currentRow]>
			<cfif isSimpleValue(txt)>
				<cfif listFindNoCase(arguments.cDataCols, col)>
					<cfset txt = "<![CDATA[" & txt & "]]" & ">">
				<cfelse>
					<cfset txt = safeText(txt)>
				</cfif>
			<cfelse>
				<cfset txt = "">
			</cfif>

			<cfset s.append("<#col#>#txt#</#col#>")>

		</cfloop>
		
		<cfset s.append("</#arguments.itemelement#>")>	
	</cfloop>
	
	<cfset s.append("</#arguments.rootelement#>")>
	
	<cfreturn s.toString()>
</cffunction>

<cffunction name="structToXML" returnType="string" access="public" output="false" hint="Converts a struct into XML.">
	<cfargument name="data" type="struct" required="true">
	<cfargument name="rootelement" type="string" required="true">
	<cfargument name="itemelement" type="string" required="true">
	<cfargument name="includeheader" type="boolean" required="false" default="true">
	
	<cfset var s = createObject('java','java.lang.StringBuffer').init()>

	<cfset var keys = structKeyList(arguments.data)>
	<cfset var key = "">

	<cfif arguments.includeheader>
		<cfset s.append("<?xml version=""1.0"" encoding=""UTF-8""?>")>
	</cfif>

	<cfset s.append("<#arguments.rootelement#>")>	
	<cfset s.append("<#arguments.itemelement#>")>

	<cfloop index="key" list="#keys#">
		<cfset s.append("<#key#>#safeText(arguments.data[key])#</#key#>")>
	</cfloop>
	
	<cfset s.append("</#arguments.itemelement#>")>
	<cfset s.append("</#arguments.rootelement#>")>
	
	<cfreturn s.toString()>		
</cffunction>

<!--- Fix damn smart quotes. Thank you Microsoft! --->
<!--- This line taken from Nathan Dintenfas' SafeText UDF --->
<!--- www.cflib.org/udf.cfm/safetext --->
<!--- I wrapped up both xmlFormat and this code together. --->
<cffunction name="safeText" returnType="string" access="private" output="false">
	<cfargument name="txt" type="string" required="true">
	<cfset arguments.txt = unicodeWin1252(arguments.txt)>
	<cfreturn xmlFormat(arguments.txt)>
</cffunction>

<!--- This method written by Ben Garret (http://www.civbox.com/) --->
<cffunction name="UnicodeWin1252" hint="Converts MS-Windows superset characters (Windows-1252) into their XML friendly unicode counterparts" returntype="string">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
		var string = value;
		string = replaceNoCase(string,chr(8218),'&##8218;','all');	// ‚ 
		string = replaceNoCase(string,chr(402),'&##402;','all');		// ƒ 
		string = replaceNoCase(string,chr(8222),'&##8222;','all');	// „ 
		string = replaceNoCase(string,chr(8230),'&##8230;','all');	// … 
		string = replaceNoCase(string,chr(8224),'&##8224;','all');	// † 
		string = replaceNoCase(string,chr(8225),'&##8225;','all');	// ‡ 
		string = replaceNoCase(string,chr(710),'&##710;','all');		// ˆ 
		string = replaceNoCase(string,chr(8240),'&##8240;','all');	// ‰ 
		string = replaceNoCase(string,chr(352),'&##352;','all');		// Š 
		string = replaceNoCase(string,chr(8249),'&##8249;','all');	// ‹ 
		string = replaceNoCase(string,chr(338),'&##338;','all');		// Œ 
		string = replaceNoCase(string,chr(8216),'&##8216;','all');	// ‘ 
		string = replaceNoCase(string,chr(8217),'&##8217;','all');	// ’ 
		string = replaceNoCase(string,chr(8220),'&##8220;','all');	// “ 
		string = replaceNoCase(string,chr(8221),'&##8221;','all');	// ” 
		string = replaceNoCase(string,chr(8226),'&##8226;','all');	// • 
		string = replaceNoCase(string,chr(8211),'&##8211;','all');	// – 
		string = replaceNoCase(string,chr(8212),'&##8212;','all');	// — 
		string = replaceNoCase(string,chr(732),'&##732;','all');		// ˜ 
		string = replaceNoCase(string,chr(8482),'&##8482;','all');	// ™ 
		string = replaceNoCase(string,chr(353),'&##353;','all');		// š 
		string = replaceNoCase(string,chr(8250),'&##8250;','all');	// › 
		string = replaceNoCase(string,chr(339),'&##339;','all');		// œ 
		string = replaceNoCase(string,chr(376),'&##376;','all');		// Ÿ 
		string = replaceNoCase(string,chr(376),'&##376;','all');		// Ÿ 
		string = replaceNoCase(string,chr(8364),'&##8364','all');		// € 
	</cfscript>
	<cfreturn string>
</cffunction>

</cfcomponent>