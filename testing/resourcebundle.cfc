<cfcomponent displayname="ResourceBundle" hint="reads and parses java resource bundle per locale: version 1.0.0 coldbox core java 8-jul-2006 paul@sustainableGIS.com" output="no">
<!---

author:         paul hastings <paul@sustainableGIS.com>
date:           08-december-2003

revisions:      15-mar-2005     fixed un-scoped var variable in formatRBString method.
                       4-mar-2006      added messageFormat method to
                       8-jul-2006 coldbox version

notes:          the purpose of this CFC is to extract text resources from a pure java resource bundle. these
                       resource bundles should be produced by a tools such as IBM's rbManager and consist of:
                               key=ANSI escaped string such as
                               (english, no need for ANSI escaped chars)
                               Cancel=Cancel
                               Go=Ok
                               (thai, ANSI escaped chars)
                               Cancel=\u0E22\u0E01\u0E40\u0E25\u0E34\u0E01
                               Go=\u0E44\u0E1B

methods in this CFC:
       - getResourceBundle returns a structure containing all key/messages value pairs in a given resource
       bundle file. required argument is rbFile containing absolute path to resource bundle file. optional
       argument is rbLocale to indicate which locale's resource bundle to use, defaults to us_EN (american
       english). PUBLIC
       - getRBKeys returns an array holding all keys in given resource bundle. required argument is rbFile
       containing absolute path to resource bundle file. optional argument is rbLocale to indicate which
       locale's resource bundle to use, defaults to us_EN (american english). PUBLIC
       - getRBString returns string containing the text for a given key in a given resource bundle. required
       arguments are rbFile containing absolute path to resource bundle file and rbKey a string holding the
       required key. optional argument is rbLocale to indicate which locale's resource bundle to use, defaults
       to us_EN (american english). PUBLIC
       - formatRBString returns string w/dynamic values substituted. performs messageFormat like
       operation on compound rb string: "You owe me {1}. Please pay by {2} or I will be forced to
       shoot you with {3} bullets." this function will replace the place holders {1}, etc. with
       values from the passed in array (or a single value, if that's all there are). required
       arguments are rbString, the string containing the placeholders, and substituteValues either
       an array or a single value containing the values to be substituted. note that the values
       are substituted sequentially, all {1} placeholders will be substituted using the first
       element in substituteValues, {2} with the  second, etc. DEPRECATED. only retained for
       backwards compatibility. please use messageFormat method instead.
       - messageFormat returns string w/dynamic values substituted. performs MessageFormat
       operation on compound rb string.  required arguments: pattern string to use as pattern for
       formatting, args array of "objects" to use as substitution values. optional argument is
       locale, java style locale       ID, "th_TH", default is "en_US". for details about format
       options please see http://java.sun.com/j2se/1.4.2/docs/api/java/text/MessageFormat.html
       - verifyPattern verifies MessageFormat pattern. required argument is pattern a string
       holding the MessageFormat pattern to test. returns a boolean indicating if the pattern is
       ok or not. PUBLIC

 --->

<!--- default init --->
<cfscript>
       variables.rB=createObject("java", "java.util.PropertyResourceBundle");
       variables.fis=createObject("java", "java.io.FileInputStream");
       variables.msgFormat=createObject("java", "java.text.MessageFormat");
       variables.locale=createObject("java","java.util.Locale");
       variables.ResourceBundleVersion="1.0.0 coldbox core java";
       variables.ResourceBundleDate="8-jul-2006"; //should be date of latest change
</cfscript>

<cffunction access="public" name="getResourceBundle" output="No" returntype="struct" hint="reads and parses java resource bundle per locale">
<cfargument name="rbFile" required="Yes" type="string">
<cfargument name="rbLocale" required="No" type="string" default="en_US">
<cfargument name="markDebug" required="No" type="boolean" default="false">
<cfscript>
       var isOk=false; // success flag
       var keys=""; // var to hold rb keys
       var resourceBundle=structNew(); // structure to hold resource bundle
       var thisKey="";
       var thisMSG="";
       var thisLang=listFirst(arguments.rbLocale,"_");
       var thisDir=GetDirectoryFromPath(arguments.rbFile);
       var thisFile=getFileFromPath(arguments.rbFile);
       var thisRBfile=thisDir & listFirst(thisFile,".") & "_"& arguments.rbLocale & "." & listLast(thisFile,".");
       if (NOT fileExists(thisRBfile)) //try just the language
               thisRBfile=thisDir & listFirst(thisFile,".") & "_"& thisLang & "." & listLast(thisFile,".");
       if (NOT fileExists(thisRBfile))// still nothing? strip thisRBfile back to base rb
               thisRBFile=arguments.rbFile;
       if (fileExists(thisRBFile)) { // final check, if this fails the file is not where it should be
               isOK=true;
               fis.init(thisRBFile);
               rB.init(fis);
               keys=rB.getKeys();
               while (keys.hasMoreElements()) {
                       thisKEY=keys.nextElement();
                       thisMSG=rB.handleGetObject(thisKey);
                       if (arguments.markDebug)
                               resourceBundle["#thisKEY#"]="****"&thisMSG;
                       else
                               resourceBundle["#thisKEY#"]=thisMSG;
                       }
               fis.close();
               }
       </cfscript>
       <cfif isOK>
               <cfreturn resourceBundle>
       <cfelse>
               <cfthrow message="Fatal error: resource bundle #thisRBfile# not found.">
       </cfif>
</cffunction>

<cffunction access="public" name="getRBKeys" output="No" returntype="array" hint="returns array of keys in java resource bundle per locale">
<cfargument name="rbFile" required="Yes" type="string">
<cfargument name="rbLocale" required="No" type="string" default="en_US">
<cfscript>
       var isOk=false; // success flag
       var keys=arrayNew(1); // var to hold rb keys
       var rbKeys="";
       var thisLang=listFirst(arguments.rbLocale,"_");
       var thisDir=GetDirectoryFromPath(arguments.rbFile);
       var thisFile=getFileFromPath(arguments.rbFile);
       var thisRBfile=thisDir & listFirst(thisFile,".") & "_"& arguments.rbLocale & "." & listLast(thisFile,".");
       if (NOT fileExists(thisRBfile)) //try just the language
               thisRBfile=thisDir & listFirst(thisFile,".") & "_"& thisLang & "." & listLast(thisFile,".");
       if (NOT fileExists(thisRBfile))// still nothing? strip thisRBfile back to base rb
               thisRBFile=arguments.rbFile;
       if (fileExists(thisRBFile)) { // final check
               isOK=true;
               fis.init(thisRBFile);
               rB.init(fis);
               rbKeys=rB.getKeys();
               while (rbKeys.hasMoreElements()) {
                       arrayAppend(keys,rbKeys.nextElement());
                       }
               fis.close();
               }
       </cfscript>
       <cfif isOK>
               <cfreturn keys>
       <cfelse>
               <cfthrow message="Fatal error: resource bundle #thisRBfile# not found.">
       </cfif>
</cffunction>

<cffunction access="public" name="getRBString" output="No" returntype="string" hint="returns text for given key in given java resource bundle per locale">
<cfargument name="rbFile" required="Yes" type="string">
<cfargument name="rbKey" required="Yes" type="string">
<cfargument name="rbLocale" required="No" type="string" default="en_US">
       <cfscript>
               var isOk=false; // success flag
               var rbString=""; // text message to return
               var resourceBundle=structNew(); // structure to hold resource bundle
               var thisLang=listFirst(arguments.rbLocale,"_");
               var thisDir=GetDirectoryFromPath(arguments.rbFile);
               var thisFile=getFileFromPath(arguments.rbFile);
               var thisRBfile=thisDir & listFirst(thisFile,".") & "_"& arguments.rbLocale & "." & listLast(thisFile,".");
               if (NOT fileExists(thisRBfile)) //try just the language
                       thisRBfile=thisDir & listFirst(thisFile,".") & "_"& thisLang & "." & listLast(thisFile,".");
               if (NOT fileExists(thisRBfile))// still nothing? strip thisRBfile back to base rb
                       thisRBFile=arguments.rbFile;
                       if (fileExists(thisRBFile)) { // final check
                               isOK=true;
                               fis.init(thisRBFile);
                               rB.init(fis);
                               rbString=rB.handleGetObject(arguments.rbKey);
                               fis.close();
               }
       </cfscript>
       <cfif NOT isOK>
               <cfthrow message="Fatal error: resource bundle #thisRBfile# not found.">
       <cfelse>
               <cfif len(trim(rbString))>
                       <cfreturn rbString>
               <cfelse>
                       <cfthrow message="Fatal error: resource bundle #thisRBfile# does not contain key #arguments.rbKEY#.">
               </cfif>
       </cfif>
</cffunction>

<cffunction name="loadResourceBundle" access="public" output="no" returnType="void" hint="Loads a bundle">
       <cfargument name="rbFile" required="yes" type="string">
       <cfargument name="rbLocale" required="no" type="string" default="en_US">
       <cfset variables.resourceBundle = getResourceBundle(arguments.rbFile,arguments.rbLocale)>
</cffunction>

<cffunction name="formatRBString" access="public" output="no" returnType="string" hint="performs messageFormat like operation on compound rb string">
       <cfargument name="rbString" required="yes" type="string">
       <cfargument name="substituteValues" required="yes"> <!--- array or single value to format --->
       <cfset var i=0>
       <cfset tmpStr=arguments.rbString>
       <cfif isArray(arguments.substituteValues)> <!--- do a bunch? --->
               <cfloop index="i" from="1" to="#arrayLen(arguments.substituteValues)#">
                       <cfset tmpStr=replace(tmpStr,"{#i#}",arguments.substituteValues[i],"ALL")>
               </cfloop>
       <cfelse> <!--- do single --->
               <cfset tmpStr=replace(tmpStr,"{1}",arguments.substituteValues,"ALL")>
       </cfif> <!--- do a bunch? --->
       <cfreturn tmpStr>
</cffunction>

<cffunction name="messageFormat" access="public" output="no" returnType="string" hint="performs messageFormat on compound rb string">
       <cfargument name="thisPattern" required="yes" type="string" hint="pattern to use in formatting">
       <cfargument name="args" required="yes" hint="substitution values"> <!--- array or single value to format --->
       <cfargument name="thisLocale" required="no" default="en_US" hint="locale to use in formatting, defaults to en_US">
               <cfset var pattern=createObject("java","java.util.regex.Pattern")>
               <cfset var regexStr="(\{[0-9]{1,},number.*?\})">
               <cfset var p="">
               <cfset var m="">
               <cfset var i=0>
               <cfset var thisFormat="">
               <cfset var inputArgs=arguments.args>
               <cfset var lang="">
               <cfset var country="">
               <cfset var variant="">
               <cfset var tLocale="">
               <cftry>
                       <cfset lang=listFirst(arguments.thisLocale,"_")>
                       <cfset country=listGetAt(arguments.thisLocale,2,"_")>
                       <cfset variant=listLast(arguments.thisLocale,"_")>
                       <cfset tLocale=variables.locale.init(lang,country,variant)>
                       <cfif NOT isArray(inputArgs)>
                               <cfset inputArgs=listToArray(inputArgs)>
                       </cfif>
                       <cfset thisFormat=msgFormat.init(arguments.thisPattern,tLocale)>
                       <!--- let's make sure any cf numerics are cast to java datatypes --->
                       <cfset p=pattern.compile(regexStr,pattern.CASE_INSENSITIVE)>
                       <cfset m=p.matcher(arguments.thisPattern)>
                       <cfloop condition="#m.find()#">
                               <cfset i=listFirst(replace(m.group(),"{",""))>
                               <cfset inputArgs[i]=javacast("float",inputArgs[i])>
                       </cfloop>
                       <cfset arrayPrepend(inputArgs,"")> <!--- dummy element to fool java --->
                       <!--- coerece to a java array of objects  --->
                       <cfreturn thisFormat.format(inputArgs.toArray())>
                       <cfcatch type="Any">
                               <cfthrow message="#cfcatch.message#" type="any" detail="#cfcatch.detail#">
                       </cfcatch>
               </cftry>
</cffunction>

<cffunction name="verifyPattern" access="public" output="no" returnType="boolean" hint="performs verification on MessageFormat pattern">
       <cfargument name="pattern" required="yes" type="string" hint="format pattern to test">
       <cfscript>
               var test="";
               var isOK=true;
               try {
                       test=msgFormat.init(arguments.pattern);
               }
               catch (Any e) {
                       isOK=false;
               }
               return isOk;
       </cfscript>
</cffunction>

<cffunction access="public" name="getVersion" output="false" returntype="struct" hint=" returns version of this CFC and java lib it uses.">
       <cfset var version=StructNew()>
       <cfset var sys=createObject("java","java.lang.System")>
       <cfset version.ResourceBundleVersion=ResourceBundleVersion>
       <cfset version.ResourceBundleDate=ResourceBundleDate>
       <cfset version.javaRuntimeVersion=sys.getProperty("java.runtime.version")>
       <cfset version.javaVersion=sys.getProperty("java.version")>
       <cfreturn version>
</cffunction>

</cfcomponent>