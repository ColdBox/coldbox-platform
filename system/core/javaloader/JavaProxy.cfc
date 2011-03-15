<!--- Document Information -----------------------------------------------------

Title:      JavaProxy.cfc

Author:     Mark Mandel
Email:      mark@compoundtheory.com

Website:    http://www.compoundtheory.com

Purpose:    JavaProxy to replace the ColdFusion one when you don't have access
			to coldfusion.* packages due to CF8 settings.

Usage:

Modification Log:

Name			Date			Description
================================================================================
Mark Mandel		27/08/2007		Created

------------------------------------------------------------------------------->

<cfcomponent output="false">

<!---
	All CF based methods have a _ in front, so that they don't interfere with the possible Java
	calls
 --->

<cffunction name="_init" hint="Constructor" access="public" returntype="JavaProxy" output="false">
	<cfargument name="class" hint="the java.lang.Class object this represents" type="any" required="Yes">
	<cfscript>
		var classLoader = createObject("java", "java.lang.ClassLoader").getSystemClassLoader();
		var objectClass = classLoader.loadClass("java.lang.Object");

		_setArray(createObject("java", "java.lang.reflect.Array"));

		_setClassMethod(objectClass.getMethod("getClass", JavaCast("null", 0)));

		_setObjectClass(objectClass);

		_setClass(arguments.class);

		_setModifier(createObject("java", "java.lang.reflect.Modifier"));

		_setStaticFields();

		_initMethodCollection();

		return this;
	</cfscript>
</cffunction>

<cffunction name="init" hint="create an instance of this object" access="public" returntype="any" output="false">
	<cfscript>
		var constructor = 0;
		var instance = 0;

		//make sure we only ever have one instance
		if(_hasClassInstance())
		{
			return _getClassInstance();
		}

		constructor = _resolveMethodByParams("Constructor", _getClass().getConstructors(), arguments);

		instance = constructor.newInstance(_buildArgumentArray(arguments));

		_setClassInstance(instance);

		return _getClassInstance();
	</cfscript>
</cffunction>

<cffunction	name="onMissingMethod" access="public" returntype="any" output="false" hint="wires the coldfusion invocation to the Java Object">
	<cfargument	name="missingMethodName" type="string"	required="true"	hint=""	/>
	<cfargument	name="missingMethodArguments" type="struct" required="true"	hint=""/>

	<cfscript>
		var method = _findMethod(arguments.missingMethodName, arguments.missingMethodArguments);

		if(_getModifier().isStatic(method.getModifiers()))
		{
			return method.invoke(JavaCast("null", 0), _buildArgumentArray(arguments.missingMethodArguments));
		}
		else
		{
			if(NOT _hasClassInstance())
			{
				//run the default constructor, just like in normal CF, if there is no instance
				init();
			}

			return method.invoke(_getClassInstance(), _buildArgumentArray(arguments.missingMethodArguments));
		}
	</cfscript>
</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="_setStaticFields" hint="loops around all the fields and sets the static one to this scope" access="private" returntype="void" output="false">
	<cfscript>
		var fields = _getClass().getFields();
		var counter = 1;
		var len = ArrayLen(fields);
		var field = 0;

		for(; counter <= len; counter++)
		{
			field = fields[counter];
			if(_getModifier().isStatic(field.getModifiers()))
			{
				this[field.getName()] = field.get(JavaCast("null", 0));
			}
		}
	</cfscript>
</cffunction>

<cffunction name="_buildArgumentArray" hint="builds an argument array out of the arguments" access="private" returntype="array" output="false">
	<cfargument name="arguments" hint="the arguments passed through" type="struct" required="Yes">
	<cfscript>
		var len = StructCount(arguments);
		var objArray = _getArray().newInstance(_getObjectClass(), len);
		var counter = 1;
		var obj = 0;

		for(; counter <= len; counter++)
		{
			obj = arguments[counter];
			_getArray().set(objArray, counter - 1, obj);
		}

		return objArray;
	</cfscript>
</cffunction>

<cffunction name="_findMethod" hint="finds the method that closest matches the signature" access="public" returntype="any" output="false">
	<cfargument name="methodName" hint="the name of the method" type="string" required="Yes">
	<cfargument name="methodArgs" hint="the arguments to look for" type="struct" required="Yes">
	<cfscript>
		var decision = 0;

		if(StructKeyExists(_getMethodCollection(), arguments.methodName))
		{
			decision = StructFind(_getMethodCollection(), arguments.methodName);

			//if there is only one option, try it, it's only going to throw a runtime exception if it doesn't work.
			if(ArrayLen(decision) == 1)
			{
				return decision[1];
			}
			else
			{
				return _resolveMethodByParams(arguments.methodName, decision, arguments.methodArgs);
			}
		}

		throwException("JavaProxy.MethodNotFoundException", "Could not find the designated method", "Could not find the method '#arguments.methodName#' in the class #_getClass().getName()#");
	</cfscript>
</cffunction>

