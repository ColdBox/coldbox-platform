<!-----------------------------------------------------------------------
Author 	 :	Tony Garcia
Date     :
Description : 			
 Displays a CAPTCHA image for form validation using ColdFusion 8 cfimage tag. 
 The display() method displays the captcha image. If the user is returning to the form from a failed captcha validation (using 
validate method), an error message also appears under the image, which can be customized by the 'message' argument.
 The validate() method is used in the event that handles the form and takes as an argument the form field value from the 
 request collection in which the user entered the CAPTCHA code. It returns true if there is a match and false if not (and also
 sets a flag in the session scope to tell the plugin to display the error message if the user is redirected back to the form.)

This plugin is free to use and modify and is provided with NO WARRANTY of merchantability or fitness for a particular purpose. 

Updates
11/16/2008 - Luis Majano - Cleanup
----------------------------------------------------------------------->
<cfcomponent name="captcha" 
			 hint="plugin for CF8 built in captcha functionality" 
			 extends="coldbox.system.plugin" 
			 output="false"
			 cache="true">
  
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->	
   
    <cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" type="any" required="true" />
        
		<cfscript>
  		super.Init(arguments.controller);
  		setpluginName("captcha");
  		setpluginVersion("0.30");
  		setpluginDescription("CAPTCHA plugin for CF8 cfimage captcha functionality");
		
  		//Return instance
  		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<cffunction name="display" access="public" returntype="any" output="false" hint="I display the captcha and an error message, if appropriate">
		<cfargument name="length" type="numeric" default="4" />
		<cfargument name="text" type="string" default="#makeRandomString(arguments.length)#" />
		<cfargument name="width" type="string" default="200" hint="width of captcha image in pixels" />
		<cfargument name="height" type="string" default="50" hint="height of captcha image in pixels" />
		<cfargument name="fonts" type="string" default="verdana,arial,times new roman,courier" hint="fonts to use for characters in captcha image" />
		<cfargument name="message" type="string" default="Please enter the correct code shown in the graphic." hint="Message to display below captcha if validate method failed.">
		<cfset var ret = "" />
		
		<cfset setCaptchaCode(arguments.text) />
		<cfsavecontent variable="ret">
			<cfimage action="captcha" 
					 text="#arguments.text#"
					 width="#arguments.width#" 
					 height="#arguments.height#" />
			<cfif not isValidated()>
			<br /><span class="cb_captchamessage"><cfoutput>#arguments.message#</cfoutput></span>
			</cfif>
		</cfsavecontent>
		<!--- after it's decided whether to display the error message,
		clear the validation flag in case user just navigates to another page and comes back --->
		<cfset setValidated(true) />
		<cfreturn ret />
	</cffunction>
	
	<cffunction name="validate" access="public" returntype="boolean" output="false" hint="I validate the passed in string against the captcha code">
		<cfargument name="code" type="string" required="true" />
		
		<cfif hash(lcase(arguments.code),'SHA') eq getCaptchaCode()>
			<cfset clearCaptcha() /><!--- delete the captcha struct --->
			<cfreturn true />
		<cfelse>
			<cfset setValidated(false) />
			<cfreturn isValidated() />
		</cfif>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

	<cffunction name="getCaptchaStorage" access="private" returntype="any" output="false">
		<cfset var oSession = getPlugin("sessionstorage")>
		<cfset var captcha = {captchaCode = "", validated = true}>
		
		<cfif not oSession.exists("cb_captcha")>
			<cfset oSession.setVar("cb_captcha",captcha)>
		</cfif>
		
		<cfreturn oSession.getVar("cb_captcha")>
	</cffunction>
	
	<cffunction name="setCaptchaCode" access="public" returntype="void" output="false">
    	<cfargument name="captchastring" type="string" required="true" />
		<cfset getCaptchaStorage().captchaCode = hash(lcase(arguments.captchastring),'SHA') />
	</cffunction>
	
	<cffunction name="getCaptchaCode" access="public" returntype="string" output="false">
		<cfreturn getCaptchaStorage().captchaCode />
	</cffunction>
	
	<cffunction name="setValidated" access="private" returntype="void" output="false">
		<cfargument name="validated" type="boolean" required="true" />
		<cfset getCaptchaStorage().validated = arguments.validated />
	</cffunction>
	
	<cffunction name="isValidated" access="private" returntype="boolean" output="false">
		<cfreturn getCaptchaStorage().validated />
	</cffunction>
	
	<cffunction name="clearCaptcha" access="private" returntype="void" output="false">
		<cfset getPlugin("sessionstorage").deleteVar("cb_captcha")>
	</cffunction>

	<cffunction name="makeRandomString" access="private" returnType="string" output="false">
		<cfargument name="length" type="numeric" default="4" />
		<cfset var min = arguments.length - 1 />
		<cfset var max = arguments.length + 1 />
		<!--- Function ripped of from Raymond Camden 
		(http://www.coldfusionjedi.com/index.cfm/2008/3/29/Quick-and-Dirty-ColdFusion-8-CAPTCHA-Guide) 
		--->
	   <cfset var chars = "23456789ABCDEFGHJKMNPQRSabcdefghjkmnpqrs">
	   <cfset var captchalength = randRange(min,max)>
	   <cfset var result = "">
	   <cfset var i = "">
	   <cfset var char = "">
	   
	   <cfscript>
	   for(i=1; i <= captchalength; i++) {
	      char = mid(chars, randRange(1, len(chars)),1);
	      result&=char;
	   }
	   </cfscript>
	      
	   <cfreturn result>
	</cffunction>
	
</cfcomponent>