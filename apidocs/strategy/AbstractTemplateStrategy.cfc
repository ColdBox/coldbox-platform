<cfcomponent hint="Abstract base class for general templating strategies" output="false"
			 colddoc:abstract="true">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cfscript>
	instance.static.META_ABSTRACT = "colddoc:abstract";
	instance.static.META_GENERIC = "colddoc:generic";
</cfscript>

<cffunction name="run" hint="Run this strategy" access="public" returntype="void" output="false">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfthrow type="AbstractMethodException" message="Method is abstract and must be overwritten"
			detail="The method 'run' in  component '#getMetadata(this).name#' is abstract and must be overwritten" />
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="init" hint="Constructor" access="private" returntype="void" output="false">
	<cfscript>
		setFunctionQueryCache( structNew() );
		setPropertyQueryCache( structnew() );
	</cfscript>
</cffunction>

<cffunction name="buildPackageTree" hint="builds a data structure that shows the tree structure of the packages" access="public" returntype="struct" output="false"
			colddoc:generic="string,struct">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfscript>
		var qPackages = 0;
		var tree = {};
		var root = 0;
		var node = 0;
		var item = 0;
    </cfscript>
	<cfquery name="qPackages" dbtype="query" debug="false">
		SELECT DISTINCT
			package
		FROM
			arguments.qMetaData
		ORDER BY
			package
	</cfquery>

	<cfloop query="qPackages">
		<cfset node = tree>
		<cfloop list="#package#" index="item" delimiters=".">
			<cfscript>
				if(NOT structKeyExists(node, item))
				{
					node[item] = {};
				}

				node = node[item];
            </cfscript>
		</cfloop>
	</cfloop>

	<cfreturn tree />
</cffunction>

<cffunction name="visitPackageTree" hint="visit each element on the package tree" access="private" returntype="void" output="false">
	<cfargument name="packageTree" hint="the package tree" type="struct" required="Yes" colddoc:generic="string,struct">
	<cfargument name="startCommand" hint="the command to call on each visit" type="any" required="Yes">
	<cfargument name="endCommand" hint="the command to call on each visit" type="any" required="Yes">
	<cfargument name="args" hint="the extra arguments to get passed on to the visitor command (name, and fullname get passed by default)" type="struct" required="No" default="#structNew()#" colddoc:generic="string,any">
	<cfscript>
		var startCall = arguments.startCommand;
		var endCall = arguments.endCommand;
		var keys = 0;
		var node = 0;
		var thisArgs = 0;

		if(NOT StructKeyExists(args, "fullname"))
		{
			arguments.args.fullname = "";
		}

		for(key in arguments.packageTree)
		{
			thisArgs = structCopy(arguments.args);
			thisArgs.name = key;
			thisArgs.fullName = listAppend(thisArgs.fullName, thisArgs.name, ".");

			startCall(argumentCollection=thisArgs);

			visitPackageTree(packageTree[key], startCall, endCall, thisArgs);

			endCall(argumentCollection=thisArgs);
		}

    </cfscript>
</cffunction>

<cffunction name="isPrimitive" hint="is the type a primitive value?" access="private" returntype="boolean" output="false">
	<cfargument name="type" hint="the cf type" type="string" required="Yes">
	<cfscript>
		var primitives = "string,date,struct,array,void,binary,numeric,boolean,query,xml,uuid,any,component";
		return ListFindNoCase(primitives, arguments.type);
    </cfscript>
</cffunction>

<cffunction name="buildFunctionMetaData" hint="builds a sorted query of function meta" access="public" returntype="query" output="false">
	<cfargument name="metadata" hint="" type="struct" required="Yes">
	<cfscript>
		var qFunctions = QueryNew("name,metadata");
		var func = 0;
		var result = 0;
		var cache = getFunctionQueryCache();

		if(StructKeyExists(cache, arguments.metadata.name))
		{
			return cache[arguments.metadata.name];
		}

		if(NOT StructKeyExists(arguments.metadata, "functions"))
		{
			return qFunctions;
		}
	</cfscript>
	<cfloop array="#arguments.metadata.functions#" index="func">
		<cfscript>
			//dodge cfthread functions
			if(NOT JavaCast("string", func.name).startsWith("_cffunccfthread_"))
			{
				QueryAddRow(qFunctions);
				QuerySetCell(qFunctions, "name", func.name);
				QuerySetCell(qFunctions, "metadata", safeFunctionMeta(func, arguments.metadata));
			}
		</cfscript>
	</cfloop>

	<cfset results = getMetaSubQuery(query=qFunctions, orderby="name asc") />

	<cfset cache[arguments.metadata.name] = results />

	<cfreturn results />
