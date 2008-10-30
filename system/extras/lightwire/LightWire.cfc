<cfcomponent name="LightWire" hint="I am the LightWire factory that creates all singleton and transient objects, injecting them with all of their necessary dependencies as defined in the configuration file." output="false">
	
<!------------------------------------------------- CONSTRUCTOR ---------------------------------------------------------->	

	<!--- Init --->
	<cffunction name="init" returntype="LightWire" access="public" output="false" hint="I initialize the LightWire object factory.">
		<!---************************************************************************************************ --->
		<cfargument name="ConfigBean" type="any" required="yes" hint="I am the initialized config bean.">
		<!---************************************************************************************************ --->
		<cfscript>
			var key = "";
			var beanStruct = structnew();
			
			/* Singleton Cache */
			variables.singleton = StructNew();
			
			/* Main LightWire Properties */
			variables.lightWire.LazyLoad = ConfigBean.getLazyLoad();
			
			/* Config Structure */
			variables.config = ConfigBean.getConfigStruct();
			
			/* Setup yourself as a singleton */
			variables.singleton.lightWire = this;
			
			/* Are we lazy loading? */
			if (NOT variables.LightWire.LazyLoad){
	   			beanStruct = variables.config;
	   		}
	   		else{
	   			/* We are not lazy Loading, just get the non-lazy beans then */
	   			beanStruct = ConfigBean.getnonLazyBeans();
	   		}	   		
	   		
	   		/* Create The appropriate Beans: either non lazy beans or all singletons according to lazy property */
	   		for(key in beanStruct){
   				// Create every singleton
	   			if (variables.Config[key].Singleton){
	   				/* Verify they are not in the singleton cache */
					if(not StructKeyExists(variables.Singleton,key)){
						// Only create if hasn't already been created as dependency of earlier singleton
						variables.Singleton[key] = variables.getObject(key,"Singleton");
					}
	   			}
   			}
	   		/* Return instance */
	   		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------------- PUBLIC ---------------------------------------------------------->	

	<!--- Get a Bean --->
	<cffunction name="getBean" returntype="any" access="public" output="false" hint="I return a bean with all of its dependencies loaded.">
		<!---************************************************************************************************ --->
		<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to generate.">
		<!---************************************************************************************************ --->
		<cfscript>
			// Depending on whether the object is singleton or transient, call the appropriate method and return the results. 
			var ReturnObject = 0;
			
			if(variables.config[ObjectName].Singleton){	
				ReturnObject = getSingleton(ObjectName); 
			}
			else{ 
				ReturnObject = getTransient(ObjectName); 
			}
			
			return returnObject;
		</cfscript>	
	</cffunction>
	
	<!--- Get a Singleton --->
	<cffunction name="getSingleton" returntype="any" access="public" output="false" hint="I return a LightWire scoped Singleton with all of its dependencies loaded.">
		<!---************************************************************************************************ --->
		<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to generate.">
		<!---************************************************************************************************ --->
		<!--- If the object doesn't exist, lazy load it  --->
		<cfif not StructKeyExists(variables.Singleton, arguments.ObjectName)>
			<cflock name="#ObjectName#Loading" timeout="5" throwontimeout="true">
				<cfif not StructKeyExists(variables.Singleton, arguments.ObjectName)>
					<cfset variables.Singleton[arguments.ObjectName] = variables.getObject(arguments.ObjectName,"Singleton")>
				</cfif>
			</cflock>
		</cfif>
		<cfreturn variables.Singleton[arguments.ObjectName] />	
	</cffunction>
	
	<!--- Get a Transient --->
	<cffunction name="getTransient" returntype="any" access="public" output="false" hint="I return a transient object.">
		<!---************************************************************************************************ --->
		<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to create." />	
		<!---************************************************************************************************ --->
		<cfreturn variables.getObject(arguments.ObjectName,"Transient") />
	</cffunction>
	
	<!--- Altered by Luis Majano for autowiring purposes. --->
	<cffunction name="containsBean" access="public" output="false" returntype="boolean" hint="returns true if the BeanFactory contains a bean definition that matches the given name">
		<!---************************************************************************************************ --->
		<cfargument name="beanName" required="true" type="string" hint="name of the bean to look for"/>
		<!---************************************************************************************************ --->
		<cfreturn structKeyExists(variables.config, arguments.beanName)>
	</cffunction>

