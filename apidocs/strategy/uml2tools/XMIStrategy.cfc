<cfcomponent output="false" hint="Strategy for generating the .uml file for Eclipse UML2Tools to generate diagrams from"
				extends="colddoc.strategy.AbstractTemplateStrategy" >

<!------------------------------------------- PUBLIC ------------------------------------------->

<cfscript>
	instance.static.TEMPLATE_PATH = "/colddoc/strategy/uml2tools/resources/templates";
</cfscript>

<cffunction name="init" hint="Constructor" access="public" returntype="XMIStrategy" output="false">
	<cfargument name="outputFile" hint="absolute path to the output file. File should end in .uml, if it doesn' it will be added." type="string" required="Yes">
	<cfscript>
		super.init();

		if(NOT arguments.outputFile.endsWith(".uml"))
		{
			arguments.outputFile &= ".uml";
		}

		setOutputFile(arguments.outputFile);

		return this;
	</cfscript>
</cffunction>

<cffunction name="run" hint="run this strategy" access="public" returntype="void" output="false">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfscript>
		var basePath = getDirectoryFromPath(getMetaData(this).path);
		var args = 0;
		var packages = buildPackageTree(arguments.qMetadata, true);

		ensureDirectory(getDirectoryFromPath(getOutputFile()));

		//write the index template
		args = {path=getOutputFile()
				,template="#instance.static.TEMPLATE_PATH#/template.uml"
				,packages = packages
				,qMetadata = qMetadata
				};
		writeTemplate(argumentCollection=args);
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="determineProperties" hint="We will make the assumption that is there is a get & set function with the same name, its a property" access="private" returntype="query" output="false">
	<cfargument name="meta" hint="the metadata for a class" type="struct" required="Yes">
	<cfargument name="package" hint="the current package" type="string" required="Yes">
	<cfscript>
		var qFunctions = buildFunctionMetaData(arguments.meta);
		var qProperties = QueryNew("name, access, type, generic");
		//is is used for boolean properties
		var qGetters = getMetaSubQuery(qFunctions, "LOWER(name) LIKE 'get%' OR LOWER(name) LIKE 'is%'");
		var qSetters = 0;
		var propertyName = 0;
		var setterMeta = 0;
		var getterMeta = 0;
		var generics = 0;
    </cfscript>
	<cfloop query="qGetters">
		<cfscript>
			if(LCase(name).startsWith("get"))
			{
				propertyName = replaceNoCase(name, "get", "");
			}
			else
			{
				propertyName = replaceNoCase(name, "is", "");
			}

			qSetters = getMetaSubQuery(qFunctions, "LOWER(name) = LOWER('set#propertyName#')");
			getterMeta = structCopy(metadata);

			//lets just take getter generics, easier to do.
			generics = getGenericTypes(metadata, arguments.package);

			if(qSetters.recordCount)
			{
				setterMeta = qSetters.metadata;

				if(structKeyExists(setterMeta, "parameters")
					AND arrayLen(setterMeta.parameters) eq 1
					AND setterMeta.parameters[1].type eq getterMeta.returnType
					)
				{
					if(setterMeta.access eq "public" OR getterMeta.access eq "public")
					{
						access = "public";
					}
					else if(setterMeta.access eq "package" OR getterMeta.access eq "package")
					{
						access = "package";
					}
					else
					{
						access = "private";
					}
					queryAddRow(qProperties);
					//lower case the front
					querySetCell(qProperties, "name", rereplace(propertyName, "([A-Z]*)(.*)", "\L\1\E\2"));
					querySetCell(qProperties, "access", access);
					querySetCell(qProperties, "type", getterMeta.returntype);
					querySetCell(qProperties, "generic", generics);
				}
			}
        </cfscript>
	</cfloop>
	<cfreturn qProperties />
</cffunction>

<cffunction name="getOutputFile" access="private" returntype="string" output="false">
	<cfreturn instance.outputFile />
</cffunction>

<cffunction name="setOutputFile" access="private" returntype="void" output="false">
	<cfargument name="outputFile" type="string" required="true">
	<cfset instance.outputFile = arguments.outputFile />
</cffunction>

</cfcomponent>