<!-----------------------------------------------------------------------
********************************************************************************
Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldboxframework.com | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author      :	Luis Majano
Date        :	01/10/2008
License		: 	Apache 2 License
Description :
	A captcha plugin
----------------------------------------------------------------------->
<cfcomponent name="captcha" 
			 hint="A captcah plugin" 
			 extends="coldbox.system.plugin" 
			 output="false">
	
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->	
   
    <cffunction name="init" access="public" returntype="paging" output="false">
		<cfargument name="controller" type="any" required="true">
		<cfscript>
  		super.Init(arguments.controller);
  		setpluginName("captcha");
  		setpluginVersion("1.0");
  		setpluginDescription("Captcha plugin");
  		
  		/* Local properties */
  		instance.salt = createUUID();
  		
  		/* Difficulty*/
  		if( settingExists('captcha.Difficulty') ){
  			instance.difficulty = getSetting('captcha.Difficulty');
  		}
  		else{
  			//high,low,medium
  			instance.difficulty = "medium"; 
  		}
  		/* Fonts */
  		if( settingExists('captcha.Fonts') ){
  			instance.fonts = getSetting('captcha.Fonts');
  		}
  		else{
  			instance.fonts = "Arial,Verdana,Georgia";
  		}
  		/* Font Size */
  		if( settingExists('captcha.FontSize') ){
  			instance.fontSize = getSetting('captcha.FontSize');
  		}
  		else{
  			instance.fontSize = 30;
  		}
  		/* Length */
  		if( settingExists('captcha.Length') ){
  			instance.length = getSetting('captcha.Length');
  		}
  		else{
  			instance.length = 5;
  		}
  		
  		//Return instance
  		return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->	
	
	<!--- Get Set Length --->
	<cffunction name="getLength" access="public" output="false" returntype="numeric" hint="Get Length">
		<cfreturn instance.Length/>
	</cffunction>
	<cffunction name="setLength" access="public" output="false" returntype="void" hint="Set Length">
		<cfargument name="Length" type="numeric" required="true"/>
		<cfset instance.Length = arguments.Length/>
	</cffunction>
	
	<!--- Get/Set Font Size --->
	<cffunction name="getFontSize" access="public" output="false" returntype="numeric" hint="Get FontSize">
		<cfreturn instance.FontSize/>
	</cffunction>
	<cffunction name="setFontSize" access="public" output="false" returntype="void" hint="Set FontSize">
		<cfargument name="FontSize" type="numeric" required="true"/>
		<cfset instance.FontSize = arguments.FontSize/>
	</cffunction>
	
	<!--- Get/Set Fonts --->	
	<cffunction name="getFonts" access="public" output="false" returntype="string" hint="Get Fonts">
		<cfreturn instance.Fonts/>
	</cffunction>
	<cffunction name="setFonts" access="public" output="false" returntype="void" hint="Set Fonts">
		<cfargument name="Fonts" type="string" required="true"/>
		<cfset instance.Fonts = arguments.Fonts/>
	</cffunction>
	
	<!--- Get/set Difficulty --->
	<cffunction name="getDifficulty" access="public" output="false" returntype="string" hint="Get Difficulty">
		<cfreturn instance.Difficulty/>
	</cffunction>
	<cffunction name="setDifficulty" access="public" output="false" returntype="void" hint="Set Difficulty">
		<cfargument name="Difficulty" type="string" required="true"/>
		<cfset instance.Difficulty = arguments.Difficulty/>
	</cffunction>

</cfcomponent>