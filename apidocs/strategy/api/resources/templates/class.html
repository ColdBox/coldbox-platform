<cfoutput>
<cfset instance.class.root = RepeatString( '../', ListLen( arguments.package, ".") ) />
<!DOCTYPE html>
<html lang="en">
<head>
	<title>#arguments.name#</title>
	<meta name="keywords" content="#arguments.package#.concurrent.Callable interface">
	<!-- common assets -->
	<cfmodule template="inc/common.html" rootPath="#instance.class.root#">
	<!-- syntax highlighter -->
	<link type="text/css" rel="stylesheet" href="#instance.class.root#highlighter/styles/shCoreDefault.css">
	<script src="#instance.class.root#highlighter/scripts/shCore.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushColdFusion.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushXml.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushSql.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushJScript.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushJava.js"></script>
	<script src="#instance.class.root#highlighter/scripts/shBrushCss.js"></script>
	<script type="text/javascript">SyntaxHighlighter.all();</script>
</head>

<body class="withNavbar">

<cfmodule template="inc/nav.html"
			page="Class"
			projectTitle= "#arguments.projectTitle#"
			package = "#arguments.package#"
			file="#replace(arguments.package, '.', '/', 'all')#/#arguments.name#"
			>

<!-- ======== start of class data ======== -->
<a name="class"><!-- --></a>

<!-- Package -->
<div class="pull-right">
	<a href="package-summary.html" title="Package: #arguments.package#"><span class="label label-success">#arguments.package#</span></a>
</div>

<h2>
<cfif arguments.metadata.type eq "interface">
Interface
<cfelse>
Class
</cfif>
 #arguments.name#</h2>

<cfset local.i = 0 />

<cfset local.ls = createObject("java", "java.lang.System").getProperty("line.separator") />
<cfset local.buffer = createObject("java", "java.lang.StringBuffer").init() />
<cfset local.thisClass = arguments.package & "." & arguments.name/>

<cfloop array="#getInheritence(arguments.metadata)#" index="className">
	<cfif local.i++ gt 0>
		<cfset local.buffer.append('#RepeatString("    ", local.i)#<img src="#instance.class.root#resources/inherit.gif" alt="extended by ">') />
		<cfif className neq local.thisClass>
			<cfset local.buffer.append(writeClassLink(getPackage(className), getObjectName(className), arguments.qMetaData, "long")) />
		<cfelse>
			<cfset local.buffer.append(className) />
		</cfif>
	<cfelse>
		<cfset local.buffer.append(className) />
	</cfif>
	<cfset local.buffer.append(local.ls) />
</cfloop>

<!-- Inheritance Tree-->
<pre>#local.buffer.toString()#</pre>

<div class="panel panel-default">
	<div class="panel-heading"><strong>Class Attributes:</strong></div>
		<div class="panel-body">
		<cfset local.cfcAttributesCount = 0>
		<cfloop collection="#arguments.metadata#" item="local.cfcmeta">
			<cfif isSimpleValue( arguments.metadata[ local.cfcmeta ] ) AND
				  !listFindNoCase( "hint,extends,fullname,functions,hashcode,name,path,properties,type,remoteaddress", local.cfcmeta ) >
			<cfset local.cfcAttributesCount++>
			<li class="label label-danger label-annotations">
				#lcase( local.cfcmeta )# 
				<cfif len( arguments.metadata[ local.cfcmeta ] )>
				: #arguments.metadata[ local.cfcmeta ]#		
				</cfif>
			</li>
			&nbsp;
			</cfif>
		</cfloop>
		<cfif local.cfcAttributesCount eq 0>
			<span class="label label-warning"><em>None</em></span>
		</cfif>
	</div>
</div>

