<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	A utility object that provides runtime mixins
----------------------------------------------------------------------->
<cfcomponent hint="A utility object that provides runtime mixins" output="false">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cffunction name="init" access="public" returntype="MixerUtil" output="false" hint="Constructor">
		<cfscript>
			instance = structnew();
			instance.mixins = StructNew();

			// Place our methods on the mixins struct
			instance.mixins[ "removeMixin" ] 				= variables.removeMixin;
			instance.mixins[ "injectMixin" ] 				= variables.injectMixin;
			instance.mixins[ "invokerMixin" ] 				= variables.invokerMixin;
			instance.mixins[ "injectPropertyMixin" ] 		= variables.injectPropertyMixin;
			instance.mixins[ "removePropertyMixin" ] 		= variables.removePropertyMixin;
			instance.mixins[ "populatePropertyMixin" ] 		= variables.populatePropertyMixin;
			instance.mixins[ "includeitMixin" ] 			= variables.includeitMixin;
			instance.mixins[ "getPropertyMixin" ]			= variables.getPropertyMixin;
			instance.mixins[ "exposeMixin" ]				= variables.exposeMixin;
			instance.mixins[ "methodProxy" ]				= variables.methodProxy;

			instance.system = createObject('java','java.lang.System');

			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC METHODS ------------------------------------------->

	<!--- Start Method Injection on a CFC --->
	<cffunction name="start" hint="Start method injection set -> Injects: includeitMixin,injectMixin,removeMixin,invokerMixin,injectPropertyMixin,removePropertyMixin,getPropertyMixin,populatePropertyMixin" access="public" returntype="void" output="false">
		<cfargument name="CFC" required="true" hint="The cfc to mixin">
		<cfset var udf = 0>

		<cfif NOT structKeyExists(arguments.CFC, "$mixed")>
		<cflock name="mixerUtil.#instance.system.identityHashCode(arguments.CFC)#" type="exclusive" timeout="15" throwontimeout="true">
			<cfif NOT structKeyExists(arguments.CFC, "$mixed")>
			<cfscript>
				for( udf in instance.mixins ){
					arguments.CFC[udf] = instance.mixins[udf];
				}
				arguments.CFC.$mixed = true;
			</cfscript>
			</cfif>
		</cflock>
		</cfif>
	</cffunction>

	<!--- Stop the injection, do cleanup --->
	<cffunction name="stop" hint="stop injection block. Removes mixed in methods." access="public" returntype="void" output="false">
		<cfargument name="CFC" hint="The cfc to inject the method into" type="any" required="Yes">
		<cfset var udf = 0>

		<cflock name="mixerUtil.#instance.system.identityHashCode(arguments.CFC)#" type="exclusive" timeout="15" throwontimeout="true">
			<cfscript>
				for( udf in instance.mixins ){
					arguments.CFC[udf] = instance.mixins[udf];
					StructDelete(arguments.CFC, udf);
				}
			</cfscript>
		</cflock>
	</cffunction>

