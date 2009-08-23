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
<cfcomponent hint="A utility tool that can marshall data to XML"
			 extends="coldbox.system.Plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<cffunction name="init" access="public" returntype="XMLConverter" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
			super.init(arguments.controller);
			
			// Plugin Properties
			setpluginName("XMLConverter");
			setpluginVersion("1.0");
			setpluginDescription("A utility to marshall data to XML");
			setPluginAuthor("Luis Majano & Sana Ullah");
			setPluginAuthorURL("http://www.coldbox.org");
			
			instance.xml = createObject("component","coldbox.system.core.util.conversion.XMLConverter").init();
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<cffunction name="toXML" access="public" returntype="string" hint="Convert any type of data to XML. This method will auto-discover the type. Valid types are array,query,struct" output="false" >
		<cfargument name="data" 		type="any"  	required="true" hint="The data to convert to xml">
		<cfargument name="columnlist"   type="string"   required="false" hint="Choose which columns to inspect, by default it uses all the columns in the query, if using a query">
		<cfargument name="useCDATA"  	type="boolean"  required="false" default="false" hint="Use CDATA content for ALL values. The default is false">
		<cfargument name="addHeader"  	type="boolean"  required="false" default="true" hint="Add an xml header to the packet returned.">
		<cfargument name="encoding" 	type="string" 	required="true"  default="UTF-8" hint="The character encoding of the header. UTF-8 is the default"/>
		<cfargument name="delimiter" 	type="string" 	required="false" default="," hint="The delimiter in the list. Comma by default">
		<cfargument name="rootName"     type="string"   required="true"   default="" hint="The name of the root element, else it defaults to the internal defaults."/>
		<cfreturn instance.xml.toXML(argumentCollection=arguments)>
	</cffunction>
	
	<cffunction name="arrayToXML" returnType="string" access="public" output="false" hint="Converts an array into XML with no headers.">
		<cfargument name="data" 		type="array"    required="true" hint="The array to convert">
		<cfargument name="useCDATA"  	type="boolean"  required="false" default="false" hint="Use CDATA content for ALL values. False by default">
		<cfargument name="rootName"     type="string"   required="true"   default="" hint="The name of the root element, else it defaults to the internal defaults."/>
		<cfreturn instance.xml.arrayToXML(argumentCollection=arguments)>
	</cffunction>
	
	<cffunction name="queryToXML" returnType="string" access="public" output="false" hint="Converts a query to XML with no headers.">
		<cfargument name="data" 		type="query"  required="true" hint="The query to convert">
		<cfargument name="CDATAColumns" type="string" required="false" default="" 		hint="Which columns to wrap in cdata tags">
		<cfargument name="columnlist"   type="string" required="false" default="#arguments.data.columnlist#" hint="Choose which columns to include in the translation, by default it uses all the columns in the query">
		<cfargument name="useCDATA"  	type="boolean" required="false" default="false" hint="Use CDATA content for ALL values">
		<cfargument name="rootName"     type="string"  required="true"   default="" hint="The name of the root element, else it defaults to the internal defaults."/>
		<cfreturn instance.xml.queryToXML(argumentCollection=arguments)>
	</cffunction>

	<cffunction name="structToXML" returnType="string" access="public" output="false" hint="Converts a struct into XML with no headers.">
		<cfargument name="data" 		type="any" 		required="true" hint="The structure, object, any to convert.">
		<cfargument name="useCDATA"  	type="boolean"  required="false"  default="false" hint="Use CDATA content for ALL values">
		<cfargument name="rootName"     type="string"   required="true"   default="" hint="The name of the root element, else it defaults to the internal defaults."/>
		<cfreturn instance.xml.structToXML(argumentCollection=arguments)>
	</cffunction>

</cfcomponent>