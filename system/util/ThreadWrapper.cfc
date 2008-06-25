<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	10/31/2007
Description :
	A thread wrapping utility
----------------------------------------------------------------------->
<cfcomponent name="ThreadWrapper" output="false" hint="A thread wrapping utility">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<cfscript>
		instance = structnew();
	</cfscript>
	
	<cffunction name="init" access="public" returntype="ThreadWrapper" output="false" hint="Constructor">
		<!--- ************************************************************* --->
		<cfargument name="target" required="true" type="any" hint="The target to wrap in this thread wrapper">
		<!--- ************************************************************* --->
		<cfscript>
			/* Save Wrapper */
			setTarget(arguments.target);
			setThread(createObject("java", "java.lang.Thread"));
			/* return instance. */
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
		<cfset var ThreadName = "coldbox.util.ThreadWrapper_#replace(createUUID(),"-","","all")#">
		<cfset var ResponseToken = createUUID()>
		
		<!--- Validate if inside thread --->
		<cfif isInsideCFThread()>
			
			<!--- Invoke the method sync --->
			<cfinvoke component="#getTarget()#"
					  method="#attributes.method#"
					  argumentcollection="#attributes.args#" />
					  
		<cfelse>
		
			<!--- Thread it. --->
			<cfthread name="#ThreadName#" args="#arguments.argCollection#">
				
				<!--- Invoke the method async --->
				<cfinvoke component="#getTarget()#"
						  method="#attributes.method#"
						  argumentcollection="#attributes.args#" />
						  
			</cfthread>
		
		</cfif>
		
		<cfreturn ResponseToken>
	</cffunction>

	<!--- Get Set Target --->
	<cffunction name="gettarget" access="public" output="false" returntype="any" hint="Get target">
		<cfreturn instance.target/>
	</cffunction>
	<cffunction name="settarget" access="public" output="false" returntype="void" hint="Set target">
		<cfargument name="target" type="any" required="true"/>
		<cfset instance.target = arguments.target/>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- Check if inside cfthread --->
	<cffunction name="isInsideCFThread" access="private" returntype="boolean" hint="See if the running thread is inside a cfthread." output="false" >
		<cfscript>
			try{
				if ( findNoCase("cfthread", getThread().currentThread().getThreadGroup().getName() ) ){
					return true;
				}
				else{
					return false;
				}
			}
			catch(Any e){ 
				return true;
			}
		</cfscript>
	</cffunction>	
	
	<!--- Get/set thread object --->
	<cffunction name="getThread" access="private" returntype="any" output="false">
		<cfreturn instance.Thread />
	</cffunction>	
	<cffunction name="setThread" access="private" returntype="void" output="false">
		<cfargument name="Thread" type="any" required="true">
		<cfset instance.Thread = arguments.Thread />
	</cffunction>

</cfcomponent>