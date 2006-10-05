<cfcomponent output="false" displayname="generatorBean" hint="I model the generation of an application.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	
	<!--- Constructor --->
	<cfset variables.instance = structnew()>
	
	<!--- ************************************************************* --->
	
	<cffunction name="init" access="public" returntype="generatorBean" output="false">
		<cfscript>
		//Init Bean
		instance.appname = "";
		instance.appmapping = "";
		instance.debugmode = "";
		instance.debugpassword = "";
		instance.enabledumpvar = "";
		instance.udflibraryfile = "";
		instance.messageboxstyleclass = "";
		instance.defaultlayout = "";
		instance.customerrortemplate = "";
		instance.coldboxlogging = "";
		instance.coldboxlogslocation = "";
		instance.coldfusionlogging = "";
		instance.i18nflag = "";
		instance.defaultlocale = "";
		instance.defaultlocalestorage = "";
		instance.defaultresourcebundle = "";
		instance.appdevmapping = "";
		instance.configautoreload = "";
		instance.handlersindexautoreload = "";
		instance.enablebugreports = "";
		instance.bugemails = ArrayNew(1);
		instance.devurls = ArrayNew(1);
		instance.webservices = ArrayNew(1);
		instance.maineventhandler = "";
		instance.defaultevent = "";
		instance.onapplicationstart = "";
		instance.onrequeststart = "";
		instance.onrequestend = "";
		instance.onexception = "";
		instance.authorname = "";
		instance.skeleton_name = "";
		instance.generation_target = "";		
		return this;
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
		