<cfif arguments.metadata.type eq "component">
	<cfset interfaces = getImplements(arguments.metadata)>
	<cfif NOT arrayIsEmpty(interfaces)>
		<div class="panel panel-default">
			<div class="panel-heading"><strong>All Implemented Interfaces:</strong></div>
  			<div class="panel-body">
			<cfset local.len = arrayLen(interfaces)>
			<cfloop from="1" to="#local.len#" index="local.counter">
				<cfset interface = interfaces[local.counter]>
				<cfif local.counter neq 1>,</cfif>
				#writeClassLink(getPackage(interface), getObjectName(interface), arguments.qMetaData, "short")#
			</cfloop>
			</div>
		</div>
	</cfif>
<cfelse>
	<cfif arguments.qImplementing.recordCount>
	<div class="panel panel-default">
		<div class="panel-heading"><strong>All Known Implementing Classes:</strong></div>
  		<div class="panel-body">
		<cfloop query="arguments.qimplementing">
			<cfif arguments.qimplementing.currentrow neq 1>,</cfif>
			#writeclasslink(arguments.qimplementing.package, arguments.qimplementing.name, arguments.qmetadata, "short")#
		</cfloop>
		</div>
	</div>
	</cfif>
</cfif>

<cfif arguments.qSubclass.recordCount>
<div class="panel panel-default">
	<div class="panel-heading"><strong><cfif arguments.metadata.type eq "component">Direct Known Subclasses<cfelse>All Known Subinterfaces</cfif>:</strong></div>
  	<div class="panel-body">
	<cfloop query="arguments.qsubclass">
		<cfif arguments.qsubclass.currentrow neq 1>,</cfif>
		<a href="#instance.class.root#/#replace(arguments.qsubclass.package, '.', '/', 'all')#/#arguments.qsubclass.name#.html" title="class in #arguments.package#">#arguments.qsubclass.name#</a>
	</cfloop>
	</div>
</div>
</cfif>

<!---
<dl>
<dt>

<cfscript>
	local.buffer.setLength(0);
	//local.buffer.append("public ");
	if(isAbstractClass(name, arguments.package))
	{
		local.buffer.append("abstract ");
	}

	if(arguments.metadata.type eq "interface")
	{
		local.buffer.append("interface");
	}
	else
	{
		local.buffer.append("class");
	}

	local.buffer.append(" <strong>#arguments.name#</strong>");
	local.buffer.append(local.ls);
	if(StructKeyExists(arguments.metadata, "extends"))
	{
		local.extendsmeta = arguments.metadata.extends;
		if(arguments.metadata.type eq "interface")
		{
			local.extendsmeta = arguments.metadata.extends[structKeyList(local.extendsmeta)];
		}
		local.buffer.append("<dt>extends #writeClassLink(getPackage(local.extendsmeta.name), getObjectName(local.extendsmeta.name), arguments.qMetaData, 'short')#</dt>");
	}
</cfscript>

<kbd>#local.buffer.tostring()#</kbd>

</dt>
</dl>
--->

<cfif StructKeyExists(arguments.metadata, "hint")>
<div id="class-hint">
	<p>#arguments.metadata.hint#</p>
</div>
</cfif>

<cfscript>
	instance.class.cache = StructNew();
	local.localFunctions = StructNew();
	
	local.qFunctions = buildFunctionMetaData(arguments.metadata);
	local.qProperties = buildPropertyMetadata(arguments.metadata);

	local.qInit = getMetaSubQuery(local.qFunctions, "UPPER(name)='INIT'");
</cfscript>

<cfif local.qProperties.recordCount>
<!-- ========== METHOD SUMMARY =========== -->