</cffunction>

<cffunction name="buildPropertyMetaData" hint="builds a sorted query of property meta" access="public" returntype="query" output="false">
	<cfargument name="metadata" hint="" type="struct" required="Yes">
	<cfscript>
		var qProperties = QueryNew( "name, metadata" );
		var prop = 0;
		var result = 0;
		var cache = getPropertyQueryCache();

		if( StructKeyExists(cache, arguments.metadata.name) )
		{
			return cache[arguments.metadata.name];
		}

		if(NOT StructKeyExists( arguments.metadata, "properties") )
		{
			return qProperties;
		}
	</cfscript>
	<cfloop array="#arguments.metadata.properties#" index="prop">
		<cfscript>
			QueryAddRow( qProperties );
			QuerySetCell( qProperties, "name", prop.name );
			QuerySetCell( qProperties, "metadata", safePropertyMeta(prop, arguments.metadata) );
		</cfscript>
	</cfloop>

	<cfset results = getMetaSubQuery( query=qProperties, orderby="name asc" ) />

	<cfset cache[ arguments.metadata.name ] = results />

	<cfreturn results />
</cffunction>

<cffunction name="getObjectName" hint="returns the simple object name from a full class name" access="private" returntype="string" output="false">
	<cfargument name="class" hint="the class name" type="string" required="Yes">
	<cfscript>
		if(len(arguments.class))
		{
			return ListGetAt(arguments.class, ListLen(arguments.class, "."), ".");
		}

		return arguments.class;
	</cfscript>
</cffunction>

<cfscript>
	function getPackage(class)
	{
		var objectname = getObjectName(arguments.class);
		var lenCount = Len(arguments.class) - (Len(objectname) + 1);
	       
		if( lenCount gt 0 )
		{
		    return Left(arguments.class, lenCount);
		}
		else
		{
		    return arguments.class;
		}
	}
</cfscript>

<cffunction name="classExists" hint="Whether or not the CFC class exists (does not test for primitives)" access="private" returntype="boolean" output="false">
	<cfargument name="qMetaData" hint="the meta data query" type="query" required="Yes">
	<cfargument name="className" hint="the name of the class to check for" type="string" required="Yes">
	<cfargument name="package" hint="the package the class comes from" type="string" required="Yes">
	<cfscript>
		var resolvedClassName = resolveClassName(arguments.className, arguments.package);
		var objectName = getObjectName(resolvedClassName);
		var packageName = getPackage(resolvedClassName);
		var qClass = getMetaSubQuery(arguments.qMetaData, "LOWER(package)=LOWER('#packageName#') AND LOWER(name)=LOWER('#objectName#')");

		return qClass.recordCount;
    </cfscript>
</cffunction>

<cffunction name="typeExists" hint="whether a type exists at all - be it class name, or primitive type" access="private" returntype="boolean" output="false">
	<cfargument name="qMetaData" hint="the meta data query" type="query" required="Yes">
	<cfargument name="className" hint="the name of the class to check for" type="string" required="Yes">
	<cfargument name="package" hint="the package the class comes from" type="string" required="Yes">
	<cfscript>
		return isPrimitive(arguments.className) OR classExists(argumentCollection=arguments);
    </cfscript>
</cffunction>

<cffunction name="resolveClassName" hint="resolves a class name that may not be full qualified" access="private" returntype="string" output="false">
	<cfargument name="className" hint="the name of the class" type="string" required="Yes">
	<cfargument name="package" hint="the package the class comes from" type="string" required="Yes">
	<cfscript>
		if(ListLen(arguments.className, ".") eq 1)
		{
			arguments.className = arguments.package & "." & arguments.className;
		}

		return arguments.className;
    </cfscript>
</cffunction>

<cffunction name="getMetaSubQuery" hint="returns a query on the meta query" access="private" returntype="query" output="false">
	<cfargument name="query" hint="the meta data query" type="query" required="Yes">
	<cfargument name="where" hint="the where string" type="string" required="false">
	<cfargument name="orderby" hint="the order by string" type="string" required="false">
	<cfset qSub = 0 />
	<cfquery name="qSub" dbtype="query" debug="false">
		SELECT *
		from
		arguments.query
		<cfif StructKeyExists(arguments, "where")>
			WHERE
			#PreserveSingleQuotes(arguments.where)#
		</cfif>
		<cfif StructKeyExists(arguments, "orderby")>
			ORDER BY
			#arguments.orderby#
		</cfif>
	</cfquery>
	<cfreturn qSub />
</cffunction>

