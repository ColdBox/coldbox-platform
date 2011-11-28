<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************
LICENSE 
Copyright 2006 Raymond Camden

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   
If you find this app worthy, I have a Amazon wish list set up (www.amazon.com/o/registry/2TCL1D08EZEYE ). Gifts are always welcome. ;)

Modifications
	Luis Majano
	- Adaptation to using a more advanced algortithm on type detections
	- Ability to nest complex variables and still convert to XML.
	
--->
<cfcomponent hint="A utility tool that can marshall data to XML"
			 extends="coldbox.system.core.conversion.XMLConverter"
			 output="false"
			 cache="true">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------>

	<cffunction name="init" access="public" returntype="XMLConverter" output="false">
		<cfscript>
			super.init();
			
			// Plugin Properties thanks to ColdBox 3.0.0 zero inheritance
			setpluginName("XMLConverter");
			setpluginVersion("1.0");
			setpluginDescription("A utility to marshall data to XML");
			setPluginAuthor("Luis Majano & Sana Ullah");
			setPluginAuthorURL("http://www.coldbox.org");
			
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>
	

</cfcomponent>