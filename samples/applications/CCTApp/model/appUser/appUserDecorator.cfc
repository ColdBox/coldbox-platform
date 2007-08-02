<cfcomponent displayname="appUserDecorator" hint="This is the accountDecorator component" output="false" 
			 extends="coldbox.samples.applications.CCTApp.model.baseDecorator">

	<cffunction name="setPassword" access="public" returntype="void" output="false" hint="Replaces default setPassword method to MD5 Hash the Password">
		<cfargument name="password" type="string" required="true" />
		<cfset getTransferObject().setPassword(hash(password)) />
	</cffunction>
	
</cfcomponent>