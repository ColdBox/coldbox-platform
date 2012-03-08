<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	may 7, 2009
Description :
	This is a concrete LightWire Adapter

----------------------------------------------------------------------->
<cfcomponent hint="The ColdBox LightWire IOC factory adapter"
			 extends="coldbox.system.ioc.AbstractIOCAdapter" 
			 output="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
	
	<!--- Constructor --->
	<cffunction name="init" access="public" returntype="LightWireAdapter" hint="Constructor" output="false" >
		<cfargument name="definitionFile" 	type="string" 	required="false" default="" hint="The definition file to load a factory with"/>
		<cfargument name="properties" 		type="struct" 	required="false" default="#structNew()#" hint="Properties to pass to the factory to create"/>
		<cfargument name="coldbox" 			type="any" 		required="false" default="" hint="A coldbox application that this instance of logbox can be linked to, not used if not using within a ColdBox Application."/>
		<cfscript>
			super.init(argumentCollection=arguments);
			
			instance.utility  = createObject("component","coldbox.system.core.util.Util");
			
			// LightWire Factory Path
			instance.LIGHTWIRE_FACTORY_PATH = "lightwire.LightWire";
			
			return this;
		</cfscript>
	</cffunction>

<!----------------------------------------- PUBLIC ------------------------------------->	

	<!--- createFactory --->
	<cffunction name="createFactory" access="public" returntype="void" hint="Create the LightWire Factory" output="false" >
		<cfscript>
			var properties = getProperties();
			
			//Create the lightwire Factory
			instance.factory = createObject("component", instance.LIGHTWIRE_FACTORY_PATH ).init( createLightwireConfigBean() );
			
		</cfscript>
	</cffunction>

	<!--- getBean --->
	<cffunction name="getBean" access="public" output="false" returntype="any" hint="Get a Bean from the object factory">
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">
		<cfscript>
			return getFactory().getBean(arguments.beanName);
		</cfscript>
	</cffunction>
	
	<!--- containsBean --->
	<cffunction name="containsBean" access="public" returntype="boolean" hint="Check if the bean factory contains a bean" output="false" >
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">	
		<cfscript>
			return getFactory().containsBean(arguments.beanName);
		</cfscript>
	</cffunction>
	
	<!--- setParentFactory --->
    <cffunction name="setParentFactory" output="false" access="public" returntype="void" hint="Set a parent factory on the adapted factory">
    	<cfargument name="parent" type="any" required="true" hint="The parent factory to add"/>
  		<cfset getFactory().setParentFactory( arguments.parent )>
    </cffunction>
	
	<!--- getParent --->
    <cffunction name="getParentFactory" output="false" access="public" returntype="any" hint="Get the parent factory">
    	<cfreturn getFactory().getParentFactory()>
    </cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	
	
	<!--- Create Lightwire Config Bean --->
	<cffunction name="createLightwireConfigBean" output="false" access="private" returntype="any" hint="Creates the lightwire config bean">
		<cfscript>
			var lightwireBeanConfig	= "";
			var isUsingXML 			= listLast(getDefinitionFile(),".") eq "xml" or listLast(getDefinitionFile(),".") eq "cfm";
			
			// Create the lightwire Config Bean.
			if( NOT isUsingXML ){
				// Create the declared config bean, but do not init it
				lightwireBeanConfig = createObject("component", getDefinitionFile());
			}
			else{
				// Create base config Bean
				lightwireBeanConfig = CreateObject("component", "lightwire.BaseConfigObject").init();	
			}
			
			// Are we using ColdBox Application Container? If so, then do mixins.
			if( isObject(getColdBox()) ){
				lightWireBeanConfig.injectMixin = instance.utility.getMixerUtil().injectMixin;
				lightWireBeanConfig.injectMixin( "getController", variables.getController );
				lightwireBeanConfig.controller = getColdBox();
			} 
			
			// Do we need to configure
			if( isUsingXML ){
				// Read in and parse the XML
				lightwireBeanConfig.parseXMLConfigFile( getDefinitionFile(), getProperties());
				return lightwireBeanConfig;
			}
			else{
				return lightwireBeanConfig.init();
			}					
		</cfscript>
	</cffunction>
	
	<!--- Controller Accessor/Mutators --->
	<cffunction name="getController" access="private" output="false" returntype="any" hint="Get controller: coldbox.system.web.Controller">
		<cfreturn this.controller/>
	</cffunction>
	
</cfcomponent>