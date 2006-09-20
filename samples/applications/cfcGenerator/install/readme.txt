Instructions:

Requirements:
* Mach-II 1.1 available at http://www.mach-ii.com/
* ColdFusion MX 7 - database introspection uses the admin API introduced in v7. It can be relatively easily converted to use the undocumented serviceFactory (which it used to use but I didn't want a project based upon undocumented features)
* Currently supports MySQL 5 (probably 4.1 but it has not been tested yet) and MSSQL 2000 (again probably 2005 but not tested)

Installation:
1) Copy the folders into a directory within your web root (location shouldn't matter)
2) Set your administrator password inside the /config/mach-ii.xml file
3) That's it.

The code is generated for you to copy and paste and do with what you will. The components will run fine as is, but this is intended as a starting point for you to customize, not an end point.

The code is generated off a set of stylesheets located in the /xsl/ folder. This is configured using the yac.xml file in the /xsl/ folder (yet another config). You can list the items you wish to generate off the stylesheet - each child of the root (i.e. <bean>) should have a base stylesheet (i.e. bean.xsl). The internal functions of most of these stylesheets have been seperated out to make them easier to tweak and customize to suit your needs - the includes are defined by the <include> children of the xml node and should be located in a folder of the same name (i.e. <bean> functions should be in the /xsl/bean/ folder). The xsl of each function will be added in the order you specify in the yac.xml. You determine where the function will be placed in your base stylesheet by the location of a comment reading "<!-- custom code -->" (see the current files if this isn't clear). Feel free to add your own generated files, you aren't limited to only the items that I created.

You can override the stylesheets used by a specific DSN. The custom stylesheets should be placed in a subfolder of /xsl/projects/ with the same name as your ColdFusion DSN. You will find a copy of the core files in there under the prototype folder that you can copy or rename. By default, if a folder exists for a given DSN, the system will generate off those. You will need a seperate yac.xml file for each custom project.

Special thanks to Beth Bowden for contributing Oracle support.

If you need assistance or would like to contribute to this project, email brian.rinaldi@gmail.com