<!------------------------------------------- PUBLIC ------------------------------------------->
	
	<!--- ************************************************************* --->
	
	<cffunction name="getInstance" access="public" returntype="struct" output="false">	
		<cfreturn instance>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="setInstance" access="public" returntype="void" output="false">	
		<cfargument name="instance" type="struct" required="true">
		<cfset instance = arguments.instance>
	</cffunction>
		
	<!--- ************************************************************* --->
	
	<cffunction name="getappname" access="public" output="false" returntype="string" hint="Get appname">
		<cfreturn instance.appname/>
	</cffunction>
	
	<cffunction name="setappname" access="public" output="false" returntype="void" hint="Set appname">
		<cfargument name="appname" type="string" required="true"/>
		<cfset instance.appname = arguments.appname />
	</cffunction>
	
	<cffunction name="getdebugmode" access="public" output="false" returntype="boolean" hint="Get debugmode">
		<cfreturn instance.debugmode/>
	</cffunction>
	
	<cffunction name="setdebugmode" access="public" output="false" returntype="void" hint="Set debugmode">
		<cfargument name="debugmode" type="boolean" required="true"/>
		<cfset instance.debugmode = arguments.debugmode/>
	</cffunction>
	
	<cffunction name="getdebugpassword" access="public" output="false" returntype="string" hint="Get debugpassword">
		<cfreturn instance.debugpassword/>
	</cffunction>
	
	<cffunction name="setdebugpassword" access="public" output="false" returntype="void" hint="Set debugpassword">
		<cfargument name="debugpassword" type="string" required="true"/>
		<cfset instance.debugpassword = arguments.debugpassword/>
	</cffunction>
	
	<cffunction name="getenabledumpvar" access="public" output="false" returntype="boolean" hint="Get enabledumpvar">
		<cfreturn instance.enabledumpvar/>
	</cffunction>
	
	<cffunction name="setenabledumpvar" access="public" output="false" returntype="voidlean" hint="Set enabledumpvar">
		<cfargument name="enabledumpvar" type="boolean" required="true"/>
		<cfset instance.enabledumpvar = arguments.enabledumpvar/>
	</cffunction>
	
	<cffunction name="getudflibraryfile" access="public" output="false" returntype="string" hint="Get udflibraryfile">
		<cfreturn instance.udflibraryfile/>
	</cffunction>
	
	<cffunction name="setudflibraryfile" access="public" output="false" returntype="void" hint="Set udflibraryfile">
		<cfargument name="udflibraryfile" type="string" required="true"/>
		<cfset instance.udflibraryfile = arguments.udflibraryfile/>
	</cffunction>
	
	<cffunction name="getmessageboxstyleclass" access="public" output="false" returntype="string" hint="Get messageboxstyleclass">
		<cfreturn instance.messageboxstyleclass/>
	</cffunction>
	
	<cffunction name="setmessageboxstyleclass" access="public" output="false" returntype="void" hint="Set messageboxstyleclass">
		<cfargument name="messageboxstyleclass" type="string" required="true"/>
		<cfset instance.messageboxstyleclass = arguments.messageboxstyleclass/>
	</cffunction>
	
	<cffunction name="getdefaultlayout" access="public" output="false" returntype="string" hint="Get defaultlayout">
		<cfreturn instance.defaultlayout/>
	</cffunction>
	
	<cffunction name="setdefaultlayout" access="public" output="false" returntype="void" hint="Set defaultlayout">
		<cfargument name="defaultlayout" type="string" required="true"/>
		<cfset instance.defaultlayout = arguments.defaultlayout/>
	</cffunction>
	
	<cffunction name="getcustomerrortemplate" access="public" output="false" returntype="string" hint="Get customerrortemplate">
		<cfreturn instance.customerrortemplate/>
	</cffunction>
	
	<cffunction name="setcustomerrortemplate" access="public" output="false" returntype="void" hint="Set customerrortemplate">
		<cfargument name="customerrortemplate" type="string" required="true"/>
		<cfset instance.customerrortemplate = arguments.customerrortemplate/>
	</cffunction>
	
	<cffunction name="getcoldboxlogging" access="public" output="false" returntype="boolean" hint="Get coldboxlogging">
		<cfreturn instance.coldboxlogging/>
	</cffunction>
	
	<cffunction name="setcoldboxlogging" access="public" output="false" returntype="void" hint="Set coldboxlogging">
		<cfargument name="coldboxlogging" type="boolean" required="true"/>
		<cfset instance.coldboxlogging = arguments.coldboxlogging/>
	</cffunction>
	
	<cffunction name="getcoldboxlogslocation" access="public" output="false" returntype="string" hint="Get coldboxlogslocation">
		<cfreturn instance.coldboxlogslocation/>
	</cffunction>
	
	<cffunction name="setcoldboxlogslocation" access="public" output="false" returntype="void" hint="Set coldboxlogslocation">
		<cfargument name="coldboxlogslocation" type="string" required="true"/>
		<cfset instance.coldboxlogslocation = arguments.coldboxlogslocation/>
	</cffunction>
	
	<cffunction name="getcoldfusionlogging" access="public" output="false" returntype="boolean" hint="Get coldfusionlogging">
		<cfreturn instance.coldfusionlogging/>
	</cffunction>
	
	<cffunction name="setcoldfusionlogging" access="public" output="false" returntype="void" hint="Set coldfusionlogging">
		<cfargument name="coldfusionlogging" type="boolean" required="true"/>
		<cfset instance.coldfusionlogging = arguments.coldfusionlogging/>
	</cffunction>
	
	<cffunction name="geti18nflag" access="public" output="false" returntype="boolean" hint="Get i18nflag">
		<cfreturn instance.i18nflag/>
	</cffunction>
	
	<cffunction name="seti18nflag" access="public" output="false" returntype="void" hint="Set i18nflag">
		<cfargument name="i18nflag" type="boolean" required="true"/>
		<cfset instance.i18nflag = arguments.i18nflag/>
	</cffunction>
	
	<cffunction name="getdefaultlocale" access="public" output="false" returntype="string" hint="Get defaultlocale">
		<cfreturn instance.defaultlocale/>
	</cffunction>
	
	<cffunction name="setdefaultlocale" access="public" output="false" returntype="void" hint="Set defaultlocale">
		<cfargument name="defaultlocale" type="string" required="true"/>
		<cfset instance.defaultlocale = arguments.defaultlocale/>
	</cffunction>
	
	<cffunction name="getdefaultlocalestorage" access="public" output="false" returntype="string" hint="Get defaultlocalestorage">
		<cfreturn instance.defaultlocalestorage/>
	</cffunction>
	
	<cffunction name="setdefaultlocalestorage" access="public" output="false" returntype="void" hint="Set defaultlocalestorage">
		<cfargument name="defaultlocalestorage" type="string" required="true"/>
		<cfset instance.defaultlocalestorage = arguments.defaultlocalestorage/>
	</cffunction>
	
	<cffunction name="getdefaultresourcebundle" access="public" output="false" returntype="string" hint="Get defaultresourcebundle">
		<cfreturn instance.defaultresourcebundle/>
	</cffunction>
	
	<cffunction name="setdefaultresourcebundle" access="public" output="false" returntype="void" hint="Set defaultresourcebundle">
		<cfargument name="defaultresourcebundle" type="string" required="true"/>
		<cfset instance.defaultresourcebundle = arguments.defaultresourcebundle/>
	</cffunction>
	
	<cffunction name="getappdevmapping" access="public" output="false" returntype="string" hint="Get appdevmapping">
		<cfreturn instance.appdevmapping/>
	</cffunction>
	
	<cffunction name="setappdevmapping" access="public" output="false" returntype="void" hint="Set appdevmapping">
		<cfargument name="appdevmapping" type="string" required="true"/>
		<cfset instance.appdevmapping = arguments.appdevmapping/>
	</cffunction>
	
	<cffunction name="getconfigautoreload" access="public" output="false" returntype="boolean" hint="Get configautoreload">
		<cfreturn instance.configautoreload/>
	</cffunction>
	
	<cffunction name="setconfigautoreload" access="public" output="false" returntype="void" hint="Set configautoreload">
		<cfargument name="configautoreload" type="boolean" required="true"/>
		<cfset instance.configautoreload = arguments.configautoreload/>
	</cffunction>
	
	<cffunction name="gethandlersindexautoreload" access="public" output="false" returntype="boolean" hint="Get handlersindexautoreload">
		<cfreturn instance.handlersindexautoreload/>
	</cffunction>
	
	<cffunction name="sethandlersindexautoreload" access="public" output="false" returntype="void" hint="Set handlersindexautoreload">
		<cfargument name="handlersindexautoreload" type="boolean" required="true"/>
		<cfset instance.handlersindexautoreload = arguments.handlersindexautoreload/>
	</cffunction>
	
	<cffunction name="getenablebugreports" access="public" output="false" returntype="boolean" hint="Get enablebugreports">
		<cfreturn instance.enablebugreports/>
	</cffunction>
	
	<cffunction name="setenablebugreports" access="public" output="false" returntype="void" hint="Set enablebugreports">
		<cfargument name="enablebugreports" type="boolean" required="true"/>
		<cfset instance.enablebugreports = arguments.getenablebugreports/>
	</cffunction>
	
	<cffunction name="getmaineventhandler" access="public" output="false" returntype="string" hint="Get maineventhandler">
		<cfreturn instance.maineventhandler/>
	</cffunction>
	
	<cffunction name="setmaineventhandler" access="public" output="false" returntype="void" hint="Set maineventhandler">
		<cfargument name="maineventhandler" type="string" required="true"/>
		<cfset instance.maineventhandler = arguments.maineventhandler/>
	</cffunction>
	
	<cffunction name="getdefaultevent" access="public" output="false" returntype="string" hint="Get defaultevent">
		<cfreturn instance.defaultevent/>
	</cffunction>
	
	<cffunction name="setdefaultevent" access="public" output="false" returntype="void" hint="Set defaultevent">
		<cfargument name="defaultevent" type="string" required="true"/>
		<cfset instance.defaultevent = arguments.defaultevent/>
	</cffunction>
	
	<cffunction name="getonapplicationstart" access="public" output="false" returntype="boolean" hint="Get onapplicationstart">
		<cfreturn instance.onapplicationstart/>
	</cffunction>
	
	<cffunction name="setonapplicationstart" access="public" output="false" returntype="void" hint="Set onapplicationstart">
		<cfargument name="onapplicationstart" type="boolean" required="true"/>
		<cfset instance.onapplicationstart =  arguments.onapplicationstart/>
	</cffunction>
	
	<cffunction name="getonrequeststart" access="public" output="false" returntype="boolean" hint="Get onrequeststart">
		<cfreturn instance.onrequeststart/>
	</cffunction>
	
	<cffunction name="setonrequeststart" access="public" output="false" returntype="void" hint="Set onrequeststart">
		<cfargument name="onrequeststart" type="boolean" required="true"/>
		<cfset instance.onrequeststart = arguments.onrequeststart/>
	</cffunction>
	
	<cffunction name="getonrequestend" access="public" output="false" returntype="boolean" hint="Get onrequestend">
		<cfreturn instance.onrequestend/>
	</cffunction>
	
	<cffunction name="setonrequestend" access="public" output="false" returntype="void" hint="Set onrequestend">
		<cfargument name="onrequestend" type="boolean" required="true"/>
		<cfset instance.onrequestend = arguments.onrequestend/>
	</cffunction>
	
	<cffunction name="getonexception" access="public" output="false" returntype="boolean" hint="Get onexception">
		<cfreturn instance.onexception/>
	</cffunction>
	
	<cffunction name="setonexception" access="public" output="false" returntype="void" hint="Set onexception">
		<cfargument name="onexception" type="boolean" required="true"/>
		<cfset instance.onexception = arguments.onexception/>
	</cffunction>
	
	<cffunction name="getauthorname" access="public" output="false" returntype="string" hint="Get authorname">
		<cfreturn instance.authorname/>
	</cffunction>
	
	<cffunction name="setauthorname" access="public" output="false" returntype="void" hint="Set authorname">
		<cfargument name="authorname" type="string" required="true"/>
		<cfset instance.authorname = arguments.authorname/>
	</cffunction>
	
	<cffunction name="getskeleton_name" access="public" output="false" returntype="string" hint="Get skeleton_name">
		<cfreturn instance.skeleton_name/>
	</cffunction>
	
	<cffunction name="setskeleton_name" access="public" output="false" returntype="void" hint="Set skeleton_name">
		<cfargument name="skeleton_name" type="string" required="true"/>
		<cfset instance.skeleton_name = arguments.skeleton_name/>
	</cffunction>
	
	<cffunction name="getgeneration_target" access="public" output="false" returntype="string" hint="Get generation_target">
		<cfreturn instance.generation_target/>
	</cffunction>
	
	<cffunction name="setgeneration_target" access="public" output="false" returntype="void" hint="Set generation_target">
		<cfargument name="generation_target" type="string" required="true"/>
		<cfset instance.generation_target = arguments.generation_target/>
	</cffunction>
	
