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
			
			/* Remove mixin methods */
			stop(this);
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC METHODS ------------------------------------------->

	<!--- Start Method Injection on a CFC --->
	<cffunction name="start" hint="start method injection set" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="CFC" hint="The cfc to inject the method into" type="web-inf.cftags.component" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			arguments.CFC["injectMixin"] = instance.mixins.injectMixin;
			arguments.CFC["removeMixin"] = instance.mixins.removeMixin;
		</cfscript>
	</cffunction>
	
	<!--- Stop the injection, do cleanup --->
	<cffunction name="stop" hint="stop injection block" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="CFC" hint="The cfc to inject the method into" type="web-inf.cftags.component" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			StructDelete(arguments.CFC, "injectMixin");
			StructDelete(arguments.CFC, "removeMixin");
		</cfscript>
	</cffunction>
	
	<!--- The actual call to inject a method on the CFC --->
	<cffunction name="injectMethod" hint="Injects a method into a CFC" access="public" returntype="web-inf.cftags.component" output="false">
		<!--- ************************************************************* --->
		<cfargument name="CFC" hint="The cfc to inject the method into" type="web-inf.cftags.component" required="Yes">
		<cfargument name="UDF" hint="UDF to be checked" type="any" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			try{
				arguments.CFC.injectMixin(arguments.UDF);
			}
			catch(Any e){
				throw("#e.message#","Error inserting method #toString(arguments.UDF)#","plugins.methodInjector.InjectionException");
			}
			/* return CFC */
			return arguments.CFC;
		</cfscript>
	</cffunction>
	
	<!--- Remove a method from a CFC --->
	<cffunction name="removeMethod" hint="Take a public Method off a CFC" access="public" returntype="void" output="false">
		<!--- ************************************************************* --->
		<cfargument name="CFC" 		hint="The cfc to inject the method into" type="web-inf.cftags.component" required="Yes">
		<cfargument name="UDFName" 	hint="Name of the UDF to be removed" type="string" required="Yes">
		<!--- ************************************************************* --->
		<cfscript>
			arguments.CFC.removeMixin(arguments.UDFName);
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
	
			if(metadata.access neq "private"){
				/* Place UDF on the this public scope */
				this[metaData.name] = arguments.UDF;
			}
			else{
				/* Place UDF on the variables Scope */
				variables[metadata.name] = arguments.UDF;
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

</cfcomponent>