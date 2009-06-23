<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
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

Modifications
	Luis Majano
	- Adaptation to using a more advanced algortithm on type detections
	- Ability to nest complex variables and still convert to XML.
	
--->
<cfcomponent name="XMLConverter"
			 hint="A utility tool that can marshall data to XML"
			 extends="coldbox.system.Plugin"
			 output="false"
			 cache="true">

	<!--- ************************************************************* --->

	<cffunction name="init" access="public" returntype="XMLConverter" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			super.Init(arguments.controller);
			
			setpluginName("XMLConverter");
			setpluginVersion("1.0");
			setpluginDescription("A utility to marshall data to XML");
			
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="toXML" access="public" returntype="string" hint="Convert any type of data to XML. This method will auto-discover the type. Valid types are array,query,struct" output="false" >
		<cfargument name="data" 		type="any"  	required="true" hint="the data to convert to xml">
		<cfargument name="rootelement" 	type="string"   required="false" default="data" hint="the root item element">
		<cfargument name="itemElement"  type="string"   required="false" hint="The name of the element representing a new element in an array or query.">
		<cfargument name="columnlist"   type="string"   required="false" hint="Choose which columns to inspect, by default it uses all the columns in the query, if using a query">
		<cfargument name="useCDATA"  	type="boolean"  required="false" default="false" hint="Use CDATA content for ALL values">
		<cfargument name="addHeader"  	type="boolean"  required="false" default="true" hint="Add an xml header">
		<cfscript>
			var buffer = createObject("java","java.lang.StringBuffer").init('');
			/* Header */
			if( arguments.addHeader ){
				buffer.append('<?xml version="1.0" encoding="UTF-8"?>');
			}
			/* if struct */
			if( isStruct(arguments.data) ){
				buffer.append( structToXML(argumentCollection=arguments) );
			}
			else if( isQuery(arguments.data) ){
				buffer.append( queryToXML(argumentCollection=arguments) );
			}
			else if( isArray(arguments.data) ){
				buffer.append( arrayToXML(argumentCollection=arguments) );
			}
			else if( isSimpleValue(arguments.data) ){
				arguments.data = listToArray(arguments.data);
				buffer.append( arrayToXML(argumentCollection=arguments) );
			}
			return buffer.toString();
		</cfscript>
	</cffunction>
	
	<cffunction name="arrayToXML" returnType="string" access="public" output="false" hint="Converts an array into XML">
		<cfargument name="data" 		type="array"  required="true" hint="the data to convert">
		<cfargument name="rootelement" 	type="string" required="false" default="array" hint="the root item element">
		<cfargument name="itemElement"  type="string" required="false" default="item" hint="The name of the element representing a new array element">
		<cfargument name="useCDATA"  	type="boolean" required="false" default="false" hint="Use CDATA content for ALL values">
		<cfscript>
		var buffer = createObject('java','java.lang.StringBuffer').init('');
		var target = arguments.data;		
		var x = 1;
		var dataLen = arrayLen(target);
		var thisValue = "";
		
		/* root */
		buffer.append("<#arguments.rootElement#>");
		
		/* Data */
		for(;x lte dataLen; x=x+1){
			thisValue = target[x];
			if( NOT isSimpleValue(thisValue) ){
				thisValue = translateValue(arguments,thisValue);
			}
			buffer.append("<#arguments.itemElement#>#safeText(thisValue,arguments.useCDATA)#</#arguments.itemElement#>");
		}
		
		/* End Root */
		buffer.append("</#arguments.rootElement#>");
		
		return buffer.toString();
		</cfscript>
	</cffunction>

	<cffunction name="listToXML" returnType="string" access="public" output="false" hint="Converts a list into XML.">
		<cfargument name="data" 		type="string" required="true" hint="The list to convert">
		<cfargument name="rootelement" 	type="string" required="false" default="list" hint="the root item element">
		<cfargument name="itemElement"  type="string" required="false" default="item" hint="The name of the element representing a new array element">
		<cfargument name="delimiter" 	type="string" required="false" default="," hint="The delimiter in the list">
		<cfargument name="useCDATA"  	type="boolean" required="false" default="false" hint="Use CDATA content for ALL values">
		<cfset arguments.data = listToArray(arguments.data,arguments.delimiter)>
		<cfreturn arrayToXML(argumentCollection=arguments)>
	</cffunction>
	
	<cffunction name="queryToXML" returnType="string" access="public" output="false" hint="Converts a query to XML">
		<cfargument name="data" 		type="query"  required="true" hint="The query to convert">
		<cfargument name="rootelement" 	type="string" required="false" default="query" 	hint="the root item element">
		<cfargument name="itemElement"  type="string" required="false" default="row" 	hint="The name of each xml item that represents a row">
		<cfargument name="cDataColumns" type="string" required="false" default="" 		hint="Which columns to wrap in cdata tags">
		<cfargument name="columnlist"   type="string" required="false" default="#arguments.data.columnlist#" hint="Choose which columns to inspect, by default it uses all the columns in the query">
		<cfargument name="useCDATA"  	type="boolean" required="false" default="false" hint="Use CDATA content for ALL values">
		<cfset var buffer = createObject('java','java.lang.StringBuffer').init('')>
		<cfset var col = "">
		<cfset var columns = arguments.columnlist>
		<cfset var value = "">
	
		<!--- Root --->
		<cfset buffer.append("<#arguments.rootelement#>")>
		
		<!--- Data --->
		<cfloop query="arguments.data">
			<cfset buffer.append("<#arguments.itemElement#>")>
			<cfloop index="col" list="#columns#">
				<!--- Get Value --->
				<cfset value = arguments.data[col][currentRow]>
				<!--- Check for nested translation --->
				<cfif NOT isSimpleValue(value)>
					<cfset value = translateValue(arguments,value)>
				</cfif>
				<!--- Check if in cdata columns --->
				<cfif arguments.useCDATA OR listFindNoCase(arguments.cDataColumns, col)>
					<cfset value = "<![CDATA[" & safeText(value) & "]]" & ">">
				<cfelse>
					<cfset value = safeText(value,arguments.useCDATA)>
				</cfif>
				<cfset buffer.append("<#col#>#value#</#col#>")>
			</cfloop>
			<cfset buffer.append("</#arguments.itemElement#>")>	
		</cfloop>
		
		<!--- End Root --->
		<cfset buffer.append("</#arguments.rootelement#>")>
		
		<cfreturn buffer.toString()>
	</cffunction>

	<cffunction name="structToXML" returnType="string" access="public" output="false" hint="Converts a struct into XML.">
		<cfargument name="data" 		type="struct" required="true">
		<cfargument name="rootelement" 	type="string" required="true">
		<cfargument name="useCDATA"  	type="boolean" required="false" default="false" hint="Use CDATA content for ALL values">
		<cfscript>
		var target = arguments.data;
		var buffer = createObject("java","java.lang.StringBuffer").init('');
		var key = 0;
		var thisValue = "";
		var args = structnew();
		
		/* Root */
		buffer.append("<#arguments.rootElement#>");
		/* Content */
		for(key in target){
			/* translate value */
			if( NOT isSimpleValue(target[key]) ){
				thisValue = translateValue(arguments,target[key]);
			}
			else{
				thisValue = safeText(target[key],arguments.useCDATA);
			}
			buffer.append("<#key#>#thisValue#</#key#>");
		}
		/* End Root */
		buffer.append("</#arguments.rootElement#>");
		
		return buffer.toString();
		</cfscript>
	</cffunction>


	<!--- This line taken from Nathan Dintenfas' SafeText UDF --->
	<!--- www.cflib.org/udf.cfm/safetext --->
	<cffunction name="safeText" returnType="string" access="private" output="false" hint="Create a safe xml text">
		<cfargument name="txt" 		type="string" required="true">
		<cfargument name="useCDATA" type="boolean" required="false" default="false" hint="Use CDATA content for ALL values">
		<cfset var newTxt = xmlFormat(unicodeWin1252(arguments.txt))>
		<cfif arguments.useCDATA>
			<cfreturn "<![CDATA[" & newTxt & "]]" & ">">
		<cfelse>
			<cfreturn newTxt>
		</cfif>
	</cffunction>

	<!--- This method written by Ben Garret (http://www.civbox.com/) --->
	<cffunction name="UnicodeWin1252" output="false" access="public" hint="Converts MS-Windows superset characters (Windows-1252) into their XML friendly unicode counterparts" returntype="string">
		<cfargument name="value" type="string" required="yes">
		<cfscript>
			var string = arguments.value;
			string = replaceNoCase(string,chr(8218),'&##8218;','all');	// � 
			string = replaceNoCase(string,chr(402),'&##402;','all');		// � 
			string = replaceNoCase(string,chr(8222),'&##8222;','all');	// � 
			string = replaceNoCase(string,chr(8230),'&##8230;','all');	// � 
			string = replaceNoCase(string,chr(8224),'&##8224;','all');	// � 
			string = replaceNoCase(string,chr(8225),'&##8225;','all');	// � 
			string = replaceNoCase(string,chr(710),'&##710;','all');		// � 
			string = replaceNoCase(string,chr(8240),'&##8240;','all');	// � 
			string = replaceNoCase(string,chr(352),'&##352;','all');		// � 
			string = replaceNoCase(string,chr(8249),'&##8249;','all');	// � 
			string = replaceNoCase(string,chr(338),'&##338;','all');		// � 
			string = replaceNoCase(string,chr(8216),'&##8216;','all');	// � 
			string = replaceNoCase(string,chr(8217),'&##8217;','all');	// � 
			string = replaceNoCase(string,chr(8220),'&##8220;','all');	// � 
			string = replaceNoCase(string,chr(8221),'&##8221;','all');	// � 
			string = replaceNoCase(string,chr(8226),'&##8226;','all');	// � 
			string = replaceNoCase(string,chr(8211),'&##8211;','all');	// � 
			string = replaceNoCase(string,chr(8212),'&##8212;','all');	// � 
			string = replaceNoCase(string,chr(732),'&##732;','all');		// � 
			string = replaceNoCase(string,chr(8482),'&##8482;','all');	// � 
			string = replaceNoCase(string,chr(353),'&##353;','all');		// � 
			string = replaceNoCase(string,chr(8250),'&##8250;','all');	// � 
			string = replaceNoCase(string,chr(339),'&##339;','all');		// � 
			string = replaceNoCase(string,chr(376),'&##376;','all');		// � 
			string = replaceNoCase(string,chr(376),'&##376;','all');		// � 
			string = replaceNoCase(string,chr(8364),'&##8364','all');		// � 
			return string;
		</cfscript>
	</cffunction>

	<cffunction name="translateValue" access="private" returntype="any" hint="Translate a value into XML" output="false" >
		<cfargument name="args"  type="struct" required="true" hint="The argument collection">
		<cfargument name="targetValue"  type="any" required="true" hint="The value to translate">
		<cfscript>
			arguments.args.data = arguments.targetValue;
			arguments.args.addHeader = false;
			return toXML(argumentCollection=arguments.args);
		</cfscript>
	</cffunction>

</cfcomponent>