<a name="property_summary"><!-- --></a>
<table class="table table-bordered table-hover">
	<tr class="info">
		<th align="left" colspan="5">
			<strong>Property Summary</strong>
		</th>
	</tr>
	<tr class="info">
		<th align="left">
			<strong>type</strong>
		</th>
		<th align="left">
			<strong>property</strong>
		</th>
		<th align="left">
			<strong>default</strong>
		</th>
		<th align="left">
			<strong>serializable</strong>
		</th>
		<th align="left">
			<strong>required</strong>
		</th>
	</tr>

	<cfloop query="local.qproperties">
	<cfset local.prop = local.qproperties.metadata />
	<cfset local.localproperties[ local.prop.name ] = 1 />
	<tr>
		<td align="right" valign="top" width="1%">
			<code>#writetypelink(local.prop.type, arguments.package, arguments.qmetadata, local.prop)#</code>
		</td>
		<td>
			#writeMethodLink(arguments.name, arguments.package, local.prop, arguments.qMetaData)# 
			<br>
			<cfif StructKeyExists( local.prop, "hint" ) AND Len( local.prop.hint )>
			<!-- only grab the first sentence of the hint -->
			#repeatString( '&nbsp;', 5)# #listGetAt( local.prop.hint, 1, chr(13)&chr(10)&'.' )#.
			</cfif>
			<br><br>
			<ul>
			<cfloop collection="#local.prop#" item="local.propmeta">
				<cfif not listFindNoCase( "hint,name,default,type,serializable,required", local.propmeta ) >
				<li class="label label-default label-annotations">#lcase( local.propmeta )# = #local.prop[ local.propmeta ]#</li>
				</cfif>
			</cfloop>
			</ul>

		</td>
		<td align="right" valign="top" width="1%">
			<cfif len( local.prop.default )>
				<code>#local.prop.default#</code>
			</cfif>
		</td>
		<td align="right" valign="top" width="1%">
			<code>
				#local.prop.serializable#
			</code>
		</td>
		<td align="right" valign="top" width="1%">
			<code>
				#local.prop.required#
			</code>
		</td>
	</tr>
	</cfloop>
	</tr>
</table>
</cfif>

<cfif local.qInit.recordCount>
	<cfset local.init = local.qInit.metadata />
	<cfset local.localFunctions[local.init.name] = 1 />
	<!-- ======== CONSTRUCTOR SUMMARY ======== -->

	<a name="constructor_summary"><!-- --></a>
	<table class="table table-bordered table-hover">
		<tr class="info">
			<th align="left" colspan="2">
				<strong>Constructor Summary</strong>
			</th>
		</tr>
		<tr>
			<cfif local.init.access neq "public">
				<td align="right" valign="top" width="1%">
					<code>#local.init.access# </code>
				</td>
			</cfif>
			<td>
				#writemethodlink(arguments.name, arguments.package, local.init, arguments.qmetadata)#
				<br>
				<cfif StructKeyExists(local.init, "hint") and len( local.init.hint ) >
				#repeatString( '&nbsp;', 5)# #listGetAt( local.init.hint, 1, chr(13)&chr(10)&'.' )#.
				</cfif>
			</td>
		</tr>
	</table>
</cfif>

<cfset local.qFunctions = getMetaSubQuery(local.qFunctions, "UPPER(name)!='INIT'") />

<cfif local.qFunctions.recordCount>
<!-- ========== METHOD SUMMARY =========== -->

<a name="method_summary"><!-- --></a>
<table class="table table-bordered table-hover">
	<tr class="info">
		<th align="left" colspan="2">
			<strong>Method Summary</strong>
		</th>
	</tr>

	<cfloop query="local.qFunctions">
	<cfset local.func = local.qFunctions.metadata />
	<cfset local.localFunctions[ local.func.name ] = 1 />
	<tr>
		<td align="right" valign="top" width="1%">
			<code><cfif local.func.access neq "public">#local.func.access#&nbsp;</cfif>#writetypelink(local.func.returntype, arguments.package, arguments.qmetadata, local.func)#</code>
		</td>
		<td>
			#writemethodlink(arguments.name, arguments.package, local.func, arguments.qmetadata)#
			<br>
			<cfif StructKeyExists(local.func, "hint") AND Len(local.func.hint)>
			#repeatString( '&nbsp;', 5)##listGetAt( local.func.hint, 1, chr(13)&chr(10)&'.' )#.
			</cfif>
		</td>
	</tr>
	</cfloop>
</table>

</cfif>

