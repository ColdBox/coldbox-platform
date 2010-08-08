<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/31/2007
Description :
	A thread wrapping utility
----------------------------------------------------------------------->
<cfcomponent output="false" hint="A thread wrapping utility">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		instance = structnew();
	</cfscript>
	
	<cffunction name="init" access="public" returntype="ThreadWrapper" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="target" required="true" type="any" hint="The target to wrap in this thread wrapper">
		<!--- ************************************************************* --->
		<cfscript>
			// Save Wrapper
			setTarget(arguments.target);
			setThread(createObject("java", "java.lang.Thread"));
			
			//uuid
			instance.uuid = createobject("java", "java.util.UUID");
			//util
			instance.util = createObject("component","coldbox.system.core.util.Util");
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- Invoker --->
	<cffunction name="invoker" hint="Executes a method on the target asynchronously" access="public" returntype="string" output="false">
		<!--- ************************************************************* --->
		<cfargument name="method" 		 type="string"  required="Yes" hint="Name of the method to invoke">
		<cfargument name="argCollection" type="struct"  required="No"  default="#structnew()#"  hint="Called with an argument collection struct">
		<!--- ************************************************************* --->
		<cfset var threadName = "ThreadWrapper_#replace(instance.uuid.randomUUID(),"-","","all")#">
		<cfset var responseToken = instance.uuid.randomUUID()>
		
		<!--- Passthrough responseToken --->
		<cfset arguments.argCollection.$responseToken = responseToken>
		
		<!--- Validate if inside thread --->
		<cfif instance.util.inThread()>
			
			<!--- Invoke the method sync --->
			<cfinvoke component="#getTarget()#"
					  method="#attributes.method#"
					  argumentcollection="#attributes.args#" />
					  
		<cfelse>
		
			<!--- Thread it. --->
			<cfthread name="#threadName#" args="#arguments.argCollection#">
				
				<!--- Invoke the method async --->
				<cfinvoke component="#getTarget()#"
						  method="#attributes.method#"
						  argumentcollection="#attributes.args#" />
						  
			</cfthread>
		
		</cfif>
		
		<cfreturn ResponseToken>
	</cffunction>

	<!--- Get Set Target --->
	<cffunction name="getTarget" access="public" output="false" returntype="any" hint="Get target object">
		<cfreturn instance.target/>
	</cffunction>
	<cffunction name="setTarget" access="public" output="false" returntype="void" hint="Set target object">
		<cfargument name="target" type="any" required="true"/>
		<cfset instance.target = arguments.target/>
	</cffunction>
	
	<!--- onMissingMethod --->
    <cffunction name="onMissingMethod" output="false" access="public" returntype="any" hint="">
    	<cfargument	name="missingMethodName"		type="string" required="true"	hint=""	/>
		<cfargument	name="missingMethodArguments" 	type="struct" required="true"	hint=""/>
    	<cfscript>
    		return invoker(arguments.missingMethodName,missingMethodArguments);
    	</cfscript>
    </cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
</cfcomponent>