<!------------------------------------------- ARRAY TYPES ------------------------------------------->	
	
	<cffunction name="getbugemails" access="public" output="false" returntype="array" hint="Get bugemails">
		<cfreturn instance.bugemails/>
	</cffunction>
	
	<cffunction name="setbugemails" access="public" output="false" returntype="void" hint="Set bugemails">
		<cfargument name="bugemails" type="array" required="true"/>
		<cfset instance.bugemails = arguments.bugemails/>
	</cffunction>
	
	<cffunction name="getdevurls" access="public" output="false" returntype="array" hint="Get devurls">
		<cfreturn instance.devurls/>
	</cffunction>
	
	<cffunction name="setdevurls" access="public" output="false" returntype="void" hint="Set devurls">
		<cfargument name="devurls" type="array" required="true"/>
		<cfset instance.devurls = arguments.devurls/>
	</cffunction>
	
	<cffunction name="getwebservices" access="public" output="false" returntype="array" hint="Get webservices">
		<cfreturn instance.webservices/>
	</cffunction>
	
	<cffunction name="setwebservices" access="public" output="false" returntype="void" hint="Set webservices">
		<cfargument name="webservices" type="array" required="true"/>
		<cfset instance.webservices = arguments.webservices/>
	</cffunction>

<!------------------------------------------- ARRAY ADDS ------------------------------------------->	

	<cffunction name="addbugemail" access="public" output="false" returntype="void" hint="Add bugemails">
		<cfargument name="bugemail" type="string" required="true"/>
		<cfset ArrayAppend(instance.bugemails,arguments.bugemail) />
	</cffunction>
	
	<cffunction name="adddevurl" access="public" output="false" returntype="void" hint="Add devurl">
		<cfargument name="devurl" type="string" required="true"/>
		<cfset ArrayAppend(instance.devurls,arguments.devurl) />
	</cffunction>
	
	<cffunction name="addwebservice" access="public" output="false" returntype="void" hint="Add webservice">
		<cfargument name="wsname"  type="string"  required="true"/>
		<cfargument name="wsdlpro" type="string"  required="true"/>
		<cfargument name="wsdldev" type="string"  required="false" default=""/>
		<cfset var wsStruct = structnew()>
		<cfset wsStruct.name = arguments.wsname>
		<cfset wsStruct.wsdlpro = arguments.wsdlpro>
		<cfset wsStruct.wsdldev = arguments.wsdldev>
		<cfset ArrayAppend(instance.webservices,wsStruct) />
	</cffunction>

	
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	

</cfcomponent>