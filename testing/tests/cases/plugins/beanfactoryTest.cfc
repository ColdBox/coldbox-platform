<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	9/3/2007
Description :
	beanFactoryTest
----------------------------------------------------------------------->
<cfcomponent name="beanfactoryTest" extends="coldbox.system.extras.baseTest" output="false">

	<cffunction name="setUp" returntype="void" access="private" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testPlugin" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("beanFactory");
			
			assertComponent(plugin);			
		</cfscript>
	</cffunction>	
	
	<cffunction name="testCreate" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("beanFactory");
			var local = structnew();
			
			/* test create */
			local.obj = plugin.create('applications.coldbox.testing.testmodel.formBean');
			AssertComponent(local.obj,"Verify create");
			
			
			
		</cfscript>
	</cffunction>
	
	<cffunction name="testPopulations" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("beanFactory");
			var local = structnew();
			var event = getRequestContext();
			
			/* We are using the formBean object: fname,lname,email,initDate */
			local.obj = plugin.create('applications.coldbox.testing.testmodel.formBean');
			
			/* Struct */
			local.myStruct = structnew();
			local.myStruct.fname = "Luis";
			local.myStruct.lname = "Majano";
			local.myStruct.email = "lmajano@coldboxframework.com";
			local.myStruct.initDate = now();
			
			/* JSON Packet */
			local.myJSON = getController().getPlugin("json").encode(local.myStruct);
			
			/* Populate RC */
			for( local.key in local.myStruct ){
				event.setValue(local.key, local.myStruct[local.key]);
			}
			
			/* Populate From Struct */
			local.obj = plugin.populateFromStruct(local.obj,local.myStruct);
			local.objInstance = local.obj.getInstance();
			/* Assert Population */
			for( local.key in local.objInstance ){
				AssertEqualsString(local.objInstance[local.key], local.myStruct[local.key], "Asserting #local.key# From Struct" );
			}
			
			/* Populate From JSON */
			local.obj = plugin.populateFromJSON(local.obj,local.myJSON);
			local.objInstance = local.obj.getInstance();
			/* Assert Population */
			for( local.key in local.objInstance ){
				AssertEqualsString(local.objInstance[local.key], local.myStruct[local.key], "Asserting #local.key# From JSON" );
			}
			
			/* Populate From JSON */
			local.obj = plugin.populateBean(local.obj);
			local.objInstance = local.obj.getInstance();
			/* Assert Population */
			for( local.key in local.objInstance ){
				AssertEqualsString(local.objInstance[local.key], local.myStruct[local.key], "Asserting #local.key# From Request Collection" );
			}
			
		</cfscript>
	</cffunction>
	
</cfcomponent>