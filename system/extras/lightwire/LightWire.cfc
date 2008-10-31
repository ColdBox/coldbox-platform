<cfcomponent name="LightWire" hint="I am the LightWire factory that creates all singleton and transient objects, injecting them with all of their necessary dependencies as defined in the configuration file." output="false">
	
<!------------------------------------------------- CONSTRUCTOR ---------------------------------------------------------->	

	<!--- Init --->
	<cffunction name="init" returntype="LightWire" access="public" output="false" hint="I initialize the LightWire object factory.">
		<!---************************************************************************************************ --->
		<cfargument name="ConfigBean" 		type="any" required="true" 	hint="I am the initialized config bean.">
		<cfargument name="parentFactory" 	type="any" required="false" hint="The lightwire parent factory to associate this factory with">
		<!---************************************************************************************************ --->
		<cfscript>
			var key = "";
			var beanStruct = structnew();
			
			/* Factory ID */
			variables.factoryID = hash(createUUID());
			/* Singleton Cache */
			variables.singleton = StructNew();
			/* Setup yourself as a singleton */
			variables.singleton.lightWire = this;
			/* Config Structure */
			variables.config = ConfigBean.getConfigStruct();
			/* Alias Mappings */
			variables.aliasMap = structnew();
			
			/* Check Parent Factory */
			if( structKeyExists(arguments,"parentFactory") ){
				/* Hierarchy Factory */
				variables.parentFactory = arguments.parentFactory;
			}
			else{
				/* Hierarchy Factory */
				variables.parentFactory = structnew();
			}
				
			/* Are we lazy loading? */
			if (NOT ConfigBean.getLazyLoad()){
	   			beanStruct = variables.config;
	   		}
	   		else{
	   			/* We are not lazy Loading, just get the non-lazy beans then */
	   			beanStruct = ConfigBean.getnonLazyBeans();
	   		}	   		
	   		
	   		/* Create The appropriate Beans: either non lazy beans or all singletons according to lazy property */
	   		for(key in beanStruct){
   				/* Create every singleton */
	   			if (variables.Config[key].Singleton){
	   				/* Verify they are not in the singleton cache */
					if(not StructKeyExists(variables.Singleton,key)){
						/* Only create if hasn't already been created as dependency of earlier singleton */
						variables.Singleton[key] = getObject(key,"Singleton");
					}
	   			}
   			}
   			
	   		/* Return instance */
	   		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------------- PUBLIC ---------------------------------------------------------->	
	
	<!--- Get Set a parent lightwire factory --->
	<cffunction name="getparentFactory" access="public" returntype="any" output="false" hint="Get the parent factory for hierarchy operations. If the parent factory is not set, this method returns an empty structure.">
		<cfreturn variables.parentFactory>
	</cffunction>
	<cffunction name="setparentFactory" access="public" returntype="void" output="false" hint="Set in a parent factory to use for hierarchy operations">
		<cfargument name="parentFactory" type="any" required="true" hint="The lightwire parent factory">
		<cfset variables.parentFactory = arguments.parentFactory>
	</cffunction>

	<!--- Get a Bean --->
	<cffunction name="getBean" returntype="any" access="public" output="false" hint="I return a bean with all of its dependencies loaded from the factory hierarchy.">
		<!---************************************************************************************************ --->
		<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to generate.">
		<!---************************************************************************************************ --->
		<cfscript>
			var ReturnObject = 0;
			var Parent = getParentFactory();
			
			/* Verify Bean exists in hierarchy */
			verifyBean(arguments.objectName);
			
			/* If we pass to this line, then the bean is guaranteed to be in the hiearchy */
			
			/* Which Factory will we use? */
			if( localFactoryContainsBean(arguments.objectName) ){
				/* Singleton or Transient? */
				if(variables.config[arguments.ObjectName].Singleton){	
					ReturnObject = getSingleton(arguments.ObjectName); 
				}
				else{ 
					ReturnObject = getTransient(arguments.ObjectName); 
				}
			}
			/* Else return it from the parent hierarchy */
			else if( isObject(Parent) ){
				ReturnObject = Parent.getBean(arguments.objectName);
			}						
			
			/* Return object */
			return returnObject;
		</cfscript>	
	</cffunction>
	
	<!--- Get a Singleton --->
	<cffunction name="getSingleton" returntype="any" access="public" output="false" hint="I return a LightWire scoped Singleton with all of its dependencies loaded from the local factory only.">
		<!---************************************************************************************************ --->
		<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to generate.">
		<!---************************************************************************************************ --->
		<!--- VerifyBean --->
		<cfset verifyBean(arguments.objectname)>
		<!--- If the object doesn't exist, lazy load it  --->
		<cfif not StructKeyExists(variables.Singleton, arguments.ObjectName)>
			<cflock name="#ObjectName#Loading" timeout="5" throwontimeout="true">
				<cfif not StructKeyExists(variables.Singleton, arguments.ObjectName)>
					<cfset variables.Singleton[arguments.ObjectName] = getObject(arguments.ObjectName,"Singleton")>
				</cfif>
			</cflock>
		</cfif>
		<cfreturn variables.Singleton[arguments.ObjectName] />	
	</cffunction>
	
	<!--- Get a Transient --->
	<cffunction name="getTransient" returntype="any" access="public" output="false" hint="I return a transient object from the local factory only.">
		<!---************************************************************************************************ --->
		<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to create." />	
		<!---************************************************************************************************ --->
		<!--- VerifyBean --->
		<cfset verifyBean(arguments.objectname)>
		<!--- Return Object --->
		<cfreturn getObject(arguments.ObjectName,"Transient") />
	</cffunction>
	
	<!--- Altered by Luis Majano for autowiring purposes. --->
	<cffunction name="containsBean" access="public" output="false" returntype="boolean" hint="returns true if the BeanFactory and its hierarchy contains a bean definition that matches the given name">
		<!---************************************************************************************************ --->
		<cfargument name="beanName" required="true" type="string" hint="name of the bean to look for"/>
		<!---************************************************************************************************ --->
		<cfscript>
			var parent = getparentFactory();
			/* Verify locally first */
			if( localFactoryContainsBean(arguments.beanName) ){
				return true;
			}
			/* Verify in parent second */
			else if( isObject(parent) and parent.containsBean(arguments.beanName) ){
				return true;
			}
			else{
				return false;
			}
		</cfscript>
	</cffunction>
	
	<!--- Altered by Luis Majano for autowiring purposes. --->
	<cffunction name="localFactoryContainsBean" access="public" output="false" returntype="boolean" hint="returns true if the local BeanFactory contains a bean definition that matches the given name">
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
			var ObjectstoCreateList = getDependentObjectList(arguments.ObjectName);
			var LoopObjectName = "";
			var TemporaryObjects = StructNew();
			var Count = 1;		
			var ReturnObject = "";		
			var LoopObjectList = ObjectstoCreateList;		
			
			// Then create all of the dependent objects
			while (ListLen(LoopObjectList))
			{
				// Get the last object name
				LoopObjectName = ListLast(LoopObjectList);
				// Call createNewObject() to create and constructor initialize it
	   			variables.Singleton[LoopObjectName] = createNewObject(LoopObjectName,"Singleton");
	   			// Remove that object name from the list
				LoopObjectList = ListDeleteAt(LoopObjectList,ListLen(LoopObjectList));
			};
			// Then create the original object
			ReturnObject = createNewObject(arguments.ObjectName,arguments.ObjectType);
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
	   			variables.Singleton[LoopObjectName] = setterandMixinInject(LoopObjectName,variables.Singleton[LoopObjectName]);
	   			// Remove that object name from the list
				LoopObjectList = ListDeleteAt(LoopObjectList,ListLen(LoopObjectList));
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
							};//end for
						};//end if structCOunt
					};//end if circular
				};//end if not a singleton
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

	<!--- VerifyBean --->
	<cffunction name="verifyBean" output="false" access="private" returntype="void" hint="Verify a bean definition exists in hierarchy, else throw error">
		<!--- ************************************************************* --->
		<cfargument name="ObjectName" type="string" required="yes" hint="I am the name of the object to generate.">
		<!--- ************************************************************* --->
		<cfscript>
			/* Verify Bean is defined */
			if( not containsBean(arguments.ObjectName) ){
				throwit("Bean definition not found","The bean #arguments.objectName# has not bean defined","Lightwire.BeanNotFoundException");
			}
		</cfscript>
	</cffunction>
	
	<!--- Dump it Facade --->
	<cffunction name="dumpit" access="private" hint="Facade for cfmx dump" returntype="void">
		<!--- ************************************************************* --->
		<cfargument name="var" required="yes" type="any">
		<cfargument name="abort" type="boolean" required="false" default="false"/>
		<!--- ************************************************************* --->
		<cfdump var="#var#"><cfif abort><cfabort></cfif>
	</cffunction>
	<!--- Abort Facade --->
	<cffunction name="abortit" access="private" hint="Facade for cfabort" returntype="void" output="false">
		<cfabort>
	</cffunction>
	<!--- Throw Facade --->
	<cffunction name="throwit" access="private" hint="Facade for cfthrow" output="false">
		<!--- ************************************************************* --->
		<cfargument name="message" 	type="string" 	required="yes">
		<cfargument name="detail" 	type="string" 	required="no" default="">
		<cfargument name="type"  	type="string" 	required="no" default="Framework">
		<!--- ************************************************************* --->
		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">
	</cffunction>

</cfcomponent>