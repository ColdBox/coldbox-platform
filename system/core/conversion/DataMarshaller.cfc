<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	Ability to serialize/deserialize data.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="Ability to serialize/deserialize data.">

	<!--- DI --->
	<cfproperty name="xmlConverter" inject="xmlConverter@coldbox">

	<!---Init --->
	<cffunction name="init" output="false" access="public" returntype="DataMarshaller" hint="Constructor">
    	<cfreturn this>
    </cffunction>

	<!--- marshallData --->
	<cffunction name="marshallData" access="public" returntype="any" hint="Marshall data according to types or conventions on data objects." output="false" >
		<!--- ******************************************************************************** --->
		<cfargument name="type" 		required="true" type="string" hint="The type to marshal to. Valid values are JSON, XML, WDDX, PLAIN, HTML, TEXT">
		<cfargument name="data" 		required="true" type="any" 	  hint="The data to marshal">
		<cfargument name="encoding" 	required="false" type="string" default="utf-8" hint="The default character encoding to use"/>
		<!--- ************************************************************* --->
		<cfargument name="jsonCallback" 	type="string" required="false" default="" hint="Only needed when using JSONP, this is the callback to add to the JSON packet"/>
		<cfargument name="jsonQueryFormat" 	type="string" 	required="false" default="query" hint="JSON Only: query or array" />
		<!--- ************************************************************* --->
		<cfargument name="xmlColumnList"    type="string"   required="false" default="" hint="XML Only: Choose which columns to inspect, by default it uses all the columns in the query, if using a query">
		<cfargument name="xmlUseCDATA"  	type="boolean"  required="false" default="false" hint="XML Only: Use CDATA content for ALL values. The default is false">
		<cfargument name="xmlListDelimiter" type="string"   required="false" default="," hint="XML Only: The delimiter in the list. Comma by default">
		<cfargument name="xmlRootName"      type="string"   required="false" default="" hint="XML Only: The name of the initial root element of the XML packet">
		<!--- ******************************************************************************** --->
		<cfargument name="pdfArgs"      type="struct"   required="false" default="#structNew()#" hint="All the PDF arguments to pass along to the CFDocument tag.">

		<cfset var results	= "">
		<cfset var args 	= {}>

		<!--- Validate Type --->
		<cfif not reFindnocase("^(JSON|JSONP|JSONT|WDDX|XML|PLAIN|HTML|TEXT|PDF)$",arguments.type)>
			<cfthrow message="Invalid type" detail="The type you sent: #arguments.type# is invalid. Valid types are JSON, JSONP, WDDX, XML, TEXT, PDF and PLAIN" type="InvalidMarshallingType">
		</cfif>

		<!--- $renderdata convention --->
		<cfif isObject( arguments.data ) AND structKeyExists( arguments.data, "$renderdata" )>
			<cfreturn arguments.data.$renderdata(argumentCollection=arguments)>
		</cfif>

		<!--- Switch on types --->
		<cfswitch expression="#arguments.type#">

			<!--- JSON --->
			<cfcase value="JSON,JSONP">
				<cfscript>
				// marshall to JSON
				results = serializeJSON( arguments.data, ( arguments.jsonQueryFormat eq "array") ? false : true );
				// wrap results in callback function for JSONP
				if( len( arguments.jsonCallback ) > 0 ){ results = "#arguments.jsonCallback#(#results#)"; }
				</cfscript>
			</cfcase>

			<!--- WDDX --->
			<cfcase value="WDDX">
				<cfwddx action="cfml2wddx" input="#arguments.data#" output="results">
			</cfcase>

			<!--- XML --->
			<cfcase value="XML">
				<cfscript>
				args.data = arguments.data;
				args.encoding = arguments.encoding;
				args.useCDATA = arguments.xmlUseCDATA;
				args.delimiter = arguments.xmlListDelimiter;
				args.rootName = arguments.xmlRootName;
				if( len( trim( arguments.xmlColumnList ) ) ){ args.columnlist = arguments.xmlColumnList; }
				// Marshal to xml
				results = xmlConverter.toXML( argumentCollection=args );
				</cfscript>
			</cfcase>

			<!--- PDF --->
			<cfcase value="pdf">
				<!--- Binary Set --->
				<cfset results = arguments.data>
				<!--- Check if NOT PDF Binary, to convert, else just return --->
				<cfif NOT isBinary( arguments.data )>
					<cfset pdfArgs.format="PDF">
					<cfset pdfArgs.name = "results">
					<!--- Convert to PDF --->
					<cfdocument attributeCollection=#pdfArgs#><cfoutput>#arguments.data#</cfoutput></cfdocument>
				</cfif>
			</cfcase>

			<!--- Plain, html, Custom --->
			<cfdefaultCase>
				<cfset results = arguments.data>
			</cfdefaultCase>
		</cfswitch>

		<!--- Return Marshalled data --->
		<cfreturn results>
	</cffunction>

   	<!--- renderContent --->
	<cffunction name="renderContent" output="false" access="public" returntype="any" hint="Facade to cfcontent as stupid CF does not allow via script">
		<cfargument name="type" 	required="true" hint="The content type"/>
		<cfargument name="variable" required="false" hint="The variable to render content from"/>
		<cfargument name="encoding" required="false" default="utf-8" hint="The encoding"/>
		<cfargument name="reset" 	required="false" default="false" type="boolean" hint="Reset the conten or not" >

   	   	<cfif structKeyExists( arguments, "variable")>
			<cfcontent type="#arguments.type#; charset=#arguments.encoding#" variable="#arguments.variable#" reset="#arguments.reset#"/>
		<cfelse>
			<cfcontent type="#arguments.type#; charset=#arguments.encoding#" reset="#arguments.reset#">
		</cfif>
		<cfsetting showdebugoutput="false" >
   	</cffunction>

	<!--- resetContent --->
	<cffunction name="resetContent" output="false" access="public" returntype="any" hint="Reset the CF content">
		<cfcontent reset="true">
	</cffunction>

</cfcomponent>