<!------------------------------------------- MIXINS ------------------------------------------>

	<!--- exposeMixin --->
	<cffunction name="exposeMixin" access="public" hint="Exposes a private function publicly" returntype="any" output="false">
		<cfargument name="method" 	required="true">
		<cfargument name="newName" 	required="false" default="">
		<cfscript>
			// get new name
			if( !len( arguments.newName ) ){
				arguments.newName = arguments.method;
			}

			// stash it away
			if( !structKeyExists( this, "$exposedMethods") ){
				this.$exposedMethods = {};
			}
			this.$exposedMethods[ arguments.method ] = variables[ arguments.method ];

			// replace with proxy.
			this[ arguments.newName ] = this.methodProxy;

			// Create alias if needed
			if( arguments.newName != arguments.method ){
				this.$exposedMethods[ arguments.newName ] = this.$exposedMethods[ arguments.method ];
			}

			return this;
		</cfscript>
	</cffunction>

	<!--- methodProxy --->
	<cffunction name="methodProxy" access="public" hint="a method proxy" returntype="any" output="false">
		<cfscript>
			var methodName = getFunctionCalledName();

			if( !structKeyExists( this.$exposedMethods, methodName ) ){
				throw( message="The exposed method you are calling: #methodName# does not exist",
					   detail="Exposed methods are #structKeyList( this.$exposedMethods )#",
					   type="ExposedMethodProxy" );
			}

			var method = this.$exposedMethods[ methodName ];
			return method( argumentCollection=arguments );
		</cfscript>
	</cffunction>

	<!--- includeitMixin --->
	<cffunction name="includeitMixin" access="public" hint="Facade for cfinclude" returntype="void" output="true">
		<cfargument name="template" required="true">
		<cfinclude template="#template#">
	</cffunction>

	<!--- injectMixin --->
	<cffunction name="injectMixin" hint="Injects a method into the CFC" access="public" returntype="void" output="false">
		<cfargument name="name" 	required="true"  hint="The name to inject the UDF as"/>
		<cfargument name="UDF"		required="true"  hint="UDF to inject">
		<cfscript>
			variables[arguments.name] 	= arguments.UDF;
			this[arguments.name] 		= arguments.UDF;
		</cfscript>
	</cffunction>

	<!--- populatePropertyMixin --->
	<cffunction name="populatePropertyMixin" hint="Populates a property if it exists" access="public" returntype="void" output="false">
		<cfargument name="propertyName" 	required="true" hint="The name of the property to inject."/>
		<cfargument name="propertyValue" 	required="true" hint="The value of the property to inject"/>
		<cfargument name="scope" 			required="false" default="variables" hint="The scope to which inject the property to."/>
		<cfscript>
			// Validate Property
			if( structKeyExists(evaluate(arguments.scope),arguments.propertyName) ){
				"#arguments.scope#.#arguments.propertyName#" = arguments.propertyValue;
			}
		</cfscript>
	</cffunction>

	<!--- getPropertyMixin --->
	<cffunction name="getPropertyMixin" hint="gets a property" access="public" returntype="any" output="false">
		<cfargument name="name" 	required="true"  hint="The name of the property to inject."/>
		<cfargument name="scope" 	required="false" default="variables" hint="The scope to which inject the property to."/>
		<cfargument name="default"  required="false" hint="Default value to return"/>
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
		<cfargument name="propertyName" 	required="true" hint="The name of the property to inject."/>
		<cfargument name="propertyValue" 	required="true" hint="The value of the property to inject"/>
		<cfargument name="scope" 			required="false" default="variables" hint="The scope to which inject the property to."/>
		<cfscript>
			"#arguments.scope#.#arguments.propertyName#" = arguments.propertyValue;
		</cfscript>
	</cffunction>

	<!--- removeMixin --->
	<cffunction name="removeMixin" hint="Removes a method in a CFC" access="public" returntype="void" output="false">
		<cfargument name="UDFName" hint="Name of the UDF to be removed" type="string" required="Yes">
		<cfscript>
			structDelete(this, arguments.udfName);
			structDelete(variables, arguments.udfName);
		</cfscript>
	</cffunction>

	<!--- removePropertyMixin --->
	<cffunction name="removePropertyMixin" hint="removes a property from the cfc used." access="public" returntype="void" output="false">
		<cfargument name="propertyName" 	required="true" hint="The name of the property to remove."/>
		<cfargument name="scope" 			required="false" default="variables" hint="The scope to which inject the property to."/>
		<cfscript>
			structDelete(evaluate(arguments.scope),arguments.propertyName);
		</cfscript>
	</cffunction>

	<!--- Invoker Mixin --->
	<cffunction name="invokerMixin" hint="Calls private/packaged/public methods" access="public" returntype="any" output="false">
		<cfargument name="method" 		 required="true" 	hint="Name of the private method to call">
		<cfargument name="argCollection" required="false"  	hint="Can be called with an argument collection struct">
		<cfargument name="argList" 		 required="false"  	hint="Can be called with an argument list, for simple values only: ex: 'object=logger,number=1'">

		<cfset var key 		= "">
		<cfset var refLocal = structnew()>

		<!--- Determine type of invocation --->
		<cfif structKeyExists(arguments,"argCollection")>
			<cfinvoke method="#arguments.method#"
					  component="#this#"
					  returnvariable="refLocal.results"
					  argumentcollection="#arguments.argCollection#" />
		<cfelseif structKeyExists(arguments, "argList")>
			<cfinvoke method="#arguments.method#"
					  component="#this#"
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