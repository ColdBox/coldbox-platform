<cfcomponent hint="Default Document Strategy for ColdDoc" extends="colddoc.strategy.AbstractTemplateStrategy" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cfscript>
	instance.static.TEMPLATE_PATH = "/colddoc/strategy/api/resources/templates";
</cfscript>


<cffunction name="init" hint="Constructor" access="public" returntype="HTMLAPIStrategy" output="false">
	<cfargument name="outputDir" hint="the output directory" type="string" required="Yes">
	<cfargument name="projectTitle" hint="the title of the project" type="string" required="No" default="Untitled">
	<cfscript>
		super.init();

		setOutputDir(arguments.outputDir);
		setProjectTitle(arguments.projectTitle);

		return this;
	</cfscript>
</cffunction>

<cffunction name="run" hint="Run this strategy" access="public" returntype="void" output="false">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfscript>
		var basePath = getDirectoryFromPath(getMetaData(this).path);
		var args = 0;

		recursiveCopy(basePath & "resources/static", getOutputDir());

		//write the index template
		args = {path=getOutputDir() & "/index.html", template="#instance.static.TEMPLATE_PATH#/index.cfm", projectTitle=getProjectTitle()};
		writeTemplate(argumentCollection=args);

		writeOverviewSummaryAndFrame(arguments.qMetaData);

		writeAllClassesFrame(arguments.qMetaData);

		writePackagePages(arguments.qMetaData);
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="writePackagePages" hint="writes the package summaries" access="private" returntype="void" output="false">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfscript>
		var currentDir = 0;
		var qPackage = 0;
		var qClasses = 0;
		var qInterfaces = 0;
	</cfscript>

	<cfoutput query="arguments.qMetaData" group="package">
		<cfscript>
			currentDir = getOutputDir() & "/" & replace(package, ".", "/", "all");
			ensureDirectory(currentDir);
			qPackage = getMetaSubquery(arguments.qMetaData, "package = '#package#'", "name asc");
			qClasses = getMetaSubquery(qPackage, "type='component'", "name asc");
			qInterfaces = getMetaSubquery(qPackage, "type='interface'", "name asc");

			writeTemplate(path=currentDir & "/package-summary.html",
						template="#instance.static.TEMPLATE_PATH#/package-summary.cfm",
						projectTitle = getProjectTitle(),
						package = package,
						qClasses = qClasses,
						qInterfaces = qInterfaces);

			writeTemplate(path=currentDir & "/package-frame.html",
						template="#instance.static.TEMPLATE_PATH#/package-frame.cfm",
						projectTitle = getProjectTitle(),
						package = package,
						qClasses = qClasses,
						qInterfaces = qInterfaces);

			buildClassPages(qPackage,
							arguments.qMetadata
							);
		</cfscript>
	</cfoutput>
</cffunction>

<cffunction name="buildClassPages" hint="builds the class pages" access="private" returntype="void" output="false">
	<cfargument name="qPackage" hint="the query for a specific package" type="query" required="Yes">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfscript>
		var qSubClass = 0;
		var qImplementing = 0;
		var currentDir = 0;
		var subClass = 0;
		var safeMeta = 0;
	</cfscript>

<!---	<cfif arguments.qPackage.package eq "coldspring.aop">
	<cfdump show="name,package,type" var="#arguments.qPackage#" ><cfabort>
	</cfif>--->

	<cfloop query="arguments.qPackage">
		<cfscript>
			currentDir = getOutputDir() & "/" & replace(package, ".", "/", "all");
			safeMeta = structCopy(metadata);

			if(safeMeta.type eq "component")
			{
				qSubClass = getMetaSubquery(arguments.qMetaData, "UPPER(extends) = UPPER('#arguments.qPackage.package#.#arguments.qPackage.name#')", "package asc, name asc");
				qImplementing = QueryNew("");
			}
			else
			{
				//all implementing subclasses
				qSubClass = getMetaSubquery(arguments.qMetaData, "UPPER(fullextends) LIKE UPPER('%:#arguments.qPackage.package#.#arguments.qPackage.name#:%')", "package asc, name asc");
				qImplementing = getMetaSubquery(arguments.qMetaData, "UPPER(implements) LIKE UPPER('%:#arguments.qPackage.package#.#arguments.qPackage.name#:%')", "package asc, name asc");
			}

			writeTemplate(path=currentDir & "/#name#.html",
						template="#instance.static.TEMPLATE_PATH#/class.cfm",
						projectTitle = getProjectTitle(),
						package = arguments.qPackage.package,
						name = arguments.qPackage.name,
						qSubClass = qSubClass,
						qImplementing = qImplementing,
						qMetadata = qMetaData,
						metadata = safeMeta
						);
		</cfscript>
	</cfloop>
</cffunction>


<cffunction name="writeOverviewSummaryAndFrame" hint="writes the overview-summary.html" access="private" returntype="void" output="false">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfscript>
		var qPackages = 0;
	</cfscript>
		<cfquery name="qPackages" dbtype="query" debug="false">
			SELECT DISTINCT
				package
			FROM
				arguments.qMetaData
			ORDER BY
				package
		</cfquery>

	<cfscript>
		writeTemplate(path=getOutputDir() & "/overview-summary.html",
					template="#instance.static.TEMPLATE_PATH#/overview-summary.cfm",
					projectTitle = getProjectTitle(),
					qPackages = qPackages);


		//overview frame
		writeTemplate(path=getOutputDir() & "/overview-frame.html",
					template="#instance.static.TEMPLATE_PATH#/overview-frame.cfm",
					projectTitle=getProjectTitle(),
					qMetaData = arguments.qMetaData);
	</cfscript>
</cffunction>

<cffunction name="writeAllClassesFrame" hint="writes the allclasses-frame.html" access="private" returntype="void" output="false">
	<cfargument name="qMetadata" hint="the meta data query" type="query" required="Yes">
	<cfscript>
		arguments.qMetadata = getMetaSubquery(query=arguments.qMetaData, orderby="name asc");

		writeTemplate(path=getOutputDir() & "/allclasses-frame.html",
					template="#instance.static.TEMPLATE_PATH#/allclasses-frame.cfm",
					qMetaData = arguments.qMetaData);
	</cfscript>
</cffunction>

<cffunction name="getOutputDir" access="private" returntype="string" output="false">
	<cfreturn instance.outputDir />
</cffunction>

<cffunction name="setOutputDir" access="private" returntype="void" output="false">
	<cfargument name="outputDir" type="string" required="true">
	<cfset instance.outputDir = arguments.outputDir />
</cffunction>

<cffunction name="getProjectTitle" access="private" returntype="string" output="false">
	<cfreturn instance.projectTitle />
</cffunction>

<cffunction name="setProjectTitle" access="private" returntype="void" output="false">
	<cfargument name="projectTitle" type="string" required="true">
	<cfset instance.projectTitle = arguments.projectTitle />
</cffunction>

</cfcomponent>