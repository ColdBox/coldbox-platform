<cfcomponent name="ehSecurity" extends="coldbox.system.eventhandler" output="false" autowire="true">
	
	<cfproperty name="securityManager" type="ioc" scope="variables">
	
	<cffunction name="init" access="public" returntype="any" output="false">
		<cfargument name="controller" type="any">
		<cfset super.init(arguments.controller)>
		<cfreturn this>
	</cffunction>

	<cffunction name="dspLogin" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		
		<cfset Event.setView("login/vwLogin")>
		
	</cffunction>

	<cffunction name="doLogin" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		
		<!--- Process login --->
		<cfif securityManager.isUserVerified(email:Event.getValue('email',''),password:Event.getValue('password',''))>
			<!--- Which redirect? --->
			<cfswitch expression="#securityManager.getUserSession().getUserType().getName()#">
				<cfcase value="Administrator">
					<cfset setNextEvent('admin.ehUser.dspUsers')>
				</cfcase>
				<cfcase value="User">
					<cfset setNextEvent('user.ehProduct.dspProducts')>
				</cfcase>
			</cfswitch>
		<cfelse>		
			<cfset setNextEvent('ehSecurity.dspLogin')>
		</cfif>
		
	</cffunction>

	<cffunction name="doLogoff" access="public" returntype="void" output="false">
		<cfargument name="Event" type="any">
		<!--- Process logoff --->
		<cfset securityManager.deleteUserSession()>
		<cfset setNextEvent('ehGeneral.index')>
	</cffunction>
	
</cfcomponent>