<a name="inherited_methods"><!-- --></a>
<cfset local.localmeta = arguments.metadata />
<cfloop condition="#StructKeyExists(local.localmeta, 'extends')#">
	<cfscript>
		if(local.localmeta.type eq "interface")
		{
			local.localmeta = local.localmeta.extends[structKeyList(local.localmeta.extends)];
		}
		else
		{
			local.localmeta = local.localmeta.extends;
		}
    </cfscript>

	<cfset local.qFunctions = buildFunctionMetaData(local.localmeta)>

	&nbsp;
	<a name="methods_inherited_from_class_#local.localmeta.name#"><!-- --></a>
	<table class="table table-hover table-bordered">
		<tr class="info">
			<th align="left">
				<strong>Methods inherited from class <kbd>#writeClassLink(getPackage(local.localmeta.name), getObjectName(local.localmeta.name), arguments.qMetaData, 'long')#</kbd></strong>
			</th>
		</tr>
		<tr>
			<td>
				<cfset local.buffer.setLength(0) />
				<cfset i = 1 />
				<cfloop query="local.qFunctions">
					<cfset local.func = local.qFunctions.metadata />
					<cfif NOT StructKeyExists(local.localFunctions, local.func.name)>
					<cfif i++ neq 1>
						<cfset local.buffer.append(", ") />
					</cfif>
					<cfset local.buffer.append('<a href="#instance.class.root#/#replace(getPackage(local.localmeta.name), '.', '/', 'all')#/#getObjectName(local.localmeta.name)#.html###local.func.name#()">#local.func.name#</a>') />
					<cfset local.localFunctions[local.func.name] = 1 />
					</cfif>
				</cfloop>
				
				<cfif local.buffer.length()>
					#local.buffer.toString()#
				<cfelse>
					<span class="label label-warning"><em>None</em></span>
				</cfif>
			</td>
		</tr>
	</table>
</cfloop>

<hr>

<!-- ========= CONSTRUCTOR DETAIL ======== -->
<cfif StructKeyExists(local, "init")>
	<a name="constructor_detail"><!-- --></a>
	<table class="table table-bordered">
		<tr class="info">
			<th colspan="1" align="left">
				<strong>Constructor Detail</strong>
			</th>
		</tr>
	</table>

	<a name="#local.init.name#()"><!-- --></a><h3>
	#local.init.name#</h3>
	<kbd>#local.init.access# #writeMethodLink(arguments.name, arguments.package, local.init, arguments.qMetaData, false)#</kbd>

	<br><br>

	<cfif StructKeyExists(local.init, "hint")>
	<p>#local.init.hint#</p>
	</cfif>

	<cfif StructKeyExists(local.init, "parameters") AND ArrayLen(local.init.parameters)>
	<dl>
		<dt><strong>Parameters:</strong></dt>
		<cfloop array="#local.init.parameters#" index="local.param">
			<dd><code>#local.param.name#</code><cfif StructKeyExists(local.param, "hint")> - #local.param.hint#</cfif></dd>
		</cfloop>
	</dl>
	</cfif>
	<hr>
</cfif>

