<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author 	    :	Luis Majano
Date        :	may 7, 2009
Description :
	This is a concrete ColdSpring Adapter


----------------------------------------------------------------------->
<cfcomponent name="ColdSpringAdapter" 
			 hint="The ColdBox ColdSpring IOC factory adapter" 
			 output="false">

<!----------------------------------------- CONSTRUCTOR ------------------------------------->			
	
	<cffunction name="init" access="public" returntype="ColdSpringAdapter" hint="Constructor" output="false" >
		<cfargument name="controller"  type="coldbox.system.web.Controller" required="true" hint="The ColdBox controller">
		<cfargument name="IOCPlugin"   type="coldbox.system.plugins.IOC" required="true" hint="The IOC plugin object">
		<cfscript>
		super.init(argumentCollection=arguments);
		
		/* Setup properties */
		instance.coldspringPath = getIOCPlugin().getCOLDSPRING_FACTORY();
		instance.expandedDefinitionFile = getIOCPlugin().getExpandedIOCDefinitionFile();
		
		
		return this;
		</cfscript>
	</cffunction>


<!----------------------------------------- PUBLIC ------------------------------------->	

	<cffunction name="createFactory" access="public" returntype="void" hint="Create the ColdSpring Factory" output="false" >
		<cfscript>
			var settingsStruct = StructNew();
			var ConfigContents = 0;
			var oUtil = getController().getPlugin("Utilities");
			
			//Copy the settings Structure
			structAppend(settingsStruct, getController().getSettingStructure());
			
			//Create the Coldspring Factory
			instance.beanFactory = createObject("component",instance.coldspringPath).init(structnew(),settingsStruct);
			
			/* Read the XML File and do string replacement First */
			ConfigContents = oUtil.readFile(instance.expandedDefinitionFile);
			ConfigContents = oUtil.placeHolderReplacer(ConfigContents,settingsStruct);	
			
			/* Load Bean Definitions */
			instance.beanFactory.loadBeansFromXmlRaw( ConfigContents );
		</cfscript>
	</cffunction>

	<cffunction name="getbeanFactory" access="public" output="false" returntype="any" hint="Get the bean factory">
		<cfreturn instance.beanFactory/>
	</cffunction>
	
	<cffunction name="getBean" access="public" output="false" returntype="any" hint="Get a Bean from the object factory">
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">
		<cfscript>
			return getBeanFactory().getBean(arguments.beanName);
		</cfscript>
	</cffunction>
		
	<cffunction name="containsBean" access="public" returntype="boolean" hint="Check if the bean factory contains a bean" output="false" >
		<cfargument name="beanName" type="string" required="true" hint="The bean name to retrieve from the object factory">	
		<cfscript>
			return getBeanFactory().containsBean(arguments.beanName);
		</cfscript>
	</cffunction>

<!----------------------------------------- PRIVATE ------------------------------------->	

	
	
</cfcomponent>