<cfcomponent displayname="Reflector" hint="I return information on a provided Java class.">
	
	<cffunction name="isClassName" access="public" hint="I indicate if the provided string is a class name" returntype="boolean">
		<cfargument name="name" hint="The string to check if it's a class name." required="yes" type="any" />
		<cfset var isClass = false />
		
		<cftry>
			<cfset isClass = IsObject(CreateObject("Java", "java.lang.Class").forName(JavaCast("string", arguments.name))) />
			<cfcatch></cfcatch>
		</cftry>
		
		<cfreturn isClass />
	</cffunction>
	
	<cffunction name="isPackageName" access="public" hint="I indicate if the provided string is a package name" returntype="boolean">
		<cfargument name="name" hint="The string to check if it's a class name." required="yes" type="any" />
		<cfset var isPackage = false />
		<cfset var package = CreateObject("Java", "java.lang.Package").getPackage(JavaCast("string", arguments.name)) />
		
		<cfif IsDefined("package")>
			<cfset isPackage = true />
		</cfif>
		
		<cfreturn isPackage />
	</cffunction>
		
	<!--- getAllPackageNames --->
	<cffunction name="getAllPackageNames" hint="I return an array of all avaliable packages." returntype="array">
		<cfset var Packages = CreateObject("Java", "java.lang.Package").getPackages() />
		<cfset var packageNames = ArrayNew(1) />
		<cfset var x = 0 />
		
		<cfloop from="1" to="#ArrayLen(Packages)#" index="x">
			<cfset ArrayAppend(packageNames, Packages[x].getName()) />
		</cfloop>
		
		<!--- sort the package names --->
		<cfset ArraySort(packageNames, "text") />
		
		<cfreturn packageNames />
	</cffunction>
	
	<!--- getClassInfoFromObject --->
	<cffunction name="getClassInfoFromObject" hint="I return a structure of information on the provided object's class." returntype="struct">
		<cfargument name="Object" hint="I am the name of an object to reflect." required="yes" type="any" />
		
		<cfreturn getClassInfo(Object.getClass().getName()) />
	</cffunction>
	
	<!--- getClassInfo --->
	<cffunction name="getClassInfo" hint="I return a structure of information on the class." returntype="struct">
		<cfargument name="String" hint="I am the name of an object to reflect." required="yes" type="any" />
		<cfset var Class = CreateObject("Java", "java.lang.Class").forName(arguments.String) />
		<cfset var Modifier = CreateObject("Java", "java.lang.reflect.Modifier") />
		<cfset var Results = StructNew() />
		<cfset var DeclaringClass = Class.getDeclaringClass() />
		
		<cfset Results.Modifiers = Modifier.toString(Class.getModifiers()) /> 
		<cfset Results.Name = ListLast(Class.getName(), ".") /> 
		<cfset Results.StringRepresentation = Class.toString() /> 
		<cfset Results.Package = Class.getPackage().getName() /> 
		<cfset Results.IsArray = Class.isArray() /> 
		<cfset Results.IsInterface = Class.isInterface() /> 
		<cfset Results.IsPrimitive = Class.isPrimitive() /> 
		
		<cfif IsDefined("DeclaringClass")>
			<cfset Results.DeclaringClass = DeclaringClass.getName() /> 
		</cfif>
		
		<cfset Results.Interfaces = getInterfaces(Class) />
		<cfset Results.Superclasses = getSuperclasses(Class) />
		
		<cfset Results.Constructors = getConstructorsInfo(Class) />
		<cfset Results.Methods = getMethodsInfo(Class) />
		<cfset Results.Fields = getFieldsInfo(Class) />
		
		<cfset Results.NestedClasses = getNestedClasses(Class) />
		
		<cfreturn Results />
	</cffunction>
	
	<!--- getSuperclasses --->
	<cffunction name="getSuperclasses" hint="I return an array of supper classes of this class." returntype="array">
		<cfargument name="Class" hint="I am the class to reflect." required="yes" type="any" />
		<cfset var Results = ArrayNew(1) />
		<cfset var x = 0 />
		<cfset var Superclass = Class.getSuperclass() />

		<cfloop condition="IsDefined('Superclass')">
			<cfset Results[ArrayLen(Results) + 1] = Superclass.getName() />
			<cfset Superclass = Superclass.getSuperclass() />
		</cfloop>
		
		<cfreturn Results />
	</cffunction>
	
	<!--- getNestedClasses --->
	<cffunction name="getNestedClasses" hint="I return an array of nested classes of this class." returntype="array">
		<cfargument name="Class" hint="I am the class to reflect." required="yes" type="any" />
		<cfset var Results = ArrayNew(1) />
		<cfset var x = 0 />
		<cfset var NestedClasses = Class.getClasses() />

		
		<cfloop from="1" to="#ArrayLen(NestedClasses)#" index="x">
			<cfset Results[ArrayLen(Results) + 1] = NestedClasses[x].getName() />
		</cfloop>
		
		<cfreturn Results />
	</cffunction>
	
	<!--- getSuperclass --->
	
	
	<!--- getInterfaces --->
	<cffunction name="getInterfaces" hint="I return an array of interfaces implemeted by this class." returntype="array">
		<cfargument name="Class" hint="I am the class to reflect." required="yes" type="any" />
		<cfset var Interfaces = arguments.Class.getInterfaces() />
		<cfset var Results = ArrayNew(1) />
		<cfset var x = 0 />
		
		<cfloop from="1" to="#ArrayLen(Interfaces)#" index="x">
			<cfset Results[x] = Interfaces[x].getName() />
		</cfloop>
		
		<cfreturn Results />
	</cffunction>
	
	<!--- getFieldsInfo --->
	<cffunction name="getFieldsInfo" hint="I return an array of structures of information on this classes fields." returntype="array">
		<cfargument name="Class" hint="I am the class to reflect." required="yes" type="any" />
		<cfset var Fields = arguments.Class.getFields() />
		<cfset var Modifier = CreateObject("Java", "java.lang.reflect.Modifier") />
		<cfset var Results = ArrayNew(1) />
		<cfset var x = 0 />
		
		<cfloop from="1" to="#ArrayLen(Fields)#" index="x">
			<cfset Results[x] = StructNew() />
			<cfset Results[x].Name = Fields[x].getName() />
			<cfset Results[x].Modifiers = Modifier.toString(Fields[x].getModifiers()) />
			<cfset Results[x].Type = getParamTypeString(Fields[y].getType()) />
			<cfset Results[x].IsPrimitive = Fields[y].getType().isPrimitive() />
			<cfset Results[x].StringRepresentation = Fields[x].toString() />
			
			<!--- if field has a static value, get it --->
			<cfif Results[x].Modifiers CONTAINS "public" AND Results[x].Modifiers CONTAINS "static">
				<cfset Results[x].StaticValue = Fields[x].get(arguments.class) />
			</cfif>
		</cfloop>
		
		<cfreturn Results />
	</cffunction>
	
	<!--- getConstructorsInfo --->
	<cffunction name="getConstructorsInfo" hint="I return an array of structures of information on this classes constructors." returntype="array">
		<cfargument name="Class" hint="I am the class to reflect." required="yes" type="any" />
		<cfset var Constructors = arguments.Class.getConstructors() />
		<cfset var Modifier = CreateObject("Java", "java.lang.reflect.Modifier") />
		<cfset var Results = ArrayNew(1) />
		<cfset var x = 0 />
		<cfset var y = 0 />
		<cfset var paramTypes = 0 />
		<cfset var exceptionTypes = 0 />
		<cfset var exception = 0 />
		
		<cfloop from="1" to="#ArrayLen(Constructors)#" index="x">
			<cfset Results[x] = StructNew() />
			<cfset Results[x].Name = ListLast(Class.getName(), ".") />
			<cfset Results[x].Modifiers = Modifier.toString(Constructors[x].getModifiers()) />
			<cfset Results[x].StringRepresentation = Constructors[x].toString() />
			<cfset Results[x].Parameters = ArrayNew(1) />
			<cfset Results[x].Exceptions = ArrayNew(1) />
			
			<!--- loop over the parameters and gather them up --->
			<cfset paramTypes = Constructors[x].getParameterTypes() />
			<cfloop from="1" to="#ArrayLen(paramTypes)#" index="y">
				<cfset Results[x].Parameters[y] = getParamTypeString(paramTypes[y]) />
			</cfloop>
			
			<!--- loop over the exeptions and gather them up --->
			<cfset exceptionTypes = Constructors[x].getExceptionTypes() />
			<cfloop from="1" to="#ArrayLen(exceptionTypes)#" index="y">
				<cfset exception = exceptionTypes[y] />
				<cfif IsDefined("exception")>
					<cfset Results[x].Exceptions[y] = exception.getName() />
				</cfif>
			</cfloop>
			
		</cfloop>
		
		<cfreturn Results />
	</cffunction>
	
	<!--- getMethodsInfo --->
	<cffunction name="getMethodsInfo" hint="I return an array of structures of information on this classes methods." returntype="array">
		<cfargument name="Class" hint="I am the class to reflect." required="yes" type="any" />
		<cfset var Methods = arguments.Class.getMethods() />
		<cfset var Modifier = CreateObject("Java", "java.lang.reflect.Modifier") />
		<cfset var Results = ArrayNew(1) />
		
		<cfloop from="1" to="#ArrayLen(Methods)#" index="x">
			<cfset Results[x] = StructNew() />
			<cfset Results[x].Name = Methods[x].getName() />
			<cfset Results[x].ReturnType = getPAramTypeString(Methods[x].getReturnType()) />
			<cfset Results[x].Modifiers = Modifier.toString(Methods[x].getModifiers()) />
			<cfset Results[x].StringRepresentation = Methods[x].toString() />
			<cfset Results[x].Parameters = ArrayNew(1) />
			<cfset Results[x].Exceptions = ArrayNew(1) />
			
			<!--- loop over the parameters and gather them up --->
			<cfset paramTypes = Methods[x].getParameterTypes() />
			<cfloop from="1" to="#ArrayLen(paramTypes)#" index="y">
				<cfset Results[x].Parameters[y] = getParamTypeString(paramTypes[y]) />
			</cfloop>
			
			<!--- loop over the exeptions and gather them up --->
			<cfset exceptionTypes = Methods[x].getExceptionTypes() />
			<cfloop from="1" to="#ArrayLen(exceptionTypes)#" index="y">
				<cfset exception = exceptionTypes[y] />
				<cfif IsDefined("exception")>
					<cfset Results[x].Exceptions[y] = exception.getName() />
				</cfif>
			</cfloop>
			
		</cfloop>
		
		<cfreturn Results />
	</cffunction>
	
	<!--- getParamTypeString --->
	<cffunction name="getParamTypeString"  hint="I return a string representation of a type." access="public" output="false" returntype="string">
		<cfargument name="param" hint="I am the param to return the type name of." required="yes" type="any" />
		<cfset var string = "" />
		
		<cfif arguments.param.isArray()>
			<cfset string = getParamTypeString(arguments.param.getComponentType()) & "[]" />
		<cfelse>
			<cfset string = arguments.param.getName() />
		</cfif>
		
		<cfreturn string />
	</cffunction>

</cfcomponent>