<cffunction name="safeFunctionMeta" hint="sets default values" access="private" returntype="any" output="false">
	<cfargument name="func" hint="the function meta" type="any" required="Yes">
	<cfargument name="metadata" hint="the original meta data" type="struct" required="Yes">
	<cfscript>
		var local = {};

		if(NOT StructKeyExists(arguments.func, "returntype"))
		{
			arguments.func.returntype = "any";
		}

		if(NOT StructKeyExists(arguments.func, "access"))
		{
			arguments.func.access = "public";
		}

		//move the cfproperty hints onto functions
		if(StructKeyExists(arguments.metadata, "properties"))
		{
			if(Lcase(arguments.func.name).startsWith("get") AND NOT StructKeyExists(arguments.func, "hint"))
			{
				local.name = replaceNoCase(arguments.func.name, "get", "");
				local.property = getPropertyMeta(local.name, arguments.metadata.properties);

				if(structKeyExists(local.property, "hint"))
				{
					arguments.func.hint = "get: " & local.property.hint;
				}

			}
			else if(LCase(arguments.func.name).startsWith("set") AND NOT StructKeyExists(arguments.func, "hint"))
			{
				local.name = replaceNoCase(arguments.func.name, "set", "");
				local.property = getPropertyMeta(local.name, arguments.metadata.properties);

				if(structKeyExists(local.property, "hint"))
				{
					arguments.func.hint = "set: " & local.property.hint;
				}
			}
		}

		//move any argument meta from @foo.bar annotations onto the argument meta
		if(structKeyExists(arguments.func, "parameters"))
		{
			for(local.metaKey in arguments.func)
			{
				if(ListLen(local.metaKey, ".") gt 1)
				{
					local.paramKey = listGetAt(local.metaKey, 1, ".");
					local.paramExtraMeta = listGetAt(local.metaKey, 2, ".");
					local.paramMetaValue = arguments.func[local.metaKey];

					local.len = ArrayLen(arguments.func.parameters);
                    for(local.counter=1; local.counter lte local.len; local.counter++)
                    {
                    	local.param = arguments.func.parameters[local.counter];

						if(local.param.name eq local.paramKey)
						{
							local.param[local.paramExtraMeta] = local.paramMetaValue;
						}
                    }
				}
			}
		}
		return arguments.func;
	</cfscript>
</cffunction>

<cffunction name="safePropertyMeta" hint="sets default values" access="private" returntype="any" output="false">
	<cfargument name="prop" hint="the property meta" type="any" required="Yes">
	<cfargument name="metadata" hint="the original meta data" type="struct" required="Yes">
	<cfscript>
		var local = {};

		if(NOT StructKeyExists(arguments.prop, "type"))
		{
			arguments.prop.type = "any";
		}

		if(NOT StructKeyExists(arguments.prop, "required"))
		{
			arguments.prop.required = false;
		}
		
		if(NOT StructKeyExists(arguments.prop, "hint"))
		{
			arguments.prop.hint = "";
		}
		
		
		if(NOT StructKeyExists(arguments.prop, "default"))
		{
			arguments.prop.default = "";
		}
		
		if(NOT StructKeyExists(arguments.prop, "serializable"))
		{
			arguments.prop.serializable = true;
		}
		
		
		return arguments.prop;
	</cfscript>
</cffunction>

<cffunction name="getPropertyMeta" hint="returns the property meta by a given name" access="private" returntype="struct" output="false">
	<cfargument name="name" hint="the name of the property" type="string" required="Yes">
	<cfargument name="properties" hint="the property meta" type="array" required="Yes">
	<cfscript>
		var local = {};
    </cfscript>
	<cfloop array="#arguments.properties#" index="local.property">
		<cfif local.property.name eq arguments.name>
			<cfreturn local.property />
		</cfif>
	</cfloop>
	<cfreturn StructNew() />
</cffunction>

<cffunction name="safeParamMeta" hint="sets default values" access="private" returntype="any" output="false">
	<cfargument name="param" hint="the param meta" type="any" required="Yes">
	<cfscript>
		if(NOT StructKeyExists(arguments.param, "type"))
		{
			arguments.param.type = "any";
		}

		return arguments.param;
	</cfscript>
</cffunction>

<cffunction name="writeTemplate" hint="builds a template" access="private" returntype="void" output="false">
	<cfargument name="path" hint="where to write the template" type="string" required="Yes">
	<cfargument name="template" hint="the tempalte to write out" type="string" required="Yes">
	<cfscript>
		var html = 0;
		var local = {}; //for local variables
	</cfscript>
	<cfsavecontent variable="html"><cfinclude template="#arguments.template#"></cfsavecontent>
	<cfscript>
		fileWrite(arguments.path, html);
	</cfscript>
</cffunction>

