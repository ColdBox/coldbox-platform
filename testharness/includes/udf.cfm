<cfscript>
function titleCase(str) {
	return uCase(left(str,1)) & right(str,len(str)-1);
}


/**
 * Tests passed value to see if it is a valid e-mail address (supports subdomain nesting and new top-level domains).
 * Update by David Kearns to support '
 * SBrown@xacting.com pointing out regex still wasn't accepting ' correctly.
 * 
 * @param str 	 The string to check. (Required)
 * @return Returns a boolean. 
 * @author Jeff Guillaume (jeff@kazoomis.com) 
 * @version 2, August 15, 2002 
 */
function isEmail(str){
   //supports new top level tlds
if (REFindNoCase("^['_a-z0-9-]+(\.['_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.(([a-z]{2,3})|(aero|coop|info|museum|name))$",arguments.str)) 
	return TRUE;
else 
	return FALSE;
 }
			
/**
 * An &quot;enhanced&quot; version of ParagraphFormat.
 * Added replacement of tab with nonbreaking space char, idea by Mark R Andrachek.
 * Rewrite and multiOS support by Nathan Dintenfas.
 * 
 * @param string 	 The string to format. (Required)
 * @return Returns a string. 
 * @author Ben Forta (ben@forta.com) 
 * @version 3, June 26, 2002 
 */
function ParagraphFormat2(str) {
	//first make Windows style into Unix style
	str = replace(str,chr(13)&chr(10),chr(10),"ALL");
	//now make Macintosh style into Unix style
	str = replace(str,chr(13),chr(10),"ALL");
	//now fix tabs
	str = replace(str,chr(9),"&nbsp;&nbsp;&nbsp;","ALL");
	//now return the text formatted in HTML
	return replace(str,chr(10),"<br />","ALL");
}
</cfscript>


