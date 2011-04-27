<cfcomponent>

	<cffunction name="init" access="public" returntype="AbstractProtocol" hint="Constructor called by a Concrete Protocol" output="false" >
		<cfargument name="properties" required="false" default="#structnew()#" hint="A map of configuration properties for the protocol" />
	
			<cfscript>			
			// Set internal properties	
			instance.properties = arguments.properties;
			
			// Return an inatcen of the protocol.
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="send" access="public" returntype="struct" hint="I send a payload via the cfmail protocol.">
		<cfargument name="Payload" required="true" type="coldbox.system.core.mail.mail" hint="I'm the payload to delivery" />

		<cfscript>
			// Throw an exception as the concrete protocol should have overwritten this method.
			throw(message="Your given mail protocol does not implement the 'send' method.", type="AbstractProtocol.Overwrite");
		</cfscript>
	</cffunction>

	<!------------------------------------------- PROPERTY METHODS ------------------------------------------->
	
	<!--- getter for the properties structure --->
	<cffunction name="getProperties" access="public" output="false" returntype="any" hint="Get properties structure map" colddoc:generic="struct">
		<cfreturn instance.properties/>
	</cffunction>
	
	<!--- setter for the properties structure --->
	<cffunction name="setProperties" access="public" output="false" returntype="void" hint="Set the entire properties structure map">
		<cfargument name="properties" required="true" colddoc:generic="struct"/>
		<cfset instance.properties = arguments.properties/>
	</cffunction>
	
	<!--- get a property --->
	<cffunction name="getProperty" access="public" returntype="any" hint="Get a property, throws exception if not found." output="false" >
		<cfargument name="property" required="true" hint="The key of the property to return.">
		<cfreturn instance.properties[arguments.property]>
	</cffunction>
	
	<!--- set a property --->
	<cffunction name="setProperty" access="public" returntype="void" hint="Set a property" output="false" >
		<cfargument name="property" required="true" hint="The property name to set.">
		<cfargument name="value" 	required="true" hint="The value of the property.">
		<cfset instance.properties[arguments.property] = arguments.value>
	</cffunction>
	
	<!--- check for a property --->
	<cffunction name="propertyExists" access="public" returntype="any" hint="Checks wether a given property exists or not." output="false" colddoc:generic="Boolean">
		<cfargument name="property" required="true" hint="The property name">
		<cfreturn structKeyExists(instance.properties,arguments.property)>		
	</cffunction>

</cfcomponent>