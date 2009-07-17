<!--- 
LICENSE 
Copyright 2007 Brian Kotek

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--->

<cfcomponent output="false">
	
	<cfset variables.instance.createdMocks = StructNew() />
	
	<cffunction name="init">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="coldMock_debug" hint="Returns the variables scope of the Mocked object, for debugging help.">
		<cfreturn variables />
	</cffunction>
	
	<cffunction name="methodCallCount" hint="I return the number of times the specified mock method has been called.">
		<cfargument name="methodName" type="string" hint="Name of the method" />
		<cfif StructKeyExists(variables.methodCalls, arguments.methodName)>
			<cfif not StructKeyExists(variables.methodCalls[arguments.methodName], 'callCounter')>
				<cfreturn 0 />
			<cfelse>
				<cfreturn variables.methodCalls[arguments.methodName].callCounter - 1 />
			</cfif>
		<cfelse>
			<cfthrow type="mock.invalidMethodName" message="The specified method #arguments.methodName# has not been mocked." />			
		</cfif>
	</cffunction>
	
	<cffunction name="createMock">
		<cfargument name="objectToMock" type="string" hint="CFC to mock (typically uses CFC dot path such as 'site.components.Product')" />
		<cfset var mock = "" />
		<cfset var targetMetaData = "" />
		
		<!--- Try to create the target CFC. --->
		<cftry>
			<cfset mock = CreateObject('component', arguments.objectToMock) />
			<cfcatch type="any">
				<cfthrow type="mock.invalidCFC" message="The specified CFC #arguments.objectToMock# could not be created. Verify the CFC name and path being specified." />			
			</cfcatch>
		</cftry>
		
		<!--- Copy the metadata of the original CFC. --->
		<cfset targetMetaData = getMetaData(mock) />
		
		<!--- Purge all methods and dynamically attach methods for performing mock duties. --->
		<cfset StructClear(mock) />
		<cfset mock.methodCallCount = methodCallCount />
		<cfset mock.coldMock_debug = coldMock_debug />
		<cfset mock.coldMock_setMetaData = coldMock_setMetaData />
		<cfset mock.coldMock_findTargetMethod = coldMock_findTargetMethod />
		<cfset mock.mockMethod= mockMethod />
		<cfset mock.returns = returns />
		<cfset mock.onMissingMethod = onMissingMethod />
		<cfset mock.coldMock_setDefaults = coldMock_setDefaults />
		<cfset mock.coldMock_setDefaults() />
		<cfset mock.coldMock_setMetaData(targetMetaData) />
		
		<!--- Store a reference to the mock object in case external code needs a reference to a mock after creation. --->
		<cfset variables.instance.createdMocks[arguments.objectToMock] = mock />
		
		<cfreturn mock />
	</cffunction>
	
	<cffunction name="coldMock_setMetaData">
		<cfargument name="metaData" type="struct" required="true" />
		<cfset variables.metadata = arguments.metaData />
	</cffunction>
	
	<cffunction name="coldMock_setDefaults">
		<cfset variables.currentMethodName = "undefined" />
		<cfset variables.methodCalls = StructNew() />
		<cfset variables.methodCalls[variables.currentMethodName] = StructNew() />
	</cffunction>
	
	<cffunction name="coldMock_findTargetMethod">
		<cfargument name="metaData" />
		<cfargument name="missingMethodName" />
		<cfset var local = StructNew() />
		
		<cfset local.matchedMethod = false />
		<cfset local.targetMethod = StructNew() />
		
		<!--- Try to match the method against the metadata. --->
		<cfif StructKeyExists(arguments.metadata, 'functions')>	
			<cfloop from="1" to="#ArrayLen(arguments.metaData.functions)#" index="local.thisFunction">
				<cfif arguments.metaData.functions[local.thisFunction].name eq arguments.missingMethodName>
					<cfset local.targetMethod = arguments.metaData.functions[local.thisFunction] />
					<cfset local.matchedMethod = true />
					<cfbreak />
				</cfif>
			</cfloop>
		</cfif>
		
		<!--- If no match was found, try to check superclasses for the method. --->
		<cfif not local.matchedMethod and StructKeyExists(arguments.metaData, 'extends')>
			<cfset local.targetMethod = this.coldMock_findTargetMethod(arguments.metaData.extends, arguments.missingMethodName) />
		</cfif>
		
		<cfreturn local.targetMethod />
	</cffunction>
	
	<!--- Public API methods to be attached to the Mock objects for use in testing. --->
	<cffunction name="getMock" hint="Can be used to obtain a reference to a mock object that was already created.">
		<cfargument name="mockObject" type="string" hint="Name of the mock CFC to return. Can specify the full CFC dot path such as 'site.components.Product', or just the CFC name such as 'Product'." />
		<cfset var thisMock = "" />
		<cfif StructKeyExists(variables.instance.createdMocks, arguments.mockObject)>
			<cfreturn variables.instance.createdMocks[arguments.mockObject] />
		<cfelse>
			<cfloop collection="#variables.instance.createdMocks#" item="thisMock">
				<cfif ListLast(thisMock, '.') eq arguments.mockObject>
					<cfreturn variables.instance.createdMocks[thisMock] />
					<cfbreak />
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>
	
	<cffunction name="mockMethod" hint="Sets up a mock method.">
		<cfargument name="methodName" type="string" />
		<cfargument name="isVirtualMethod" type="boolean" required="false" default="false" />
		<cfset variables.methodCalls[methodName] = StructNew() />
		<cfset variables.methodCalls[methodName].isVirtualMethod = arguments.isVirtualMethod />
		<cfset variables.methodCalls[methodName].callCounter = 1 />
		<cfset variables.currentMethodName = methodName />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="returns" hint="Defines the return value for a mock method.">
		<cfset variables.methodCalls[variables.currentMethodName].returnValues = arguments />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="onMissingMethod">
		<!--- 
		Please note that under normal conditions I would not write a giant procedural method like this. 
		However, since all the methods have to be attached to the target CFC at runtime, splitting it up
		into a dozen or more small methods and then attaching all of them to every mock object is impractical. 
		--->
		
		<cfset var local = StructNew() />
		<cfset local.targetMethod = arguments.missingMethodName />
		<cfset local.thisCFCName = variables.metaData.name />
		
		<!--- Handle mocked "virtual methods", which are methods that are not in the component metadata because they were injected dynamically. --->
		<cfif StructKeyExists(variables.methodCalls, local.targetMethod) and variables.methodCalls[local.targetMethod].isVirtualMethod>
			
			<!--- Declare the method call counter for this method if it hasn't been defined. 
			<cfparam name="variables.methodCalls[local.targetMethod].callCounter" default="1" />
			--->
			
			<!--- Check to make sure the proper number of return values have been defined for the method. --->
			<cfif ArrayLen(variables.methodCalls[local.targetMethod].returnValues) gte variables.methodCalls[local.targetMethod].callCounter>
				<cfset local.result = variables.methodCalls[local.targetMethod].returnValues[variables.methodCalls[local.targetMethod].callCounter] />
			<cfelse>
				<cfthrow type="mock.invalidNumberOfMethodCalls" message="You tried to call method #arguments.missingMethodName# in component #local.thisCFCName# #variables.methodCalls[local.targetMethod].callCounter# time(s), but you only defined #ArrayLen(variables.methodCalls[local.targetMethod].returnValues)# return value(s) for the mocked method." />
			</cfif>
			
			<!--- Increment the call counter for this method and return defined data. --->
			<cfset variables.methodCalls[local.targetMethod].callCounter = variables.methodCalls[local.targetMethod].callCounter + 1 />
			<cfreturn local.result />
			
		<cfelse>
		
			<!--- Start by assuming no matched method. --->
			<cfset local.matchedMethod = false />
			
			<cfset local.currentFunction = this.coldMock_findTargetMethod(variables.metaData, local.targetMethod) />
			<cfif StructKeyExists(local.currentFunction, 'name')>
				<cfset local.matchedMethod = true />
			<cfelse>	
				<cfthrow type="mock.invalidMethod" message="The method named #arguments.missingMethodName# does not exist in component #local.thisCFCName#." />
			</cfif>
			
			<!--- If the metadata doesn't specify a void return type and there is no mock method set up with return values, throw an exception. --->
			<cfif (StructKeyExists(local.currentFunction, 'returnType') 
				and local.currentFunction.returnType neq 'void') 
				and variables.currentMethodName neq 'undefined'
				and not StructKeyExists(variables.methodCalls, arguments.missingMethodName)>
				<cfthrow type="mock.invalidMethod" message="A mock method named #arguments.missingMethodName# has not had return values declared for component #local.thisCFCName#." />
			</cfif>
			
			<!--- Determine if the call uses named arguments or positional arguments. --->
			<cfset local.namedArguments = true />
			<cfif StructCount(arguments.missingMethodArguments) gt 0 and StructKeyExists(arguments.missingMethodArguments, '1')>
				<cfset local.namedArguments = false />
			</cfif>
			
			<cfif not local.matchedMethod>
				<cfthrow type="mock.invalidMethod" message="The method #arguments.missingMethodName# in component #local.thisCFCName# does not exist." />
			<cfelse>
			
				<!--- Loop over the defined arguments in the metadata. --->
				<cfloop from="1" to="#ArrayLen(local.currentFunction.parameters)#" index="local.thisArg">
						<cfif local.namedArguments>
							<cfset local.tempKey = local.currentFunction.parameters[local.thisArg].name />
						<cfelse>
							<cfset local.tempKey = local.thisArg />
						</cfif>
						
						<!--- If the metadata defines the argument as required and has a type, validate the type of the incoming argument. --->
						<cfif StructKeyExists(arguments.missingMethodArguments, local.tempKey) 
								and StructKeyExists(local.currentFunction.parameters[local.thisArg], 'type') 
								and StructKeyExists(local.currentFunction.parameters[local.thisArg], 'required')
								and local.currentFunction.parameters[local.thisArg].required>
							<cfif IsObject(arguments.missingMethodArguments[local.tempKey]) and local.currentFunction.parameters[local.thisArg].type neq "any"
								and not IsInstanceOf(arguments.missingMethodArguments[local.tempKey], local.currentFunction.parameters[local.thisArg].type)>
								<cfthrow type="mock.invalidType" message="Argument #local.currentFunction.parameters[local.thisArg].name# of method #arguments.missingMethodName# in component #local.thisCFCName# is not of type #local.currentFunction.parameters[local.thisArg].type#." />
							<cfelseif not IsObject(arguments.missingMethodArguments[local.tempKey])>
								<cftry>
									<cfif not IsValid(local.currentFunction.parameters[local.thisArg].type, arguments.missingMethodArguments[local.tempKey])>
										<cfthrow type="mock.invalidType" message="Argument #local.currentFunction.parameters[local.thisArg].name# of method #arguments.missingMethodName# in component #local.thisCFCName# is not of type #local.currentFunction.parameters[local.thisArg].type#." />
									</cfif>
									<cfcatch type="coldfusion.runtime.CFPage$IllegalParamTypeException">
										<cfthrow type="mock.invalidType" message="Argument #local.currentFunction.parameters[local.thisArg].name# of method #arguments.missingMethodName# in component #local.thisCFCName# is not of type #local.currentFunction.parameters[local.thisArg].type#." />					
									</cfcatch>
								</cftry>
							</cfif>
						
						<!--- Otherwise, if the argument is required but not passed in, throw an exception. --->	
						<cfelseif StructKeyExists(local.currentFunction.parameters[local.thisArg], 'required') 
								and local.currentFunction.parameters[local.thisArg].required 
								and not StructKeyExists(arguments.missingMethodArguments, local.tempKey)>
							<cfthrow type="mock.missingArgument" message="Required argument #local.currentFunction.parameters[local.thisArg].name# of method #arguments.missingMethodName# in component #local.thisCFCName# does not exist.">	
						</cfif>
					</cfloop>	
			</cfif>
			
			<!--- If the function has been mocked and there are return values defined, get the mock result. --->
			<cfif StructKeyExists(variables.methodCalls, local.targetMethod) and StructKeyExists(variables.methodCalls[local.targetMethod], 'returnValues')>
				
				<cfif variables.currentMethodName eq 'undefined'>
					<cfset local.targetMethod = 'undefined' />
				</cfif>
				
				<!--- Declare the method call counter for this method if it hasn't been defined. 
				<cfparam name="variables.methodCalls[local.targetMethod].callCounter" default="1" />
				--->
				
				<!--- Check to make sure the proper number of return values have been defined for the method. --->
				<cfif ArrayLen(variables.methodCalls[local.targetMethod].returnValues) gte variables.methodCalls[local.targetMethod].callCounter>
					<cfset local.result = variables.methodCalls[local.targetMethod].returnValues[variables.methodCalls[local.targetMethod].callCounter] />
				<cfelse>
					<cfthrow type="mock.invalidNumberOfMethodCalls" message="You tried to call method #arguments.missingMethodName# in component #local.thisCFCName# #variables.methodCalls[local.targetMethod].callCounter# time(s), but you only defined #ArrayLen(variables.methodCalls[local.targetMethod].returnValues)# return value(s) for the mocked method." />
				</cfif>
				
				<!--- Check that a result was found for this method call. --->
				<cfif not StructKeyExists(local, 'result')>
					<cfthrow type="mock.noReturnValueDefined" message="You tried to call method #arguments.missingMethodName# in component #local.thisCFCName#, but a return value could not be found for the mocked method." />
				</cfif>
				
				<!--- If a return type was specified, and the return type not void, and there are return values defined, get the mock result and validate the type. --->			
				<cfif (StructKeyExists(local.currentFunction, 'returnType') and local.currentFunction.returnType neq 'void') 
					  and (variables.currentMethodName eq 'undefined' or (StructKeyExists(variables.methodCalls, local.targetMethod) and StructKeyExists(variables.methodCalls[local.targetMethod], 'returnValues')))>
					
					<cfif IsObject(local.result) and local.currentFunction.returntype neq "any" and not IsInstanceOf(local.result, local.currentFunction.returntype)>
						<cfthrow type="mock.invalidType" message="The return value of method #arguments.missingMethodName# in component #local.thisCFCName# is not of type #local.currentFunction.returntype#." />
					<cfelseif not IsObject(local.result)>
						<cftry>
							<!--- If return type is array of components, check the type of the components in the array. --->
							<cfif Right(local.currentFunction.returntype,2) eq '[]'>
							        <cfset local.cfcTypeToCheck = Left(local.currentFunction.returntype,len(local.currentFunction.returntype )-2)>
							        <cfloop from="1" to="#Arraylen(local.result)#" index="local.tempTypedArray">
							            <cfif not (IsValid( 'component', local.result[local.tempTypedArray]) and GetMetaData(local.result[local.tempTypedArray]).name eq local.cfcTypeToCheck )>
							                <cfthrow type="mock.invalidType" message="Element in position #local.tempTypedArray# of the return value of method #arguments.missingMethodName# in component #local.thisCFCName# is not of type #local.cfcTypeToCheck#." />
							            </cfif>
							        </cfloop>
							        
							<!--- Otherwise, validate the single return value. --->        
							<cfelse>
							    <cfif not IsValid(local.currentFunction.returntype, local.result)>
							        <cfthrow type="mock.invalidType" message="The return value of method #arguments.missingMethodName# in component #local.thisCFCName# is not of type #local.currentFunction.returntype#." />
							    </cfif>
							</cfif>
							<cfcatch type="coldfusion.runtime.CFPage$IllegalParamTypeException">
							    <cfthrow type="mock.invalidType" message="The return value of method #arguments.missingMethodName# in component #local.thisCFCName# is not of type #local.currentFunction.returntype#." />
							</cfcatch>
						</cftry>
					</cfif>
					
				</cfif>
				
				<!--- Increment the call counter for this method and return defined data. --->
				<cfset variables.methodCalls[local.targetMethod].callCounter = variables.methodCalls[local.targetMethod].callCounter + 1 />
				<cfreturn local.result />
			
			<!--- If the return type is void, create an entry in the methodCalls struct if necessary and update the method call counter. --->
			<cfelseif StructKeyExists(local.currentFunction, 'returnType') and local.currentFunction.returnType eq 'void'>
				
				<cfif not StructKeyExists(variables.methodCalls, local.targetMethod)>
					<cfset this.mockMethod(local.targetMethod) />
				</cfif>
							
				<!--- Increment the call counter for this method and return defined data. --->
				<cfset variables.methodCalls[local.targetMethod].callCounter = variables.methodCalls[local.targetMethod].callCounter + 1 />
				
			</cfif>
		</cfif>	 
		
	</cffunction>
	
</cfcomponent>