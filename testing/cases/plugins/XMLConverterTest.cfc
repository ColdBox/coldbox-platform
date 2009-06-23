<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Sana Ullah
Date        :	June 23, 2009
Description :
	XMLConverter
----------------------------------------------------------------------->
<cfcomponent name="XMLConverter" extends="coldbox.system.testing.BaseTestCase" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox/testharness");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		
		variables.q1 = queryNew('idt,fname,lname,phone,location');
		variables.ArData = Arraynew(1);
		variables.StData = StructNew();
		</cfscript>

		<cfloop from="1" to="10" index="i">
			<cfset queryAddRow(q1,1) />
			<cfset querySetCell(q1, 'idt', '#i#')>
			<cfset querySetCell(q1, 'fname', 'fname-q1-#chr(65 + i)#')>
			<cfset querySetCell(q1, 'lname', 'lname-q1-#chr(65 + i)#')>
			<cfset querySetCell(q1, 'phone', 'phone-q1-954-555-5555-#i#')>
			<cfset querySetCell(q1, 'location', 'location-q1-#chr(65 + i)#')>
			
			<cfset variables.ArData[i] = "fname-q1-#chr(65 + i)#" />
			
			<cfset variables.StData[i] = "fname-q1-#chr(65 + i)#" />
		</cfloop>
		
	</cffunction>
	
	<cffunction name="testA" access="public" returntype="void" output="false">
		<!--- Now test some events --->
		<cfscript>
			var plugin = getController().getPlugin("XMLConverter");
			
			assertTrue( IsObject(plugin), "XMLConverter plugin is not a object");
		</cfscript>
	</cffunction>	
	
	<cffunction name="testArray" access="public" returntype="void" output="false">
		<!--- Now test some data to convert into XML format --->
		<cfset var plugin = getController().getPlugin("XMLConverter") />

		<cfset assertTrue(IsXML(plugin.toXML(data=variables.ArData,addHeader=true)),'Returned values is not valid XML') />
	</cffunction>
	
	<cffunction name="testStructure" access="public" returntype="void" output="false">
		<!--- Now test some data to convert into XML format --->
		<cfset var plugin = getController().getPlugin("XMLConverter") />

		<cfset assertTrue(IsXML(plugin.toXML(data=variables.StData,addHeader=true)),'Returned values is not valid XML') />
	</cffunction>
	
	<cffunction name="testQuery" access="public" returntype="void" output="false">
		<!--- Now test some data to convert into XML format --->
		<cfset var plugin = getController().getPlugin("XMLConverter") />

		<cfset assertTrue(IsXML(plugin.toXML(data=variables.q1,addHeader=true)),'Returned values is not valid XML') />
	</cffunction>
	
</cfcomponent>