<!------------------------------------------------- PRIVATE ---------------------------------------------------------->	

	<!--- Get an Object --->
	<cffunction name="getObject" returntype="any" access="private" output="false" hint="I return a LightWire scoped object (Singleton or Transient) with all of its dependencies loaded.">
		<!---************************************************************************************************ --->
		<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to return.">
		<cfargument name="ObjectType" type="string" required="yes" hint="I am the type of object to return (Singleton or Transient).">
		<!---************************************************************************************************ --->
		<cfscript>
			// Firstly get a list of all constructor dependent singleton objects that haven't been created (if any) - n levels deep
			var ObjectstoCreateList = variables.getDependentObjectList(arguments.ObjectName);
			var LoopObjectName = "";
			var TemporaryObjects = StructNew();
			var Count = 1;		
			var ListLength = 0;		
			var ReturnObject = "";		
			var LoopObjectList = ObjectstoCreateList;		
			
			// Then create all of the dependent objects
			while (ListLen(LoopObjectList))
			{
				// Get the last object name
				LoopObjectName = ListLast(LoopObjectList);
				// Call createNewObject() to create and constructor initialize it
	   			variables.Singleton[LoopObjectName] = variables.createNewObject(LoopObjectName,"Singleton");
	   			// Remove that object name from the list
				ListLength = ListLen(LoopObjectList);
				LoopObjectList = ListDeleteAt(LoopObjectList,ListLength);
			};
			// Then create the original object
			ReturnObject = variables.createNewObject(arguments.ObjectName,arguments.ObjectType);
			// And if it is a singleton, cache it within LightWire
			If (arguments.ObjectType EQ "Singleton")
				variables.Singleton[arguments.ObjectName] = ReturnObject;
				
	   		// Then for each dependent object, do any setter and mixin injections required
	   		LoopObjectList = ObjectstoCreateList;
			while (ListLen(LoopObjectList))
			{
				// Get the last object name
				LoopObjectName = ListLast(LoopObjectList);
				// Call setterandmixinInject() to inject any setter or mixin dependencies
	   			variables.Singleton[LoopObjectName] = variables.setterandMixinInject(LoopObjectName,variables.Singleton[LoopObjectName]);
	   			// Remove that object name from the list
				ListLength = ListLen(LoopObjectList);
				LoopObjectList = ListDeleteAt(LoopObjectList,ListLength);
			};
	   		
	   		// Finally for the requested object, do any setter and mixin injections required
	   		ReturnObject = variables.setterandMixinInject(arguments.ObjectName,ReturnObject);
			
			//Return Object
			return ReturnObject;
		</cfscript>
	</cffunction>
						
	<cffunction name="getDependentObjectList" returntype="string" access="private" output="false" hint="I return a comma delimited list of all of the dependencies that have not been created yet for an object - n-levels down.">
		<!---************************************************************************************************ --->
		<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to get the dependencies for.">
		<!---************************************************************************************************ --->
		<cfscript>
			var ObjectDependencyList = "";
			var TempObjectDependencyList = "";
			var ObjectstoCreateList = "";
			var LoopObjectName = "";
			var LoopObjectDependencySet = "";
			var CircularDependency = "";
			var ListLength = "";
			var NewObjectName = "";
			var Position = "";
			var Count = 1;
			var ConfigCount = 1;
			var Key	= "";
			
			If (StructCount(variables.Config[arguments.ObjectName].ConstructorDependencyStruct))
				{ObjectDependencyList = StructKeyList(variables.Config[arguments.ObjectName].ConstructorDependencyStruct);}
			
			// Add the original object name to each element in the object dependency list for circular dependency checking
			For (Count = 1; Count lte listlen(ObjectDependencyList); Count = Count + 1)
	   		{ 
				// Get current object name
				LoopObjectName = ListGetAt(ObjectDependencyList, Count);
				// Prepend it with ObjectName
				LoopObjectName = ListAppend(arguments.ObjectName,LoopObjectName,"|");
				// Add it to the new object dependency list
				TempObjectDependencyList = ListAppend(TempObjectDependencyList,LoopObjectName);
	   		};
	   		// Replace the original object dependency list with the one prepended with its dependency parent for circular dependency resolution checking
			ObjectDependencyList = TempObjectDependencyList;
								
			while (ListLen(ObjectDependencyList))
			{
				// Get the first object dependency set on the list
				LoopObjectDependencySet = ListFirst(ObjectDependencyList);
				// Get the list of the object name within that dependency set
				LoopObjectName = ListLast(LoopObjectDependencySet,"|");
				// Remove that last record from the list
				ListLength = ListLen(LoopObjectDependencySet,"|");
				LoopObjectDependencySet = ListDeleteAt(LoopObjectDependencySet,ListLength,"|");
				
				If (not StructKeyExists(variables.Singleton,LoopObjectName))
				{
					// This object doesn't exist
					// Firstly make sure the dependency != circular
					If (ListFindNoCase(LoopObjectName,LoopObjectDependencySet,"|")) 
					{
						CircularDependency = ListAppend(CircularDependency,"#LoopObjectName# is dependent on a parent. Its dependency path is #LoopObjectDependencySet#");
					}
					Else
					{
						// If it already exists on the list  of objects to create remove it from where it is
						while (ListFindNoCase(ObjectstoCreateList,LoopObjectName))
						{
							Position = ListFindNoCase(ObjectstoCreateList,LoopObjectName);
							ObjectstoCreateList = ListDeleteAt(ObjectstoCreateList,Position);
						};
						
						// Add it to the list of dependent objects to create
						ObjectstoCreateList = ListAppend(ObjectstoCreateList,LoopObjectName);			
						
						// And we need to add its dependencies to this list if it has any
						If (StructCount(variables.Config[LoopObjectName].ConstructorDependencyStruct))
						{
							// Set the parent dependency set for this object
							LoopObjectDependencySet = ListAppend(LoopObjectDependencySet,LoopObjectName,"|");
							
	   						For (Key in variables.Config[LoopObjectName].ConstructorDependencyStruct)
	   						{ 
								// Firstly make sure the new dependency != circular
								If (ListFindNoCase(LoopObjectDependencySet,Key,"|")) 
								{
									CircularDependency = ListAppend(CircularDependency,"#Key# is dependent on a parent. Its dependency path is #LoopObjectDependencySet#");
								}
								Else
								{
									// Append new object with parent dependency to object dependency list
									ObjectDependencyList = ListAppend(ObjectDependencyList,LoopObjectDependencySet & "|" & Key);			
								};
							};
						};
					};
				};
				// Remove the current object name from the list
				ObjectDependencyList = ListDeleteAt(ObjectDependencyList,1);
			};
		</cfscript>	
		<cfreturn ObjectstoCreateList>
	</cffunction>
	
	<cffunction name="createNewObject" returntype="any" access="private" output="false" hint="I create a object.">
		<!---************************************************************************************************ --->
		<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to create.">
		<cfargument name="ObjectType" type="string" required="yes" hint="I am the type of object to create. Singleton or Transient.">
		<!---************************************************************************************************ --->
		<cfscript>
			var ReturnObject = "";
			var InitStruct = StructNew();
			var TempObjectName = "";
			var Count = 0;
			var ObjectPath = "";
			var ObjectFactory = "";
			var ObjectMethod = "";
			var Key	= "";
			var CreateType = variables.Config[arguments.ObjectName].Type;
			
			/* Map Type to CF create object types */
			if( CreateType eq "cfc" ){ createType = "component"; }
			if( CreateType eq "java" ){ CreateType = "java"; }
			if( CreateType eq "webservice" ){ CreateType = "webservice"; }
			
			// Get any constructor properties
			If (StructKeyExists(variables.Config[arguments.ObjectName], "ConstructorProperties"))
				{InitStruct = variables.Config[arguments.ObjectName].ConstructorProperties;}
			
			// Get any constructor dependencies		
			If (StructCount(variables.Config[arguments.ObjectName].ConstructorDependencyStruct))
			For (Key in variables.Config[arguments.ObjectName].ConstructorDependencyStruct)
	   		{
				InitStruct[variables.Config[arguments.ObjectName].ConstructorDependencyStruct[key]] = variables.getBean(Key);
	   		};		
	
			// See whether the object is a factory created bean
			If ( not variables.config[arguments.ObjectName].isFactoryBean)
			{
				// Get the configured object path
				ObjectPath = "#variables.Config[arguments.ObjectName].Path#";
				if( CreateType eq "component" ){
					// if the objectPath is empty correct the dot path
					ObjectPath = Replace(ObjectPath,"..",".","all");
				}
				
				// Create the object and initialize it
				ReturnObject = CreateObject(CreateType,ObjectPath);
				
				
				//LuisMajano: Initialize if available. It might not have an init constructor
				if( structKeyExists(ReturnObject,"init") ){
					ReturnObject = ReturnObject.init(ArgumentCollection=InitStruct);
				}
			}
			Else
			{
				// The object doesn't have a path - get the factory info and ask the factory for it (using getSingleton to get the factory)
				ObjectFactory = getSingleton(variables.config[arguments.ObjectName].FactoryBean);
				ObjectMethod = variables.config[arguments.ObjectName].FactoryMethod;
				/* invoke the Method */
				ReturnObject = invoker(objectFactory,objectMethod,InitStruct);
			};
	
			// Give it the Lightwire methods to allow for mixin injection and annotations
			if( CreateType eq "component" ){
				ReturnObject.lightwireMixin = variables.lightwireMixin;
				ReturnObject.lightwireGetAnnotations = variables.lightwireGetAnnotations;
			}
			
			/* Return */
			return ReturnObject;
		</cfscript>
	</cffunction>
	
	<cffunction name="setterandMixinInject" returntype="any" access="private" output="false" hint="I handle.">
		<!---************************************************************************************************ --->
		<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to inject dependencies into.">
		<cfargument name="Object" type="any" required="yes" hint="I am the object to inject dependencies into.">
		<!---************************************************************************************************ --->
		<cfscript>
			var DependentObjectName = "";
			var Count = 1;
			var Key = "";
			var MixinInjectionList = "";
			var ObjectType = variables.Config[arguments.ObjectName].Type;
			
			// SETTER DEPENDENCIES
			// If there are any setter dependencies
			If (StructCount(variables.Config[arguments.ObjectName].SetterDependencyStruct))
			{ 
				// Inject them all 
				For (Key in variables.Config[arguments.ObjectName].SetterDependencyStruct)
		   		{ 
					If (key NEQ arguments.ObjectName)
					{
						evaluate("arguments.object.set#Config[arguments.ObjectName].SetterDependencyStruct[Key]#(variables.getSingleton(key))");	
					};
				};
			};	
			
			// SETTER PROPERTIES
			// If there are any setter properties
			If (StructKeyExists(variables.Config[arguments.ObjectName],"SetterProperties"))
			{ 
	   			For (key in variables.Config[arguments.ObjectName].SetterProperties)
	   			{
					evaluate("arguments.object.set#key#(variables.Config[arguments.ObjectName].SetterProperties[key])");	
	   			};
			};
			
			/* Only Mixin if CFC */
			if( ObjectType eq "cfc" ){
				// MIXIN DEPENDENCIES
				// If there are any mixin dependencies
				// If (StructKeyExists(variables.Config[arguments.ObjectName],"MixinDependencies"))
				If (StructCount(variables.Config[arguments.ObjectName].MixinDependencyStruct))
				{ 
					// Inject them all 
					For (Key in variables.Config[arguments.ObjectName].MixinDependencyStruct)
			   		{ 
						// Get current object name
						If (Key NEQ arguments.ObjectName)
						{
							arguments.object.lightwireMixin(Config[arguments.ObjectName].MixinDependencyStruct[Key], variables.getSingleton(Key));			
						};
					};
				};
				
				// MIXIN DEPENDENCIES (annotations)
				MixinInjectionList = arguments.object.lightwireGetAnnotations();
				For (Count = 1; Count lte listlen(MixinInjectionList); Count = Count + 1)
		   		{ 
					// Get current object name
					LoopObjectName = ListGetAt(MixinInjectionList, Count);
					arguments.object.lightwireMixin(LoopObjectName, getSingleton(LoopObjectName));
		   		};				
		
				// MIXIN PROPERTIES
				// If there are any mixin properties
				If (StructKeyExists(variables.Config[arguments.ObjectName],"MixinProperties"))
				{ 
		   			For (key in variables.Config[arguments.ObjectName].MixinProperties)
		   			{
						arguments.object.lightwireMixin(key, variables.Config[arguments.ObjectName].MixinProperties[key]);			
		   			};
				};
					
				// Always Mixin LightWire Factory
				arguments.object.lightwireMixin("LightWire", variables.singleton.LightWire);			
			}//end if mixin for cfc's only
			
			// Finally implement InitMethod if exists
			//LuisMajano, check if the initMethod property exists, else its a factoryBean.
			If ( structKeyExists(variables.config[arguments.objectName],"InitMethod") and Len(variables.Config[arguments.ObjectName].InitMethod) GT 0)
			{
				/* Invoke the INitMethod */
				invoker(arguments.object,variables.Config[arguments.ObjectName].InitMethod);
			};
			
			return arguments.object;
		</cfscript>
	</cffunction>
	
	<cffunction name="lightwireMixin" returntype="void" access="public" output="false" hint="I add the passed elements to the variables scope within this object. I am mixed in by LightWire to support mixin injection of dependencies and properties.">
		<!---************************************************************************************************ --->
		<cfargument name="ElementName" type="string" required="yes" hint="I am the name of the element to mix in.">
		<cfargument name="ElementValue" type="any" required="yes" hint="I am the value of the element to mix in.">
		<!---************************************************************************************************ --->
		<cfset variables[ElementName] = ElementValue>
	</cffunction>
	
	<cffunction name="lightwireGetAnnotations" returntype="string" access="public" output="false" hint="I return the comma delimited list of beans to mixin based on variables.MixinObjectNameList if it was set in the init().">
		<cfscript>
			var ReturnString = "";
			If(StructKeyExists(variables, "MixinObjectNameList"))
			{ReturnString = variables.MixinObjectNameList;};
		</cfscript>
		<cfreturn ReturnString>
	</cffunction>

