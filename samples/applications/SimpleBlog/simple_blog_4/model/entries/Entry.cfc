<cfcomponent displayname="Entry" hint="Entry deceorator" extends="Transfer.com.TransferDecorator" output="false">
	
	<cfproperty name="DateUtil" type="ioc" scope="instance">
	
	<!--- getTime --->
	<cffunction name="getTime" access="public" returntype="any" output="false" hint="Decorator for Entry getTime function.">
		<cfargument name="format" required="yes" default="short">
		
		
		<cfscript>
			var result = "";
			var time = getTransferObject().getTime();
			result = instance.DateUtil.formatDateTime(time, format);
		</cfscript>
	     
		<cfreturn result>
	
    </cffunction>
</cfcomponent> 