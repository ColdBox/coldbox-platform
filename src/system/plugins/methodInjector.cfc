<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
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
			
			/* Place our two methods on the mixins struct */
			instance.mixins["removeMixin"] = variables.removeMixin;
			instance.mixins["injectMixin"] = variables.injectMixin;
			instance.mixins["invokerMixin"] = variables.invokerMixin;
			
			/* Remove mixin methods */
			stop(this);
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC METHODS ------------------------------------------->

	<!--- Start Method Injection on a CFC --->
	<cffunction name="start" hint="start method injection set. Injects: injectMixin,removeMixin, invokerMixin" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="CFC" hint="The cfc to inject the method into" type="web-inf.cftags.component" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			arguments.CFC["injectMixin"] = instance.mixins.injectMixin;
			arguments.CFC["removeMixin"] = instance.mixins.removeMixin;
			arguments.CFC["invokerMixin"] = instance.mixins.invokerMixin;
		</cfscript>
	</cffunction>
	
	<!--- Stop the injection, do cleanup --->
	<cffunction name="stop" hint="stop injection block. Removes mixed in methods." access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="CFC" hint="The cfc to inject the method into" type="web-inf.cftags.component" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			StructDelete(arguments.CFC, "injectMixin");
			StructDelete(arguments.CFC, "removeMixin");
			StructDelete(arguments.CFC, "invokerMixin");
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<!--- mixin --->
	<cffunction name="injectMixin" hint="[mixin, removed at init] - injects a method into the CFC scope" access="public" returntype="void" output="false">
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
	
	<!--- Remove Mixin --->
	<cffunction name="removeMixin" hint="[mixin, removed at init] - injects a method into the CFC scope" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="UDFName" hint="Name of the UDF to be removed" type="string" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			StructDelete(this, arguments.udfName);
			StructDelete(variables, arguments.udfName);
		</cfscript>
	</cffunction>
	
	<!--- Invoker Mixin --->
	<cffunction name="invokerMixin" hint="[mixin, removed at init] - calls private methods" access="public" returntype="any" output="false">
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