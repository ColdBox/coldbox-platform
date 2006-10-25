<cfcomponent output="false" displayname="appGeneratorService" hint="I am the Dashboard Application Generator Service.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->
	<!--- Constructor --->
	<cfset variables.instance = structnew()>
	
	<cffunction name="init" access="public" returntype="appGeneratorService" output="false">
		<cfset variables.instance.skeletonsPath = ExpandPath("config/generator_skeletons")>
		<cfreturn this>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<cffunction name="generate" access="public" output="false" returntype="struct">
		<!--- ************************************************************* --->
		<cfargument name="argc" required="true" type="struct" hint="The request Collection">
		<!--- ************************************************************* --->
		<cfset var rtnStruct = structnew()>
		<cfset var genBean = "">
		<cfset var x = 0>
		<cfset rtnStruct.error = true>
		<cfset rtnStruct.errorMessage = "">
		<cfset rtnStruct.results = "">
		
		<cftry>
			
			<cfscript>
			//Get generator bean
			genBean = CreateObject("component","beans.generatorBean").init();
			genBean.setappanme(arguments.argc.appname);
			genBean.setappmapping(arguments.argc.appmapping);
			genBean.setdebugmode(arguments.argc.debugmode);
			genBean.setdebugpassword(arguments.argc.debugpassword);
			genBean.setenabledumpvar(arguments.argc.enabledumpvar);
			genBean.setudflibraryfile(arguments.argc.udflibraryfile);
			genBean.setmessageboxstyleclass(arguments.argc.messageboxstyleclass);
			genBean.setdefaultlayout(arguments.argc.defaultlayout);
			genBean.setcustomerrortemplate(arguments.argc.customerrortemplate);
			genBean.setcoldboxlogging(arguments.argc.coldboxlogging);
			genBean.setcoldboxlogslocation(arguments.argc.coldboxlogslocation);
			genBean.setcoldfusionlogging(arguments.argc.coldfusionlogging);
			genBean.seti18nflag(arguments.argc.i18nflag);
			genBean.setdefaultlocale(arguments.argc.defaultlocale);
			genBean.setdefaultlocalestorage(arguments.argc.defaultlocalestorage);
			genBean.setdefaultresourcebundle(arguments.argc.defaultresourcebundle);
			genBean.setappdevmapping(arguments.argc.appdevmapping);
			genBean.setconfigautoreload(arguments.argc.configautoreload);
			genBean.sethandlersindexautoreload(arguments.argc.handlersindexautoreload);
			genBean.setenablebugreports(arguments.argc.enablebugreports);
			//Bug Emails
			for (x=1; x lte listlen(arguments.argc.bugemails); x=x+1){
				genBean.addbugemail( listgetAt(arguments.argc.bugemails, x) );
			
			}
			//Dev URLS
			for (x=1; x lte listlen(arguments.argc.devurls); x=x+1){
				genBean.adddevurl( listgetAt(arguments.argc.devurls, x) );
			
			}
			//WebServices
			for (x=1; x lte listlen(arguments.argc.bugemails); x=x+1){
				genBean.addwebservice( listgetAt(arguments.argc.bugemails, x) );
			
			}
			
			//Handlers
			genBean.setmaineventhandler(arguments.argc.maineventhandler);
			genBean.setdefaultevent(arguments.argc.defaultevent);
			genBean.setonapplicationstart(arguments.argc.onapplicationstart_cb);
			genBean.setonrequeststart(arguments.argc.onrequeststart_cb);
			genBean.setonrequestend(arguments.argc.onrequestend_cb);
			genBean.setonexception(arguments.argc.onexception_cb);
			//Generator settings
			genBean.setauthorname(arguments.argc.authorname);
			genBean.skeleton_name(arguments.argc.skeleton_name);
			genBean.setgeneration_target(arguments.argc.generation_target);
			
			rtnStruct.error = false;			
			</cfscript>
			
			<!--- Catch --->
			<cfcatch type="any">
				<cfset rtnStruct.errorMessage = "Error during generation: #cfcatch.Detail# #cfcatch.Message#">
			</cfcatch>
		</cftry>
		<cfreturn rtnStruct>
	</cffunction>
	

</cfcomponent>