<!-- ============ PROPERTY DETAIL ========== -->
<cfif local.qProperties.recordCount>
	<a name="property_detail"><!-- --></a>
	<table class="table table-bordered">
		<tr class="info">
			<th colspan="1" align="left">
				<strong>Property Detail</strong>
			</th>
		</tr>
	</table>

	<cfloop query="local.qProperties">
		<cfset local.prop = local.qProperties.metadata />
		<a name="#local.prop.name#()"><!-- --></a>
		<h3>#local.prop.name#</h3>

		<kbd>
			property #writeTypeLink(local.prop.type, arguments.package, arguments.qMetaData, local.prop)# 
			#writeMethodLink(arguments.name, arguments.package, local.prop, arguments.qMetaData, false)#
			<cfif structKeyExists( local.prop, "default" ) and len( local.prop.default )>
			= [#local.prop.default#]
			</cfif>
		</kbd>

		<br><br>
		<cfif StructKeyExists(local.prop, "hint") AND Len(local.prop.hint)>
			<p>#local.prop.hint#</p>
		</cfif>

		<dl>
		<dt><strong>Attributes:</strong></dt>
		<cfloop collection="#local.prop#" item="local.param">
			<cfif not listFindNoCase( "name,type,hint,default", local.param )>
			<dd><code>#lcase( local.param )#</code> - #local.prop[ local.param ]#</dd>
			</cfif>
		</cfloop>
		</dl>

		<hr>
	</cfloop>
</cfif>



<cfset local.qFunctions = buildFunctionMetaData(arguments.metadata) />
<cfset local.qFunctions = getMetaSubQuery(local.qFunctions, "UPPER(name)!='INIT'") />

<cfif local.qFunctions.recordCount>

<!-- ============ METHOD DETAIL ========== -->

<a name="method_detail"><!-- --></a>
<table class="table table-bordered">
	<tr class="info">
		<th colspan="1" align="left">
			<strong>Method Detail</strong>
		</th>
	</tr>
</table>

<cfloop query="local.qFunctions">
	<cfset local.func = local.qFunctions.metadata />
	<a name="#local.func.name#()"><!-- --></a>
	<h3>#local.func.name#</h3>
	
	<kbd>#local.func.access# #writeTypeLink(local.func.returnType, arguments.package, arguments.qMetaData, local.func)# #writeMethodLink(arguments.name, arguments.package, local.func, arguments.qMetaData, false)#</kbd>
	
	<br><br>

	<cfif StructKeyExists(local.func, "hint") AND Len(local.func.hint)>
		<p>#local.func.hint#</p>
	</cfif>

	<cfif arguments.metadata.type eq "component">
		<cfset local.specified = findSpecifiedBy(arguments.metaData, local.func.name) />
		<cfif Len(local.specified)>
			<dl>
				<dt><strong>Specified by:</strong></dt>
				<dd>
				<code>
				<a href="#instance.class.root#/#replace(getPackage(local.specified), '.', '/', 'all')#/#getObjectName(local.specified)#.html###local.func.name#()">#local.func.name#</a></code>
				in interface
				<code>
					#writeClassLink(getPackage(local.specified), getObjectName(local.specified), arguments.qMetaData, 'short')#
				</code>
				</dd>
			</dl>
		</cfif>
	</cfif>

	<cfset local.overWrites = findOverwrite(arguments.metaData, local.func.name) />
	<cfif Len(local.overWrites)>
		<dl>
			<dt><strong>Overrides:</strong></dt>
			<dd>
			<code>
			<a href="#instance.class.root#/#replace(getPackage(local.overWrites), '.', '/', 'all')#/#getObjectName(local.overWrites)#.html###local.func.name#()">#local.func.name#</a></code>
			in class
			<code>
				#writeClassLink(getPackage(local.overWrites), getObjectName(local.overWrites), arguments.qMetaData, 'short')#
			</code>
			</dd>
		</dl>
	</cfif>

	<cfif StructKeyExists(local.func, "parameters") AND ArrayLen(local.func.parameters)>
		<dl>
		<dt><strong>Parameters:</strong></dt>
		<cfloop array="#local.func.parameters#" index="local.param">
		<dd><code>#local.param.name#</code><cfif StructKeyExists(local.param, "hint")> - #local.param.hint#</cfif></dd>
		</cfloop>
		</dl>
	</cfif>

	<cfif StructKeyExists(local.func, "return") AND isSimplevalue(local.func.return)>
		<dl>
			<dt><strong>Returns:</strong></dt>
			<dd>#local.func.return#</dd>
		</dl>
	</cfif>

	</dl>
	<hr>
</cfloop>
</cfif>


</body>
</html>
</cfoutput>
<cfsilent>
	<cffunction name="writeMethodLink" hint="draws a method link" access="private" returntype="string" output="false">
		<cfargument name="name" hint="the name of the class" type="string" required="Yes">
		<cfargument name="package" hint="out current package" type="string" required="Yes">
		<cfargument name="func" hint="the function to link to" required="Yes">
		<cfargument name="qMetaData" hint="the meta daya query" type="query" required="Yes">
		<cfargument name="drawMethodLink" hint="actually draw the link on the method" type="boolean" required="No" default="true">
		<cfset var param = 0 />
		<cfset var i = 1 />
		<cfset var builder = createObject("java", "java.lang.StringBuilder").init() />
		<cfsilent>

		<cfif StructKeyExists(arguments.func, "parameters")>
			<cfset builder.append("(") />
				<cfloop array="#arguments.func.parameters#" index="param">
					<cfscript>
						if(i++ neq 1)
						{
							builder.append(", ");
						}

						if(NOT StructKeyExists(param, "required"))
						{
							param.required = false;
						}

						if(NOT param.required)
						{
							builder.append("[");
						}
					</cfscript>

					<cfscript>
						safeParamMeta(param);
						builder.append(writeTypeLink(param.type, arguments.package, arguments.qMetadata, param));

						builder.append(" " & param.name);

						if(StructKeyExists(param, "default"))
						{
							builder.append("='" & param.default & "'");
						}

						if(NOT param.required)
						{
							builder.append("]");
						}
					</cfscript>
				</cfloop>
			<cfset builder.append(")") />
		</cfif>

		</cfsilent>
		<cfif arguments.drawMethodLink>
			<cfreturn '<strong><a href="#arguments.name#.html###arguments.func.name#()">#arguments.func.name#</A></strong>#builder.toString()#'/>
		<cfelse>
			<cfreturn '<strong>#arguments.func.name#</strong>#builder.toString()#'/>
		</cfif>
	</cffunction>

	<cffunction name="writeTypeLink" hint="writes a link to a type, or a class" access="private" returntype="string" output="false">
		<cfargument name="type" hint="the type/class" type="string" required="Yes">
		<cfargument name="package" hint="the current package" type="string" required="Yes">
		<cfargument name="qMetaData" hint="the meta data query" type="query" required="Yes">
		<cfargument name="genericMeta" hint="optional meta that may contain generic type information" type="struct" required="No" default="#structNew()#">
		<cfscript>
			var result = createObject("java", "java.lang.StringBuilder").init();
			var local = {};

			if(isPrimitive(arguments.type))
			{
				result.append(arguments.type);
			}
			else
			{
				arguments.type = resolveClassName(arguments.type, arguments.package);
				result.append(writeClassLink(getPackage(arguments.type), getObjectName(arguments.type), arguments.qMetaData, 'short'));
			}

			if(NOT structIsEmpty(arguments.genericMeta))
			{
				local.array = getGenericTypes(arguments.genericMeta, arguments.package);
				if(NOT arrayIsEmpty(local.array))
				{
					result.append("&lt;");

					local.len = ArrayLen(local.array);
                    for(local.counter=1; local.counter lte local.len; local.counter++)
                    {
						if(local.counter neq 1)
						{
							result.append(",");
						}

                    	local.generic = local.array[local.counter];
						result.append(writeTypeLink(local.generic, arguments.package, arguments.qMetaData));
                    }

					result.append("&gt;");
				}
			}

			return result.toString();
        </cfscript>
	</cffunction>

	<cfscript>
		/*
		function getArgumentList(func)
		{
			var list = "";
			var len = 0;
			var counter = 1;
			var param = 0;

			if(StructKeyExists(arguments.func, "parameters"))
			{
				len = ArrayLen(arguments.func.parameters);
				for(; counter lte len; counter = counter + 1)
				{
					param = safeParamMeta(arguments.func.parameters[counter]);
					list = listAppend(list, param.type);
				}
			}

			return list;
		}
		*/

		function writeClassLink(package, name, qMetaData, format)
		{
			var qClass = getMetaSubQuery(arguments.qMetaData, "LOWER(package)=LOWER('#arguments.package#') AND LOWER(name)=LOWER('#arguments.name#')");
			var builder = 0;
			var safeMeta = 0;
			var title = 0;

			if(qClass.recordCount)
			{
				safeMeta = StructCopy(qClass.metadata);

				title = "class";
				if(safeMeta.type eq "interface")
				{
					title = "interface";
				}

				builder = createObject("java", "java.lang.StringBuilder").init();
				builder.append('<a href="#instance.class.root##replace(qClass.package, '.', '/', 'all')#/#qClass.name#.html" title="#title# in #qClass.package#">');
				if(arguments.format eq "short")
				{
					builder.append(qClass.name);
				}
				else
				{
					builder.append(qClass.package & "." & qClass.name);
				}
				builder.append("</a>");

				return builder.toString();
			}

			return package & "." & name;
		}

		function getInheritence(metadata)
		{
			var localmeta = arguments.metadata;
			var inheritence = [arguments.metadata.name];

			while(StructKeyExists(localmeta, "extends"))
			{
				//manage interfaces
				if(localmeta.type eq "interface")
				{
					localmeta = localmeta.extends[structKeyList(localmeta.extends)];
				}
				else
				{
					localmeta = localmeta.extends;
				}

				ArrayPrepend(inheritence, localmeta.name);
			}

			return inheritence;
		}

		function getImplements(metadata)
		{
			var localmeta = arguments.metadata;
			var interfaces = {};
			var key = 0;
			var imeta = 0;

			while(StructKeyExists(localmeta, "extends"))
			{
				if(StructKeyExists(localmeta, "implements"))
				{
					for(key in localmeta.implements)
					{
						imeta = localmeta.implements[local.key];
						interfaces[imeta.name] = 1;
					}
				}
				localmeta = localmeta.extends;
			}

			interfaces = structKeyArray(interfaces);

			arraySort(interfaces, "textnocase");

			return interfaces;
		}

		function findOverwrite(metadata, functionName)
		{
			var qFunctions = 0;

			while(StructKeyExists(arguments.metadata, "extends"))
			{
				if(arguments.metadata.type eq "interface")
				{
					arguments.metadata = arguments.metadata.extends[structKeyList(arguments.metadata.extends)];
				}
				else
				{
					arguments.metadata = arguments.metadata.extends;
				}

				qFunctions = buildFunctionMetaData(arguments.metadata);
				qFunctions = getMetaSubQuery(qFunctions, "name='#arguments.functionName#'");

				if(qFunctions.recordCount)
				{
					return arguments.metadata.name;

				}
			}

			return "";
		}

		function findSpecifiedBy(metadata, functionname)
		{
			var imeta = 0;
			var qFunctions = 0;
			var key = 0;

			if(structKeyExists(arguments.metadata, "implements"))
			{
				for(key in arguments.metadata.implements)
				{
					imeta = arguments.metadata.implements[local.key];

					qFunctions = buildFunctionMetaData(imeta);
					qFunctions = getMetaSubQuery(qFunctions, "name='#arguments.functionName#'");

					if(qFunctions.recordCount)
					{
						return imeta.name;
					}

					//now look up super-interfaces
					while(structKeyExists(imeta, "extends"))
					{
						imeta = imeta.extends[structKeyList(imeta.extends)];

						qFunctions = buildFunctionMetaData(imeta);
						qFunctions = getMetaSubQuery(qFunctions, "name='#arguments.functionName#'");

						if(qFunctions.recordCount)
						{
							return imeta.name;
						}
					}
				}

			}

			return "";
		}

		//stupid cleanup

		StructDelete(variables, "findOverwrite");
		StructDelete(variables, "writeTypeLink");
		StructDelete(variables, "writeMethodLink");
		StructDelete(variables, "getArgumentList");
		StructDelete(variables, "writeClassLink");
		StructDelete(variables, "getInheritence");
		StructDelete(variables, "writeObjectLink");
		StructDelete(variables, "getImplements");
		StructDelete(variables, "findSpecifiedBy");

		//store for resident data
		StructDelete(variables.instance, "class");
	</cfscript>
</cfsilent>