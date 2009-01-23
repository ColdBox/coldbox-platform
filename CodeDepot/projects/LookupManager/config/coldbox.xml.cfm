<!-- Please copy the following settings into your coldbox.xml.cfm
     and tweak the parameters as needed.
     The lookups_tables setting is a JSON structure of alias -> Transfer object mapping.
     
     'alias':'transferobject'
     
      -->
<YourSettings>
	<!-- Lookups Settings -->
	<Setting name="lookups_tables"				value="{'Permissions':'security.Permission', 
														'Roles':'security.Role', 
														'Security Rules':'security.SecurityRules',
														'System Options':'wiki.Option',
														'Wiki Namespaces':'wiki.Namespace',
														'Wiki Categories':'wiki.Category'}" />		
	<Setting name="lookups_imgPath"				value="includes/lookups/images" />
	<Setting name="lookups_cssPath"				value="includes/lookups/styles" />
	<Setting name="lookups_jsPath"				value="includes/lookups/js" />
	<!-- Leave empty if handlers and views not in a package -->
	<Setting name="lookups_packagePath"			value="" />
</YourSettings>