<cffunction name="recursiveCopy" hint="does a recursive copy from one dir to another" access="private" returntype="void" output="false">
	<cfargument name="fromDir" hint="the input directory" type="string" required="Yes">
	<cfargument name="toDir" hint="the output directory" type="string" required="Yes">
	<cfscript>
		var files = 0;
		var currentDir = "";
		var safeDir = "";

		arguments.fromDir = replaceNoCase(arguments.fromDir, "\", "/", "all");
		arguments.toDir = replaceNoCase(arguments.toDir, "\", "/", "all");
	</cfscript>
	<cfdirectory action="list" directory="#arguments.fromDir#" recurse="true" name="qFiles">

	<cfoutput group="directory" query="qFiles">

		<cfset safeDir = replaceNoCase(directory, "\", "/", "all") />

		<!--- dodge svn directories --->
		<cfif NOT FindNoCase("/.", directory)>
			<cfscript>
				currentDir = arguments.toDir & replaceNoCase(safeDir & "/", arguments.fromDir, "");
				ensureDirectory(currentDir);
			</cfscript>
			<cfoutput>
				<cfscript>
					if(type neq "dir")
					{
						fileCopy(directory & "/" & name, currentDir & name);
					}
				</cfscript>
			</cfoutput>
		</cfif>
	</cfoutput>
</cffunction>

<cffunction name="ensureDirectory" hint="if a directory doesn't exist, create it" access="private" returntype="void" output="false">
	<cfargument name="path" hint="" type="string" required="Yes">
	<cfif NOT directoryExists(arguments.path)>
		<cfdirectory action="create" directory="#arguments.path#">
	</cfif>
</cffunction>

<!--- anotation discovery methods --->
<cffunction name="isAbstractClass" hint="is this class annotated as an abstract class?" access="private" returntype="boolean" output="false">
	<cfargument name="class" hint="the class name" type="string" required="Yes">
	<cfargument name="package" hint="the package the class comes from" type="string" required="Yes">
	<cfscript>
		var meta = 0;
		arguments.class = resolveClassName(arguments.class, arguments.package);

		meta = getComponentMetadata(arguments.class);

		if(structKeyExists(meta, instance.static.META_ABSTRACT))
		{
			return meta[instance.static.META_ABSTRACT];
		}

		return false;
    </cfscript>
</cffunction>

<cffunction name="getGenericTypes" hint="return an array of generic types associated with this function/argument" access="private" returntype="array" output="false"
	colddoc:generic="string">
	<cfargument name="meta" hint="either function, or argument metadata struct" type="struct" required="Yes">
	<cfargument name="package" hint="what package are we currently in?" type="string" required="Yes">
	<cfscript>
		var array = [];
		var local = {};

		if(structKeyExists(arguments.meta, instance.static.META_GENERIC))
		{
			array = listToArray(arguments.meta[instance.static.META_GENERIC]);

			local.len = ArrayLen(array);
            for(local.counter=1; local.counter lte local.len; local.counter++)
            {
            	local.class = array[local.counter];
				if(NOT isPrimitive(local.class))
				{
					array[local.counter] = resolveClassName(local.class, arguments.package);
				}
            }
		}

		return array;
    </cfscript>
</cffunction>

<cffunction name="getFunctionQueryCache" access="private" returntype="struct" output="false" colddoc:generic="string,struct">
	<cfreturn instance.functionQueryCache />
</cffunction>

<cffunction name="getPropertyQueryCache" access="private" returntype="struct" output="false" colddoc:generic="string,struct">
	<cfreturn instance.propertyQueryCache />
</cffunction>

<cffunction name="setFunctionQueryCache" access="private" returntype="void" output="false">
	<cfargument name="functionQueryCache" type="struct" required="true" colddoc:generic="string,query">
	<cfset instance.functionQueryCache = arguments.functionQueryCache />
</cffunction>

<cffunction name="setPropertyQueryCache" access="private" returntype="void" output="false">
	<cfargument name="propertyQueryCache" type="struct" required="true" colddoc:generic="string,query">
	<cfset instance.propertyQueryCache = arguments.propertyQueryCache />
</cffunction>

<cffunction name="_trace">
	<cfargument name="s">
	<cfset var g = "">
	<cfsetting showdebugoutput="true">
	<cfsavecontent variable="g">
		<cfdump var="#arguments.s#">
	</cfsavecontent>
	<cftrace text="#g#">
</cffunction>

<cffunction name="_dump">
	<cfargument name="s">
	<cfargument name="abort" default="true">
	<cfset var g = "">
		<cfdump var="#arguments.s#">
		<cfif arguments.abort>
		<cfabort>
		</cfif>
</cffunction>

</cfcomponent>
