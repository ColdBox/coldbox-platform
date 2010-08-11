<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	This is a method injector based on the work by Mark Mandel.
----------------------------------------------------------------------->
<cfcomponent hint="It provides a nice way to mixin and remove methods from CFCs"
			 output="false">
			 
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="MethodInjector" output="false" hint="Constructor">
		<cfscript>
			
			instance.mixins = StructNew();
			
			// Place our methods on the mixins struct
			instance.mixins["removeMixin"] 				= variables.removeMixin;
			instance.mixins["injectMixin"] 				= variables.injectMixin;
			instance.mixins["invokerMixin"] 			= variables.invokerMixin;
			instance.mixins["injectPropertyMixin"] 		= variables.injectPropertyMixin;
			instance.mixins["removePropertyMixin"] 		= variables.removePropertyMixin;
			instance.mixins["populatePropertyMixin"] 	= variables.populatePropertyMixin;
			instance.mixins["includeitMixin"] 			= variables.includeitMixin;
						
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC METHODS ------------------------------------------->

	<!--- Start Method Injection on a CFC --->
	<cffunction name="start" hint="start method injection set. Injects: injectMixin,removeMixin,invokerMixin,injectPropertyMixin,removePropertyMixin" access="public" returntype="void" output="false">
		<cfargument name="CFC" hint="The cfc to inject the method into" type="any" required="Yes">
		<cfset var udf = 0>
		
		<cflock name="plugin.MethodInjector.#getmetadata(arguments.cfc).name#" type="exclusive" timeout="5" throwontimeout="true">
			<cfscript>
				for( udf in instance.mixins ){
					arguments.CFC[udf] = instance.mixins[udf];
				}
			</cfscript>
		</cflock>		
	</cffunction>
	
	<!--- Stop the injection, do cleanup --->
	<cffunction name="stop" hint="stop injection block. Removes mixed in methods." access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="CFC" hint="The cfc to inject the method into" type="any" required="Yes">
		<!--- ************************************************************* --->
		<cfset var udf = 0>
		
		<cflock name="plugin.MethodInjector.#getmetadata(arguments.cfc).name#" type="exclusive" timeout="5" throwontimeout="true">
			<cfscript>
				for( udf in instance.mixins ){
					arguments.CFC[udf] = instance.mixins[udf];
					StructDelete(arguments.CFC, udf);
				}
			</cfscript>
		</cflock>
	</cffunction>

