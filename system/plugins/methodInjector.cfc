<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/31/2007
Description :
	This is a method injector based on the work by Mark Mandel.
----------------------------------------------------------------------->
<cfcomponent name="methodInjector"
			 hint="Method Injector plugin. It provides a nice way to mixin and remove methods from cfc's"
			 extends="coldbox.system.plugin"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="methodInjector" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="controller" type="any" required="true">
		<!--- ************************************************************* --->
		<cfscript>
			super.init(arguments.controller);
			
			/* Plugin Properties */
			setPluginName("Method Injector");
			setPluginVersion("1.0");
			setPluginDescription("A way to inject and remove methods from cfc's");
			
			/* Our mixins Struct */
			instance.mixins = StructNew();
			
			/* Place our methods on the mixins struct */
			instance.mixins["removeMixin"] 				= variables.removeMixin;
			instance.mixins["injectMixin"] 				= variables.injectMixin;
			instance.mixins["invokerMixin"] 			= variables.invokerMixin;
			instance.mixins["injectPropertyMixin"] 		= variables.injectPropertyMixin;
			instance.mixins["removePropertyMixin"] 		= variables.removePropertyMixin;
			instance.mixins["populatePropertyMixin"] 	= variables.populatePropertyMixin;
			
			/* Remove mixin methods */
			stop(this);
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC METHODS ------------------------------------------->

	<!--- Start Method Injection on a CFC --->
	<cffunction name="start" hint="start method injection set. Injects: injectMixin,removeMixin,invokerMixin,injectPropertyMixin,removePropertyMixin" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="CFC" hint="The cfc to inject the method into" type="any" required="Yes">
		<!--- ************************************************************* --->
		<cfset var udf = 0>
		
		<cflock name="plugin.methodInjector.#getmetadata(arguments.cfc).name#" type="exclusive" timeout="5" throwontimeout="true">
			<cfscript>
				/* Inject Mixins methods */
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
		
		<cflock name="plugin.methodInjector.#getmetadata(arguments.cfc).name#" type="exclusive" timeout="5" throwontimeout="true">
			<cfscript>
				/* Remove Mixin Methods */
				for( udf in instance.mixins ){
					arguments.CFC[udf] = instance.mixins[udf];
					StructDelete(arguments.CFC, udf);
				}
			</cfscript>
		</cflock>
	</cffunction>
	
	<!--- ColdBox Controller Accessor/Mutators used to mixing --->
	<cffunction name="getcontroller" access="public" output="false" returntype="any" hint="Get controller: coldbox.system.controller">
		<cfreturn variables.controller/>
	</cffunction>
	<cffunction name="setcontroller" access="public" output="false" returntype="void" hint="Set controller">
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.controller"/>
		<cfset variables.controller = arguments.controller/>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- mixin --->
	<cffunction name="injectMixin" hint="injects a method into the CFC scope" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="UDF" hint="UDF to be checked" type="any" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			var metadata = getMetaData(arguments.UDF);
			
			/* Check for metadata Access */
			if( not structKeyExists(metadata, "access") ){
				metadata.access = "public";
			}
			
			/* Place UDF on the variables Scope */
			variables[metadata.name] = arguments.UDF;
	
			if(metadata.access neq "private"){
				/* Place UDF on the this public scope */
				this[metaData.name] = arguments.UDF;
			}
		</cfscript>
	</cffunction>
	
	<!--- mixin --->
	<cffunction name="populatePropertyMixin" hint="Populates a property if it exists" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="propertyName" 	type="string" 	required="true" hint="The name of the property to inject."/>
		<cfargument name="propertyValue" 	type="any" 		required="true" hint="The value of the property to inject"/>
		<cfargument name="scope" 			type="string" 	required="false" default="variables" hint="The scope to which inject the property to."/>
		<!--- ************************************************************* --->
		<cfscript>
			/* Validate Property */
			if( structKeyExists(evaluate(arguments.scope),arguments.propertyName) ){
				/* Populate Property */
				"#arguments.scope#.#arguments.propertyName#" = arguments.propertyValue;
			}			
		</cfscript>
	</cffunction>
	
	<!--- mixin --->
	<cffunction name="injectPropertyMixin" hint="injects a property into the passed scope" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="propertyName" 	type="string" 	required="true" hint="The name of the property to inject."/>
		<cfargument name="propertyValue" 	type="any" 		required="true" hint="The value of the property to inject"/>
		<cfargument name="scope" 			type="string" 	required="false" default="variables" hint="The scope to which inject the property to."/>
		<!--- ************************************************************* --->
		<cfscript>
			/* Inject Property */
			"#arguments.scope#.#arguments.propertyName#" = arguments.propertyValue;
		</cfscript>
	</cffunction>
	
	<!--- Remove Mixin --->
	<cffunction name="removeMixin" hint="removes a method in a CFC" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="UDFName" hint="Name of the UDF to be removed" type="string" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			StructDelete(this, arguments.udfName);
			StructDelete(variables, arguments.udfName);
		</cfscript>
	</cffunction>
	
	<!--- Remove Mixin --->
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
		<cfset var results = "">
		<cfset var key = "">
		
		<!--- Determine type of invocation --->
		<cfif structKeyExists(arguments,"argCollection")>
			<cfinvoke method="#arguments.method#" 
					  returnvariable="results" 
					  argumentcollection="#arguments.argCollection#" />
		<cfelseif structKeyExists(arguments, "argList")>
			<cfinvoke method="#arguments.method#" 
					  returnvariable="results">
				<cfloop list="#argList#" index="key">
					<cfinvokeargument name="#listFirst(key,'=')#" value="#listLast(key,'=')#">
				</cfloop>
			</cfinvoke>
		<cfelse>
			<cfinvoke method="#arguments.method#" 
					  returnvariable="results" />
		</cfif>
		
		<!--- Return results if Found --->
		<cfif isDefined("results")>
			<cfreturn results>
		</cfif>
	</cffunction>

</cfcomponent>