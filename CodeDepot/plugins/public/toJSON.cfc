<!---
	Stolen from Raymond Camden. This is a very similar to Ray's toXML.cfc. 
	If you are going to steal, steal from the best. 
				Doug Laakso
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
	Name         : toJSON
	Author       : Raymond Camden (ray@camdenfamily.com) 
	Created      : 2007
	Last Updated : Tuesday, March 20, 2007
	History      : Switched to stringbuffer (rkc 7/13/06)
							 : Switched from xml to json.		
--->

<cfcomponent name="toJSON"
			 hint="Set of utility functions to generate JSON."
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

	<!--- ************************************************************* --->

	<cffunction name="init" access="public" returntype="toJSON" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
		super.Init(arguments.controller);
		setpluginName("To JSON");
		setpluginVersion("1.0");
		setpluginDescription("utility functions to generate JSON");
		return this;
		</cfscript>
	</cffunction>
	
<cffunction name="arrayToJSON" returnType="string" access="public" output="false" hint="Converts an array into JSON">
	<cfargument name="data" type="array" required="true" />
	<cfargument name="rootelement" type="string" required="false" default="" />
	<cfset var s = createObject('java','java.lang.StringBuffer').init("")>
	<cfset var x = "">
	<cfset var d1="" />
	<cfset var d2="," />	
	<cfif len(arguments.rootelement)>
		<cfset s.append('{"#arguments.rootelement#>":') />		
	</cfif>	
	<cfset s.append('[') />
	<cfloop index="x" from="1" to="#arrayLen(arguments.data)#">
		<cfset s.append('#d1#"#arguments.rootelement#":"#safeText(arguments.data[x])#"')>
		<cfset d1=d2 />
	</cfloop>
	<cfset s.append(']') />
	<cfif len(arguments.rootelement)>
		<cfset s.append("}")>	
	</cfif>
	<cfreturn s.toString()>
</cffunction>

<cffunction name="listToJSON" returnType="string" access="public" output="false" hint="Converts a list into JSON.">
	<cfargument name="data" type="string" required="true">
	<cfargument name="rootelement" type="string" required="false" default="" />
	<cfargument name="delimiter" type="string" required="false" default="," />
	<cfreturn arrayToJSON( listToArray(arguments.data, arguments.delimiter), arguments.rootelement)>
</cffunction>

<cffunction name="queryToJSON" returnType="string" access="public" output="false" hint="Converts a query to JSON">
	<cfargument name="data" type="query" required="true" />
	<cfargument name="rootelement" type="string" required="true" /> 
	<cfargument name="cDataCols" type="string" required="false" default="" />
	
	<cfset var s = createObject('java','java.lang.StringBuffer').init("") />
	<cfset var col = "" />
	<cfset var columns = arguments.data.columnlist />
	<cfset var txt = "" />
	<cfset var d1="" />
	<cfset var d2="," />

	<cfset s.append('{"#arguments.rootelement#":[') />
	<cfloop query="arguments.data">
		<cfset s.append("#d1#{") />
		<cfset d1="" />
		<cfloop index="col" list="#columns#">
			<cfset txt = arguments.data[col][currentRow] />
			<cfif isSimpleValue(txt)>					
				<cfif listFindNoCase(arguments.cDataCols, col)>
					<cfset txt = escText(txt) />
				<cfelse>
					<cfset txt = safeText(txt) />
				</cfif>
			<cfelse>
				<cfset txt = "" />
			</cfif>

			<cfset s.append('#d1#"#col#":"#txt#"') />
			<cfset d1=d2 />
		</cfloop>
		
		<cfset s.append("}") />	
	</cfloop>	
	<cfset s.append("]}") />
	<cfreturn s.toString() />
</cffunction>

<cffunction name="structToJSON" returnType="string" access="public" output="false" hint="Converts a struct into JSON.">
	<cfargument name="data" type="struct" required="true" />
	<cfargument name="rootelement" type="string" required="true" />
	<cfset var s = createObject('java','java.lang.StringBuffer').init("") />
	<cfset var keys = structKeyList(arguments.data) />
	<cfset var key = "" />
	<cfset var d1="" />
	<cfset var d2="," />
	<cfset s.append('"#arguments.rootelement#"{') />
	<cfloop index="key" list="#keys#">
		<cfset s.append('#d1#"#key#":"#safeText(arguments.data[key])#"') />
		<cfset d1=d2 />
	</cfloop>	
	<cfset s.append("}") />	
	<cfreturn s.toString() />		
</cffunction>

<!--- Fix damn smart quotes. Thank you Microsoft! --->
<!--- This line taken from Nathan Dintenfas' SafeText UDF --->
<!--- www.cflib.org/udf.cfm/safetext --->
<!--- I wrapped up both xmlFormat and this code together. --->
<cffunction name="safeText" returnType="string" access="private" output="false">
	<cfargument name="txt" type="string" required="true">
	<cfset arguments.txt = replaceList(arguments.txt,chr(8216) & "," & chr(8217) & "," & chr(8220) & "," & chr(8221) & "," & chr(8212) & "," & chr(8213) & "," & chr(8230),"',',"","",--,--,...")>
	<cfreturn xmlFormat(arguments.txt)>
</cffunction>

<cffunction name="escText" returntype="string" access="private" output="false" hint="I escape reserved characters.">
	<cfargument name="txt" required="true" />
	<cfset var bad  = "\,"",#chr(8)#,#chr(9)#,#chr(12)#,#chr(13)##chr(10)#,#chr(10)#,#chr(13)#" /> 
	<cfset var good = "\\,\"",\b,\t,\f,\n,\n" />
	<cfset arguments.txt = replaceList(arguments.txt,bad,good) />
	<cfset arguments.txt = REReplace(arguments.txt, "\bu([0-9a-f]{4})\b", "\u\1") />
	<cfset arguments.txt = replaceList(arguments.txt,chr(8216) & "," & chr(8217) & "," & chr(8220) & "," & chr(8221) & "," & chr(8212) & "," & chr(8213) & "," & chr(8230),"',',"","",--,--,...")>
<!--- 
	<cfset arguments.txt = REReplace(arguments.txt, "\s+", " ") />
 --->
	<cfreturn arguments.txt />
</cffunction>

</cfcomponent>