<!------------------------------------------- MIXINS ------------------------------------------>

	<!--- includeitMixin --->
	<cffunction name="includeitMixin" access="public" hint="Facade for cfinclude" returntype="void" output="false">
		<cfargument name="template" type="string" required="yes">
		<cfinclude template="#template#">
	</cffunction>

	<!--- injectMixin --->
	<cffunction name="injectMixin" hint="injects a method into the CFC scope" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="UDF"	type="any" 		required="true"  hint="UDF to inject">
		<cfargument name="name" type="string"	required="false" default="" hint="The name to inject the UDF as"/>
		<!--- ************************************************************* --->
		<cfscript>
			var metadata = getMetaData(arguments.UDF);
			
			// Check for metadata Access
			if( not structKeyExists(metadata, "access") ){
				metadata.access = "public";
			}
			
			// Name Override?
			if( len(arguments.name) ){
				metadata.name = arguments.name;
			}
			
			// Place UDF on the variables scope
			variables[metadata.name] = arguments.UDF;
	
			if(metadata.access neq "private"){
				// Place UDF on the this public scope
				this[metaData.name] = arguments.UDF;
			}
		</cfscript>
	</cffunction>

	<!--- populatePropertyMixin --->
	<cffunction name="populatePropertyMixin" hint="Populates a property if it exists" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="propertyName" 	type="string" 	required="true" hint="The name of the property to inject."/>
		<cfargument name="propertyValue" 	type="any" 		required="true" hint="The value of the property to inject"/>
		<cfargument name="scope" 			type="string" 	required="false" default="variables" hint="The scope to which inject the property to."/>
		<!--- ************************************************************* --->
		<cfscript>
			// Validate Property 
			if( structKeyExists(evaluate(arguments.scope),arguments.propertyName) ){
				"#arguments.scope#.#arguments.propertyName#" = arguments.propertyValue;
			}			
		</cfscript>
	</cffunction>
	
	<!--- getPropertyMixin --->
	<cffunction name="getPropertyMixin" hint="gets a property" access="public" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="name" 	type="string" 	required="true" hint="The name of the property to inject."/>
		<cfargument name="scope" 	type="string" 	required="false" default="variables" hint="The scope to which inject the property to."/>
		<cfargument name="default"  type="any"      required="false" hint="Default value to return"/>
		<!--- ************************************************************* --->
		<cfscript>
			var thisScope = variables;
			if( arguments.scope eq "this"){ thisScope = this; }
			
			if( NOT structKeyExists(thisScope,arguments.name) AND structKeyExists(arguments,"default")){
				return arguments.default;
			}
			
			return thisScope[arguments.name];
		</cfscript>
	</cffunction>
	
	<!--- injectPropertyMixin --->
	<cffunction name="injectPropertyMixin" hint="injects a property into the passed scope" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="propertyName" 	type="string" 	required="true" hint="The name of the property to inject."/>
		<cfargument name="propertyValue" 	type="any" 		required="true" hint="The value of the property to inject"/>
		<cfargument name="scope" 			type="string" 	required="false" default="variables" hint="The scope to which inject the property to."/>
		<!--- ************************************************************* --->
		<cfscript>
			"#arguments.scope#.#arguments.propertyName#" = arguments.propertyValue;
		</cfscript>
	</cffunction>
	
	<!--- removeMixin --->
	<cffunction name="removeMixin" hint="removes a method in a CFC" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="UDFName" hint="Name of the UDF to be removed" type="string" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			StructDelete(this, arguments.udfName);
			StructDelete(variables, arguments.udfName);
		</cfscript>
	</cffunction>
	
	<!--- removePropertyMixin --->
	<cffunction name="removePropertyMixin" hint="removes a property from the cfc used." access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="propertyName" 	type="string" 	required="true" hint="The name of the property to remove."/>
		<cfargument name="scope" 			type="string" 	required="false" default="variables" hint="The scope to which inject the property to."/>
		<!--- ************************************************************* --->
		<cfscript>
			structDelete(evaluate(arguments.scope),arguments.propertyName);
		</cfscript>
	</cffunction>
	
	<!--- Invoker Mixin --->
	<cffunction name="invokerMixin" hint="calls private/packaged/public methods" access="public" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="method" 		 type="string" required="Yes" hint="Name of the private method to call">
		<cfargument name="argCollection" type="struct" required="No"  hint="Can be called with an argument collection struct">
		<cfargument name="argList" 		 type="string" required="No"  hint="Can be called with an argument list, for simple values only: ex: 'plugin=logger,number=1'">
		<!--- ************************************************************* --->
		<cfset var key 		= "">
		<cfset var refLocal = structnew()>
		
		<!--- Determine type of invocation --->
		<cfif structKeyExists(arguments,"argCollection")>
			<cfinvoke method="#arguments.method#" 
					  returnvariable="refLocal.results" 
					  argumentcollection="#arguments.argCollection#" />
		<cfelseif structKeyExists(arguments, "argList")>
			<cfinvoke method="#arguments.method#" 
					  returnvariable="refLocal.results">
				<cfloop list="#argList#" index="key">
					<cfinvokeargument name="#listFirst(key,'=')#" value="#listLast(key,'=')#">
				</cfloop>
			</cfinvoke>
		<cfelse>
			<cfinvoke method="#arguments.method#" returnvariable="refLocal.results" />
		</cfif>
		
		<!--- Return results if Found --->
		<cfif structKeyExists(refLocal,"results")>
			<cfreturn refLocal.results>
		</cfif>
	</cffunction>

</cfcomponent>