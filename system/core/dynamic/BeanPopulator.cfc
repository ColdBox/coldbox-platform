<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	This is a bean populator that binds different types of data to a bean.
----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is a bean populator that binds different types of data to a bean.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<!--- init --->
    <cffunction name="init" output="false" access="public" returntype="BeanPopulator" hint="Constructor">
    	<cfscript>
    		JSONUtil  = createObject("component","coldbox.system.core.conversion.JSON").init();
			mixerUtil = createObject("component","coldbox.system.core.dynamic.MixerUtil").init();
			
			return this;
		</cfscript>
    </cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- populateFromJSON --->
	<cffunction name="populateFromJSON" access="public" returntype="any" hint="Populate a named or instantiated bean from a json string" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true"  	type="any" 		hint="The target to populate">
		<cfargument name="JSONString"   	required="true" 	type="string" 	hint="The JSON string to populate the object with. It has to be valid JSON and also a structure with name-key value pairs. ">
		<cfargument name="scope" 			required="false" 	type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" 	type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" 	type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" 	type="string"  default="" hint="A list of keys to exclude in the population">
		<!--- ************************************************************* --->
		<cfscript>
			// Inflate JSON
			arguments.memento = JSONUtil.decode(arguments.JSONString);

			// populate and return
			return populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>
	
	<!--- Populate from XML--->
	<cffunction name="populateFromXML" access="public" returntype="any" hint="Populate a named or instantiated bean from an XML packet" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true"  	type="any" 		hint="The target to populate">
		<cfargument name="xml"   			required="true" 	type="any" 		hint="The XML string or packet">
		<cfargument name="root"   			required="false" 	type="string"  default=""  hint="The XML root element to start from">
		<cfargument name="scope" 			required="false" 	type="string"  default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" 	type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" 	type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false"	type="string"  default="" hint="A list of keys to exclude in the population">
		<!--- ************************************************************* --->
		<cfscript>
			var key				= "";
			var childElements 	= "";
			var	x				= 1;
			
			// determine XML
			if( isSimpleValue(arguments.xml) ){
				arguments.xml = xmlParse( arguments.xml );
			}
			
			// check root
			if( NOT len(arguments.root) ){
				arguments.root = "XMLRoot";
			}
			
			// check children
			if( NOT structKeyExists(arguments.xml[arguments.root],"XMLChildren") ){
				return;
			}
			
			// prepare memento
			arguments.memento = structnew();
			
			// iterate and build struct of data
			childElements = arguments.xml[arguments.root].XMLChildren;
			for(x=1; x lte arrayLen(childElements); x=x+1){
				arguments.memento[ childElements[x].XMLName ] = trim(childElements[x].XMLText);
			}
			
			return populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate from Query --->
	<cffunction name="populateFromQuery" access="public" returntype="Any" hint="Populate a named or instantiated bean from query" output="false">
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true"  type="any" 	hint="The target to populate">
		<cfargument name="qry"       		required="true"  type="query"   hint="The query to popluate the bean object with">
		<cfargument name="rowNumber" 		required="false" type="Numeric" hint="The query row number to use for population" default="1">
		<cfargument name="scope" 			required="false" type="string"  default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<!--- ************************************************************* --->
		<cfscript>
			//by default to take values from first row of the query
			var row = arguments.RowNumber;
			//columns array
			var cols = listToArray(arguments.qry.columnList);
			var i   = 1;
			
			arguments.memento = structnew();

			//build the struct from the query row
			for(i = 1; i lte arraylen(cols); i = i + 1){
				arguments.memento[cols[i]] = arguments.qry[cols[i]][row];
			}

			//populate bean and return
			return populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>
	
	<!--- Populate an object using a query, but, only specific columns in the query. --->
	<cffunction name="populateFromQueryWithPrefix" output=false
		hint="Populates an Object using only specific columns from a query. Useful for performing a query with joins that needs to populate multiple objects.">
		<cfargument name="target"  			required="true"  	type="any" 	 	hint="This can be an instantiated bean object or a bean instantitation path as a string. If you pass an instantiation path and the bean has an 'init' method. It will be executed. This method follows the bean contract (set{property_name}). Example: setUsername(), setfname()">
		<cfargument name="qry"       		required="true"  	type="query"   	hint="The query to popluate the bean object with">
		<cfargument name="rowNumber" 		required="false" 	type="Numeric" 	hint="The query row number to use for population" default="1">
		<cfargument name="scope" 			required="false" 	type="string"   default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>
		<cfargument name="trustedSetter"  	required="false" 	type="boolean" 	default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" 	type="string"  	default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" 	type="string"  	default="" hint="A list of keys to exclude in the population">
		<cfargument name="prefix"  			required="true" 	type="string"  	hint="The prefix used to filter, Example: 'user_' would apply to the following columns: 'user_id' and 'user_name' but not 'address_id'.">
		<cfscript>
			// Create a struct including only those keys that match the prefix.
			//by default to take values from first row of the query
			var row 			= arguments.rowNumber;
			var cols 			= listToArray(arguments.qry.columnList);
			var i   			= 1;
			var n				= arrayLen(cols);
			var prefixLength 	= len(arguments.prefix);
			var trueColumnName 	= "";
			
			arguments.memento = structNew();

			//build the struct from the query row
			for(i = 1; i LTE n; i = i + 1){
				if ( left(cols[i], prefixLength) EQ arguments.prefix ) {
					trueColumnName = right(cols[i], len(cols[i]) - prefixLength);
					arguments.memento[trueColumnName] = arguments.qry[cols[i]][row];
				}
			}

			//populate bean and return
			return populateFromStruct(argumentCollection=arguments);
		</cfscript>
	</cffunction>

	<!--- Populate a bean from a structure --->
	<cffunction name="populateFromStruct" access="public" returntype="any" hint="Populate a named or instantiated bean from a structure" output="false" >
		<!--- ************************************************************* --->
		<cfargument name="target" 			required="true"  type="any" 	hint="The target to populate">
		<cfargument name="memento"  		required="true"  type="struct" 	hint="The structure to populate the object with.">
		<cfargument name="scope" 			required="false" type="string"  hint="Use scope injection instead of setters population."/>
		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>
		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">
		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">
		<!--- ************************************************************* --->
		<cfscript>
			var beanInstance = arguments.target;
			var key = "";
			var pop = true;
			var scopeInjection = false;
			var udfCall = "";
			var args = "";

			try{
				
				// Determine Method of population
				if( structKeyExists(arguments,"scope") and len(trim(arguments.scope)) neq 0 ){
					scopeInjection = true;
					mixerUtil.start( beanInstance );
				}

				// Populate Bean
				for(key in arguments.memento){
					pop = true;
					// Include List?
					if( len(arguments.include) AND NOT listFindNoCase(arguments.include,key) ){
						pop = false;
					}
					// Exclude List?
					if( len(arguments.exclude) AND listFindNoCase(arguments.exclude,key) ){
						pop = false;
					}

					// Pop?
					if( pop ){
						// Scope Injection?
						if( scopeInjection ){
							beanInstance.populatePropertyMixin(propertyName=key,propertyValue=arguments.memento[key],scope=arguments.scope);
						}
						// Check if setter exists, evaluate is used, so it can call on java/groovy objects
						else if( structKeyExists(beanInstance,"set" & key) or arguments.trustedSetter ){
							evaluate("beanInstance.set#key#(arguments.memento[key])");
						}
					}

				}//end for loop

				return beanInstance;
			}
			catch(Any e){
				if (isObject(arguments.memento[key]) OR isCustomFunction(arguments.memento[key])){
					arguments.keyTypeAsString = getMetaData(arguments.memento[key]).name;
				}
				else{
		        	arguments.keyTypeAsString = arguments.memento[key].getClass().toString();
				}
				getUtil().throwIt(type="BeanPopulator.PopulateBeanException",
					  			  message="Error populating bean #getMetaData(beanInstance).name# with argument #key# of type #arguments.keyTypeAsString#.",
					  			  detail="#e.Detail#<br>#e.message#<br>#e.tagContext.toString()#");
			}
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>

	<!--- Get ColdBox Util --->
	<cffunction name="getUtil" access="private" output="false" returntype="coldbox.system.core.util.Util" hint="Create and return a util object">
		<cfreturn createObject("component","coldbox.system.core.util.Util")/>
	</cffunction>

</cfcomponent>