<!------------------------------------------------- PRIVATE ---------------------------------------------------------->	
	
	<!--- Invoker Mixin --->
	<cffunction name="invoker" hint="calls private/packaged/public methods" access="private" returntype="any" output="false">
		<!--- ************************************************************* --->
		<cfargument name="object" 		 type="any" 	required="true"	 hint="The object to call a method on">
		<cfargument name="method" 		 type="string"  required="true"  hint="Name of the private method to call">
		<cfargument name="argCollection" type="struct"  required="false" hint="Can be called with an argument collection struct">
		<cfargument name="argList" 		 type="string"  required="false" hint="Can be called with an argument list, for simple values only: ex: 'plugin=logger,number=1'">
		<!--- ************************************************************* --->
		<cfset var results = "">
		<cfset var key = "">
		
		<!--- Determine type of invocation --->
		<cfif structKeyExists(arguments,"argCollection")>
			<cfinvoke component="#arguments.object#"
					  method="#arguments.method#" 
					  returnvariable="results" 
					  argumentcollection="#arguments.argCollection#" />
		<cfelseif structKeyExists(arguments, "argList")>
			<cfinvoke component="#arguments.object#"
					  method="#arguments.method#" 
					  returnvariable="results">
				<cfloop list="#argList#" index="key">
					<cfinvokeargument name="#listFirst(key,'=')#" value="#listLast(key,'=')#">
				</cfloop>
			</cfinvoke>
		<cfelse>
			<cfinvoke component="#arguments.object#"
					  method="#arguments.method#" 
					  returnvariable="results" />
		</cfif>
		
		<!--- Return results if Found --->
		<cfif isDefined("results")>
			<cfreturn results>
		</cfif>
	</cffunction>

	<!--- Dump it Facade --->
	<cffunction name="dumpit" access="private" hint="Facade for cfmx dump" returntype="void">
		<cfargument name="var" required="yes" type="any">
		<cfargument name="abort" type="boolean" required="false" default="false"/>
		<cfdump var="#var#"><cfif abort><cfabort></cfif>
	</cffunction>
	<!--- Abort Facade --->
	<cffunction name="abortit" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>

</cfcomponent>