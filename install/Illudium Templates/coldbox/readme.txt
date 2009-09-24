********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************
ILLIDIUM COLDBOX SCAFFOLDING TEMPLATE
********************************************************************************
These templates will help you scaffold a ColdBox application with the use of 
Brian Rinaldi's Illidium Generator.  Please note the following:

UNIT TESTS:
- The generator will create the unit tests for the handlers for you. However,
  you MUST supply the application's mapping in the generated SETUP methods.

  
COLDSPRING:
- Once the coldspring.xml is generated, you will have to replace the 
  "YOUR_ALIAS_HERE" with the alias of your datasource as you define it in 
  the config.xml.cfm.
  
  <Datasource alias="MyDSNAlias" name="real_dsn_name" dbtype="mysql" username="" password="" />


DAO SAVE METHOD:
The save method is pre-configured to create a UUID for the primary key. If you do
not want this to happen (You might have another pk method or an incremental sequence,
or autonumber) then please comment the following line in your generated DAO or
Template:

<!--- Comment the following if you would NOT like to generate UUID's --->
<cfset arguments.#root.bean.xmlAttributes.name#.set#primaryKey#(createUUID())>

  
STYLE.CSS:
You will need to add the style declaration to the layout if you want to use
the pre-set stylesheet. If not, just use your own.