<cffunction name="_resolveMethodByParams" hint="resolves the method to use by the parameters provided" access="private" returntype="any" output="false">
	<cfargument name="methodName" hint="the name of the method" type="string" required="Yes">
	<cfargument name="decision" hint="the array of methods to decide from" type="array" required="Yes">
	<cfargument name="methodArgs" hint="the arguments to look for" type="struct" required="Yes">
	<cfscript>
		var decisionLen = ArrayLen(arguments.decision);
		var method = 0;
		var counter = 1;
		var argLen = ArrayLen(arguments.methodArgs);
		var parameters = 0;
		var paramLen = 0;
		var pCounter = 0;
		var param = 0;
		var class = 0;
		var found = true;

		for(; counter <= decisionLen; counter++)
		{
			method = arguments.decision[counter];
			parameters = method.getParameterTypes();
			paramLen = ArrayLen(parameters);

			found = true;

			if(argLen eq paramLen)
			{
				for(pCounter = 1; pCounter <= paramLen AND found; pCounter++)
				{
					param = parameters[pCounter];
					class = _getClassMethod().invoke(arguments.methodArgs[pCounter], JavaCast("null", 0));

					if(param.isAssignableFrom(class))
					{
						found = true;
					}
					else if(param.isPrimitive()) //if it's a primitive, it can be mapped to object primtive classes
					{
						if(param.getName() eq "boolean" AND class.getName() eq "java.lang.Boolean")
						{
							found = true;
						}
						else if(param.getName() eq "int" AND class.getName() eq "java.lang.Integer")
						{
							found = true;
						}
						else if(param.getName() eq "long" AND class.getName() eq "java.lang.Long")
						{
							found = true;
						}
						else if(param.getName() eq "float" AND class.getName() eq "java.lang.Float")
						{
							found = true;
						}
						else if(param.getName() eq "double" AND class.getName() eq "java.lang.Double")
						{
							found = true;
						}
						else if(param.getName() eq "char" AND class.getName() eq "java.lang.Character")
						{
							found = true;
						}
						else if(param.getName() eq "byte" AND class.getName() eq "java.lang.Byte")
						{
							found = true;
						}
						else if(param.getName() eq "short" AND class.getName() eq "java.lang.Short")
						{
							found = true;
						}
						else
						{
							found = false;
						}
					}
					else
					{
						found = false;
					}
				}

				if(found)
				{
					return method;
				}
			}
		}

		throwException("JavaProxy.MethodNotFoundException", "Could not find the designated method", "Could not find the method '#arguments.methodName#' in the class #_getClass().getName()#");
	</cfscript>
</cffunction>

<cffunction name="_initMethodCollection" hint="creates a method collection of all the methods that are available on the class (this may be cached externally later)" access="private" returntype="void" output="false">
	<cfscript>
		var methods = _getClass().getMethods();
		var len = ArrayLen(methods);
		var counter = 1;
		var method = 0;

		_setMethodCollection(StructNew());

		for(; counter <= len; counter++)
		{
			method = methods[counter];

			if(NOT StructKeyExists(_getMethodCollection(), method.getName()))
			{
				StructInsert(_getMethodCollection(), method.getName(), ArrayNew(1));
			}

			ArrayAppend(StructFind(_getMethodCollection(), method.getName()), method);
		}
	</cfscript>
</cffunction>

<cffunction name="_getMethodCollection" access="private" returntype="struct" output="false">
	<cfreturn instance.MethodCollection />
</cffunction>

<cffunction name="_setMethodCollection" access="private" returntype="void" output="false">
	<cfargument name="MethodCollection" type="struct" required="true">
	<cfset instance.MethodCollection = arguments.MethodCollection />
</cffunction>

<cffunction name="_hasClassInstance" hint="if the proxy has an instance yet" access="private" returntype="boolean" output="false">
	<cfreturn StructKeyExists(instance, "ClassInstance") />
</cffunction>

<cffunction name="_getClassInstance" access="private" returntype="any" output="false">
	<cfreturn instance.ClassInstance />
</cffunction>

<cffunction name="_setClassInstance" access="private" returntype="void" output="false">
	<cfargument name="ClassInstance" type="any" required="true">
	<cfset instance.ClassInstance = arguments.ClassInstance />
</cffunction>

<cffunction name="_getObjectClass" access="private" returntype="any" output="false">
	<cfreturn instance.ObjectClass />
</cffunction>

<cffunction name="_setObjectClass" access="private" returntype="void" output="false">
	<cfargument name="ObjectClass" type="any" required="true">
	<cfset instance.ObjectClass = arguments.ObjectClass />
</cffunction>

<cffunction name="_getArray" access="private" returntype="any" output="false">
	<cfreturn instance.Array />
</cffunction>

<cffunction name="_setArray" access="private" returntype="void" output="false">
	<cfargument name="Array" type="any" required="true">
	<cfset instance.Array = arguments.Array />
</cffunction>

<cffunction name="_getClassMethod" access="private" returntype="any" output="false">
	<cfreturn instance.ClassMethod />
</cffunction>

<cffunction name="_setClassMethod" access="private" returntype="void" output="false">
	<cfargument name="ClassMethod" type="any" required="true">
	<cfset instance.ClassMethod = arguments.ClassMethod />
</cffunction>

<cffunction name="_getClass" access="private" returntype="any" output="false">
	<cfreturn instance.Class />
</cffunction>

<cffunction name="_setClass" access="private" returntype="void" output="false">
	<cfargument name="Class" type="any" required="true">
	<cfset instance.Class = arguments.Class />
</cffunction>

<cffunction name="_getModifier" access="private" returntype="any" output="false">
	<cfreturn instance.Modifier />
</cffunction>

<cffunction name="_setModifier" access="private" returntype="void" output="false">
	<cfargument name="Modifier" type="any" required="true">
	<cfset instance.Modifier = arguments.Modifier />
</cffunction>

<cffunction name="throwException" access="private" hint="Throws an Exception" output="false">
	<cfargument name="type" hint="The type of exception" type="string" required="Yes">
	<cfargument name="message" hint="The message to accompany the exception" type="string" required="Yes">
	<cfargument name="detail" type="string" hint="The detail message for the exception" required="No" default="">
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#">
</cffunction>

</cfcomponent>